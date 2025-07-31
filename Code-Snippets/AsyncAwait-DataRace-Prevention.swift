//
//  AsyncAwait-DataRace-Prevention.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import SwiftUI

// MARK: - Basic Async/Await Examples
class AsyncAwaitBasics1 {
    
    // MARK: - Simple Async Function
    func fetchUserData() async throws -> UserData1 {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Simulate potential failure
        if Bool.random() {
            throw NetworkError1.serverError
        }
        
        return UserData1(id: 1, name: "John Doe", email: "john@example.com")
    }
    
    // MARK: - Multiple Async Calls (Sequential)
    func fetchUserProfileSequential() async throws -> UserProfile1 {
        print("🔄 Starting sequential fetch...")
        
        let userData = try await fetchUserData()
        let userPosts = try await fetchUserPosts(userId: userData.id)
        let userSettings = try await fetchUserSettings(userId: userData.id)
        
        print("✅ Sequential fetch completed")
        return UserProfile1(user: userData, posts: userPosts, settings: userSettings)
    }
    
    // MARK: - Multiple Async Calls (Concurrent)
    func fetchUserProfileConcurrent() async throws -> UserProfile1 {
        print("🚀 Starting concurrent fetch...")
        
        // These run concurrently
        async let userData = fetchUserData()
        async let userPosts = fetchUserPosts(userId: 1) // Assuming user ID
        async let userSettings = fetchUserSettings(userId: 1)
        
        // Wait for all to complete
        let profile = try await UserProfile1(
            user: userData,
            posts: userPosts,
            settings: userSettings
        )
        
        print("✅ Concurrent fetch completed")
        return profile
    }
    
    // MARK: - TaskGroup for Dynamic Concurrency
    func fetchMultipleUsersData(userIds: [Int]) async throws -> [UserData1] {
        return try await withThrowingTaskGroup(of: UserData1.self) { group in
            var users: [UserData1] = []
            
            // Add tasks to the group
            for userId in userIds {
                group.addTask {
                    return try await self.fetchUserDataById(userId)
                }
            }
            
            // Collect results
            for try await user in group {
                users.append(user)
            }
            
            return users
        }
    }
    
    // MARK: - Helper Functions
    private func fetchUserPosts(userId: Int) async throws -> [Post1] {
        try await Task.sleep(nanoseconds: 800_000_000)
        return [
            Post1(id: 1, title: "First Post", content: "Hello World"),
            Post1(id: 2, title: "Second Post", content: "Swift Concurrency")
        ]
    }
    
    private func fetchUserSettings(userId: Int) async throws -> UserSettings1 {
        try await Task.sleep(nanoseconds: 600_000_000)
        return UserSettings1(theme: "dark", notifications: true)
    }
    
    private func fetchUserDataById(_ id: Int) async throws -> UserData1 {
        try await Task.sleep(nanoseconds: 500_000_000)
        return UserData1(id: id, name: "User \(id)", email: "user\(id)@example.com")
    }
}

// MARK: - Data Models
struct UserData1: Codable {
    let id: Int
    let name: String
    let email: String
}

struct Post1: Codable {
    let id: Int
    let title: String
    let content: String
}

struct UserSettings1: Codable {
    let theme: String
    let notifications: Bool
}

struct UserProfile1 {
    let user: UserData1
    let posts: [Post1]
    let settings: UserSettings1
}

enum NetworkError1: Error {
    case serverError
    case noData
    case invalidResponse
}

// MARK: - Actor for Data Race Prevention
actor UserDataManager1 {
    private var userData: [Int: UserData1] = [:]
    private var accessCount = 0
    
    // Actor methods are automatically isolated
    func storeUser(_ user: UserData1) {
        userData[user.id] = user
        accessCount += 1
        print("👤 Stored user: \(user.name), Total accesses: \(accessCount)")
    }
    
    func getUser(id: Int) -> UserData1? {
        accessCount += 1
        print("🔍 Retrieved user ID: \(id), Total accesses: \(accessCount)")
        return userData[id]
    }
    
    func getAllUsers() -> [UserData1] {
        accessCount += 1
        return Array(userData.values)
    }
    
    func getUserCount() -> Int {
        return userData.count
    }
    
    // Async actor method
    func updateUserAsync(id: Int, name: String) async {
        // Simulate some async work
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        if var user = userData[id] {
            // Can't directly modify struct, need to replace
            let updatedUser = UserData1(id: user.id, name: name, email: user.email)
            userData[id] = updatedUser
            accessCount += 1
        }
    }
}

// MARK: - MainActor for UI Updates
@MainActor
class UserViewModel1: ObservableObject {
    @Published var users: [UserData1] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userManager = UserDataManager1()
    private let asyncBasics = AsyncAwaitBasics1()
    
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch users concurrently
            let userIds = [1, 2, 3, 4, 5]
            let fetchedUsers = try await asyncBasics.fetchMultipleUsersData(userIds: userIds)
            
            // Store in actor (thread-safe)
            for user in fetchedUsers {
                await userManager.storeUser(user)
            }
            
            // Update UI (already on MainActor)
            users = fetchedUsers
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addUser(name: String, email: String) async {
        let newUser = UserData1(
            id: Int.random(in: 1000...9999),
            name: name,
            email: email
        )
        
        await userManager.storeUser(newUser)
        
        // Update UI
        users.append(newUser)
    }
}

// MARK: - AsyncSequence Example
struct NetworkStream1: AsyncSequence {
    typealias Element = String
    
    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator()
    }
    
    struct AsyncIterator: AsyncIteratorProtocol {
        private var current = 0
        private let maxCount = 10
        
        mutating func next() async -> String? {
            guard current < maxCount else { return nil }
            
            // Simulate delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            current += 1
            return "Data chunk \(current)"
        }
    }
}

// MARK: - Async Stream for Real-time Data
class RealTimeDataProvider1 {
    
    func startDataStream() -> AsyncStream<String> {
        return AsyncStream { continuation in
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                let data = "Real-time data: \(Date().timeIntervalSince1970)"
                continuation.yield(data)
            }
            
            continuation.onTermination = { _ in
                timer.invalidate()
            }
        }
    }
    
    func startThrowingDataStream() -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            var counter = 0
            
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                counter += 1
                
                if counter > 5 {
                    continuation.finish(throwing: NetworkError1.serverError)
                    return
                }
                
                let data = "Stream data \(counter)"
                continuation.yield(data)
            }
            
            continuation.onTermination = { _ in
                timer.invalidate()
            }
        }
    }
}

// MARK: - Task Management and Cancellation
class TaskManager1 {
    private var currentTask: Task<Void, Never>?
    
    func startLongRunningTask() {
        currentTask = Task {
            for i in 1...100 {
                // Check for cancellation
                if Task.isCancelled {
                    print("❌ Task was cancelled at step \(i)")
                    return
                }
                
                print("🔄 Processing step \(i)/100")
                
                // Simulate work
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            
            print("✅ Long running task completed")
        }
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
        print("🛑 Task cancellation requested")
    }
}

// MARK: - Data Race Prevention Examples
class DataRaceExamples1 {
    
    // WRONG: This can cause data races
    private var unsafeCounter = 0
    
    // RIGHT: Using actor for thread safety
    private let safeCounterManager = SafeCounterManager1()
    
    func demonstrateUnsafeAccess() {
        print("=== Unsafe Access Demo (Don't do this!) ===")
        
        // This is unsafe - multiple tasks modifying the same variable
        for i in 1...10 {
            Task {
                unsafeCounter += 1
                print("Unsafe counter: \(unsafeCounter)")
            }
        }
    }
    
    func demonstrateSafeAccess() async {
        print("=== Safe Access Demo (Using Actor) ===")
        
        // This is safe - actor provides isolation
        await withTaskGroup(of: Void.self) { group in
            for i in 1...10 {
                group.addTask {
                    await self.safeCounterManager.increment()
                    let count = await self.safeCounterManager.getCount()
                    print("Safe counter: \(count)")
                }
            }
        }
    }
}

// MARK: - Safe Counter Actor
actor SafeCounterManager1 {
    private var counter = 0
    
    func increment() {
        counter += 1
    }
    
    func decrement() {
        counter -= 1
    }
    
    func getCount() -> Int {
        return counter
    }
    
    func reset() {
        counter = 0
    }
}

// MARK: - SwiftUI Integration
struct AsyncAwaitDemoView1: View {
    @StateObject private var viewModel = UserViewModel1()
    @State private var streamData: [String] = []
    @State private var isStreamActive = false
    
    private let dataProvider = RealTimeDataProvider1()
    private let taskManager = TaskManager1()
    
    var body: some View {
        NavigationView {
            List {
                Section("Users") {
                    if viewModel.isLoading {
                        ProgressView("Loading users...")
                    } else {
                        ForEach(viewModel.users, id: \.id) { user in
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Real-time Stream") {
                    ForEach(streamData.suffix(5), id: \.self) { data in
                        Text(data)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Async/Await Demo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isStreamActive ? "Stop Stream" : "Start Stream") {
                        toggleStream()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Load Users") {
                        Task {
                            await viewModel.loadUsers()
                        }
                    }
                }
            }
        }
        .task {
            // Automatically load users when view appears
            await viewModel.loadUsers()
        }
    }
    
    private func toggleStream() {
        if isStreamActive {
            isStreamActive = false
            // Stream will automatically stop when task is cancelled
        } else {
            isStreamActive = true
            Task {
                for await data in dataProvider.startDataStream() {
                    if !isStreamActive { break }
                    streamData.append(data)
                    
                    // Keep only last 20 items
                    if streamData.count > 20 {
                        streamData.removeFirst()
                    }
                }
            }
        }
    }
}

// MARK: - Advanced Async Patterns
class AdvancedAsyncPatterns1 {
    
    // MARK: - Async Property Wrapper
    @propertyWrapper
    struct AsyncLazy<T> {
        private let loader: () async throws -> T
        private var value: T?
        
        init(_ loader: @escaping () async throws -> T) {
            self.loader = loader
        }
        
        var wrappedValue: T {
            get async throws {
                if let value = value {
                    return value
                }
                
                let loadedValue = try await loader()
                self.value = loadedValue
                return loadedValue
            }
        }
    }
    
    // Usage of async property wrapper
    @AsyncLazy
    private var expensiveData = {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "Expensive data loaded"
    }
    
    func getExpensiveData() async throws -> String {
        return try await expensiveData
    }
    
    // MARK: - Retry Logic with Async
    func performWithRetry<T>(
        maxRetries: Int = 3,
        delay: TimeInterval = 1.0,
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                print("Attempt \(attempt) failed: \(error)")
                
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError!
    }
    
    // MARK: - Timeout Implementation
    func withTimeout<T>(
        _ duration: TimeInterval,
        operation: () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // Add the main operation
            group.addTask {
                try await operation()
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                throw TimeoutError.timeout
            }
            
            // Return first completed result
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

enum TimeoutError: Error {
    case timeout
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Async/Await Basics**:
    - async functions can be suspended and resumed
    - await keyword suspends execution until async operation completes
    - Replaces completion handlers with cleaner syntax
    - Automatic error propagation with try/await

 2. **Concurrency vs Parallelism**:
    - Sequential: await each operation one by one
    - Concurrent: async let for independent operations
    - TaskGroup for dynamic number of concurrent tasks
    - Structured concurrency ensures proper cleanup

 3. **Actors for Data Race Prevention**:
    - Actor isolates state from concurrent access
    - Only one task can access actor state at a time
    - Automatic synchronization without explicit locks
    - @MainActor for UI-related operations

 4. **Task Management**:
    - Task.sleep() for delays
    - Task.isCancelled for cancellation checking
    - Task cancellation is cooperative
    - Structured concurrency with TaskGroup

 5. **AsyncSequence & AsyncStream**:
    - AsyncSequence for asynchronous iteration
    - AsyncStream for creating custom async sequences
    - AsyncThrowingStream for error-throwing sequences
    - Real-time data streaming

 6. **Data Race Prevention**:
    - Actors prevent data races automatically
    - Sendable protocol for thread-safe types
    - Value types are inherently sendable
    - Reference types need careful consideration

 7. **Common Pitfalls**:
    - Blocking main thread with synchronous operations
    - Not handling cancellation properly
    - Creating retain cycles with async closures
    - Mixing old and new concurrency models

 8. **Performance Considerations**:
    - Use concurrent operations when possible
    - Avoid creating too many tasks
    - Consider task priority and QoS
    - Profile async code for bottlenecks

 9. **Common Interview Questions**:
    - Q: Difference between async/await and GCD?
    - A: async/await provides structured concurrency and better error handling
    
    - Q: How do actors prevent data races?
    - A: By ensuring exclusive access to their state
    
    - Q: When to use TaskGroup?
    - A: When you need dynamic number of concurrent operations
    
    - Q: How does cancellation work?
    - A: It's cooperative - tasks must check Task.isCancelled

 10. **Best Practices**:
     - Use MainActor for UI updates
     - Implement proper cancellation handling
     - Prefer structured concurrency over unstructured
     - Use actors for shared mutable state
     - Handle errors appropriately with try/await
     - Consider timeout for network operations
     - Test concurrent code thoroughly
*/ 