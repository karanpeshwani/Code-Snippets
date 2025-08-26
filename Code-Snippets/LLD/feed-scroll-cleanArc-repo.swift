//
//  LLD-Example-5.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 26/08/25.
//

import SwiftUI
import Combine
import Foundation

// MARK: - Domain Models (Following DDD and Clean Architecture)

/// Base protocol for all feed items - Open/Closed Principle
protocol FeedItem {
    var id: String { get }
    var timestamp: Date { get }
    var author: User { get }
    var type: FeedItemType { get }
}

/// Enum defining different types of feed items - Extensible design
enum FeedItemType: String, CaseIterable {
    case text = "text"
    case image = "image"
    case video = "video"
}

/// User model with essential properties
struct User {
    let id: String
    let username: String
    let displayName: String
    let avatarURL: String?
}

/// Text post implementation
struct TextPost: FeedItem {
    let id: String
    let timestamp: Date
    let author: User
    let type: FeedItemType = .text
    let content: String
    let likesCount: Int
    let commentsCount: Int
}

/// Image post implementation
struct ImagePost: FeedItem {
    let id: String
    let timestamp: Date
    let author: User
    let type: FeedItemType = .image
    let caption: String?
    let imageURL: String
    let likesCount: Int
    let commentsCount: Int
}

/// Video post implementation
struct VideoPost: FeedItem {
    let id: String
    let timestamp: Date
    let author: User
    let type: FeedItemType = .video
    let caption: String?
    let videoURL: String
    let thumbnailURL: String
    let duration: TimeInterval
    let likesCount: Int
    let commentsCount: Int
}

// MARK: - Use Cases (Business Logic Layer)

/// Protocol for feed use cases - Interface Segregation Principle
protocol FeedUseCaseProtocol {
    func loadInitialFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void)
    func loadMoreFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void)
    func refreshFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void)
}

/// Implementation of feed use cases
class FeedUseCase: FeedUseCaseProtocol {
    private let repository: FeedRepositoryProtocol
    private var currentPage = 0
    private let pageSize = 10
    
    init(repository: FeedRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadInitialFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        currentPage = 0
        repository.fetchFeedItems(page: currentPage, limit: pageSize, completion: completion)
    }
    
    func loadMoreFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        currentPage += 1
        repository.fetchFeedItems(page: currentPage, limit: pageSize, completion: completion)
    }
    
    func refreshFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        currentPage = 0
        repository.refreshFeed(completion: completion)
    }
}

// MARK: - View Model (Presentation Layer)

/// Feed view model following MVVM pattern
class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private let feedUseCase: FeedUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }
    
    func loadInitialFeed() {
        guard !isLoading else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        feedUseCase.loadInitialFeed { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.feedItems = items
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    func refreshFeed() {
        guard !isRefreshing else { return }
        
        DispatchQueue.main.async {
            self.isRefreshing = true
            self.errorMessage = nil
        }
        
        feedUseCase.refreshFeed { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.feedItems = items
                    self?.isRefreshing = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isRefreshing = false
                }
            }
        }
    }
    
    func loadMoreFeed() {
        guard !isLoadingMore else { return }
        
        DispatchQueue.main.async {
            self.isLoadingMore = true
        }
        
        feedUseCase.loadMoreFeed { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newItems):
                    self?.feedItems.append(contentsOf: newItems)
                    self?.isLoadingMore = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoadingMore = false
                }
            }
        }
    }
}

// MARK: - View Factory (Factory Pattern for Creating Views)

/// Factory for creating feed item views - Factory Pattern
struct FeedItemViewFactory {
    static func createView(for item: FeedItem) -> AnyView {
        switch item.type {
        case .text:
            if let textPost = item as? TextPost {
                return AnyView(TextPostView(post: textPost))
            }
        case .image:
            if let imagePost = item as? ImagePost {
                return AnyView(ImagePostView(post: imagePost))
            }
        case .video:
            if let videoPost = item as? VideoPost {
                return AnyView(VideoPostView(post: videoPost))
            }
        }
        return AnyView(EmptyView())
    }
}

// MARK: - SwiftUI Views

/// Main feed screen view
struct FeedView: View {
    @StateObject private var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.feedItems.isEmpty {
                    ProgressView("Loading feed...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    feedContentView
                }
            }
            .navigationTitle("Feed")
            .refreshable {
                viewModel.refreshFeed()
            }
            .onAppear {
                if viewModel.feedItems.isEmpty {
                    viewModel.loadInitialFeed()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var feedContentView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.feedItems, id: \.id) { item in
                    FeedItemViewFactory.createView(for: item)
                        .onAppear {
                            // Load more when reaching near the end
                            if item.id == viewModel.feedItems.last?.id {
                                viewModel.loadMoreFeed()
                            }
                        }
                }
                
                if viewModel.isLoadingMore {
                    ProgressView("Loading more...")
                        .padding()
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Text post view component
struct TextPostView: View {
    let post: TextPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PostHeaderView(user: post.author, timestamp: post.timestamp)
            
            Text(post.content)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            PostActionsView(likesCount: post.likesCount, commentsCount: post.commentsCount)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// Image post view component
struct ImagePostView: View {
    let post: ImagePost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PostHeaderView(user: post.author, timestamp: post.timestamp)
            
            if let caption = post.caption {
                Text(caption)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            
            AsyncImage(url: URL(string: post.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay(
                        ProgressView()
                    )
            }
            .cornerRadius(8)
            
            PostActionsView(likesCount: post.likesCount, commentsCount: post.commentsCount)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// Video post view component
struct VideoPostView: View {
    let post: VideoPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PostHeaderView(user: post.author, timestamp: post.timestamp)
            
            if let caption = post.caption {
                Text(caption)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            
            ZStack {
                AsyncImage(url: URL(string: post.thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            ProgressView()
                        )
                }
                .cornerRadius(8)
                
                // Play button overlay
                Button(action: {
                    // Handle video play action
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                // Duration indicator
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(formatDuration(post.duration))
                            .font(.caption)
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .padding(.trailing, 8)
                            .padding(.bottom, 8)
                    }
                }
            }
            
            PostActionsView(likesCount: post.likesCount, commentsCount: post.commentsCount)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Reusable post header component
struct PostHeaderView: View {
    let user: User
    let timestamp: Date
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatTimestamp(timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// Reusable post actions component
struct PostActionsView: View {
    let likesCount: Int
    let commentsCount: Int
    @State private var isLiked = false
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                isLiked.toggle()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .primary)
                    Text("\(likesCount + (isLiked ? 1 : 0))")
                        .font(.caption)
                }
            }
            
            Button(action: {
                // Handle comment action
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(commentsCount)")
                        .font(.caption)
                }
            }
            
            Button(action: {
                // Handle share action
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            
            Spacer()
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Dependency Injection Container

/// Simple DI container for managing dependencies
class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    // Network and Cache services
    lazy var networkService: NetworkServiceProtocol = NetworkService()
    lazy var cacheService: CacheServiceProtocol = CacheService()
    
    // Repository - Switch between Real and Mock implementations
    lazy var feedRepository: FeedRepositoryProtocol = {
        #if DEBUG
        // Use mock repository in debug builds for development
        return MockFeedRepository()
        #else
        // Use real repository in release builds
        return RealFeedRepository(networkService: networkService, cacheService: cacheService)
        #endif
    }()
    
    lazy var feedUseCase: FeedUseCaseProtocol = FeedUseCase(repository: feedRepository)
    
    func makeFeedViewModel() -> FeedViewModel {
        return FeedViewModel(feedUseCase: feedUseCase)
    }
    
    // Method to create real repository for testing or specific scenarios
    func makeRealFeedRepository() -> FeedRepositoryProtocol {
        return RealFeedRepository(networkService: networkService, cacheService: cacheService)
    }
}

// MARK: - App Entry Point

/// Main app structure
struct SocialFeedApp: App {
    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: DIContainer.shared.makeFeedViewModel())
        }
    }
}


// MARK: - Repository Pattern (Data Layer Abstraction)

/// Protocol for feed data repository - Dependency Inversion Principle
protocol FeedRepositoryProtocol {
    func fetchFeedItems(page: Int, limit: Int, completion: @escaping (Result<[FeedItem], Error>) -> Void)
    func refreshFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void)
}

// MARK: - Network Layer

/// Custom errors for network operations
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkFailure(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

/// Protocol for network service
protocol NetworkServiceProtocol {
    func fetchFeedItems(page: Int, limit: Int, completion: @escaping (Result<FeedResponse, NetworkError>) -> Void)
}

/// Network service implementation
class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://api.example.com/v1"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchFeedItems(page: Int, limit: Int, completion: @escaping (Result<FeedResponse, NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/feed?page=\(page)&limit=\(limit)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Add authentication headers if needed
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkFailure(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let feedResponse = try JSONDecoder().decode(FeedResponse.self, from: data)
                completion(.success(feedResponse))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

// MARK: - DTOs (Data Transfer Objects)

/// Response structure from API
struct FeedResponse: Codable {
    let items: [FeedItemDTO]
    let hasMore: Bool
    let nextPage: Int?
}

/// DTO for feed items from API
struct FeedItemDTO: Codable {
    let id: String
    let type: String
    let timestamp: String
    let author: UserDTO
    let content: String?
    let caption: String?
    let imageURL: String?
    let videoURL: String?
    let thumbnailURL: String?
    let duration: Double?
    let likesCount: Int
    let commentsCount: Int
}

/// DTO for user from API
struct UserDTO: Codable {
    let id: String
    let username: String
    let displayName: String
    let avatarURL: String?
}

// MARK: - Cache Layer

/// Protocol for cache service
protocol CacheServiceProtocol {
    func saveFeedItems(_ items: [FeedItem], for page: Int)
    func loadFeedItems(for page: Int) -> [FeedItem]?
    func clearCache()
    func getCacheTimestamp(for page: Int) -> Date?
}

/// Cache service implementation using UserDefaults (for simplicity)
/// In production, consider using Core Data, SQLite, or Realm
class CacheService: CacheServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let cacheKeyPrefix = "feed_cache_page_"
    private let timestampKeyPrefix = "feed_timestamp_page_"
    private let cacheExpiryInterval: TimeInterval = 300 // 5 minutes
    
    func saveFeedItems(_ items: [FeedItem], for page: Int) {
        let cacheKey = cacheKeyPrefix + "\(page)"
        let timestampKey = timestampKeyPrefix + "\(page)"
        
        // Convert FeedItem to cacheable format
        let cacheableItems = items.map { item -> [String: Any] in
            var dict: [String: Any] = [
                "id": item.id,
                "timestamp": item.timestamp.timeIntervalSince1970,
                "type": item.type.rawValue,
                "author": [
                    "id": item.author.id,
                    "username": item.author.username,
                    "displayName": item.author.displayName,
                    "avatarURL": item.author.avatarURL ?? ""
                ]
            ]
            
            // Add type-specific properties
            switch item {
            case let textPost as TextPost:
                dict["content"] = textPost.content
                dict["likesCount"] = textPost.likesCount
                dict["commentsCount"] = textPost.commentsCount
            case let imagePost as ImagePost:
                dict["caption"] = imagePost.caption ?? ""
                dict["imageURL"] = imagePost.imageURL
                dict["likesCount"] = imagePost.likesCount
                dict["commentsCount"] = imagePost.commentsCount
            case let videoPost as VideoPost:
                dict["caption"] = videoPost.caption ?? ""
                dict["videoURL"] = videoPost.videoURL
                dict["thumbnailURL"] = videoPost.thumbnailURL
                dict["duration"] = videoPost.duration
                dict["likesCount"] = videoPost.likesCount
                dict["commentsCount"] = videoPost.commentsCount
            default:
                break
            }
            
            return dict
        }
        
        userDefaults.set(cacheableItems, forKey: cacheKey)
        userDefaults.set(Date().timeIntervalSince1970, forKey: timestampKey)
    }
    
    func loadFeedItems(for page: Int) -> [FeedItem]? {
        let cacheKey = cacheKeyPrefix + "\(page)"
        let timestampKey = timestampKeyPrefix + "\(page)"
        
        // Check if cache is expired
        if let timestamp = userDefaults.object(forKey: timestampKey) as? TimeInterval {
            let cacheDate = Date(timeIntervalSince1970: timestamp)
            if Date().timeIntervalSince(cacheDate) > cacheExpiryInterval {
                return nil // Cache expired
            }
        } else {
            return nil // No timestamp found
        }
        
        guard let cacheableItems = userDefaults.array(forKey: cacheKey) as? [[String: Any]] else {
            return nil
        }
        
        return cacheableItems.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let timestampInterval = dict["timestamp"] as? TimeInterval,
                  let typeString = dict["type"] as? String,
                  let authorDict = dict["author"] as? [String: Any],
                  let authorId = authorDict["id"] as? String,
                  let username = authorDict["username"] as? String,
                  let displayName = authorDict["displayName"] as? String else {
                return nil
            }
            
            let avatarURL = authorDict["avatarURL"] as? String
            let author = User(id: authorId, username: username, displayName: displayName, 
                            avatarURL: avatarURL?.isEmpty == true ? nil : avatarURL)
            let timestamp = Date(timeIntervalSince1970: timestampInterval)
            
            switch typeString {
            case "text":
                guard let content = dict["content"] as? String,
                      let likesCount = dict["likesCount"] as? Int,
                      let commentsCount = dict["commentsCount"] as? Int else { return nil }
                return TextPost(id: id, timestamp: timestamp, author: author, 
                              content: content, likesCount: likesCount, commentsCount: commentsCount)
                
            case "image":
                guard let imageURL = dict["imageURL"] as? String,
                      let likesCount = dict["likesCount"] as? Int,
                      let commentsCount = dict["commentsCount"] as? Int else { return nil }
                let caption = dict["caption"] as? String
                return ImagePost(id: id, timestamp: timestamp, author: author, 
                               caption: caption?.isEmpty == true ? nil : caption, imageURL: imageURL, 
                               likesCount: likesCount, commentsCount: commentsCount)
                
            case "video":
                guard let videoURL = dict["videoURL"] as? String,
                      let thumbnailURL = dict["thumbnailURL"] as? String,
                      let duration = dict["duration"] as? Double,
                      let likesCount = dict["likesCount"] as? Int,
                      let commentsCount = dict["commentsCount"] as? Int else { return nil }
                let caption = dict["caption"] as? String
                return VideoPost(id: id, timestamp: timestamp, author: author, 
                               caption: caption?.isEmpty == true ? nil : caption, videoURL: videoURL, 
                               thumbnailURL: thumbnailURL, duration: duration, 
                               likesCount: likesCount, commentsCount: commentsCount)
                
            default:
                return nil
            }
        }
    }
    
    func clearCache() {
        let keys = userDefaults.dictionaryRepresentation().keys
        keys.forEach { key in
            if key.hasPrefix(cacheKeyPrefix) || key.hasPrefix(timestampKeyPrefix) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    func getCacheTimestamp(for page: Int) -> Date? {
        let timestampKey = timestampKeyPrefix + "\(page)"
        guard let timestamp = userDefaults.object(forKey: timestampKey) as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}

// MARK: - Real Repository Implementation

/// Real repository implementation with cache-first strategy
class RealFeedRepository: FeedRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    init(networkService: NetworkServiceProtocol, cacheService: CacheServiceProtocol) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    func fetchFeedItems(page: Int, limit: Int, completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        // Try cache first
        if let cachedItems = cacheService.loadFeedItems(for: page) {
            completion(.success(cachedItems))
            return
        }
        
        // Fallback to network
        networkService.fetchFeedItems(page: page, limit: limit) { [weak self] result in
            switch result {
            case .success(let feedResponse):
                let feedItems = self?.mapDTOsToFeedItems(feedResponse.items) ?? []
                // Cache the results
                self?.cacheService.saveFeedItems(feedItems, for: page)
                completion(.success(feedItems))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func refreshFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        // Clear cache and fetch fresh data
        cacheService.clearCache()
        fetchFeedItems(page: 0, limit: 10, completion: completion)
    }
    
    private func mapDTOsToFeedItems(_ dtos: [FeedItemDTO]) -> [FeedItem] {
        return dtos.compactMap { dto in
            let dateFormatter = ISO8601DateFormatter()
            let timestamp = dateFormatter.date(from: dto.timestamp) ?? Date()
            
            let author = User(
                id: dto.author.id,
                username: dto.author.username,
                displayName: dto.author.displayName,
                avatarURL: dto.author.avatarURL
            )
            
            switch dto.type.lowercased() {
            case "text":
                guard let content = dto.content else { return nil }
                return TextPost(
                    id: dto.id,
                    timestamp: timestamp,
                    author: author,
                    content: content,
                    likesCount: dto.likesCount,
                    commentsCount: dto.commentsCount
                )
                
            case "image":
                guard let imageURL = dto.imageURL else { return nil }
                return ImagePost(
                    id: dto.id,
                    timestamp: timestamp,
                    author: author,
                    caption: dto.caption,
                    imageURL: imageURL,
                    likesCount: dto.likesCount,
                    commentsCount: dto.commentsCount
                )
                
            case "video":
                guard let videoURL = dto.videoURL,
                      let thumbnailURL = dto.thumbnailURL,
                      let duration = dto.duration else { return nil }
                return VideoPost(
                    id: dto.id,
                    timestamp: timestamp,
                    author: author,
                    caption: dto.caption,
                    videoURL: videoURL,
                    thumbnailURL: thumbnailURL,
                    duration: duration,
                    likesCount: dto.likesCount,
                    commentsCount: dto.commentsCount
                )
                
            default:
                return nil
            }
        }
    }
}

/// Mock repository implementation for testing and development
class MockFeedRepository: FeedRepositoryProtocol {
    func fetchFeedItems(page: Int, limit: Int, completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
            let items = self.generateMockFeedItems(count: limit)
            completion(.success(items))
        }
    }
    
    func refreshFeed(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
            let items = self.generateMockFeedItems(count: 10)
            completion(.success(items))
        }
    }
    
    private func generateMockFeedItems(count: Int) -> [FeedItem] {
        let users = [
            User(id: "1", username: "john_doe", displayName: "John Doe", avatarURL: "https://example.com/avatar1.jpg"),
            User(id: "2", username: "jane_smith", displayName: "Jane Smith", avatarURL: "https://example.com/avatar2.jpg"),
            User(id: "3", username: "tech_guru", displayName: "Tech Guru", avatarURL: "https://example.com/avatar3.jpg")
        ]
        
        var items: [FeedItem] = []
        
        for i in 0..<count {
            let randomUser = users.randomElement()!
            let randomType = [FeedItemType.text, .image, .video].randomElement()!
            
            switch randomType {
            case .text:
                items.append(TextPost(
                    id: "text_\(i)",
                    timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400)),
                    author: randomUser,
                    content: "This is a sample text post #\(i). Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    likesCount: Int.random(in: 0...1000),
                    commentsCount: Int.random(in: 0...100)
                ))
            case .image:
                items.append(ImagePost(
                    id: "image_\(i)",
                    timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400)),
                    author: randomUser,
                    caption: "Beautiful image post #\(i)",
                    imageURL: "https://picsum.photos/400/300?random=\(i)",
                    likesCount: Int.random(in: 0...1000),
                    commentsCount: Int.random(in: 0...100)
                ))
            case .video:
                items.append(VideoPost(
                    id: "video_\(i)",
                    timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400)),
                    author: randomUser,
                    caption: "Amazing video content #\(i)",
                    videoURL: "https://example.com/video\(i).mp4",
                    thumbnailURL: "https://picsum.photos/400/300?random=\(i+100)",
                    duration: Double.random(in: 30...300),
                    likesCount: Int.random(in: 0...1000),
                    commentsCount: Int.random(in: 0...100)
                ))
            }
        }
        
        return items.sorted { $0.timestamp > $1.timestamp }
    }
}



/*
System Overview

Social Media Feed System - Low Level Design

Key Components & Architecture:
- Clean Architecture Implementation: 3-layer separation (Domain, Data, Presentation) with clear boundaries
- MVVM Pattern: SwiftUI views bind to ViewModels that coordinate with business logic
- Protocol-Oriented Design: Abstractions for Repository, UseCase, and FeedItem enable testability and flexibility
- Factory Pattern: FeedItemViewFactory creates appropriate views based on post types
- Dependency Injection: DIContainer manages object creation and dependencies
- Repository Pattern: Abstracts data access with protocol-based design for easy mocking/testing

Core Features:
- Multi-Type Posts: Text, Image, Video posts with extensible architecture
- Infinite Scrolling: Pagination with lazy loading and performance optimization
- Pull-to-Refresh: Native SwiftUI refresh functionality
- Async Image Loading: Built-in AsyncImage with placeholders and error handling
- Real-time UI Updates: Reactive programming with Combine and @Published properties
- Error Handling: Comprehensive error management across all layers
- Memory Optimization: LazyVStack for efficient rendering of large lists

SOLID Principles Implementation:
- Single Responsibility: Each class has one clear purpose (ViewModel handles UI state, UseCase handles business logic)
- Open/Closed: FeedItem protocol allows new post types without modifying existing code
- Liskov Substitution: All FeedItem implementations are interchangeable
- Interface Segregation: Focused protocols (FeedRepositoryProtocol, FeedUseCaseProtocol)
- Dependency Inversion: High-level modules depend on abstractions, not concretions

Performance & Scalability:
- Lazy Loading: Only renders visible items in LazyVStack
- Pagination: Limits memory usage and network requests
- Async Operations: All network calls are non-blocking
- Image Caching: AsyncImage provides built-in caching
- State Management: Efficient @Published property updates
*/


/*
 MARK: - 10 Comprehensive Interview Questions & Answers
 
 Q1: How did you implement the Open/Closed Principle in this feed system?
 A1: I implemented OCP through the FeedItem protocol which allows extending new post types (like PollPost, LivePost) without modifying existing code. The FeedItemViewFactory uses a switch statement that can easily accommodate new types, and each post type (TextPost, ImagePost, VideoPost) implements the protocol independently.
 
 Q2: Explain your approach to handling different post types and why you chose this pattern?
 A2: I used a combination of Protocol-Oriented Programming and Factory Pattern. The FeedItem protocol defines the contract, concrete types implement specific behavior, and FeedItemViewFactory creates appropriate views. This approach provides type safety, extensibility, and separation of concerns while avoiding massive if-else chains.
 
 Q3: How does your architecture support testability?
 A3: The architecture supports testability through:
 - Dependency Injection via protocols (FeedRepositoryProtocol, FeedUseCaseProtocol)
 - MockFeedRepository for testing without network calls
 - Separation of business logic in UseCases from UI logic in ViewModels
 - Pure functions and immutable data structures
 - Protocol-based design enabling easy mocking
 
 Q4: How would you handle memory management and performance optimization for large feeds?
 A4: Current optimizations include:
 - LazyVStack for efficient rendering of only visible items
 - AsyncImage for lazy image loading with placeholder
 - Pagination to limit memory usage
 - ObservableObject with @Published for efficient UI updates
 Additional optimizations: Image caching, view recycling, background threading for heavy operations, and data prefetching.
 
 Q5: Explain the data flow in your MVVM implementation?
 A5: Data flows as follows:
 View → ViewModel (user actions) → UseCase (business logic) → Repository (data access) → Network/Cache
 Response flows back: Repository → UseCase → ViewModel → View (UI updates)
 ViewModels use @Published properties for reactive UI updates, and all async operations are handled with proper error handling.
 
 Q6: How would you implement caching and offline support?
 A6: I would:
 - Create a CacheRepository implementing FeedRepositoryProtocol
 - Use Core Data or SQLite for persistent storage
 - Implement a CompositeRepository that tries cache first, then network
 - Add cache invalidation strategies (TTL, manual refresh)
 - Store images locally using URLCache or custom image cache
 - Implement sync mechanisms for when connectivity returns
 
 Q7: How does your error handling strategy work across layers?
 A7: Error handling follows a layered approach:
 - Repository layer: Throws specific domain errors (NetworkError, ParseError)
 - UseCase layer: Catches and transforms errors if needed
 - ViewModel layer: Catches errors and updates UI state (@Published errorMessage)
 - View layer: Displays error alerts and retry mechanisms
 Each layer handles appropriate concerns without leaking implementation details.
 
 Q8: How would you implement real-time updates (like new posts, likes)?
 A8: I would implement:
 - WebSocket connection in a separate RealTimeService
 - Event-driven architecture with Combine publishers
 - Update mechanisms that merge real-time data with existing feed
 - Optimistic UI updates for immediate feedback
 - Conflict resolution for simultaneous updates
 - Background app refresh for iOS background modes
 
 Q9: Explain your approach to infinite scrolling and pagination?
 A9: Implementation includes:
 - Page-based pagination in UseCase with currentPage tracking
 - Trigger loading when reaching last item in LazyVStack
 - Loading states (isLoadingMore) to prevent duplicate requests
 - Error handling for failed page loads
 - Smooth UX with loading indicators
 - Configurable page sizes for different network conditions
 
 Q10: How would you handle different screen sizes and accessibility?
 A10: For responsive design:
 - Use SwiftUI's adaptive layouts and size classes
 - Implement dynamic type support for text scaling
 - Add VoiceOver labels and hints for accessibility
 - Support dark mode with semantic colors
 - Test on different device sizes and orientations
 - Implement proper focus management for keyboard navigation
 - Add haptic feedback for better user experience
 */


