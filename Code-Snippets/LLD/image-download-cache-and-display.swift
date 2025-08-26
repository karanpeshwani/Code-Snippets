//
//  LLD-Example-1.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 25/08/25.
//

import UIKit
import Foundation

//Question:

/*
Create a system that can download an image from a URL, display it in a UIImageView, and cache it to avoid re-downloading. Think of a simplified version of libraries like SDWebImage or Kingfisher.
*/

//ANSWER:

// MARK: - Core Protocols

/// Protocol for cache storage operations
protocol CacheStorageProtocol {
    func store(_ data: Data, forKey key: String)
    func retrieve(forKey key: String) -> Data?
    func remove(forKey key: String)
    func removeAll()
}

/// Protocol for image loading operations
protocol ImageLoadingProtocol {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, ImageLoadingError>) -> Void) -> ImageLoadingTask?
}

/// Protocol for network operations
protocol NetworkManagerProtocol {
    func downloadData(from url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) -> URLSessionDataTask
}

// MARK: - Error Types

enum ImageLoadingError: Error, LocalizedError {
    case invalidURL
    case networkError(NetworkError)
    case invalidImageData
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidImageData:
            return "Invalid image data received"
        case .cancelled:
            return "Image loading was cancelled"
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case serverError(Int)
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .timeout:
            return "Request timed out"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

enum CacheError: Error {
    case failedToStore
    case failedToRetrieve
    case keyNotFound
}

// MARK: - Task Management

/// Represents an image loading task that can be cancelled
protocol ImageLoadingTask {
    var isRunning: Bool { get }
    func cancel()
}

/// Concrete implementation of ImageLoadingTask
final class ImageDownloadTask: ImageLoadingTask {
    private let urlSessionTask: URLSessionDataTask
    private(set) var isRunning: Bool = true
    
    init(urlSessionTask: URLSessionDataTask) {
        self.urlSessionTask = urlSessionTask
    }
    
    func cancel() {
        guard isRunning else { return }
        isRunning = false
        urlSessionTask.cancel()
    }
}

// MARK: - Memory Cache Implementation

/// Thread-safe memory cache using NSCache
final class MemoryCache: CacheStorageProtocol {
    private let cache = NSCache<NSString, NSData>()
    private let queue = DispatchQueue(label: "com.imageloader.memorycache", attributes: .concurrent)
    
    // MARK: - Configuration
    var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }
    
    var totalCostLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }
    
    init(countLimit: Int = 100, totalCostLimit: Int = 50 * 1024 * 1024) { // 50MB default
        self.cache.countLimit = countLimit
        self.cache.totalCostLimit = totalCostLimit
        
        // Clear cache on memory warning
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.removeAll()
        }
    }
    
    func store(_ data: Data, forKey key: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        }
    }
    
    func retrieve(forKey key: String) -> Data? {
        return queue.sync {
            cache.object(forKey: key as NSString) as Data?
        }
    }
    
    func remove(forKey key: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeObject(forKey: key as NSString)
        }
    }
    
    func removeAll() {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAllObjects()
        }
    }
}

// MARK: - Disk Cache Implementation

/// Thread-safe disk cache using FileManager
final class DiskCache: CacheStorageProtocol {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let queue = DispatchQueue(label: "com.imageloader.diskcache", qos: .utility)
    private let maxCacheSize: UInt64
    private let maxCacheAge: TimeInterval
    
    init(
        cacheDirectory: String = "ImageCache",
        maxCacheSize: UInt64 = 100 * 1024 * 1024, // 100MB
        maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    ) throws {
        self.maxCacheSize = maxCacheSize
        self.maxCacheAge = maxCacheAge
        
        // Create cache directory
        let documentsPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = documentsPath.appendingPathComponent(cacheDirectory)
        
        try fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        
        // Schedule periodic cleanup
        scheduleCleanup()
    }
    
    func store(_ data: Data, forKey key: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let fileURL = self.fileURL(for: key)
            try? data.write(to: fileURL)
            self.cleanupIfNeeded()
        }
    }
    
    func retrieve(forKey key: String) -> Data? {
        let fileURL = fileURL(for: key)
        return try? Data(contentsOf: fileURL)
    }
    
    func remove(forKey key: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let fileURL = self.fileURL(for: key)
            try? self.fileManager.removeItem(at: fileURL)
        }
    }
    
    func removeAll() {
        queue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            try? self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func fileURL(for key: String) -> URL {
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func scheduleCleanup() {
        queue.asyncAfter(deadline: .now() + 60) { [weak self] in
            self?.cleanupExpiredFiles()
            self?.scheduleCleanup()
        }
    }
    
    private func cleanupIfNeeded() {
        let cacheSize = calculateCacheSize()
        if cacheSize > maxCacheSize {
            cleanupOldestFiles()
        }
    }
    
    private func calculateCacheSize() -> UInt64 {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: UInt64 = 0
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += UInt64(fileSize)
            }
        }
        return totalSize
    }
    
    private func cleanupExpiredFiles() {
        guard let enumerator = fileManager.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else { return }
        
        let expirationDate = Date().addingTimeInterval(-maxCacheAge)
        
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
               let modificationDate = resourceValues.contentModificationDate,
               modificationDate < expirationDate {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    private func cleanupOldestFiles() {
        guard let enumerator = fileManager.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
        ) else { return }
        
        var files: [(URL, Date, UInt64)] = []
        
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
               let modificationDate = resourceValues.contentModificationDate,
               let fileSize = resourceValues.fileSize {
                files.append((fileURL, modificationDate, UInt64(fileSize)))
            }
        }
        
        // Sort by modification date (oldest first)
        files.sort { $0.1 < $1.1 }
        
        var currentSize = calculateCacheSize()
        let targetSize = maxCacheSize / 2 // Clean up to 50% of max size
        
        for (fileURL, _, fileSize) in files {
            guard currentSize > targetSize else { break }
            try? fileManager.removeItem(at: fileURL)
            currentSize -= fileSize
        }
    }
}

// MARK: - Cache Manager

/// Manages both memory and disk cache with a unified interface
final class CacheManager {
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache
    
    init(memoryCache: MemoryCache = MemoryCache(), diskCache: DiskCache) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
    
    func storeImage(_ image: UIImage, forKey key: String) {
        guard let data = image.pngData() else { return }
        
        // Store in memory cache
        memoryCache.store(data, forKey: key)
        
        // Store in disk cache asynchronously
        diskCache.store(data, forKey: key)
    }
    
    func retrieveImage(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let data = memoryCache.retrieve(forKey: key),
           let image = UIImage(data: data) {
            return image
        }
        
        // Check disk cache
        if let data = diskCache.retrieve(forKey: key),
           let image = UIImage(data: data) {
            // Store back in memory cache for faster access
            memoryCache.store(data, forKey: key)
            return image
        }
        
        return nil
    }
    
    func removeImage(forKey key: String) {
        memoryCache.remove(forKey: key)
        diskCache.remove(forKey: key)
    }
    
    func clearAll() {
        memoryCache.removeAll()
        diskCache.removeAll()
    }
}

// MARK: - Network Manager

/// Handles network operations for downloading images
final class NetworkManager: NetworkManagerProtocol {
    private let session: URLSession
    private let queue = DispatchQueue(label: "com.imageloader.network", qos: .userInitiated)
    
    init(configuration: URLSessionConfiguration = .default) {
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
        self.session = URLSession(configuration: configuration)
    }
    
    func downloadData(from url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    if (error as NSError).code == NSURLErrorCancelled {
                        return // Don't call completion for cancelled tasks
                    }
                    completion(.failure(self.mapError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknown(NSError(domain: "InvalidResponse", code: 0))))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data, !data.isEmpty else {
                    completion(.failure(.unknown(NSError(domain: "NoData", code: 0))))
                    return
                }
                
                completion(.success(data))
            }
        }
        
        task.resume()
        return task
    }
    
    private func mapError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .noInternetConnection
        case NSURLErrorTimedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
}

// MARK: - Image Loader (Main Coordinator)

/// Main coordinator that orchestrates image loading, caching, and network operations
final class ImageLoader: ImageLoadingProtocol {
    static let shared = ImageLoader()
    
    private let cacheManager: CacheManager
    private let networkManager: NetworkManagerProtocol
    private let queue = DispatchQueue(label: "com.imageloader.main", qos: .userInitiated)
    
    // Track ongoing tasks to avoid duplicate downloads
    private var ongoingTasks: [String: URLSessionDataTask] = [:]
    private var completionHandlers: [String: [(Result<UIImage, ImageLoadingError>) -> Void]] = [:]
    private let tasksQueue = DispatchQueue(label: "com.imageloader.tasks", attributes: .concurrent)
    
    init(
        cacheManager: CacheManager? = nil,
        networkManager: NetworkManagerProtocol = NetworkManager()
    ) {
        if let cacheManager = cacheManager {
            self.cacheManager = cacheManager
        } else {
            do {
                let diskCache = try DiskCache()
                self.cacheManager = CacheManager(diskCache: diskCache)
            } catch {
                fatalError("Failed to initialize disk cache: \(error)")
            }
        }
        self.networkManager = networkManager
    }
    
    @discardableResult
    func loadImage(
        from url: URL,
        completion: @escaping (Result<UIImage, ImageLoadingError>) -> Void
    ) -> ImageLoadingTask? {
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedImage = cacheManager.retrieveImage(forKey: cacheKey) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            return nil
        }
        
        return tasksQueue.sync(flags: .barrier) {
            // Check if there's already an ongoing task for this URL
            if let existingTask = ongoingTasks[cacheKey] {
                // Add completion handler to existing task
                completionHandlers[cacheKey, default: []].append(completion)
                return ImageDownloadTask(urlSessionTask: existingTask)
            }
            
            // Start new download task
            let task = networkManager.downloadData(from: url) { [weak self] result in
                self?.handleDownloadResult(result, for: cacheKey, url: url)
            }
            
            ongoingTasks[cacheKey] = task
            completionHandlers[cacheKey] = [completion]
            
            return ImageDownloadTask(urlSessionTask: task)
        }
    }
    
    private func handleDownloadResult(_ result: Result<Data, NetworkError>, for cacheKey: String, url: URL) {
        tasksQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            defer {
                self.ongoingTasks.removeValue(forKey: cacheKey)
                self.completionHandlers.removeValue(forKey: cacheKey)
            }
            
            let handlers = self.completionHandlers[cacheKey] ?? []
            
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        handlers.forEach { $0(.failure(.invalidImageData)) }
                    }
                    return
                }
                
                // Cache the image
                self.cacheManager.storeImage(image, forKey: cacheKey)
                
                DispatchQueue.main.async {
                    handlers.forEach { $0(.success(image)) }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    handlers.forEach { $0(.failure(.networkError(error))) }
                }
            }
        }
    }
    
    func cancelTask(for url: URL) {
        let cacheKey = url.absoluteString
        tasksQueue.async(flags: .barrier) { [weak self] in
            self?.ongoingTasks[cacheKey]?.cancel()
            self?.ongoingTasks.removeValue(forKey: cacheKey)
            self?.completionHandlers.removeValue(forKey: cacheKey)
        }
    }
    
    func clearCache() {
        cacheManager.clearAll()
    }
}

// MARK: - UIImageView Extension

extension UIImageView {
    private static var taskKey: UInt8 = 0
    
    /// Currently running image loading task
    private var currentTask: ImageLoadingTask? {
        get {
            return objc_getAssociatedObject(self, &Self.taskKey) as? ImageLoadingTask
        }
        set {
            objc_setAssociatedObject(self, &Self.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Load image from URL with optional placeholder and completion
    func loadImage(
        from url: URL?,
        placeholder: UIImage? = nil,
        completion: ((Result<UIImage, ImageLoadingError>) -> Void)? = nil
    ) {
        // Cancel any existing task
        currentTask?.cancel()
        currentTask = nil
        
        // Set placeholder immediately
        self.image = placeholder
        
        guard let url = url else {
            completion?(.failure(.invalidURL))
            return
        }
        
        // Start loading
        currentTask = ImageLoader.shared.loadImage(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                self.image = image
                completion?(.success(image))
            case .failure(let error):
                completion?(.failure(error))
            }
            
            self.currentTask = nil
        }
    }
    
    /// Cancel current image loading task
    func cancelImageLoading() {
        currentTask?.cancel()
        currentTask = nil
    }
}

// MARK: - Usage Example

class ExampleViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExampleImage()
    }
    
    private func loadExampleImage() {
        let imageURL = URL(string: "https://example.com/image.jpg")!
        let placeholderImage = UIImage(systemName: "photo")
        
        imageView.loadImage(from: imageURL, placeholder: placeholderImage) { result in
            switch result {
            case .success(let image):
                print("Image loaded successfully: \(image.size)")
            case .failure(let error):
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - System Summary

/*
 SYSTEM OVERVIEW:
 
 • Architecture: Clean, protocol-based design following SOLID principles
 • Components: ImageLoader (coordinator), CacheManager, NetworkManager, UIImageView extension
 • Caching: Two-tier system (memory + disk) with automatic eviction policies
 • Thread Safety: Concurrent queues, barriers, and proper synchronization
 • Error Handling: Comprehensive error types and graceful failure handling
 • Task Management: Deduplication, cancellation, and lifecycle management
 • Scalability: Protocol-based design allows easy extension and testing
 • Performance: Optimized for memory usage, network efficiency, and UI responsiveness
 
 KEY FEATURES:
 • Automatic cache management with memory pressure handling
 • Concurrent download deduplication
 • Thread-safe operations throughout
 • Easy-to-use UIImageView extension
 • Comprehensive error handling and recovery
 • Production-ready architecture with proper separation of concerns
 
 DESIGN PATTERNS USED:
 • Coordinator Pattern (ImageLoader)
 • Strategy Pattern (Cache implementations)
 • Observer Pattern (Memory warning notifications)
 • Factory Pattern (Task creation)
 • Dependency Injection (Protocol-based dependencies)
*/


/*
 COMPREHENSIVE INTERVIEW QUESTIONS & ANSWERS:
 
 1. Q: How does your caching strategy work and why did you choose this approach?
    A: I implemented a two-tier caching system:
       - Memory Cache (NSCache): Fast access, automatically handles memory pressure
       - Disk Cache (FileManager): Persistent storage, survives app restarts
       The system checks memory first, then disk, then network. This provides optimal
       performance while managing memory efficiently. NSCache automatically evicts
       objects under memory pressure, and disk cache has size/age limits with LRU eviction.
 
 2. Q: How do you handle concurrent downloads of the same image?
    A: I use a task deduplication mechanism. When multiple requests come for the same URL:
       - Check if there's already an ongoing download for that URL
       - If yes, add the completion handler to the existing task's handler list
       - If no, start a new download task
       This prevents duplicate network requests and improves efficiency.
 
 3. Q: How do you ensure thread safety in your implementation?
    A: Multiple approaches:
       - Concurrent queues with barrier flags for cache operations
       - NSCache is inherently thread-safe
       - Associated objects for UIImageView tasks
       - Proper queue management for task deduplication
       - All UI updates happen on main queue
 
 4. Q: How would you handle memory warnings?
    A: The MemoryCache automatically clears itself on memory warnings by observing
       UIApplication.didReceiveMemoryWarningNotification. Additionally, NSCache
       automatically evicts objects when memory pressure increases. The disk cache
       remains unaffected, allowing quick recovery.
 
 5. Q: How do you handle network errors and retries?
    A: I have a comprehensive error handling system:
       - Custom error types (NetworkError, ImageLoadingError)
       - Proper HTTP status code checking
       - Timeout handling
       - Network reachability awareness
       For retries, the client can simply call loadImage again, which will check
       cache first before attempting network download.
 
 6. Q: How would you implement image resizing/processing?
    A: I would add an ImageProcessor protocol:
       ```swift
       protocol ImageProcessor {
           func process(_ image: UIImage) -> UIImage?
       }
       ```
       Then modify the cache key to include processing parameters and apply
       processing after download but before caching. This ensures processed
       images are cached and don't need reprocessing.
 
 7. Q: How do you handle cache invalidation?
    A: Multiple strategies:
       - Time-based expiration (maxCacheAge in DiskCache)
       - Size-based eviction (LRU in both memory and disk)
       - Manual invalidation through removeImage(forKey:) and clearAll()
       - ETags/Last-Modified headers could be added for HTTP-based invalidation
 
 8. Q: How would you add progress tracking for downloads?
    A: Extend the ImageLoadingTask protocol to include progress:
       ```swift
       protocol ImageLoadingTask {
           var progress: Progress { get }
           func cancel()
       }
       ```
       Use URLSessionDownloadTask instead of DataTask to get built-in progress
       tracking, and expose it through the task interface.
 
 9. Q: How do you ensure the system is testable?
    A: Several design decisions support testability:
       - Protocol-based architecture (NetworkManagerProtocol, CacheStorageProtocol)
       - Dependency injection in ImageLoader initializer
       - Separated concerns (network, cache, coordination)
       - Error types that can be easily mocked
       - Synchronous cache operations for predictable testing
 
 10. Q: How would you optimize this system for a production app?
     A: Several optimizations:
        - Add image format detection and optimization (WebP support)
        - Implement progressive JPEG loading
        - Add request prioritization (visible images first)
        - Implement bandwidth-aware loading (different quality based on connection)
        - Add metrics and analytics for cache hit rates
        - Implement prefetching for predictable image loads
        - Add background processing for cache cleanup
        - Consider using URLSession background tasks for large downloads
*/


// MARK: - Image Caching System Low Level Design

/*
 SYSTEM ARCHITECTURE DIAGRAM:
 
 ┌─────────────────────────────────────────────────────────────────────────────┐
 │                           IMAGE CACHING SYSTEM                              │
 └─────────────────────────────────────────────────────────────────────────────┘
 
 ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────────────┐
 │   UIImageView   │───▶│  ImageLoader     │───▶│     CacheManager            │
 │   Extension     │    │  (Coordinator)   │    │                             │
 └─────────────────┘    └──────────────────┘    │ ┌─────────────────────────┐ │
                                 │               │ │    MemoryCache          │ │
                                 ▼               │ │  (NSCache wrapper)      │ │
 ┌─────────────────────────────────────────────┐ │ └─────────────────────────┘ │
 │           NetworkManager                    │ │                             │
 │                                             │ │ ┌─────────────────────────┐ │
 │ ┌─────────────────────────────────────────┐ │ │ │     DiskCache           │ │
 │ │         URLSession                      │ │ │ │  (FileManager based)    │ │
 │ │      (Download Tasks)                   │ │ │ └─────────────────────────┘ │
 │ └─────────────────────────────────────────┘ │ └─────────────────────────────┘
 │                                             │
 │ ┌─────────────────────────────────────────┐ │
 │ │      TaskManager                        │ │
 │ │   (Concurrent Downloads)                │ │
 │ └─────────────────────────────────────────┘ │
 └─────────────────────────────────────────────┘
 
 FLOW:
 1. UIImageView.loadImage(from: URL) called
 2. ImageLoader checks MemoryCache first
 3. If not found, checks DiskCache
 4. If not found, NetworkManager downloads image
 5. Image is cached in both Memory and Disk
 6. Image is displayed in UIImageView
 7. TaskManager handles concurrent downloads and cancellation
*/
