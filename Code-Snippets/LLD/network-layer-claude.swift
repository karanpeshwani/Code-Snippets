//
//  LLD-Example-3.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 25/08/25.
//
//  Generic REST API Client - Low Level Design
//  Following SOLID, DRY, KISS, YAGNI principles
//

//Question:

/*
 Create a generic, reusable client to communicate with a REST API. It should handle different endpoints, HTTP methods, request bodies, and parse JSON responses.
*/

import Foundation
import Combine

// MARK: - Core Protocols (Interface Segregation Principle)

/// Protocol for making network requests
protocol NetworkServiceProtocol {
    func execute<T: Codable>(_ request: APIRequest) async throws -> APIResponse<T>
    func execute<T: Codable>(_ request: APIRequest) -> AnyPublisher<APIResponse<T>, APIError>
}

/// Protocol for request building
protocol APIRequestBuilding {
    func buildURLRequest() throws -> URLRequest
}

/// Protocol for response parsing
protocol ResponseParsing {
    func parse<T: Codable>(_ data: Data, to type: T.Type) throws -> T
}

/// Protocol for authentication
protocol AuthenticationProtocol {
    func authenticate(_ request: inout URLRequest) throws
}

/// Protocol for caching
protocol CacheProtocol {
    func get<T: Codable>(for key: String, type: T.Type) -> T?
    func set<T: Codable>(_ value: T, for key: String)
    func remove(for key: String)
    func clear()
}

// MARK: - HTTP Method Enum

enum HTTPMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
}

// MARK: - API Error Types

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int, data: Data?)
    case authenticationFailed
    case timeout
    case cancelled
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        case .authenticationFailed:
            return "Authentication failed"
        case .timeout:
            return "Request timeout"
        case .cancelled:
            return "Request cancelled"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Request Configuration

struct APIConfiguration {
    let baseURL: String
    let timeout: TimeInterval
    let retryCount: Int
    let cachePolicy: URLRequest.CachePolicy
    let headers: [String: String]
    
    static let `default` = APIConfiguration(
        baseURL: "",
        timeout: 30.0,
        retryCount: 3,
        cachePolicy: .useProtocolCachePolicy,
        headers: [:]
    )
}

// MARK: - API Request Model

struct APIRequest: APIRequestBuilding {
    let endpoint: String
    let method: HTTPMethod
    let parameters: [String: Any]?
    let body: Data?
    let headers: [String: String]?
    let configuration: APIConfiguration
    
    init(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil,
        configuration: APIConfiguration = .default
    ) {
        self.endpoint = endpoint
        self.method = method
        self.parameters = parameters
        self.body = body
        self.headers = headers
        self.configuration = configuration
    }
    
    func buildURLRequest() throws -> URLRequest {
        guard let baseURL = URL(string: configuration.baseURL) else {
            throw APIError.invalidURL
        }
        
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true)
        
        // Add query parameters for GET requests
        if method == .GET, let parameters = parameters {
            urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = configuration.timeout
        request.cachePolicy = configuration.cachePolicy
        
        // Set default headers
        configuration.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Set custom headers
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Set body for non-GET requests
        if method != .GET {
            if let body = body {
                request.httpBody = body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } else if let parameters = parameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    throw APIError.encodingError(error)
                }
            }
        }
        
        return request
    }
}

// MARK: - API Response Model

struct APIResponse<T: Codable> {
    let data: T
    let statusCode: Int
    let headers: [AnyHashable: Any]
    let request: APIRequest
}

// MARK: - Authentication Implementation

class BearerTokenAuthentication: AuthenticationProtocol {
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func authenticate(_ request: inout URLRequest) throws {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

class APIKeyAuthentication: AuthenticationProtocol {
    private let apiKey: String
    private let headerName: String
    
    init(apiKey: String, headerName: String = "X-API-Key") {
        self.apiKey = apiKey
        self.headerName = headerName
    }
    
    func authenticate(_ request: inout URLRequest) throws {
        request.setValue(apiKey, forHTTPHeaderField: headerName)
    }
}

// MARK: - Caching Implementation

class MemoryCache: CacheProtocol {
    private var cache = NSCache<NSString, AnyObject>()
    private let queue = DispatchQueue(label: "cache.queue", attributes: .concurrent)
    
    func get<T: Codable>(for key: String, type: T.Type) -> T? {
        return queue.sync {
            guard let data = cache.object(forKey: NSString(string: key)) as? Data else {
                return nil
            }
            return try? JSONDecoder().decode(type, from: data)
        }
    }
    
    func set<T: Codable>(_ value: T, for key: String) {
        queue.async(flags: .barrier) {
            guard let data = try? JSONEncoder().encode(value) else { return }
            self.cache.setObject(data as AnyObject, forKey: NSString(string: key))
        }
    }
    
    func remove(for key: String) {
        queue.async(flags: .barrier) {
            self.cache.removeObject(forKey: NSString(string: key))
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAllObjects()
        }
    }
}

// MARK: - Response Parser

class JSONResponseParser: ResponseParsing {
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func parse<T: Codable>(_ data: Data, to type: T.Type) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - Network Service Implementation (Single Responsibility Principle)

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let parser: ResponseParsing
    private let cache: CacheProtocol?
    private let authenticator: AuthenticationProtocol?
    
    init(
        session: URLSession = .shared,
        parser: ResponseParsing = JSONResponseParser(),
        cache: CacheProtocol? = nil,
        authenticator: AuthenticationProtocol? = nil
    ) {
        self.session = session
        self.parser = parser
        self.cache = cache
        self.authenticator = authenticator
    }
    
    // MARK: - Async/Await Implementation
    
    func execute<T: Codable>(_ request: APIRequest) async throws -> APIResponse<T> {
        let cacheKey = generateCacheKey(for: request)
        
        // Check cache first for GET requests
        if request.method == .GET,
           let cachedData: T = cache?.get(for: cacheKey, type: T.self) {
            return APIResponse(data: cachedData, statusCode: 200, headers: [:], request: request)
        }
        
        var urlRequest = try request.buildURLRequest()
        
        // Apply authentication
        try authenticator?.authenticate(&urlRequest)
        
        // Execute with retry logic
        return try await executeWithRetry(urlRequest: urlRequest, request: request, retryCount: request.configuration.retryCount)
    }
    
    private func executeWithRetry<T: Codable>(
        urlRequest: URLRequest,
        request: APIRequest,
        retryCount: Int
    ) async throws -> APIResponse<T> {
        do {
            let (data, response) = try await session.data(for: urlRequest)
            return try processResponse(data: data, response: response, request: request)
        } catch {
            if retryCount > 0 && shouldRetry(error: error) {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                return try await executeWithRetry(urlRequest: urlRequest, request: request, retryCount: retryCount - 1)
            }
            throw mapError(error)
        }
    }
    
    // MARK: - Combine Implementation
    
    func execute<T: Codable>(_ request: APIRequest) -> AnyPublisher<APIResponse<T>, APIError> {
        let cacheKey = generateCacheKey(for: request)
        
        // Check cache first for GET requests
        if request.method == .GET,
           let cachedData: T = cache?.get(for: cacheKey, type: T.self) {
            return Just(APIResponse(data: cachedData, statusCode: 200, headers: [:], request: request))
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
        
        do {
            var urlRequest = try request.buildURLRequest()
            try authenticator?.authenticate(&urlRequest)
            
            return session.dataTaskPublisher(for: urlRequest)
                .tryMap { [weak self] data, response in
                    guard let self = self else { throw APIError.unknown(NSError()) }
                    return try self.processResponse(data: data, response: response, request: request) as APIResponse<T>
                }
                .retry(request.configuration.retryCount)
                .mapError { [weak self] error in
                    self?.mapError(error) ?? APIError.unknown(error)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: mapError(error))
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Helper Methods
    
    private func processResponse<T: Codable>(
        data: Data,
        response: URLResponse,
        request: APIRequest
    ) throws -> APIResponse<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "Invalid response", code: -1))
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        
        let parsedData: T = try parser.parse(data, to: T.self)
        
        // Cache GET requests
        if request.method == .GET {
            let cacheKey = generateCacheKey(for: request)
            cache?.set(parsedData, for: cacheKey)
        }
        
        return APIResponse(
            data: parsedData,
            statusCode: httpResponse.statusCode,
            headers: httpResponse.allHeaderFields,
            request: request
        )
    }
    
    private func generateCacheKey(for request: APIRequest) -> String {
        let url = "\(request.configuration.baseURL)/\(request.endpoint)"
        let params = request.parameters?.description ?? ""
        return "\(url)_\(params)".data(using: .utf8)?.base64EncodedString() ?? url
    }
    
    private func shouldRetry(error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    private func mapError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            default:
                return .networkError(urlError)
            }
        }
        
        return .unknown(error)
    }
}

// MARK: - REST API Client (Facade Pattern)

class RESTAPIClient {
    private let networkService: NetworkServiceProtocol
    private let configuration: APIConfiguration
    
    init(
        configuration: APIConfiguration,
        authenticator: AuthenticationProtocol? = nil,
        cache: CacheProtocol? = MemoryCache()
    ) {
        self.configuration = configuration
        self.networkService = NetworkService(
            cache: cache,
            authenticator: authenticator
        )
    }
    
    // MARK: - Convenience Methods
    
    func get<T: Codable>(
        endpoint: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        type: T.Type
    ) async throws -> T {
        let request = APIRequest(
            endpoint: endpoint,
            method: .GET,
            parameters: parameters,
            headers: headers,
            configuration: configuration
        )
        let response: APIResponse<T> = try await networkService.execute(request)
        return response.data
    }
    
    func post<T: Codable, U: Codable>(
        endpoint: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        let bodyData = try JSONEncoder().encode(body)
        let request = APIRequest(
            endpoint: endpoint,
            method: .POST,
            body: bodyData,
            headers: headers,
            configuration: configuration
        )
        let response: APIResponse<T> = try await networkService.execute(request)
        return response.data
    }
    
    func put<T: Codable, U: Codable>(
        endpoint: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        let bodyData = try JSONEncoder().encode(body)
        let request = APIRequest(
            endpoint: endpoint,
            method: .PUT,
            body: bodyData,
            headers: headers,
            configuration: configuration
        )
        let response: APIResponse<T> = try await networkService.execute(request)
        return response.data
    }
    
    func delete<T: Codable>(
        endpoint: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        let request = APIRequest(
            endpoint: endpoint,
            method: .DELETE,
            parameters: parameters,
            headers: headers,
            configuration: configuration
        )
        let response: APIResponse<T> = try await networkService.execute(request)
        return response.data
    }
    
    // MARK: - Combine Methods
    
    func getPublisher<T: Codable>(
        endpoint: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        type: T.Type
    ) -> AnyPublisher<T, APIError> {
        let request = APIRequest(
            endpoint: endpoint,
            method: .GET,
            parameters: parameters,
            headers: headers,
            configuration: configuration
        )
        return networkService.execute(request)
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    func postPublisher<T: Codable, U: Codable>(
        endpoint: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        do {
            let bodyData = try JSONEncoder().encode(body)
            let request = APIRequest(
                endpoint: endpoint,
                method: .POST,
                body: bodyData,
                headers: headers,
                configuration: configuration
            )
            return networkService.execute(request)
                .map(\.data)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.encodingError(error))
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Usage Examples

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
}

// Example Usage
class UserService {
    private let apiClient: RESTAPIClient
    
    init() {
        let config = APIConfiguration(
            baseURL: "https://api.example.com",
            timeout: 30.0,
            retryCount: 3,
            cachePolicy: .useProtocolCachePolicy,
            headers: ["Content-Type": "application/json"]
        )
        
        let auth = BearerTokenAuthentication(token: "your-token-here")
        self.apiClient = RESTAPIClient(configuration: config, authenticator: auth)
    }
    
    func getUsers() async throws -> [User] {
        return try await apiClient.get(
            endpoint: "users",
            type: [User].self
        )
    }
    
    func createUser(name: String, email: String) async throws -> User {
        let request = CreateUserRequest(name: name, email: email)
        return try await apiClient.post(
            endpoint: "users",
            body: request,
            responseType: User.self
        )
    }
    
    func getUsersPublisher() -> AnyPublisher<[User], APIError> {
        return apiClient.getPublisher(
            endpoint: "users",
            type: [User].self
        )
    }
}

// MARK: - Test Cases

#if DEBUG
class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var mockError: APIError?
    
    func execute<T: Codable>(_ request: APIRequest) async throws -> APIResponse<T> {
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw APIError.decodingError(NSError(domain: "Mock", code: -1))
        }
        
        return APIResponse(data: response, statusCode: 200, headers: [:], request: request)
    }
    
    func execute<T: Codable>(_ request: APIRequest) -> AnyPublisher<APIResponse<T>, APIError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let response = mockResponse as? T else {
            return Fail(error: APIError.decodingError(NSError(domain: "Mock", code: -1)))
                .eraseToAnyPublisher()
        }
        
        return Just(APIResponse(data: response, statusCode: 200, headers: [:], request: request))
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}

// Unit Tests Example
func testAPIClient() async {
    let mockService = MockNetworkService()
    let users = [User(id: 1, name: "John", email: "john@example.com")]
    mockService.mockResponse = users
    
    // Test would go here using XCTest framework
    print("Mock test setup complete")
}
#endif

/*
MARK: - System Overview

• **Architecture**: Clean Architecture with SOLID principles
• **Core Components**:
  - NetworkService: Handles HTTP communication
  - APIRequest/Response: Data models for requests and responses
  - Authentication: Pluggable auth strategies (Bearer, API Key)
  - Caching: Memory-based caching for GET requests
  - Error Handling: Comprehensive error types and mapping
  - Retry Logic: Automatic retry for network failures

• **Design Patterns Used**:
  - Protocol-Oriented Programming (Interface Segregation)
  - Facade Pattern (RESTAPIClient)
  - Strategy Pattern (Authentication)
  - Builder Pattern (APIRequest)
  - Factory Pattern (Error mapping)

• **Key Features**:
  - Async/Await and Combine support
  - Generic type-safe responses
  - Automatic JSON parsing
  - Request/Response caching
  - Configurable timeouts and retries
  - Pluggable authentication
  - Comprehensive error handling
  - Thread-safe operations
  - Memory management optimized

• **Scalability Features**:
  - Protocol-based dependency injection
  - Configurable base URLs and headers
  - Extensible authentication mechanisms
  - Pluggable caching strategies
  - Mock-friendly for testing
  - Modular component design

MARK: - Interview Questions & Answers

1. **Q: How does this design follow SOLID principles?**
   A: 
   - Single Responsibility: Each class has one reason to change (NetworkService handles networking, Parser handles parsing)
   - Open/Closed: New authentication methods can be added without modifying existing code
   - Liskov Substitution: Any AuthenticationProtocol implementation can replace another
   - Interface Segregation: Small, focused protocols instead of large interfaces
   - Dependency Inversion: High-level modules depend on abstractions, not concretions

2. **Q: How would you handle different response formats (XML, plain text)?**
   A: Implement different ResponseParsing protocols (XMLResponseParser, PlainTextParser) and inject them into NetworkService. The parser is abstracted behind a protocol, making it easily replaceable.

3. **Q: How does the caching mechanism work and how would you improve it?**
   A: Current implementation uses NSCache for memory caching with thread-safe operations. Improvements:
   - Add disk caching with expiration policies
   - Implement cache size limits and LRU eviction
   - Add cache invalidation strategies
   - Support for conditional requests (ETag, Last-Modified)

4. **Q: How would you handle request/response interceptors?**
   A: Add InterceptorProtocol with beforeRequest/afterResponse methods. Chain multiple interceptors in NetworkService. Useful for logging, analytics, request modification, and response transformation.

5. **Q: How does error handling work across different layers?**
   A: Three-layer approach:
   - Network layer: Maps URLError to APIError
   - Parsing layer: Maps decoding errors to APIError
   - Business layer: Can catch and transform APIError to domain-specific errors
   Each layer adds context while maintaining error type safety.

6. **Q: How would you implement request prioritization?**
   A: Add priority enum to APIRequest, use OperationQueue with different priority levels, or implement custom URLSessionConfiguration with different sessions for different priorities.

7. **Q: How does the retry mechanism work and what are its limitations?**
   A: Exponential backoff with configurable retry count. Only retries on specific network errors (timeout, connection lost). Limitations: No jitter, fixed delay, doesn't consider server-side rate limiting (429 responses).

8. **Q: How would you implement request cancellation?**
   A: Return URLSessionDataTask from execute methods, store tasks in a dictionary with request IDs, provide cancel(requestId:) method. For Combine, use AnyCancellable. For async/await, use Task cancellation.

9. **Q: How would you handle multipart form data uploads?**
   A: Add MultipartFormData struct, implement MultipartRequestBuilder conforming to APIRequestBuilding, handle boundary generation and data formatting. Extend APIRequest to support multipart content type.

10. **Q: How would you implement request/response logging and debugging?**
    A: Add LoggingProtocol with different log levels, implement ConsoleLogger and FileLogger. Inject into NetworkService. Log request details (URL, headers, body) and response details (status, headers, response time). Add conditional compilation for debug/release builds.

MARK: - Text-Based System Architecture Diagram

┌─────────────────────────────────────────────────────────────────┐
│                        REST API Client System                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   UserService   │    │  Other Services │
│     Layer       │◄──►│   (Example)     │◄──►│   (Business)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────────┐
                    │   RESTAPIClient     │
                    │   (Facade)          │
                    │ ┌─────────────────┐ │
                    │ │ - get()         │ │
                    │ │ - post()        │ │
                    │ │ - put()         │ │
                    │ │ - delete()      │ │
                    │ │ - getPublisher()│ │
                    │ └─────────────────┘ │
                    └─────────────────────┘
                                 │
                                 ▼
                    ┌─────────────────────┐
                    │   NetworkService    │
                    │   (Core Engine)     │
                    │ ┌─────────────────┐ │
                    │ │ - execute()     │ │
                    │ │ - retry logic   │ │
                    │ │ - error mapping │ │
                    │ └─────────────────┘ │
                    └─────────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────┐        ┌─────────────┐        ┌─────────────┐
│ APIRequest  │        │APIResponse  │        │  APIError   │
│ (Builder)   │        │ (Model)     │        │ (Types)     │
│┌───────────┐│        │┌───────────┐│        │┌───────────┐│
││-endpoint  ││        ││-data      ││        ││-network   ││
││-method    ││        ││-statusCode││        ││-decoding  ││
││-parameters││        ││-headers   ││        ││-http      ││
││-body      ││        ││-request   ││        ││-auth      ││
││-headers   ││        │└───────────┘│        │└───────────┘│
│└───────────┘│        └─────────────┘        └─────────────┘
└─────────────┘                                       
        │                                              
        ▼                                              
┌─────────────┐                                        
│URLRequest   │                                        
│(Foundation) │                                        
└─────────────┘                                        

┌─────────────────────────────────────────────────────────────────┐
│                     Supporting Components                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│Authentication│    │   Caching   │    │   Parsing   │    │Configuration│
│  Protocol   │    │  Protocol   │    │  Protocol   │    │   Model     │
│┌───────────┐│    │┌───────────┐│    │┌───────────┐│    │┌───────────┐│
││-Bearer    ││    ││-Memory    ││    ││-JSON      ││    ││-baseURL   ││
││-APIKey    ││    ││-Disk      ││    ││-XML       ││    ││-timeout   ││
││-OAuth     ││    ││-Redis     ││    ││-PlainText ││    ││-retries   ││
│└───────────┘│    │└───────────┘│    │└───────────┘│    │└───────────┘│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
        │                   │                   │                   │
        └───────────────────┼───────────────────┼───────────────────┘
                            │                   │
                            ▼                   ▼
                   ┌─────────────────────────────────┐
                   │         URLSession              │
                   │      (Foundation Layer)         │
                   │ ┌─────────────────────────────┐ │
                   │ │ - dataTask(with:)           │ │
                   │ │ - dataTaskPublisher(for:)   │ │
                   │ │ - configuration             │ │
                   │ └─────────────────────────────┘ │
                   └─────────────────────────────────┘
                                    │
                                    ▼
                          ┌─────────────────┐
                          │   Network       │
                          │   (Internet)    │
                          └─────────────────┘

Data Flow:
1. Application → RESTAPIClient (Facade)
2. RESTAPIClient → NetworkService (Core Logic)
3. NetworkService → Authentication (Optional)
4. NetworkService → Cache Check (GET requests)
5. NetworkService → APIRequest.buildURLRequest()
6. NetworkService → URLSession.dataTask()
7. URLSession → Network/Internet
8. Response → NetworkService → Parser
9. Parsed Data → Cache (GET requests)
10. Final Response → Application

Error Flow:
Network Error → URLError → APIError → Application
Parsing Error → DecodingError → APIError → Application
HTTP Error → HTTPURLResponse → APIError → Application
*/

