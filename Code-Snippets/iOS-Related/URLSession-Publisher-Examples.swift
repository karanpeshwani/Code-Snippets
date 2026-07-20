//
//  URLSession-Publisher-Examples.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 19/07/25.
//

import SwiftUI
import Combine
import Foundation

// MARK: - Models
struct Album: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
}

struct Comment: Codable, Identifiable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}

struct CreatePostRequest: Codable {
    let title: String
    let body: String
    let userId: Int
}

struct CreatePostResponse: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

// MARK: - Custom Errors
enum PublisherNetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    case requestFailed(Error)
    case downloadFailed(Error)
    case uploadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .downloadFailed(let error):
            return "Download failed: \(error.localizedDescription)"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Network Service Protocol (Following SOLID Principles)
/// Protocol defining the contract for publisher-based networking operations
/// This follows the Interface Segregation Principle by defining specific reactive methods
protocol PublisherNetworkServiceProtocol {
    // Data Tasks
    func fetchAlbums() -> AnyPublisher<[Album], PublisherNetworkError>
    func createPost(request: CreatePostRequest) -> AnyPublisher<CreatePostResponse, PublisherNetworkError>
    func fetchAlbumsAndComments() -> AnyPublisher<([Album], [Comment]), PublisherNetworkError>
    func fetchFirstAlbumComments() -> AnyPublisher<[Comment], PublisherNetworkError>
    func fetchAlbumsWithRetry() -> AnyPublisher<[Album], PublisherNetworkError>
    func downloadFile(from urlString: String) -> AnyPublisher<(data: Data, progress: Double), PublisherNetworkError>
    func searchAlbums(query: String) -> AnyPublisher<[Album], PublisherNetworkError>
    
    // WebSocket Tasks
    func connectWebSocket(to urlString: String) -> AnyPublisher<URLSessionWebSocketTask, PublisherNetworkError>
    func webSocketMessages(from task: URLSessionWebSocketTask) -> AnyPublisher<URLSessionWebSocketTask.Message, PublisherNetworkError>
    func sendWebSocketMessage(_ message: URLSessionWebSocketTask.Message, to task: URLSessionWebSocketTask) -> AnyPublisher<Void, PublisherNetworkError>
    
    // Stream Tasks  
    func createStreamConnection(to host: String, port: Int) -> AnyPublisher<URLSessionStreamTask, PublisherNetworkError>
    func streamData(from task: URLSessionStreamTask) -> AnyPublisher<Data, PublisherNetworkError>
    func sendStreamData(_ data: Data, to task: URLSessionStreamTask) -> AnyPublisher<Void, PublisherNetworkError>
}

// MARK: - URLSession Publisher-Based Network Service Implementation
/// Concrete implementation of PublisherNetworkServiceProtocol using Combine
/// This follows the Single Responsibility Principle - handles only reactive network operations
/// This follows the Dependency Inversion Principle - depends on URLSession abstraction
class PublisherNetworkService: PublisherNetworkServiceProtocol {
    
    // MARK: - Dependencies
    private let urlSession: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    /// Dependency injection for URLSession (following Dependency Inversion Principle)
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Data Task Publisher Example
    /// Performs a GET request using dataTaskPublisher
    func fetchAlbums() -> AnyPublisher<[Album], PublisherNetworkError> {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/albums") else {
            return Fail(error: PublisherNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { output in
                // Validate HTTP response
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw PublisherNetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw PublisherNetworkError.serverError(statusCode: httpResponse.statusCode)
                }
                
                return output.data
            }
            .decode(type: [Album].self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return PublisherNetworkError.decodingError(error)
                } else if let networkError = error as? PublisherNetworkError {
                    return networkError
                } else {
                    return PublisherNetworkError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Data Task Publisher with Custom Request
    /// Performs a POST request using dataTaskPublisher with custom URLRequest
    func createPost(request: CreatePostRequest) -> AnyPublisher<CreatePostResponse, PublisherNetworkError> {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return Fail(error: PublisherNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: PublisherNetworkError.uploadFailed(error))
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw PublisherNetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw PublisherNetworkError.serverError(statusCode: httpResponse.statusCode)
                }
                
                return output.data
            }
            .decode(type: CreatePostResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return PublisherNetworkError.decodingError(error)
                } else if let networkError = error as? PublisherNetworkError {
                    return networkError
                } else {
                    return PublisherNetworkError.uploadFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Multiple Concurrent Requests
    /// Demonstrates fetching multiple resources concurrently using Publishers.Zip
    func fetchAlbumsAndComments() -> AnyPublisher<([Album], [Comment]), PublisherNetworkError> {
        let albumsPublisher = fetchAlbums()
        let commentsPublisher = fetchComments()
        
        return Publishers.Zip(albumsPublisher, commentsPublisher)
            .eraseToAnyPublisher()
    }
    
    /// Helper method to fetch comments
    private func fetchComments() -> AnyPublisher<[Comment], PublisherNetworkError> {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments?_limit=10") else {
            return Fail(error: PublisherNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (output.response as? HTTPURLResponse)?.statusCode ?? 500
                    throw PublisherNetworkError.serverError(statusCode: statusCode)
                }
                return output.data
            }
            .decode(type: [Comment].self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return PublisherNetworkError.decodingError(error)
                } else if let networkError = error as? PublisherNetworkError {
                    return networkError
                } else {
                    return PublisherNetworkError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sequential Requests with FlatMap
    /// Demonstrates sequential requests where the second request depends on the first
    func fetchFirstAlbumComments() -> AnyPublisher<[Comment], PublisherNetworkError> {
        return fetchAlbums()
            .flatMap { albums -> AnyPublisher<[Comment], PublisherNetworkError> in
                guard let firstAlbum = albums.first else {
                    return Just([])
                        .setFailureType(to: PublisherNetworkError.self)
                        .eraseToAnyPublisher()
                }
                
                return self.fetchCommentsForPost(postId: firstAlbum.id)
            }
            .eraseToAnyPublisher()
    }
    
    /// Helper method to fetch comments for a specific post
    private func fetchCommentsForPost(postId: Int) -> AnyPublisher<[Comment], PublisherNetworkError> {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments?postId=\(postId)") else {
            return Fail(error: PublisherNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (output.response as? HTTPURLResponse)?.statusCode ?? 500
                    throw PublisherNetworkError.serverError(statusCode: statusCode)
                }
                return output.data
            }
            .decode(type: [Comment].self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return PublisherNetworkError.decodingError(error)
                } else if let networkError = error as? PublisherNetworkError {
                    return networkError
                } else {
                    return PublisherNetworkError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Retry and Timeout Examples
    /// Demonstrates retry logic and timeout handling
    func fetchAlbumsWithRetry() -> AnyPublisher<[Album], PublisherNetworkError> {
        return fetchAlbums()
            .timeout(.seconds(10), scheduler: DispatchQueue.main)
            .retry(3) // Retry up to 3 times on failure
            .catch { error -> AnyPublisher<[Album], PublisherNetworkError> in
                // Fallback to empty array on persistent failure
                print("Failed after retries: \(error)")
                return Just([])
                    .setFailureType(to: PublisherNetworkError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Download Task Publisher (Custom Implementation)
    /// Custom download publisher with progress tracking
    func downloadFile(from urlString: String) -> AnyPublisher<(data: Data, progress: Double), PublisherNetworkError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: PublisherNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (output.response as? HTTPURLResponse)?.statusCode ?? 500
                    throw PublisherNetworkError.serverError(statusCode: statusCode)
                }
                
                // For simplicity, we're returning 100% progress since dataTaskPublisher
                // doesn't provide built-in progress tracking like downloadTask
                return (data: output.data, progress: 1.0)
            }
            .mapError { error in
                if let networkError = error as? PublisherNetworkError {
                    return networkError
                } else {
                    return PublisherNetworkError.downloadFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Debounced Search Example
    /// Demonstrates debounced search using Combine operators
    func searchAlbums(query: String) -> AnyPublisher<[Album], PublisherNetworkError> {
        guard !query.isEmpty else {
            return Just([])
                .setFailureType(to: PublisherNetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return fetchAlbums()
            .map { albums in
                albums.filter { album in
                    album.title.localizedCaseInsensitiveContains(query)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - WebSocket Publisher Examples
    /// Creates a WebSocket connection and returns the task as a publisher
    func connectWebSocket(to urlString: String) -> AnyPublisher<URLSessionWebSocketTask, PublisherNetworkError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: PublisherNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return Future { promise in
            let webSocketTask = self.urlSession.webSocketTask(with: url)
            webSocketTask.resume()
            promise(.success(webSocketTask))
        }
        .eraseToAnyPublisher()
    }
    
    /// Creates a publisher for WebSocket messages from a task
    func webSocketMessages(from task: URLSessionWebSocketTask) -> AnyPublisher<URLSessionWebSocketTask.Message, PublisherNetworkError> {
        return Future<URLSessionWebSocketTask.Message, PublisherNetworkError> { promise in
            task.receive { result in
                switch result {
                case .success(let message):
                    promise(.success(message))
                case .failure(let error):
                    promise(.failure(.requestFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Sends a WebSocket message and returns completion as publisher
    func sendWebSocketMessage(_ message: URLSessionWebSocketTask.Message, to task: URLSessionWebSocketTask) -> AnyPublisher<Void, PublisherNetworkError> {
        return Future { promise in
            task.send(message) { error in
                if let error = error {
                    promise(.failure(.uploadFailed(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Stream Publisher Examples
    /// Creates a stream connection and returns the task as a publisher
    func createStreamConnection(to host: String, port: Int) -> AnyPublisher<URLSessionStreamTask, PublisherNetworkError> {
        return Future { promise in
            let streamTask = self.urlSession.streamTask(withHostName: host, port: port)
            streamTask.resume()
            promise(.success(streamTask))
        }
        .eraseToAnyPublisher()
    }
    
    /// Creates a publisher for reading data from a stream task
    func streamData(from task: URLSessionStreamTask) -> AnyPublisher<Data, PublisherNetworkError> {
        return Future { promise in
            task.readData(ofMinLength: 1, maxLength: 65536, timeout: 30.0) { data, atEOF, error in
                if let error = error {
                    promise(.failure(.requestFailed(error)))
                } else if let data = data {
                    promise(.success(data))
                } else {
                    promise(.failure(.downloadFailed(NSError(domain: "StreamError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Sends data through a stream connection as a publisher
    func sendStreamData(_ data: Data, to task: URLSessionStreamTask) -> AnyPublisher<Void, PublisherNetworkError> {
        return Future { promise in
            task.write(data, timeout: 30.0) { error in
                if let error = error {
                    promise(.failure(.uploadFailed(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Mock Network Service for Testing
/// Mock implementation for unit testing (following Open/Closed Principle)
class MockPublisherNetworkService: PublisherNetworkServiceProtocol {
    var shouldSucceed = true
    var mockAlbums: [Album] = []
    var mockComments: [Comment] = []
    var mockCreatePostResponse: CreatePostResponse?
    var mockError: PublisherNetworkError = .invalidURL
    
    func fetchAlbums() -> AnyPublisher<[Album], PublisherNetworkError> {
        if shouldSucceed {
            return Just(mockAlbums)
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func createPost(request: CreatePostRequest) -> AnyPublisher<CreatePostResponse, PublisherNetworkError> {
        if shouldSucceed, let response = mockCreatePostResponse {
            return Just(response)
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchAlbumsAndComments() -> AnyPublisher<([Album], [Comment]), PublisherNetworkError> {
        if shouldSucceed {
            return Just((mockAlbums, mockComments))
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchFirstAlbumComments() -> AnyPublisher<[Comment], PublisherNetworkError> {
        if shouldSucceed {
            return Just(mockComments)
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchAlbumsWithRetry() -> AnyPublisher<[Album], PublisherNetworkError> {
        return fetchAlbums()
    }
    
    func downloadFile(from urlString: String) -> AnyPublisher<(data: Data, progress: Double), PublisherNetworkError> {
        if shouldSucceed {
            return Just((Data(), 1.0))
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func searchAlbums(query: String) -> AnyPublisher<[Album], PublisherNetworkError> {
        let filtered = mockAlbums.filter { $0.title.localizedCaseInsensitiveContains(query) }
        return Just(filtered)
            .setFailureType(to: PublisherNetworkError.self)
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func connectWebSocket(to urlString: String) -> AnyPublisher<URLSessionWebSocketTask, PublisherNetworkError> {
        if shouldSucceed {
            let mockTask = URLSession.shared.webSocketTask(with: URL(string: "wss://echo.websocket.org")!)
            return Just(mockTask)
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func webSocketMessages(from task: URLSessionWebSocketTask) -> AnyPublisher<URLSessionWebSocketTask.Message, PublisherNetworkError> {
        if shouldSucceed {
            return Just(.string("Mock WebSocket message"))
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func sendWebSocketMessage(_ message: URLSessionWebSocketTask.Message, to task: URLSessionWebSocketTask) -> AnyPublisher<Void, PublisherNetworkError> {
        if shouldSucceed {
            return Just(())
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func createStreamConnection(to host: String, port: Int) -> AnyPublisher<URLSessionStreamTask, PublisherNetworkError> {
        if shouldSucceed {
            let mockTask = URLSession.shared.streamTask(withHostName: host, port: port)
            return Just(mockTask)
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func streamData(from task: URLSessionStreamTask) -> AnyPublisher<Data, PublisherNetworkError> {
        if shouldSucceed {
            return Just("Mock stream data".data(using: .utf8) ?? Data())
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    func sendStreamData(_ data: Data, to task: URLSessionStreamTask) -> AnyPublisher<Void, PublisherNetworkError> {
        if shouldSucceed {
            return Just(())
                .setFailureType(to: PublisherNetworkError.self)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError)
                .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - ViewModel for Publisher-Based Networking
/// ViewModel following MVVM pattern with dependency injection and reactive programming
class PublisherNetworkViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var createPostResponse: CreatePostResponse?
    @Published var downloadProgress: Double = 0.0
    @Published var downloadedData: Data?
    @Published var searchQuery = ""
    @Published var searchResults: [Album] = []
    
    // MARK: - Dependency Injection (Following Dependency Inversion Principle)
    private let networkService: PublisherNetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializer with dependency injection for better testability
    init(networkService: PublisherNetworkServiceProtocol = PublisherNetworkService()) {
        self.networkService = networkService
        setupSearchDebouncing()
    }
    

    
    // MARK: - Basic Data Fetching
    func fetchAlbums() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchAlbums()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] albums in
                    self?.albums = albums
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Concurrent Requests
    func fetchAlbumsAndComments() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchAlbumsAndComments()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] (albums, comments) in
                    self?.albums = albums
                    self?.comments = comments
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Sequential Requests
    func fetchFirstAlbumComments() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchFirstAlbumComments()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] comments in
                    self?.comments = comments
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Create Post
    func createPost() {
        isLoading = true
        errorMessage = nil
        
        let request = CreatePostRequest(
            title: "Sample Post from Combine",
            body: "This post was created using Combine publishers",
            userId: 1
        )
        
        networkService.createPost(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.createPostResponse = response
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Download with Retry
    func fetchAlbumsWithRetry() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchAlbumsWithRetry()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] albums in
                    self?.albums = albums
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Download File
    func downloadSampleFile() {
        isLoading = true
        errorMessage = nil
        downloadProgress = 0.0
        
        let sampleURL = "https://jsonplaceholder.typicode.com/posts/1"
        
        networkService.downloadFile(from: sampleURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] (data, progress) in
                    self?.downloadedData = data
                    self?.downloadProgress = progress
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Debounced Search Setup
    private func setupSearchDebouncing() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [weak self] query -> AnyPublisher<[Album], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return self.networkService.searchAlbums(query: query)
                    .catch { _ in Just([]) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.searchResults, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - SwiftUI View
struct PublisherNetworkView: View {
    @StateObject private var viewModel = PublisherNetworkViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Debounced Search")
                            .font(.headline)
                        
                        TextField("Search albums...", text: $viewModel.searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !viewModel.searchResults.isEmpty {
                            Text("Found \(viewModel.searchResults.count) results")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    // Basic Fetch Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Basic Data Task Publisher")
                            .font(.headline)
                        
                        Button("Fetch Albums") {
                            viewModel.fetchAlbums()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !viewModel.albums.isEmpty {
                            Text("Fetched \(viewModel.albums.count) albums")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    // Concurrent Requests Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Concurrent Requests (Zip)")
                            .font(.headline)
                        
                        Button("Fetch Albums & Comments") {
                            viewModel.fetchAlbumsAndComments()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !viewModel.albums.isEmpty && !viewModel.comments.isEmpty {
                            Text("Fetched \(viewModel.albums.count) albums & \(viewModel.comments.count) comments")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    // Sequential Requests Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sequential Requests (FlatMap)")
                            .font(.headline)
                        
                        Button("Fetch First Album Comments") {
                            viewModel.fetchFirstAlbumComments()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !viewModel.comments.isEmpty {
                            Text("Fetched \(viewModel.comments.count) comments for first album")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    // Create Post Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("POST Request Publisher")
                            .font(.headline)
                        
                        Button("Create Post") {
                            viewModel.createPost()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if let response = viewModel.createPostResponse {
                            Text("Created post with ID: \(response.id)")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    // Retry Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Retry & Timeout Example")
                            .font(.headline)
                        
                        Button("Fetch with Retry") {
                            viewModel.fetchAlbumsWithRetry()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Divider()
                    
                    // Download Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Download Example")
                            .font(.headline)
                        
                        Button("Download Sample File") {
                            viewModel.downloadSampleFile()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if viewModel.downloadProgress > 0 {
                            ProgressView(value: viewModel.downloadProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        
                        if let data = viewModel.downloadedData {
                            Text("Downloaded \(data.count) bytes")
                                .foregroundColor(.green)
                                .font(.caption)
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
            .navigationTitle("Publisher Network Examples")
        }
    }
}

// MARK: - Preview
struct PublisherNetworkView_Previews: PreviewProvider {
    static var previews: some View {
        PublisherNetworkView()
    }
}

// MARK: - 🎯 SENIOR iOS ENGINEER INTERVIEW QUESTIONS & ANSWERS
/*
 
 ═══════════════════════════════════════════════════════════════════════════════════════
 📚 COMPREHENSIVE INTERVIEW PREPARATION FOR SENIOR iOS ENGINEERS
 ═══════════════════════════════════════════════════════════════════════════════════════
 
 🔥 COMBINE FRAMEWORK & REACTIVE PROGRAMMING DEEP DIVE
 
 Q1: What is Combine and how does it differ from traditional callback-based networking?
 
 A1: Combine is Apple's reactive programming framework:
 
 Key Concepts:
 • Publisher: Emits values over time
 • Subscriber: Receives values from publishers
 • Operators: Transform, filter, and combine publishers
 • Cancellable: Manages subscription lifecycle
 
 Differences from Callbacks:
 
 Callbacks:
 • Imperative programming style
 • Manual memory management
 • Difficult to compose multiple operations
 • Callback hell with nested operations
 • Manual error handling
 
 Combine:
 • Declarative programming style
 • Automatic memory management with AnyCancellable
 • Easy composition with operators
 • Functional chaining of operations
 • Built-in error handling with operators
 
 Example Comparison:
 // Callback approach
 fetchUsers { users in
     fetchPosts { posts in
         updateUI(users: users, posts: posts)
     }
 }
 
 // Combine approach
 Publishers.Zip(fetchUsers(), fetchPosts())
     .receive(on: DispatchQueue.main)
     .sink { users, posts in
         updateUI(users: users, posts: posts)
     }
 
 
 Q2: Explain the key Combine operators and their use cases in networking.
 
 A2: Essential Combine operators for networking:
 
 Transformation Operators:
 • map: Transform values
 • tryMap: Transform with error throwing
 • decode: JSON decoding
 • compactMap: Remove nil values
 
 Error Handling:
 • mapError: Transform errors
 • catch: Provide fallback publisher
 • retry: Retry on failure
 • replaceError: Replace error with default value
 
 Filtering:
 • filter: Filter values based on condition
 • removeDuplicates: Remove consecutive duplicates
 • debounce: Delay emissions for specified time
 • throttle: Limit emission rate
 
 Combining:
 • zip: Combine latest values from multiple publishers
 • combineLatest: Combine when any publisher emits
 • merge: Merge multiple publishers into one
 • flatMap: Transform and flatten publishers
 
 Timing:
 • delay: Delay emissions
 • timeout: Fail after specified time
 • receive(on:): Specify scheduler for downstream
 
 Practical Example:
 func searchWithDebounce(query: String) -> AnyPublisher<[Result], Error> {
     Just(query)
         .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
         .removeDuplicates()
         .flatMap { query in
             self.performSearch(query: query)
                 .catch { _ in Just([]) }
         }
         .eraseToAnyPublisher()
 }
 
 
 Q3: How do you handle memory management in Combine?
 
 A3: Memory management strategies in Combine:
 
 1. AnyCancellable Storage:
    private var cancellables = Set<AnyCancellable>()
    
    publisher
        .sink { value in /* handle */ }
        .store(in: &cancellables)
 
 2. Automatic Cancellation:
    • Cancellables are automatically cancelled when deallocated
    • Set<AnyCancellable> cancels all subscriptions on deallocation
    • No need for manual cleanup in most cases
 
 3. Weak References:
    publisher
        .sink { [weak self] value in
            self?.handleValue(value)
        }
        .store(in: &cancellables)
 
 4. Custom Cancellation:
    let cancellable = publisher.sink { /* handle */ }
    
    // Later...
    cancellable.cancel()
 
 5. Lifecycle Management:
    class ViewModel: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        
        deinit {
            // Automatic cancellation when cancellables is deallocated
        }
    }
 
 6. Memory Leak Prevention:
    • Always use [weak self] in closures
    • Store cancellables properly
    • Avoid retain cycles with publishers
    • Use assign(to:) carefully with object references
 
 
 Q4: What are the different ways to create Publishers in Combine?
 
 A4: Various Publisher creation methods:
 
 1. Built-in Publishers:
    • Just(value): Emits single value then completes
    • Empty(): Completes immediately without emitting
    • Fail(error): Fails immediately with error
    • Future: For async operations with single result
 
 2. URLSession Publishers:
    • dataTaskPublisher(for:): Network requests
    • downloadTaskPublisher(for:): File downloads
 
 3. Property Publishers:
    • @Published: SwiftUI property wrapper
    • assign(to:): Assign values to properties
 
 4. Subject Publishers:
    • PassthroughSubject: Relay values to subscribers
    • CurrentValueSubject: Holds current value
 
 5. Custom Publishers:
    struct CustomPublisher: Publisher {
        typealias Output = String
        typealias Failure = Never
        
        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            // Custom implementation
        }
    }
 
 6. Timer Publishers:
    Timer.publish(every: 1.0, on: .main, in: .common)
 
 7. Notification Publishers:
    NotificationCenter.default.publisher(for: .didBecomeActive)
 
 Example Usage:
 // Future for async operations
 func fetchData() -> AnyPublisher<Data, Error> {
     Future { promise in
         // Async operation
         URLSession.shared.dataTask(with: url) { data, _, error in
             if let error = error {
                 promise(.failure(error))
             } else if let data = data {
                 promise(.success(data))
             }
         }.resume()
     }
     .eraseToAnyPublisher()
 }
 
 
 Q5: How do you implement error handling and retry logic in Combine?
 
 A5: Comprehensive error handling strategies:
 
 1. Basic Error Handling:
    publisher
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Completed successfully")
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            },
            receiveValue: { value in
                print("Received: \(value)")
            }
        )
 
 2. Error Transformation:
    publisher
        .mapError { error -> CustomError in
            switch error {
            case URLError.notConnectedToInternet:
                return .noConnection
            case URLError.timedOut:
                return .timeout
            default:
                return .unknown(error)
            }
        }
 
 3. Retry Logic:
    publisher
        .retry(3) // Retry up to 3 times
        .catch { error in
            // Fallback publisher
            Just(defaultValue)
        }
 
 4. Advanced Retry with Delay:
    extension Publisher {
        func retryWithDelay<T, E>(
            retries: Int,
            delay: T.SchedulerTimeType.Stride,
            scheduler: T
        ) -> Publishers.TryCatch<Self, AnyPublisher<Self.Output, Self.Failure>>
        where T: Scheduler, E: Error, Self.Failure == E {
            
            return self.tryCatch { error in
                return Publishers.Sequence(sequence: 0..<retries)
                    .flatMap { attempt in
                        return self
                            .delay(for: delay * Double(attempt + 1), scheduler: scheduler)
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
 
 5. Exponential Backoff:
    func exponentialBackoff<T: Scheduler>(
        retries: Int,
        scheduler: T
    ) -> AnyPublisher<Output, Failure> {
        return self.catch { error in
            Publishers.Sequence(sequence: 1...retries)
                .flatMap { attempt in
                    let delay = pow(2.0, Double(attempt))
                    return self
                        .delay(for: .seconds(delay), scheduler: scheduler)
                        .catch { _ in Empty() }
                }
                .first()
                .setFailureType(to: Failure.self)
        }
        .eraseToAnyPublisher()
    }
 
 6. Circuit Breaker Pattern:
    class CircuitBreaker {
        private var failureCount = 0
        private var lastFailureTime: Date?
        private let threshold = 5
        private let timeout: TimeInterval = 60
        
        func execute<T>(_ publisher: AnyPublisher<T, Error>) -> AnyPublisher<T, Error> {
            if isOpen {
                return Fail(error: CircuitBreakerError.open)
                    .eraseToAnyPublisher()
            }
            
            return publisher
                .handleEvents(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.reset()
                        case .failure:
                            self.recordFailure()
                        }
                    }
                )
                .eraseToAnyPublisher()
        }
    }
 
 
 Q6: How do you test Combine-based networking code?
 
 A6: Testing strategies for Combine code:
 
 1. Mock Publishers:
    class MockNetworkService: NetworkServiceProtocol {
        var mockResult: Result<[User], Error> = .success([])
        
        func fetchUsers() -> AnyPublisher<[User], Error> {
            switch mockResult {
            case .success(let users):
                return Just(users)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            case .failure(let error):
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
    }
 
 2. Test Schedulers:
    func testDebounce() {
        let scheduler = DispatchQueue.test
        let publisher = PassthroughSubject<String, Never>()
        
        let result = publisher
            .debounce(for: .seconds(1), scheduler: scheduler)
            .collect()
        
        var output: [String] = []
        let cancellable = result.sink { output = $0 }
        
        publisher.send("a")
        publisher.send("b")
        publisher.send("c")
        
        scheduler.advance(by: .seconds(1))
        
        XCTAssertEqual(output, ["c"])
    }
 
 3. Expectation-based Testing:
    func testNetworkCall() {
        let expectation = XCTestExpectation(description: "Network call")
        let mockService = MockNetworkService()
        let viewModel = ViewModel(networkService: mockService)
        
        viewModel.$users
            .dropFirst() // Skip initial empty value
            .sink { users in
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchUsers()
        wait(for: [expectation], timeout: 1.0)
    }
 
 4. Error Testing:
    func testErrorHandling() {
        let mockService = MockNetworkService()
        mockService.mockResult = .failure(NetworkError.serverError)
        
        let viewModel = ViewModel(networkService: mockService)
        
        let errorExpectation = XCTestExpectation(description: "Error received")
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { errorMessage in
                XCTAssertFalse(errorMessage.isEmpty)
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchUsers()
        wait(for: [errorExpectation], timeout: 1.0)
    }
 
 5. URLProtocol for Integration Tests:
    class MockURLProtocol: URLProtocol {
        static var mockData: Data?
        static var mockResponse: URLResponse?
        static var mockError: Error?
        
        override func startLoading() {
            if let error = MockURLProtocol.mockError {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
            
            if let response = MockURLProtocol.mockResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = MockURLProtocol.mockData {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
    }
 
 
 Q7: What are Subjects in Combine and when would you use them?
 
 A7: Subjects are publishers that can be manually controlled:
 
 1. PassthroughSubject:
    • Doesn't hold state
    • Only forwards values to current subscribers
    • Good for events and notifications
    
    let subject = PassthroughSubject<String, Never>()
    
    subject.sink { print($0) }.store(in: &cancellables)
    subject.send("Hello") // Prints "Hello"
    
    // New subscriber won't receive previous values
    subject.sink { print("New: \($0)") }.store(in: &cancellables)
    subject.send("World") // Both subscribers receive "World"
 
 2. CurrentValueSubject:
    • Holds current value
    • New subscribers immediately receive current value
    • Good for state management
    
    let subject = CurrentValueSubject<Int, Never>(0)
    
    subject.sink { print($0) }.store(in: &cancellables) // Prints 0
    subject.send(1) // Prints 1
    
    // New subscriber immediately gets current value
    subject.sink { print("New: \($0)") }.store(in: &cancellables) // Prints "New: 1"
 
 3. Use Cases:
 
    Event Broadcasting:
    class EventBus {
        private let eventSubject = PassthroughSubject<Event, Never>()
        
        var events: AnyPublisher<Event, Never> {
            eventSubject.eraseToAnyPublisher()
        }
        
        func send(_ event: Event) {
            eventSubject.send(event)
        }
    }
    
    State Management:
    class UserManager {
        private let userSubject = CurrentValueSubject<User?, Never>(nil)
        
        var currentUser: AnyPublisher<User?, Never> {
            userSubject.eraseToAnyPublisher()
        }
        
        func login(_ user: User) {
            userSubject.send(user)
        }
        
        func logout() {
            userSubject.send(nil)
        }
    }
 
 4. Best Practices:
    • Use PassthroughSubject for events
    • Use CurrentValueSubject for state
    • Always expose as AnyPublisher to hide implementation
    • Remember to send completion when done
    • Handle backpressure if needed
 
 
 Q8: How do you handle backpressure in Combine?
 
 A8: Backpressure management strategies:
 
 1. Understanding Backpressure:
    • Occurs when publisher emits faster than subscriber can process
    • Can lead to memory issues and performance problems
    • Combine provides several strategies to handle this
 
 2. Built-in Operators:
 
    Buffering:
    publisher
        .buffer(size: 100, prefetch: .keepFull, whenFull: .dropOldest)
    
    Throttling:
    publisher
        .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
    
    Sampling:
    publisher
        .sample(timer) // Only emit when timer fires
    
    Debouncing:
    publisher
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
 
 3. Custom Backpressure Handling:
    extension Publisher {
        func handleBackpressure<S: Scheduler>(
            bufferSize: Int,
            scheduler: S
        ) -> AnyPublisher<Output, Failure> {
            return self
                .buffer(size: bufferSize, prefetch: .keepFull, whenFull: .dropOldest)
                .receive(on: scheduler)
                .eraseToAnyPublisher()
        }
    }
 
 4. Demand-based Processing:
    class CustomSubscriber<Input, Failure: Error>: Subscriber {
        func receive(subscription: Subscription) {
            subscription.request(.max(1)) // Request one at a time
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            // Process input
            return .max(1) // Request one more
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            // Handle completion
        }
    }
 
 5. Monitoring and Metrics:
    publisher
        .handleEvents(
            receiveSubscription: { _ in print("Subscribed") },
            receiveOutput: { _ in print("Received value") },
            receiveCompletion: { _ in print("Completed") },
            receiveCancel: { print("Cancelled") },
            receiveRequest: { demand in print("Requested: \(demand)") }
        )
 
 
 Q9: How do you implement caching with Combine publishers?
 
 A9: Caching strategies with Combine:
 
 1. Simple Memory Cache:
    class CachedPublisher<Output, Failure: Error> {
        private var cache: [String: Output] = [:]
        private let publisher: (String) -> AnyPublisher<Output, Failure>
        
        init(publisher: @escaping (String) -> AnyPublisher<Output, Failure>) {
            self.publisher = publisher
        }
        
        func get(key: String) -> AnyPublisher<Output, Failure> {
            if let cached = cache[key] {
                return Just(cached)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }
            
            return publisher(key)
                .handleEvents(receiveOutput: { [weak self] output in
                    self?.cache[key] = output
                })
                .eraseToAnyPublisher()
        }
    }
 
 2. Time-based Cache:
    struct CacheEntry<T> {
        let value: T
        let timestamp: Date
        let ttl: TimeInterval
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    class TTLCache<T> {
        private var cache: [String: CacheEntry<T>] = [:]
        
        func get(key: String) -> T? {
            guard let entry = cache[key], !entry.isExpired else {
                cache.removeValue(forKey: key)
                return nil
            }
            return entry.value
        }
        
        func set(key: String, value: T, ttl: TimeInterval) {
            cache[key] = CacheEntry(value: value, timestamp: Date(), ttl: ttl)
        }
    }
 
 3. Cache-First Strategy:
    func fetchWithCache<T: Codable>(
        _ type: T.Type,
        key: String,
        networkPublisher: AnyPublisher<T, Error>
    ) -> AnyPublisher<T, Error> {
        
        // Check cache first
        if let cached = cache.get(key: key) {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Fetch from network and cache
        return networkPublisher
            .handleEvents(receiveOutput: { [weak self] value in
                self?.cache.set(key: key, value: value, ttl: 3600)
            })
            .eraseToAnyPublisher()
    }
 
 4. Network-First with Fallback:
    func fetchNetworkFirst<T: Codable>(
        _ type: T.Type,
        key: String,
        networkPublisher: AnyPublisher<T, Error>
    ) -> AnyPublisher<T, Error> {
        
        return networkPublisher
            .handleEvents(receiveOutput: { [weak self] value in
                self?.cache.set(key: key, value: value, ttl: 3600)
            })
            .catch { [weak self] error -> AnyPublisher<T, Error> in
                if let cached = self?.cache.get(key: key) {
                    return Just(cached)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
 
 5. Reactive Cache Invalidation:
    class ReactiveCache<T> {
        private let cacheSubject = CurrentValueSubject<[String: T], Never>([:])
        private let invalidationSubject = PassthroughSubject<String, Never>()
        
        var cache: AnyPublisher<[String: T], Never> {
            Publishers.Merge(
                cacheSubject,
                invalidationSubject
                    .map { key in
                        var current = self.cacheSubject.value
                        current.removeValue(forKey: key)
                        return current
                    }
            )
            .removeDuplicates { $0.keys == $1.keys }
            .eraseToAnyPublisher()
        }
        
        func set(key: String, value: T) {
            var current = cacheSubject.value
            current[key] = value
            cacheSubject.send(current)
        }
        
        func invalidate(key: String) {
            invalidationSubject.send(key)
        }
    }
 
 
 Q10: What are the performance considerations when using Combine?
 
 A10: Performance optimization strategies:
 
 1. Scheduler Selection:
    • Use appropriate schedulers for different tasks
    • Background queues for heavy processing
    • Main queue only for UI updates
    
    publisher
        .subscribe(on: DispatchQueue.global(qos: .background)) // Heavy work
        .receive(on: DispatchQueue.main) // UI updates
 
 2. Memory Management:
    • Store cancellables properly
    • Use weak references in closures
    • Cancel subscriptions when not needed
    
    // Good
    publisher
        .sink { [weak self] value in
            self?.handleValue(value)
        }
        .store(in: &cancellables)
    
    // Avoid retain cycles
    publisher
        .assign(to: \.property, on: weakObject)
 
 3. Operator Efficiency:
    • Use share() for expensive publishers
    • Prefer map over flatMap when possible
    • Use removeDuplicates to avoid unnecessary work
    
    let expensivePublisher = heavyComputation()
        .share() // Share among multiple subscribers
    
    expensivePublisher.sink { /* subscriber 1 */ }
    expensivePublisher.sink { /* subscriber 2 */ }
 
 4. Backpressure Management:
    • Buffer appropriately
    • Use throttle/debounce for high-frequency events
    • Drop old values when necessary
    
    highFrequencyPublisher
        .buffer(size: 10, prefetch: .keepFull, whenFull: .dropOldest)
        .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
 
 5. Avoid Common Pitfalls:
    • Don't create publishers in body of SwiftUI views
    • Avoid excessive use of eraseToAnyPublisher()
    • Don't ignore cancellables
    • Be careful with flatMap and nested publishers
 
 6. Profiling and Monitoring:
    • Use Instruments to profile Combine code
    • Monitor memory usage and retain cycles
    • Track publisher creation and cancellation
    • Measure operator performance
 
 ═══════════════════════════════════════════════════════════════════════════════════════
 💡 KEY TAKEAWAYS FOR SENIOR iOS ENGINEERS:
 
 1. Master Combine operators and their appropriate use cases
 2. Implement proper memory management with AnyCancellable
 3. Use protocol-based architecture for testable reactive code
 4. Handle errors gracefully with retry and fallback strategies
 5. Understand backpressure and implement appropriate handling
 6. Use Subjects correctly for event broadcasting and state management
 7. Implement efficient caching strategies with reactive invalidation
 8. Choose appropriate schedulers for different types of work
 9. Write comprehensive tests using mock publishers and test schedulers
 10. Monitor performance and avoid common Combine pitfalls
 
 ═══════════════════════════════════════════════════════════════════════════════════════
 
 */
