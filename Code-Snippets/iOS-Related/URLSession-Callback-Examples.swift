//
//  URLSession-Callback-Examples.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 19/07/25.
//

import SwiftUI
import Foundation

// MARK: - Models
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let username: String
}

struct UploadResponse: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

// MARK: - Custom Errors
enum NetworkCallbackError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    case uploadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Network Service Protocol (Following SOLID Principles)
/// Protocol defining the contract for callback-based networking operations
/// This follows the Interface Segregation Principle by defining specific methods
protocol CallbackNetworkServiceProtocol {
    // Data Tasks
    func fetchUsers(completion: @escaping (Result<[User], NetworkCallbackError>) -> Void)
    func createPost(title: String, body: String, userId: Int, completion: @escaping (Result<UploadResponse, NetworkCallbackError>) -> Void)
    
    // Download Tasks
    func downloadFile(from urlString: String, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, NetworkCallbackError>) -> Void)
    
    // Upload Tasks
    func uploadData(_ data: Data, to urlString: String, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void)
    func uploadFile(at fileURL: URL, to urlString: String, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void)
    
    // WebSocket Tasks
    func connectWebSocket(to urlString: String, messageHandler: @escaping (Result<URLSessionWebSocketTask.Message, NetworkCallbackError>) -> Void, completion: @escaping (Result<URLSessionWebSocketTask, NetworkCallbackError>) -> Void)
    func sendWebSocketMessage(_ message: URLSessionWebSocketTask.Message, task: URLSessionWebSocketTask, completion: @escaping (Result<Void, NetworkCallbackError>) -> Void)
    
    // Stream Tasks
    func createStreamConnection(to host: String, port: Int, completion: @escaping (Result<URLSessionStreamTask, NetworkCallbackError>) -> Void)
    func sendStreamData(_ data: Data, task: URLSessionStreamTask, completion: @escaping (Result<Void, NetworkCallbackError>) -> Void)
    func readStreamData(from task: URLSessionStreamTask, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void)
}

// MARK: - URLSession Callback-Based Network Service Implementation
/// Concrete implementation of CallbackNetworkServiceProtocol
/// This follows the Single Responsibility Principle - handles only network operations
/// This follows the Dependency Inversion Principle - depends on URLSession abstraction
class CallbackNetworkService: CallbackNetworkServiceProtocol {
    
    // MARK: - Dependencies
    private let urlSession: URLSessionProtocol
    
    // MARK: - Initialization
    /// Dependency injection for URLSession (following Dependency Inversion Principle)
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Data Task Example
    /// Performs a GET request using dataTask with completion handler
    func fetchUsers(completion: @escaping (Result<[User], NetworkCallbackError>) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create a data task with completion handler
        let task = urlSession.dataTask(with: url) { data, response, error in
            // Handle network error
            if error != nil {
                completion(.failure(.serverError(statusCode: 0)))
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Validate data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Decode JSON
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        // Start the task
        task.resume()
    }
    
    // MARK: - Data Task with Custom Request
    /// Performs a POST request using dataTask with custom URLRequest
    func createPost(title: String, body: String, userId: Int, completion: @escaping (Result<UploadResponse, NetworkCallbackError>) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create custom request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body
        let postData = [
            "title": title,
            "body": body,
            "userId": userId
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postData)
        } catch {
            completion(.failure(.uploadFailed(error)))
            return
        }
        
        // Create data task with custom request
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(.serverError(statusCode: statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
                completion(.success(uploadResponse))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
    
    // MARK: - Download Task Example
    /// Downloads a file using downloadTask with progress tracking
    func downloadFile(from urlString: String,
                     progressHandler: @escaping (Double) -> Void,
                     completion: @escaping (Result<URL, NetworkCallbackError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create download task
        let task = urlSession.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(.serverError(statusCode: statusCode)))
                return
            }
            
            guard let localURL = localURL else {
                completion(.failure(.noData))
                return
            }
            
            // Move file to documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
            
            do {
                // Remove existing file if it exists
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                // Move downloaded file to destination
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                completion(.success(destinationURL))
            } catch {
                completion(.failure(.uploadFailed(error)))
            }
        }
        task.resume()
    }
    
    // MARK: - Upload Task Example
    /// Uploads data using uploadTask
    func uploadData(_ data: Data, to urlString: String, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Create upload task
        let task = urlSession.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(.serverError(statusCode: statusCode)))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(responseData))
        }
        
        task.resume()
    }
    
    // MARK: - Upload Task with File
    /// Uploads a file using uploadTask
    func uploadFile(at fileURL: URL, to urlString: String, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Create upload task with file URL
        
        //let task = urlSession.uploadTask(with: request, from: data) { data, response, error in    => (for data: Data)
        let task = urlSession.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(.serverError(statusCode: statusCode)))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(responseData))
        }
        task.resume()
    }
    
    // MARK: - WebSocket Task Example
    /// Creates a WebSocket connection for real-time bidirectional communication
    func connectWebSocket(to urlString: String, messageHandler: @escaping (Result<URLSessionWebSocketTask.Message, NetworkCallbackError>) -> Void, completion: @escaping (Result<URLSessionWebSocketTask, NetworkCallbackError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create WebSocket task
        let webSocketTask = urlSession.webSocketTask(with: url)
        
        // Start receiving messages
        receiveWebSocketMessage(task: webSocketTask, messageHandler: messageHandler)
        
        // Resume the task to establish connection
        webSocketTask.resume()
        
        completion(.success(webSocketTask))
    }
    
    /// Recursively receives WebSocket messages
    private func receiveWebSocketMessage(task: URLSessionWebSocketTask, messageHandler: @escaping (Result<URLSessionWebSocketTask.Message, NetworkCallbackError>) -> Void) {
        task.receive { result in
            switch result {
            case .success(let message):
                messageHandler(.success(message))
                // Continue receiving messages
                self.receiveWebSocketMessage(task: task, messageHandler: messageHandler)
            case .failure(let error):
                messageHandler(.failure(.uploadFailed(error)))
            }
        }
    }
    
    /// Sends a message through WebSocket
    func sendWebSocketMessage(_ message: URLSessionWebSocketTask.Message, task: URLSessionWebSocketTask, completion: @escaping (Result<Void, NetworkCallbackError>) -> Void) {
        task.send(message) { error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Stream Task Example
    /// Creates a TCP stream connection for custom protocols
    func createStreamConnection(to host: String, port: Int, completion: @escaping (Result<URLSessionStreamTask, NetworkCallbackError>) -> Void) {
        // Create stream task
        let streamTask = urlSession.streamTask(withHostName: host, port: port)
        
        // Resume the task to establish connection
        streamTask.resume()
        
        completion(.success(streamTask))
    }
    
    /// Sends data through stream connection
    func sendStreamData(_ data: Data, task: URLSessionStreamTask, completion: @escaping (Result<Void, NetworkCallbackError>) -> Void) {
        task.write(data, timeout: 30.0) { error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Reads data from stream connection
    func readStreamData(from task: URLSessionStreamTask, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void) {
        task.readData(ofMinLength: 1, maxLength: 65536, timeout: 30.0) { data, atEOF, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(data))
        }
    }
}

// MARK: - URLSession Protocol for Dependency Injection
/// Protocol wrapper for URLSession to enable dependency injection and testing
protocol URLSessionProtocol {
    // Data Tasks
    func dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    
    // Download Tasks
    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
    func downloadTask(with request: URLRequest, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
    
    // Upload Tasks
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask
    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask
    
    // WebSocket Tasks
    func webSocketTask(with url: URL) -> URLSessionWebSocketTask
    func webSocketTask(with url: URL, protocols: [String]) -> URLSessionWebSocketTask
    func webSocketTask(with request: URLRequest) -> URLSessionWebSocketTask
    
    // Stream Tasks
    func streamTask(withHostName hostname: String, port: Int) -> URLSessionStreamTask
    func streamTask(with netService: NetService) -> URLSessionStreamTask
}

// MARK: - URLSession Extension
/// Extension to make URLSession conform to URLSessionProtocol
extension URLSession: URLSessionProtocol {}

// MARK: - Mock Network Service for Testing
/// Mock implementation for unit testing (following Open/Closed Principle)
class MockCallbackNetworkService: CallbackNetworkServiceProtocol {
    var shouldSucceed = true
    var mockUsers: [User] = []
    var mockUploadResponse: UploadResponse?
    var mockError: NetworkCallbackError = .invalidURL
    
    func fetchUsers(completion: @escaping (Result<[User], NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                completion(.success(self.mockUsers))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func createPost(title: String, body: String, userId: Int, completion: @escaping (Result<UploadResponse, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed, let response = self.mockUploadResponse {
                completion(.success(response))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func downloadFile(from urlString: String, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            progressHandler(1.0)
            if self.shouldSucceed {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("mock_file.json")
                completion(.success(tempURL))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func uploadData(_ data: Data, to urlString: String, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                completion(.success(Data()))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func uploadFile(at fileURL: URL, to urlString: String, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                completion(.success(Data()))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func connectWebSocket(to urlString: String, messageHandler: @escaping (Result<URLSessionWebSocketTask.Message, NetworkCallbackError>) -> Void, completion: @escaping (Result<URLSessionWebSocketTask, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                // Create a mock WebSocket task (this would be a real task in production)
                let mockTask = URLSession.shared.webSocketTask(with: URL(string: "wss://echo.websocket.org")!)
                completion(.success(mockTask))
                
                // Simulate receiving messages
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    messageHandler(.success(.string("Mock WebSocket message")))
                }
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func sendWebSocketMessage(_ message: URLSessionWebSocketTask.Message, task: URLSessionWebSocketTask, completion: @escaping (Result<Void, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func createStreamConnection(to host: String, port: Int, completion: @escaping (Result<URLSessionStreamTask, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                let mockTask = URLSession.shared.streamTask(withHostName: host, port: port)
                completion(.success(mockTask))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func sendStreamData(_ data: Data, task: URLSessionStreamTask, completion: @escaping (Result<Void, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
    
    func readStreamData(from task: URLSessionStreamTask, completion: @escaping (Result<Data, NetworkCallbackError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                completion(.success("Mock stream data".data(using: .utf8) ?? Data()))
            } else {
                completion(.failure(self.mockError))
            }
        }
    }
}

// MARK: - ViewModel for Callback-Based Networking
/// ViewModel following MVVM pattern with dependency injection
class CallbackNetworkViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var downloadProgress: Double = 0.0
    @Published var downloadedFileURL: URL?
    @Published var uploadResponse: UploadResponse?
    @Published var webSocketTask: URLSessionWebSocketTask?
    @Published var webSocketMessages: [String] = []
    @Published var streamTask: URLSessionStreamTask?
    @Published var streamData: String = ""
    
    // MARK: - Dependency Injection (Following Dependency Inversion Principle)
    private let networkService: CallbackNetworkServiceProtocol
    
    /// Initializer with dependency injection for better testability
    init(networkService: CallbackNetworkServiceProtocol = CallbackNetworkService()) {
        self.networkService = networkService
    }
    
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func createPost() {
        isLoading = true
        errorMessage = nil
        
        networkService.createPost(title: "Test Post", body: "This is a test post", userId: 1) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.uploadResponse = response
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func downloadSampleFile() {
        isLoading = true
        errorMessage = nil
        downloadProgress = 0.0
        
        // Example: Download a sample JSON file
        let sampleURL = "https://jsonplaceholder.typicode.com/posts/1"
        
        networkService.downloadFile(from: sampleURL, progressHandler: { [weak self] progress in
            DispatchQueue.main.async {
                self?.downloadProgress = progress
            }
        }) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fileURL):
                    self?.downloadedFileURL = fileURL
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func connectWebSocket() {
        isLoading = true
        errorMessage = nil
        
        networkService.connectWebSocket(
            to: "wss://echo.websocket.org",
            messageHandler: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        switch message {
                        case .string(let text):
                            self?.webSocketMessages.append("Received: \(text)")
                        case .data(let data):
                            self?.webSocketMessages.append("Received data: \(data.count) bytes")
                        @unknown default:
                            break
                        }
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let task):
                    self?.webSocketTask = task
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func sendWebSocketMessage(_ text: String) {
        guard let task = webSocketTask else { return }
        
        let message = URLSessionWebSocketTask.Message.string(text)
        networkService.sendWebSocketMessage(message, task: task) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.webSocketMessages.append("Sent: \(text)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func createStreamConnection() {
        isLoading = true
        errorMessage = nil
        
        networkService.createStreamConnection(to: "httpbin.org", port: 80) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let task):
                    self?.streamTask = task
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func sendStreamData(_ text: String) {
        guard let task = streamTask else { return }
        
        let data = text.data(using: .utf8) ?? Data()
        networkService.sendStreamData(data, task: task) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.streamData += "Sent: \(text)\n"
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func readStreamData() {
        guard let task = streamTask else { return }
        
        networkService.readStreamData(from: task) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let text = String(data: data, encoding: .utf8) ?? "Binary data"
                    self?.streamData += "Received: \(text)\n"
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - SwiftUI View
struct CallbackNetworkView: View {
    @StateObject private var viewModel = CallbackNetworkViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Fetch Users Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Data Task Example")
                            .font(.headline)
                        
                        Button("Fetch Users") {
                            viewModel.fetchUsers()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !viewModel.users.isEmpty {
                            Text("Fetched \(viewModel.users.count) users")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    // Create Post Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Upload Task Example")
                            .font(.headline)
                        
                        Button("Create Post") {
                            viewModel.createPost()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if let response = viewModel.uploadResponse {
                            Text("Created post with ID: \(response.id)")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    // Download Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Download Task Example")
                            .font(.headline)
                        
                        Button("Download Sample File") {
                            viewModel.downloadSampleFile()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if viewModel.downloadProgress > 0 {
                            ProgressView(value: viewModel.downloadProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        
                        if let fileURL = viewModel.downloadedFileURL {
                            Text("Downloaded to: \(fileURL.lastPathComponent)")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Divider()
                    
                    // WebSocket Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("WebSocket Task Example")
                            .font(.headline)
                        
                        Button("Connect WebSocket") {
                            viewModel.connectWebSocket()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if viewModel.webSocketTask != nil {
                            HStack {
                                TextField("Message", text: .constant("Hello WebSocket!"))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Send") {
                                    viewModel.sendWebSocketMessage("Hello WebSocket!")
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            if !viewModel.webSocketMessages.isEmpty {
                                ScrollView {
                                    LazyVStack(alignment: .leading) {
                                        ForEach(viewModel.webSocketMessages.indices, id: \.self) { index in
                                            Text(viewModel.webSocketMessages[index])
                                                .font(.caption)
                                                .padding(.vertical, 2)
                                        }
                                    }
                                }
                                .frame(maxHeight: 100)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Stream Task Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Stream Task Example")
                            .font(.headline)
                        
                        Button("Create Stream Connection") {
                            viewModel.createStreamConnection()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if viewModel.streamTask != nil {
                            HStack {
                                Button("Send Data") {
                                    viewModel.sendStreamData("GET / HTTP/1.1\r\nHost: httpbin.org\r\n\r\n")
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Read Data") {
                                    viewModel.readStreamData()
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            if !viewModel.streamData.isEmpty {
                                ScrollView {
                                    Text(viewModel.streamData)
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxHeight: 150)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Loading and Error States
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .navigationTitle("Callback Network Examples")
        }
    }
}

// MARK: - Preview
struct CallbackNetworkView_Previews: PreviewProvider {
    static var previews: some View {
        CallbackNetworkView()
    }
}

// MARK: - 🎯 SENIOR iOS ENGINEER INTERVIEW QUESTIONS & ANSWERS
/*
 
 ═══════════════════════════════════════════════════════════════════════════════════════
 📚 COMPREHENSIVE INTERVIEW PREPARATION FOR SENIOR iOS ENGINEERS
 ═══════════════════════════════════════════════════════════════════════════════════════
 
 🔥 NETWORKING & URLSession DEEP DIVE
 
 Q1: What are the different types of URLSession tasks and when would you use each?
 
 A1: URLSession provides several task types:
 
 • URLSessionDataTask:
   - Used for GET/POST requests that return data in memory
   - Best for: API calls, JSON responses, small data transfers
   - Memory efficient for small responses but loads entire response into memory
   
 • URLSessionDownloadTask:
   - Downloads data directly to disk as a temporary file
   - Best for: Large files, images, videos, documents
   - Memory efficient - doesn't load entire file into memory
   - Provides built-in progress tracking
   - Supports background downloads
   
 • URLSessionUploadTask:
   - Uploads data from memory or file to server
   - Best for: File uploads, form data, multipart uploads
   - Can upload from Data object or file URL
   - Supports background uploads
   
 • URLSessionStreamTask:
   - Creates TCP/IP connection for bidirectional communication
   - Best for: Custom protocols, real-time communication
   - Less commonly used in typical iOS apps
 
 
 Q2: Explain the difference between dataTask and downloadTask in terms of memory management.
 
 A2: Key differences in memory management:
 
 DataTask:
 • Loads entire response into memory (Data object)
 • Memory usage = size of response
 • Risk of memory pressure with large responses
 • Completion handler receives Data object
 • Good for: < 10MB responses
 
 DownloadTask:
 • Streams data directly to disk
 • Minimal memory footprint regardless of file size
 • System manages temporary file location
 • Completion handler receives file URL
 • Good for: Any size file, especially > 10MB
 • Supports resume functionality for interrupted downloads
 
 Example memory impact:
 - 100MB file via dataTask: 100MB+ RAM usage
 - 100MB file via downloadTask: ~1MB RAM usage
 
 
 Q3: How do you implement proper error handling in URLSession?
 
 A3: Comprehensive error handling involves multiple layers:
 
 1. Network Layer Errors:
    • URLError (no internet, timeout, etc.)
    • HTTP status code validation (200-299 success range)
    • Response type validation (HTTPURLResponse)
 
 2. Data Layer Errors:
    • Missing data validation
    • JSON decoding errors
    • Data corruption
 
 3. Custom Error Mapping:
    enum NetworkError: Error, LocalizedError {
        case noInternet
        case timeout
        case serverError(Int)
        case decodingFailed
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .noInternet: return "No internet connection"
            case .timeout: return "Request timed out"
            case .serverError(let code): return "Server error: \(code)"
            case .decodingFailed: return "Failed to parse response"
            case .invalidResponse: return "Invalid server response"
            }
        }
    }
 
 4. Error Recovery Strategies:
    • Retry logic with exponential backoff
    • Fallback to cached data
    • User-friendly error messages
    • Logging for debugging
 
 
 Q4: What are the SOLID principles and how do they apply to networking code?
 
 A4: SOLID principles in networking context:
 
 S - Single Responsibility Principle:
 • NetworkService handles only network operations
 • JSONDecoder handles only data parsing
 • ViewModel handles only UI state management
 • Each class has one reason to change
 
 O - Open/Closed Principle:
 • NetworkServiceProtocol allows extension without modification
 • Can add new implementations (MockNetworkService) without changing existing code
 • Easy to add new endpoints or modify behavior
 
 L - Liskov Substitution Principle:
 • Any NetworkServiceProtocol implementation should be interchangeable
 • MockNetworkService can replace real NetworkService in tests
 • Behavior contracts must be maintained
 
 I - Interface Segregation Principle:
 • Separate protocols for different concerns (NetworkServiceProtocol, URLSessionProtocol)
 • Clients depend only on methods they use
 • Avoid fat interfaces with unused methods
 
 D - Dependency Inversion Principle:
 • High-level modules (ViewModel) don't depend on low-level modules (URLSession)
 • Both depend on abstractions (protocols)
 • Dependencies are injected, not created internally
 
 
 Q5: How do you handle authentication and token refresh in network requests?
 
 A5: Comprehensive authentication strategy:
 
 1. Token Storage:
    • Keychain for sensitive tokens (access/refresh tokens)
    • UserDefaults for non-sensitive data (user preferences)
    • Never store in plain text files
 
 2. Request Interceptor Pattern:
    protocol RequestInterceptor {
        func adapt(_ urlRequest: URLRequest) -> URLRequest
        func retry(_ request: URLRequest, for session: URLSession, dueTo error: Error) -> Bool
    }
 
 3. Automatic Token Refresh:
    class AuthenticationInterceptor: RequestInterceptor {
        func adapt(_ urlRequest: URLRequest) -> URLRequest {
            var request = urlRequest
            if let token = KeychainManager.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return request
        }
        
        func retry(_ request: URLRequest, for session: URLSession, dueTo error: Error) -> Bool {
            guard let httpResponse = error.httpResponse,
                  httpResponse.statusCode == 401 else { return false }
            
            // Attempt token refresh
            return refreshTokenAndRetry()
        }
    }
 
 4. Thread Safety:
    • Use serial queue for token operations
    • Prevent multiple simultaneous refresh attempts
    • Queue pending requests during refresh
 
 
 Q6: Explain the concept of URLSessionConfiguration and its types.
 
 A6: URLSessionConfiguration controls session behavior:
 
 1. .default:
    • Standard configuration with disk caching
    • Persistent cookies and credentials
    • Uses system proxy settings
    • Best for: Regular app networking
 
 2. .ephemeral:
    • No persistent storage (memory only)
    • No cookies, cache, or credentials stored
    • Private browsing equivalent
    • Best for: Sensitive data, temporary sessions
 
 3. .background(withIdentifier:):
    • Continues transfers when app is backgrounded/terminated
    • System manages the session
    • Requires unique identifier
    • Best for: Large file uploads/downloads
 
 Key Configuration Properties:
 • timeoutIntervalForRequest: Individual request timeout
 • timeoutIntervalForResource: Overall resource timeout
 • allowsCellularAccess: Control cellular usage
 • waitsForConnectivity: Wait for network availability
 • httpMaximumConnectionsPerHost: Connection pooling
 • requestCachePolicy: Caching behavior
 
 
 Q7: How do you implement request/response caching strategies?
 
 A7: Multi-layered caching approach:
 
 1. HTTP Cache Control:
    • Server sends Cache-Control headers
    • URLCache respects HTTP caching rules
    • Automatic validation with ETags/Last-Modified
 
 2. Custom Cache Implementation:
    protocol CacheManager {
        func cache<T: Codable>(_ object: T, forKey key: String, expiry: TimeInterval)
        func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T?
        func isExpired(forKey key: String) -> Bool
    }
 
 3. Cache Strategies:
    • Cache-First: Check cache, then network
    • Network-First: Try network, fallback to cache
    • Cache-Only: Use only cached data
    • Network-Only: Always fetch from network
 
 4. Cache Invalidation:
    • Time-based expiry
    • Version-based invalidation
    • Manual cache clearing
    • Memory pressure handling
 
 Example Implementation:
 func fetchWithCache<T: Codable>(_ type: T.Type, from url: URL) -> AnyPublisher<T, Error> {
     // Check cache first
     if let cached = cacheManager.retrieve(type, forKey: url.absoluteString),
        !cacheManager.isExpired(forKey: url.absoluteString) {
         return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
     }
     
     // Fetch from network and cache
     return URLSession.shared.dataTaskPublisher(for: url)
         .map(\.data)
         .decode(type: type, decoder: JSONDecoder())
         .handleEvents(receiveOutput: { [weak self] object in
             self?.cacheManager.cache(object, forKey: url.absoluteString, expiry: 3600)
         })
         .eraseToAnyPublisher()
 }
 
 
 Q8: What are the best practices for handling network requests in iOS apps?
 
 A8: Comprehensive best practices:
 
 1. Architecture:
    • Use protocol-based design for testability
    • Implement repository pattern for data layer
    • Separate network logic from UI logic
    • Use dependency injection
 
 2. Error Handling:
    • Implement comprehensive error types
    • Provide user-friendly error messages
    • Log errors for debugging
    • Implement retry mechanisms
 
 3. Performance:
    • Use appropriate task types (data vs download)
    • Implement request/response caching
    • Use connection pooling
    • Compress request/response data
 
 4. Security:
    • Use HTTPS for all requests
    • Implement certificate pinning
    • Validate SSL certificates
    • Secure token storage in Keychain
 
 5. User Experience:
    • Show loading states
    • Handle offline scenarios
    • Implement pull-to-refresh
    • Provide retry options
 
 6. Testing:
    • Mock network services for unit tests
    • Test error scenarios
    • Use URLProtocol for integration tests
    • Test offline behavior
 
 7. Monitoring:
    • Track network performance
    • Monitor error rates
    • Log request/response times
    • Implement analytics
 
 
 Q9: How do you handle concurrent network requests and avoid race conditions?
 
 A9: Concurrency management strategies:
 
 1. Operation Queues:
    let networkQueue = OperationQueue()
    networkQueue.maxConcurrentOperationCount = 3
    
    class NetworkOperation: Operation {
        override func main() {
            guard !isCancelled else { return }
            // Perform network request
        }
    }
 
 2. Dispatch Groups:
    let group = DispatchGroup()
    
    group.enter()
    fetchUsers { _ in group.leave() }
    
    group.enter()
    fetchPosts { _ in group.leave() }
    
    group.notify(queue: .main) {
        // All requests completed
    }
 
 3. Combine Publishers:
    Publishers.Zip(fetchUsers(), fetchPosts())
        .sink { completion in
            // Handle completion
        } receiveValue: { users, posts in
            // Handle results
        }
 
 4. Race Condition Prevention:
    • Use serial queues for shared state
    • Implement proper cancellation
    • Use atomic operations where needed
    • Avoid shared mutable state
 
 5. Request Deduplication:
    class RequestManager {
        private var activeRequests: [String: URLSessionTask] = [:]
        private let queue = DispatchQueue(label: "request.manager")
        
        func performRequest(for key: String, request: () -> URLSessionTask) -> URLSessionTask {
            return queue.sync {
                if let existingTask = activeRequests[key] {
                    return existingTask
                }
                
                let task = request()
                activeRequests[key] = task
                
                task.resume()
                return task
            }
        }
    }
 
 
 Q10: How do you implement background downloads and handle app lifecycle events?
 
 A10: Background download implementation:
 
 1. Configuration Setup:
    let config = URLSessionConfiguration.background(withIdentifier: "com.app.background")
    config.isDiscretionary = true // System decides when to run
    config.allowsCellularAccess = false // WiFi only
    
    lazy var backgroundSession: URLSession = {
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
 
 2. Delegate Implementation:
    extension AppDelegate: URLSessionDownloadDelegate {
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            // Move file to permanent location
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent("downloaded_file")
            
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                // Notify UI of completion
            } catch {
                print("Failed to move file: \(error)")
            }
        }
        
        func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            DispatchQueue.main.async {
                if let completionHandler = self.backgroundCompletionHandler {
                    completionHandler()
                    self.backgroundCompletionHandler = nil
                }
            }
        }
    }
 
 3. App Lifecycle Handling:
    // In AppDelegate
    var backgroundCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
 
 4. Progress Tracking:
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            // Update UI with progress
            NotificationCenter.default.post(name: .downloadProgress, object: progress)
        }
    }
 
 5. Best Practices:
    • Use unique session identifiers
    • Handle app termination gracefully
    • Implement proper error handling
    • Respect user's cellular data preferences
    • Use discretionary flag for non-critical downloads
 
 ═══════════════════════════════════════════════════════════════════════════════════════
 🔥 ADDITIONAL 20 CRUCIAL NETWORKING QUESTIONS FOR SENIOR iOS ENGINEERS
 
 Q11: What are WebSockets and when would you use URLSessionWebSocketTask?
 
 A11: WebSockets provide full-duplex communication over a single TCP connection:
 
 Key Characteristics:
 • Persistent connection after initial handshake
 • Bidirectional real-time communication
 • Lower overhead than HTTP polling
 • Built-in ping/pong for connection health
 
 URLSessionWebSocketTask Features:
 • Native iOS 13+ WebSocket implementation
 • Automatic connection management
 • Built-in message framing
 • Support for text and binary messages
 • Automatic reconnection capabilities
 
 Use Cases:
 • Real-time chat applications
 • Live sports scores/stock prices
 • Collaborative editing (Google Docs style)
 • Gaming multiplayer features
 • IoT device communication
 
 Implementation Pattern:
 let webSocketTask = URLSession.shared.webSocketTask(with: url)
 webSocketTask.resume()
 
 // Receive messages recursively
 func receiveMessage() {
     webSocketTask.receive { result in
         switch result {
         case .success(let message):
             handleMessage(message)
             receiveMessage() // Continue listening
         case .failure(let error):
             handleError(error)
         }
     }
 }
 
 
 Q12: Explain URLSessionStreamTask and its use cases.
 
 A12: URLSessionStreamTask provides TCP/IP stream communication:
 
 Purpose:
 • Direct TCP socket communication
 • Custom protocol implementation
 • Low-level network operations
 • Binary protocol communication
 
 Key Features:
 • Bidirectional data streaming
 • Custom timeout handling
 • Connection state management
 • Support for NetService (Bonjour)
 
 Use Cases:
 • Custom protocols (not HTTP/WebSocket)
 • IoT device communication
 • Database connections
 • Gaming protocols
 • Legacy system integration
 
 Example Implementation:
 let streamTask = URLSession.shared.streamTask(withHostName: "example.com", port: 1234)
 streamTask.resume()
 
 // Write data
 streamTask.write(data, timeout: 30.0) { error in
     if let error = error {
         print("Write failed: \(error)")
     }
 }
 
 // Read data
 streamTask.readData(ofMinLength: 1, maxLength: 1024, timeout: 30.0) { data, atEOF, error in
     // Handle received data
 }
 
 ═══════════════════════════════════════════════════════════════════════════════════════
 💡 KEY TAKEAWAYS FOR SENIOR iOS ENGINEERS:
 
 1. Master all URLSession task types (Data, Download, Upload, WebSocket, Stream)
 2. Implement protocol-based architecture following SOLID principles
 3. Handle comprehensive error scenarios with proper retry mechanisms
 4. Understand HTTP/2, HTTP/3, and modern protocol features
 5. Implement robust security practices (HTTPS, certificate pinning, ATS)
 6. Use appropriate caching strategies for performance optimization
 7. Handle offline scenarios and network reachability properly
 8. Implement proper request prioritization and connection pooling
 9. Master WebSocket subprotocols for real-time communication
 10. Use Stream tasks for custom protocols and low-level networking
 
 ═══════════════════════════════════════════════════════════════════════════════════════
 
 */
