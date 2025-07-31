//
//  Network-Call.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 19/07/25.
//

import SwiftUI
import Combine

// MARK: - Model
// Represents the data structure of a single post from the API.
// Note the property names are camelCase (e.g., `userId`), but the API returns snake_case (e.g., "user_id").
// We will handle this using a JSONDecoder strategy.
struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// MARK: - Networking Service
// Defines a set of requirements for a networking service.
// Using a protocol allows us to easily swap out the real network service with a mock one for testing.
protocol NetworkServiceProtocol {
    func fetchPosts() -> AnyPublisher<[Post], NetworkError>
}

// Custom error enum to represent different networking failures.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .requestFailed(let error):
            return "The network request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode the server response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        }
    }
}

// The concrete implementation of our networking service.
class NetworkService: NetworkServiceProtocol {
    private var cancellables = Set<AnyCancellable>()
    private let postsURL = URL(string: "https://jsonplaceholder.typicode.com/posts")

    func fetchPosts() -> AnyPublisher<[Post], NetworkError> {
        guard let url = postsURL else {
            // If the URL is invalid, immediately fail with a custom error.
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        // Create a JSONDecoder and configure its key decoding strategy.
        // This tells the decoder to convert snake_case keys from the JSON (like "user_id")
        // to camelCase properties in our Swift model (like `userId`).
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Use URLSession's dataTaskPublisher to create a Combine publisher for the network request.
        return URLSession.shared.dataTaskPublisher(for: url)
            // `tryMap` allows us to inspect the output and potentially throw an error.
            // Here, we check for a successful HTTP status code.
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (output.response as? HTTPURLResponse)?.statusCode ?? 500
                    throw NetworkError.serverError(statusCode: statusCode)
                }
                return output.data
            }
            // Decode the received data into an array of `Post` objects using our configured decoder.
            .decode(type: [Post].self, decoder: decoder)
            // Map any decoding errors to our custom `decodingFailed` error.
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingFailed(error)
                } else {
                    return NetworkError.requestFailed(error)
                }
            }
            // Erase the publisher to a generic `AnyPublisher` to hide implementation details.
            .eraseToAnyPublisher()
    }
}


// MARK: - ViewModel
// Manages the state and business logic for the PostsView.
class PostsViewModel: ObservableObject {

    // @Published properties will automatically notify any observing SwiftUI views of changes.
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // We inject the network service as a dependency, which is great for testability.
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchPosts() {
        // Reset state before fetching
        self.isLoading = true
        self.errorMessage = nil

        networkService.fetchPosts()
            // Ensure UI updates are performed on the main thread.
            // This is crucial as networking happens on a background thread.
            .receive(on: DispatchQueue.main)
            // `sink` subscribes to the publisher's events (completion and value).
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    // The publisher finished successfully.
                    break
                case .failure(let error):
                    // The publisher failed. We update the error message.
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] fetchedPosts in
                // We successfully received and decoded the posts.
                self?.posts = fetchedPosts
            })
            // Store the subscription in `cancellables` to keep it alive.
            .store(in: &cancellables)
    }
}

// MARK: - View
// The SwiftUI view that displays the list of posts.
struct PostsView: View {

    // @StateObject ensures the ViewModel is created only once and its lifecycle is tied to the view.
    @StateObject private var viewModel: PostsViewModel

    // The view receives the ViewModel as a dependency.
    init(viewModel: PostsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Group {
                // Conditionally render the UI based on the ViewModel's state.
                if viewModel.isLoading {
                    ProgressView("Fetching posts...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            viewModel.fetchPosts()
                        }
                        .padding(.top)
                    }
                } else {
                    List(viewModel.posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.body)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Posts")
            .onAppear {
                // Fetch posts when the view first appears.
                if viewModel.posts.isEmpty {
                    viewModel.fetchPosts()
                }
            }
        }
    }
}

// MARK: - App Entry Point & Composition Root
// This is where we compose our application and inject dependencies.

//@main
//struct InterviewPrepApp: App {
//    var body: some Scene {
//        WindowGroup {
//            // Create the concrete network service and inject it into the ViewModel.
//            // The ViewModel is then passed to the View.
//            // This is known as Dependency Injection.
//            let networkService = NetworkService()
//            let viewModel = PostsViewModel(networkService: networkService)
//            PostsView(viewModel: viewModel)
//        }
//    }
//}


