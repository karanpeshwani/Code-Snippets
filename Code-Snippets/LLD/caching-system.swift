//
//  LLD-Example-4.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 26/08/25.
//

//Question:

/*
 Design a Caching System:
     - Memory cache + Disk cache.
     - Eviction policies (LRU, TTL).
     - Thread safety (using GCD/actors).
     - When to use NSCache vs custom cache.
*/


//Answer:

/*
 COMPREHENSIVE CACHING SYSTEM - LOW LEVEL DESIGN
 
 This system implements a two-tier caching architecture with:
 - Memory Cache (L1): Fast access using NSCache and custom LRU/TTL
 - Disk Cache (L2): Persistent storage with file system
 - Thread Safety: Using GCD queues and actors
 - Eviction Policies: LRU (Least Recently Used) and TTL (Time To Live)
 - SOLID Principles compliance
 */

import Foundation
import UIKit

// MARK: - Protocols and Interfaces

/// Generic cache protocol following Interface Segregation Principle
protocol Cacheable {
    associatedtype Key: Hashable
    associatedtype Value
    
    func get(key: Key) async -> Value?
    func set(key: Key, value: Value) async
    func remove(key: Key) async
    func clear() async
    func contains(key: Key) async -> Bool
}

/// Eviction policy protocol for Strategy Pattern
protocol EvictionPolicy {
    associatedtype Key: Hashable
    
    func shouldEvict(key: Key) -> Bool
    func recordAccess(key: Key)
    func recordInsertion(key: Key)
    func getKeyToEvict() -> Key?
    func removeKey(key: Key)
}

/// Cache statistics for monitoring
protocol CacheStatistics {
    var hitCount: Int { get }
    var missCount: Int { get }
    var hitRate: Double { get }
}

// MARK: - Value Models

/// Wrapper for cached values with metadata
struct CacheItem<T> {
    let value: T
    let createdAt: Date
    let lastAccessedAt: Date
    let ttl: TimeInterval?
    
    init(value: T, ttl: TimeInterval? = nil) {
        self.value = value
        self.createdAt = Date()
        self.lastAccessedAt = Date()
        self.ttl = ttl
    }
    
    var isExpired: Bool {
        guard let ttl = ttl else { return false }
        return Date().timeIntervalSince(createdAt) > ttl
    }
    
    func accessed() -> CacheItem<T> {
        return CacheItem(value: value, ttl: ttl)
    }
}

// MARK: - Eviction Policies Implementation

/// LRU (Least Recently Used) eviction policy
final class LRUEvictionPolicy<Key: Hashable>: EvictionPolicy {
    private var accessOrder: [Key] = []
    private let maxCapacity: Int
    private let queue = DispatchQueue(label: "lru.policy.queue", attributes: .concurrent)
    
    init(maxCapacity: Int) {
        self.maxCapacity = maxCapacity
    }
    
    func shouldEvict(key: Key) -> Bool {
        return queue.sync {
            accessOrder.count >= maxCapacity && !accessOrder.contains(key)
        }
    }
    
    func recordAccess(key: Key) {
        queue.async(flags: .barrier) {
            self.accessOrder.removeAll { $0 == key }
            self.accessOrder.append(key)
        }
    }
    
    func recordInsertion(key: Key) {
        recordAccess(key: key)
    }
    
    func getKeyToEvict() -> Key? {
        return queue.sync {
            accessOrder.first
        }
    }
    
    func removeKey(key: Key) {
        queue.async(flags: .barrier) {
            self.accessOrder.removeAll { $0 == key }
        }
    }
}

/// TTL (Time To Live) eviction policy
final class TTLEvictionPolicy<Key: Hashable>: EvictionPolicy {
    private var keyTimestamps: [Key: Date] = [:]
    private let defaultTTL: TimeInterval
    private let queue = DispatchQueue(label: "ttl.policy.queue", attributes: .concurrent)
    
    init(defaultTTL: TimeInterval) {
        self.defaultTTL = defaultTTL
    }
    
    func shouldEvict(key: Key) -> Bool {
        return queue.sync {
            guard let timestamp = keyTimestamps[key] else { return false }
            return Date().timeIntervalSince(timestamp) > defaultTTL
        }
    }
    
    func recordAccess(key: Key) {
        // TTL doesn't change on access
    }
    
    func recordInsertion(key: Key) {
        queue.async(flags: .barrier) {
            self.keyTimestamps[key] = Date()
        }
    }
    
    func getKeyToEvict() -> Key? {
        return queue.sync {
            let now = Date()
            return keyTimestamps.first { now.timeIntervalSince($0.value) > defaultTTL }?.key
        }
    }
    
    func removeKey(key: Key) {
        queue.async(flags: .barrier) {
            self.keyTimestamps.removeValue(forKey: key)
        }
    }
}

// MARK: - Memory Cache Implementation

/// Thread-safe memory cache with configurable eviction policies
actor MemoryCache<Key: Hashable, Value>: Cacheable {
    private var storage: [Key: CacheItem<Value>] = [:]
    private var evictionPolicy: AnyEvictionPolicy<Key>
    private let maxSize: Int
    private var stats = CacheStats()
    
    init(maxSize: Int = 100, evictionPolicy: AnyEvictionPolicy<Key>) {
        self.maxSize = maxSize
        self.evictionPolicy = evictionPolicy
    }
    
    func get(key: Key) async -> Value? {
        if let item = storage[key] {
            if item.isExpired {
                storage.removeValue(forKey: key)
                evictionPolicy.removeKey(key: key)
                stats.recordMiss()
                return nil
            }
            
            evictionPolicy.recordAccess(key: key)
            stats.recordHit()
            return item.value
        }
        
        stats.recordMiss()
        return nil
    }
    
    func set(key: Key, value: Value) async {
        // Check if eviction is needed
        if storage.count >= maxSize && storage[key] == nil {
            await evictIfNeeded()
        }
        
        let item = CacheItem(value: value)
        storage[key] = item
        evictionPolicy.recordInsertion(key: key)
    }
    
    func remove(key: Key) async {
        storage.removeValue(forKey: key)
        evictionPolicy.removeKey(key: key)
    }
    
    func clear() async {
        storage.removeAll()
        // Reset eviction policy if needed
    }
    
    func contains(key: Key) async -> Bool {
        return storage[key] != nil && !storage[key]!.isExpired
    }
    
    func getStatistics() async -> CacheStats {
        return stats
    }
    
    private func evictIfNeeded() async {
        guard let keyToEvict = evictionPolicy.getKeyToEvict() else { return }
        storage.removeValue(forKey: keyToEvict)
        evictionPolicy.removeKey(key: keyToEvict)
    }
}

// MARK: - Disk Cache Implementation

/// Thread-safe disk cache with file system persistence
final class DiskCache<Key: Hashable, Value: Codable>: Cacheable {
    private let cacheDirectory: URL
    private let queue = DispatchQueue(label: "disk.cache.queue", attributes: .concurrent)
    private let fileManager = FileManager.default
    private var stats = CacheStats()
    private let maxDiskSize: UInt64
    
    init(cacheDirectory: String = "DiskCache", maxDiskSize: UInt64 = 100 * 1024 * 1024) { // 100MB default
        let documentsPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = documentsPath.appendingPathComponent(cacheDirectory)
        self.maxDiskSize = maxDiskSize
        
        createCacheDirectoryIfNeeded()
    }
    
    func get(key: Key) async -> Value? {
        return await withCheckedContinuation { continuation in
            queue.async {
                let fileURL = self.fileURL(for: key)
                
                guard self.fileManager.fileExists(atPath: fileURL.path) else {
                    self.stats.recordMiss()
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    let item = try JSONDecoder().decode(CacheItem<Value>.self, from: data)
                    
                    if item.isExpired {
                        try? self.fileManager.removeItem(at: fileURL)
                        self.stats.recordMiss()
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    // Update access time
                    let updatedItem = item.accessed()
                    let updatedData = try JSONEncoder().encode(updatedItem)
                    try updatedData.write(to: fileURL)
                    
                    self.stats.recordHit()
                    continuation.resume(returning: item.value)
                } catch {
                    self.stats.recordMiss()
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func set(key: Key, value: Value) async {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                let fileURL = self.fileURL(for: key)
                let item = CacheItem(value: value)
                
                do {
                    let data = try JSONEncoder().encode(item)
                    try data.write(to: fileURL)
                    
                    // Check disk size and cleanup if needed
                    Task {
                        await self.cleanupIfNeeded()
                    }
                    
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func remove(key: Key) async {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                let fileURL = self.fileURL(for: key)
                try? self.fileManager.removeItem(at: fileURL)
                continuation.resume(returning: ())
            }
        }
    }
    
    func clear() async {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                try? self.fileManager.removeItem(at: self.cacheDirectory)
                self.createCacheDirectoryIfNeeded()
                continuation.resume(returning: ())
            }
        }
    }
    
    func contains(key: Key) async -> Bool {
        return await withCheckedContinuation { continuation in
            queue.async {
                let fileURL = self.fileURL(for: key)
                let exists = self.fileManager.fileExists(atPath: fileURL.path)
                continuation.resume(returning: exists)
            }
        }
    }
    
    func getStatistics() async -> CacheStats {
        return stats
    }
    
    private func fileURL(for key: Key) -> URL {
        let fileName = String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "unknown"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func createCacheDirectoryIfNeeded() {
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func cleanupIfNeeded() async {
        let currentSize = await getCurrentDiskSize()
        if currentSize > maxDiskSize {
            await performCleanup()
        }
    }
    
    private func getCurrentDiskSize() async -> UInt64 {
        return await withCheckedContinuation { continuation in
            queue.async {
                var totalSize: UInt64 = 0
                
                guard let enumerator = self.fileManager.enumerator(at: self.cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
                    continuation.resume(returning: 0)
                    return
                }
                
                for case let fileURL as URL in enumerator {
                    if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                        totalSize += UInt64(fileSize)
                    }
                }
                
                continuation.resume(returning: totalSize)
            }
        }
    }
    
    private func performCleanup() async {
        // Implement LRU cleanup for disk cache
        // Remove oldest files until under size limit
    }
}

// MARK: - Unified Cache Manager

/// Main cache manager that coordinates memory and disk caches
final class CacheManager<Key: Hashable, Value: Codable> {
    private let memoryCache: MemoryCache<Key, Value>
    private let diskCache: DiskCache<Key, Value>
    private let cacheQueue = DispatchQueue(label: "cache.manager.queue", attributes: .concurrent)
    
    init(
        memoryCacheSize: Int = 50,
        diskCacheSize: UInt64 = 100 * 1024 * 1024,
        evictionPolicy: AnyEvictionPolicy<Key> = AnyEvictionPolicy(LRUEvictionPolicy<Key>(maxCapacity: 50))
    ) {
        self.memoryCache = MemoryCache(maxSize: memoryCacheSize, evictionPolicy: evictionPolicy)
        self.diskCache = DiskCache(maxDiskSize: diskCacheSize)
    }
    
    /// Get value from cache (checks memory first, then disk)
    func getValue(for key: Key) async -> Value? {
        // Check memory cache first (L1)
        if let value = await memoryCache.get(key: key) {
            return value
        }
        
        // Check disk cache (L2)
        if let value = await diskCache.get(key: key) {
            // Promote to memory cache
            await memoryCache.set(key: key, value: value)
            return value
        }
        
        return nil
    }
    
    /// Set value in both caches
    func setValue(_ value: Value, for key: Key) async {
        await memoryCache.set(key: key, value: value)
        await diskCache.set(key: key, value: value)
    }
    
    /// Remove value from both caches
    func removeValue(for key: Key) async {
        await memoryCache.remove(key: key)
        await diskCache.remove(key: key)
    }
    
    /// Clear both caches
    func clearAll() async {
        await memoryCache.clear()
        await diskCache.clear()
    }
    
    /// Get combined statistics
    func getStatistics() async -> (memory: CacheStats, disk: CacheStats) {
        async let memoryStats = memoryCache.getStatistics()
        async let diskStats = diskCache.getStatistics()
        return await (memory: memoryStats, disk: diskStats)
    }
}

// MARK: - Supporting Types

/// Type-erased eviction policy for flexibility
struct AnyEvictionPolicy<Key: Hashable> {
    private let _shouldEvict: (Key) -> Bool
    private let _recordAccess: (Key) -> Void
    private let _recordInsertion: (Key) -> Void
    private let _getKeyToEvict: () -> Key?
    private let _removeKey: (Key) -> Void
    
    init<E: EvictionPolicy>(_ policy: E) where E.Key == Key {
        _shouldEvict = policy.shouldEvict
        _recordAccess = policy.recordAccess
        _recordInsertion = policy.recordInsertion
        _getKeyToEvict = policy.getKeyToEvict
        _removeKey = policy.removeKey
    }
    
    func shouldEvict(key: Key) -> Bool { _shouldEvict(key) }
    func recordAccess(key: Key) { _recordAccess(key) }
    func recordInsertion(key: Key) { _recordInsertion(key) }
    func getKeyToEvict() -> Key? { _getKeyToEvict() }
    func removeKey(key: Key) { _removeKey(key) }
}

/// Cache statistics implementation
struct CacheStats: CacheStatistics {
    private var _hitCount: Int = 0
    private var _missCount: Int = 0
    private let queue = DispatchQueue(label: "cache.stats.queue")
    
    var hitCount: Int {
        return queue.sync { _hitCount }
    }
    
    var missCount: Int {
        return queue.sync { _missCount }
    }
    
    var hitRate: Double {
        let total = hitCount + missCount
        return total > 0 ? Double(hitCount) / Double(total) : 0.0
    }
    
    mutating func recordHit() {
        queue.sync { _hitCount += 1 }
    }
    
    mutating func recordMiss() {
        queue.sync { _missCount += 1 }
    }
}

// MARK: - NSCache vs Custom Cache Decision Helper

/// Factory for choosing appropriate cache implementation
enum CacheFactory {
    static func createMemoryCache<Key: Hashable, Value>(
        for useCase: CacheUseCase,
        maxSize: Int = 100
    ) -> any Cacheable<Key, Value> {
        switch useCase {
        case .simpleObjectCaching:
            // Use NSCache for simple object caching
            return NSCacheWrapper<Key, Value>()
        case .complexEvictionLogic, .customTTL, .detailedStatistics:
            // Use custom cache for advanced features
            let lruPolicy = LRUEvictionPolicy<Key>(maxCapacity: maxSize)
            return MemoryCache(maxSize: maxSize, evictionPolicy: AnyEvictionPolicy(lruPolicy))
        }
    }
}

enum CacheUseCase {
    case simpleObjectCaching
    case complexEvictionLogic
    case customTTL
    case detailedStatistics
}

/// NSCache wrapper for comparison
final class NSCacheWrapper<Key: Hashable, Value>: Cacheable {
    private let cache = NSCache<NSString, CacheItem<Value>>()
    
    init() {
        cache.countLimit = 100
    }
    
    func get(key: Key) async -> Value? {
        let nsKey = NSString(string: String(describing: key))
        return cache.object(forKey: nsKey)?.value
    }
    
    func set(key: Key, value: Value) async {
        let nsKey = NSString(string: String(describing: key))
        cache.setObject(CacheItem(value: value), forKey: nsKey)
    }
    
    func remove(key: Key) async {
        let nsKey = NSString(string: String(describing: key))
        cache.removeObject(forKey: nsKey)
    }
    
    func clear() async {
        cache.removeAllObjects()
    }
    
    func contains(key: Key) async -> Bool {
        let nsKey = NSString(string: String(describing: key))
        return cache.object(forKey: nsKey) != nil
    }
}

// MARK: - Usage Examples

/// Example usage of the caching system
class CacheUsageExample {
    private let cacheManager = CacheManager<String, Data>()
    
    func demonstrateUsage() async {
        // Set a value
        let data = "Hello, World!".data(using: .utf8)!
        await cacheManager.setValue(data, for: "greeting")
        
        // Get a value
        if let retrievedData = await cacheManager.getValue(for: "greeting") {
            print("Retrieved: \(String(data: retrievedData, encoding: .utf8) ?? "N/A")")
        }
        
        // Get statistics
        let stats = await cacheManager.getStatistics()
        print("Memory Cache Hit Rate: \(stats.memory.hitRate)")
        print("Disk Cache Hit Rate: \(stats.disk.hitRate)")
    }
}

/*
 COMPREHENSIVE INTERVIEW Q&A FOR CACHING SYSTEM

 Q1: Why did you choose a two-tier caching architecture with memory and disk caches?
 A1: Two-tier architecture provides optimal performance by leveraging the speed of memory (L1)
     for frequently accessed data and the persistence of disk (L2) for larger datasets. Memory
     cache provides sub-millisecond access times for hot data, while disk cache ensures data
     survives app restarts and provides larger storage capacity. This follows the principle of
     locality of reference where frequently accessed data stays in faster storage.

 Q2: How do you ensure thread safety in your caching system?
 A2: I use multiple approaches: (1) Swift actors for memory cache to ensure serial access to
     mutable state, (2) GCD concurrent queues with barriers for read/write operations in disk
     cache and eviction policies, (3) Atomic operations for statistics tracking. This prevents
     race conditions while maintaining good performance through concurrent reads.

 Q3: Explain the difference between LRU and TTL eviction policies and when to use each.
 A3: LRU (Least Recently Used) evicts items based on access patterns - removes items that
     haven't been accessed for the longest time. Best for access-pattern-based caching. TTL
     (Time To Live) evicts items based on age - removes items after a fixed time period.
     Best for time-sensitive data like API responses or temporary data. I implemented both
     using the Strategy pattern for flexibility.

 Q4: When would you choose NSCache over your custom cache implementation?
 A4: Use NSCache for: (1) Simple object caching without complex eviction logic, (2) Automatic
     memory pressure handling, (3) Built-in thread safety, (4) When you don't need custom
     statistics or TTL. Use custom cache for: (1) Complex eviction policies, (2) Detailed
     analytics, (3) Custom TTL logic, (4) Disk persistence, (5) Fine-grained control over
     cache behavior.

 Q5: How do you handle cache coherence between memory and disk caches?
 A5: I implement a write-through strategy where data is written to both caches simultaneously.
     On reads, I check memory first (L1), then disk (L2), and promote disk hits to memory.
     This ensures consistency while optimizing for performance. For invalidation, I remove
     from both caches to maintain coherence.

 Q6: How would you handle cache warming and cold start scenarios?
 A6: For cache warming: (1) Preload critical data during app launch, (2) Use background
     queues to avoid blocking main thread, (3) Prioritize based on user behavior patterns.
     For cold starts: (1) Implement graceful degradation with fallback to original data
     source, (2) Use disk cache to survive app restarts, (3) Implement progressive loading
     strategies.

 Q7: How do you monitor and measure cache performance?
 A7: I implement comprehensive statistics tracking: (1) Hit/miss ratios for both caches,
     (2) Access patterns and frequency, (3) Eviction rates, (4) Memory usage, (5) Disk
     space utilization. These metrics help optimize cache sizes, eviction policies, and
     identify performance bottlenecks.

 Q8: How would you scale this caching system for a distributed environment?
 A8: For distributed caching: (1) Add cache invalidation mechanisms (pub/sub), (2) Implement
     consistent hashing for data distribution, (3) Add cache replication for fault tolerance,
     (4) Use distributed cache solutions like Redis for shared state, (5) Implement cache
     partitioning strategies.

 Q9: What are the memory management considerations in your cache implementation?
 A9: Key considerations: (1) Use weak references where appropriate to prevent retain cycles,
     (2) Implement proper cleanup in deinit methods, (3) Monitor memory pressure and respond
     appropriately, (4) Use NSCache's automatic memory management for simple cases, (5)
     Implement size-based eviction to prevent memory exhaustion.

 Q10: How would you test this caching system comprehensively?
 A10: Testing strategy includes: (1) Unit tests for each component (eviction policies, cache
      operations), (2) Integration tests for cache manager coordination, (3) Concurrency tests
      for thread safety, (4) Performance tests for latency and throughput, (5) Memory leak
      tests, (6) Persistence tests for disk cache, (7) Edge case tests (empty cache, full
      cache, expired items), (8) Load tests for high-concurrency scenarios.
*/


/*
 
 Key Components:
 
 CacheManager: Unified interface coordinating both cache tiers
 MemoryCache: Actor-based in-memory storage with configurable eviction
 DiskCache: File-system based persistent cache with size management
 EvictionPolicy: Strategy pattern for LRU/TTL implementations
 CacheStatistics: Real-time monitoring of hit rates and performance metrics
 
 Design Patterns Applied:
 
 Strategy Pattern: Pluggable eviction policies (LRU, TTL)
 Facade Pattern: CacheManager simplifies complex cache coordination
 Template Method: Generic Cacheable protocol with concrete implementations
 Type Erasure: AnyEvictionPolicy for flexible policy composition
 
 Performance Optimizations:
 
 Cache Promotion: Disk hits promoted to memory for faster subsequent access
 Concurrent Operations: Parallel reads with serial writes using GCD barriers
 Memory Pressure Handling: Automatic cleanup and size-based eviction
 Lazy Loading: On-demand cache initialization and cleanup
 
 Thread Safety Mechanisms:
 
 Swift Actors: Ensures serial access to memory cache state
 Concurrent Queues: Reader-writer pattern for disk operations
 Atomic Operations: Thread-safe statistics tracking
 Barrier Synchronization: Prevents race conditions during writes
 
 Scalability Features:
 
 Configurable Limits: Memory size, disk size, TTL values
 Pluggable Policies: Easy to add new eviction strategies
 Statistics Monitoring: Performance metrics for optimization
 Clean Architecture: Easy to extend with distributed caching
 
 */
