//
//  LLD-Example-2.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 26/08/25.
//

//Question:

/*
 Create a generic, reusable client to communicate with a REST API. It should handle different endpoints, HTTP methods, request bodies, and parse JSON responses.
*/

import Foundation
import Combine

// MARK: - 1. Core Protocols (Abstractions)

/// Defines the contract for a network service that can fetch data.
/// This allows for mocking and dependency injection.
protocol NetworkService {
    /// Fetches data for a given URL request.
    /// - Parameter request: The URLRequest to be executed.
    /// - Returns: A tuple containing the raw `Data` and the `URLResponse`.
    /// - Throws: An error if the network request fails.
    func requestData(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Defines the contract for a data parser.
/// This allows for different parsing strategies (e.g., JSON, XML).
protocol DataParser {
    /// Decodes data into a specified Decodable type.
    /// - Parameters:
    ///   - data: The raw data to be decoded.
    ///   - type: The `Decodable` type to decode into.
    /// - Returns: An instance of the specified type.
    /// - Throws: An error if decoding fails.
    func decode<T: Decodable>(_ data: Data) throws -> T
}


/// Defines the properties of a network request.
/// Conforming types will represent specific API endpoints.
protocol Request {
    /// The associated response model type, which must be Decodable.
    associatedtype ResponseType: Decodable

    /// The base URL of the API (e.g., "https://api.example.com").
    var baseURL: String { get }

    /// The path for the specific endpoint (e.g., "/users").
    var path: String { get }

    /// The HTTP method for the request (e.g., .get, .post).
    var method: HTTPMethod { get }

    /// The headers to be included in the request.
    var headers: [String: String]? { get }

    /// The parameters to be sent with the request.
    /// For GET requests, these are URL-encoded. For POST/PUT, they are in the body if `body` is nil.
    var parameters: [String: Any]? { get }
    
    /// The raw data to be sent as the request's body.
    /// If this is provided, it takes precedence over `parameters` for POST/PUT requests.
    var body: Data? { get }
}

// Provide a default implementation for `body` to make it optional for conforming types.
extension Request {
    var body: Data? { nil }
}

// MARK: - 2. Concrete Implementations

/// The production network service using URLSession.
final class URLSessionNetworkService: NetworkService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func requestData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
    }
}

/// The production data parser using JSONDecoder.
final class JSONParser: DataParser {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        // Configure the decoder as needed (e.g., date formatting strategies)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - 3. API Client (The Main Engine)

/// The generic client responsible for executing requests and handling responses.
final class APIClient {
    private let networkService: NetworkService
    private let dataParser: DataParser

    /// Initializes the APIClient with dependencies.
    /// - Parameters:
    ///   - networkService: The service to handle network calls. Defaults to URLSessionNetworkService.
    ///   - dataParser: The service to parse response data. Defaults to JSONParser.
    init(networkService: NetworkService = URLSessionNetworkService(),
         dataParser: DataParser = JSONParser()) {
        self.networkService = networkService
        self.dataParser = dataParser
    }

    /// Executes a request and returns the decoded response.
    /// This is the primary modern method using async/await.
    /// - Parameter request: The `Request` object describing the API call.
    /// - Returns: The decoded response model of `ResponseType`.
    /// - Throws: An `APIError` if any step in the process fails.
    func execute<R: Request>(_ request: R) async throws -> R.ResponseType {
        // 1. Build the URLRequest from the Request protocol
        let urlRequest = try buildURLRequest(from: request)

        // 2. Perform the network call
        let (data, response) = try await networkService.requestData(for: urlRequest)

        // 3. Validate the HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode, data: data)
        }

        // 4. Decode the data into the expected ResponseType
        let decodedObject: R.ResponseType = try dataParser.decode(data)
        
        return decodedObject
    }

    // Helper function to construct a URLRequest from a Request object.
    private func buildURLRequest<R: Request>(from request: R) throws -> URLRequest {
        guard let baseURL = URL(string: request.baseURL) else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: true)
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // Add headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Add parameters or body
        switch request.method {
        case .get, .delete:
            if let parameters = request.parameters {
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                urlRequest.url = components?.url
            }
        case .post, .put, .patch:
            // Prioritize the raw `body` data if it exists.
            if let body = request.body {
                urlRequest.httpBody = body
            } else if let parameters = request.parameters {
                // Fallback to serializing `parameters` dictionary.
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    throw APIError.encodingError(error)
                }
            }
        }
        
        return urlRequest
    }
}

// MARK: - 4. Supporting Enums and Structs

/// Enum for HTTP methods to ensure type safety.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Custom error type for the API client for clear, specific errors.
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case encodingError(Error)
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int, data: Data?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .encodingError(let error):
            return "Failed to encode the request body: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .serverError(let statusCode, _):
            return "Server error with status code: \(statusCode)."
        }
    }
}


// MARK: - 5. Example Usage

// Define a data model that conforms to Codable.
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

// Define a specific request by conforming to the Request protocol.
struct GetUsersRequest: Request {
    typealias ResponseType = [User] // We expect an array of Users

    var baseURL: String { "https://jsonplaceholder.typicode.com" }
    var path: String { "/users" }
    var method: HTTPMethod { .get }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
}

// A Codable struct for the request body, promoting type safety.
struct CreateUserPayload: Codable {
    let name: String
    let email: String
}

struct CreateUserRequest: Request {
    typealias ResponseType = User // We expect a single created User back

    private let payload: CreateUserPayload

    init(name: String, email: String) {
        self.payload = CreateUserPayload(name: name, email: email)
    }

    var baseURL: String { "https://jsonplaceholder.typicode.com" }
    var path: String { "/users" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil } // We use `body` instead.
    
    // Encode the Codable payload into Data for the request body.
    var body: Data? {
        try? JSONEncoder().encode(payload)
    }
}

// Example of how a ViewModel or service would use the APIClient.
@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?
    
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchUsers() async {
        let request = GetUsersRequest()
        do {
            self.users = try await apiClient.execute(request)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching users: \(error)")
        }
    }
    
    func createUser(name: String, email: String) async {
        let request = CreateUserRequest(name: name, email: email)
        do {
            let newUser = try await apiClient.execute(request)
            print("Successfully created user: \(newUser.name)")
            users.append(newUser) // Note: jsonplaceholder returns a dummy ID
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error creating user: \(error)")
        }
    }
}






/*
 ================================================================================
 Interview Questions & Answers
 ================================================================================

 Q1: How does this design promote testability, especially for the network layer which is notoriously hard to test?
 A1: This design promotes testability primarily through Dependency Injection and Protocol-Oriented Programming.
    - The `APIClient` depends on a `NetworkService` protocol, not a concrete `URLSession`. In our tests, we can inject a `MockNetworkService` that returns predefined data, errors, or responses without making actual network calls.
    - Similarly, the `Request` protocol and its concrete implementations can be tested in isolation to ensure they build correct URLs and encode parameters properly.
    - The `JSONParser` is also injected, allowing us to test parsing logic with mock data or even swap it out for a different parsing strategy if needed.

 Q2: Explain how the SOLID principles are applied in this architecture.
 A2:
    - Single Responsibility Principle (SRP): Each component has one job. `APIClient` handles the request execution lifecycle, `NetworkService` handles the network call, `Request` defines an endpoint, and `JSONParser` handles decoding.
    - Open/Closed Principle (OCP): The system is open for extension but closed for modification. We can add new API endpoints by creating new structs that conform to the `Request` protocol without changing the `APIClient` itself. We could also introduce a new parser (e.g., for XML) by creating a new class conforming to `DataParser` and injecting it.
    - Liskov Substitution Principle (LSP): Not directly applicable in this specific structure as we don't have a deep class hierarchy, but the use of protocols ensures that any conforming type can be substituted. For example, any object conforming to `NetworkService` can be used by `APIClient`.
    - Interface Segregation Principle (ISP): The protocols are lean and specific. `Request` only defines what's needed for an API call. `NetworkService` only defines the data fetching operation. We don't force a single, monolithic protocol on all components.
    - Dependency Inversion Principle (DIP): High-level modules (`APIClient`) depend on abstractions (`NetworkService`, `DataParser`), not on low-level concretions (`URLSessionNetworkService`, `JSONParser`). This decoupling is achieved through dependency injection.

 Q3: How would you handle API versioning (e.g., /api/v1/users vs /api/v2/users)?
 A3: The `Request` protocol's `baseURL` and `path` properties are perfect for this. We could have a global configuration for the base URL that includes the version (`https://api.example.com/v1`). A better, more flexible approach would be to make the version part of the `path`. We could create a `VersionedRequest` protocol that inherits from `Request` and adds a `version` property, which is then prepended to the `path` during URL construction. This allows different requests to target different API versions if needed.

 Q4: How would you add support for uploading a file (multipart/form-data)?
 A4: I would extend the `Request` protocol to include an optional property for multipart data, something like `var multipartData: [MultipartDataItem]?`. The `MultipartDataItem` struct would contain the data, name, filename, and MIME type.
    Then, the `URLSessionNetworkService` would need to be updated. When `multipartData` is present, instead of using `URLRequest`'s `httpBody`, it would construct a multipart body, set the appropriate `Content-Type` header (e.g., `multipart/form-data; boundary=...`), and use `URLSession.uploadTask(with:from:completionHandler:)`.

 Q5: How do you handle different environments (e.g., development, staging, production)?
 A5: The `baseURL` in the `Request` protocol is the key. I would create an `EnvironmentManager` or a similar configuration object that provides the correct base URL based on the current build configuration (e.g., using compiler flags like `-D DEBUG`). The `Request` implementations would then get their `baseURL` from this manager, ensuring that the app points to the correct backend for each environment without changing the request logic.

 Q6: What are the benefits of using a generic `APIClient.execute<T: Decodable>(request:completion:)` method?
 A6: The primary benefit is type safety and convenience.
    - Type Safety: The compiler enforces that the `T` you expect as a result is `Decodable`. The JSON parser will try to decode the response into this specific type. This catches potential mismatches between your data models and the API response at compile time.
    - Convenience: The caller doesn't need to manually parse the data and handle decoding errors. They simply provide the model type they expect (e.g., `User.self`), and the client handles the rest. This reduces boilerplate code significantly.
    - Reusability: The same `execute` method can be used for any `Decodable` model and any `Request`, making it highly reusable.

 Q7: How would you implement request cancellation?
 A7: The `URLSessionDataTask` returned by `URLSession.dataTask(with:completionHandler:)` can be cancelled by calling its `cancel()` method. To expose this, our `NetworkService` protocol's `requestData` method could return the `URLSessionDataTask?`. The `APIClient`'s `execute` method would then also return this task. The caller who initiates the request could hold onto this task and call `cancel()` on it when needed (e.g., when a view controller is deallocated before the request completes).

 Q8: How would you handle authentication, specifically OAuth2 tokens that need to be refreshed?
 A8: I would create a "Request Interceptor" or "Request Adapter" pattern. Before the `URLSessionNetworkService` sends a request, it would pass it to an `AuthAdapter`.
    - This adapter would check if an access token exists and add it to the `Authorization` header.
    - If a request fails with a 401 Unauthorized error, the `APIClient` would delegate this to a `TokenRefresher` component.
    - The `TokenRefresher` would perform the token refresh API call. Once a new token is obtained, it would automatically retry the original failed request. It would also need to handle queuing subsequent requests that arrive while a refresh is in progress to avoid multiple refresh calls.

 Q9: Why was `async/await` chosen over completion handlers in the primary `execute` method? What are the trade-offs?
 A9: The primary `execute` method uses `async/await` for modern concurrency, which offers better readability and error handling.
    - Benefits: It avoids the "pyramid of doom" (nested closures) and allows writing asynchronous code that looks sequential. Error handling is cleaner with `try/catch` blocks instead of checking an `error` parameter in a closure.
    - Trade-offs: It requires the client code to be in an `async` context. For older parts of a codebase that still use completion handlers, we've provided a backward-compatible `execute` method that takes a completion block. This ensures the client can be adopted incrementally.

 Q10: How could you add a caching layer to this client?
 A10: I would introduce a `CacheService` protocol and inject it into the `APIClient`.
    - Before making a network call, the `APIClient` would first check the `CacheService` for a valid, non-expired response for the given request. The request's URL could serve as the cache key.
    - If a cached response exists, it's returned immediately.
    - If not, the network call is made. Upon a successful response, the data is stored in the `CacheService` with an appropriate expiration policy (e.g., based on `Cache-Control` headers from the response).
    - The `CacheService` implementation could use `URLCache` for HTTP-level caching or a custom solution with `NSCache` or a database for more granular control. This would be another example of the Open/Closed Principle.
 ================================================================================
*/
