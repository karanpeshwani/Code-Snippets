//
//  XCTest-Advanced-Testing.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import XCTest
import Foundation
import UIKit

// MARK: - Test Models and Classes

// Simple model for testing
struct User3: Equatable, Codable {
    let id: Int
    let name: String
    let email: String
    let isActive: Bool
    
    init(id: Int, name: String, email: String, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.email = email
        self.isActive = isActive
    }
}

// Network service protocol for dependency injection
protocol NetworkServiceProtocol3 {
    func fetchUser(id: Int) async throws -> User3
    func createUser(_ user: User3) async throws -> User3
    func updateUser(_ user: User3) async throws -> User3
    func deleteUser(id: Int) async throws
}

// Real network service implementation
class NetworkService3: NetworkServiceProtocol3 {
    
    enum NetworkError: Error, Equatable {
        case invalidURL
        case noData
        case decodingError
        case serverError(Int)
    }
    
    func fetchUser(id: Int) async throws -> User3 {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Simulate different responses based on ID
        switch id {
        case 1:
            return User3(id: 1, name: "John Doe", email: "john@example.com")
        case 2:
            return User3(id: 2, name: "Jane Smith", email: "jane@example.com")
        case 404:
            throw NetworkError.serverError(404)
        default:
            throw NetworkError.noData
        }
    }
    
    func createUser(_ user: User3) async throws -> User3 {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Simulate validation
        guard !user.name.isEmpty, !user.email.isEmpty else {
            throw NetworkError.serverError(400)
        }
        
        return user
    }
    
    func updateUser(_ user: User3) async throws -> User3 {
        try await Task.sleep(nanoseconds: 300_000_000)
        return user
    }
    
    func deleteUser(id: Int) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        if id == 999 {
            throw NetworkError.serverError(404)
        }
    }
}

// User manager that depends on network service
class UserManager3 {
    private let networkService: NetworkServiceProtocol3
    private var cachedUsers: [Int: User3] = [:]
    
    init(networkService: NetworkServiceProtocol3) {
        self.networkService = networkService
    }
    
    func getUser(id: Int, useCache: Bool = true) async throws -> User3 {
        // Check cache first
        if useCache, let cachedUser = cachedUsers[id] {
            return cachedUser
        }
        
        let user = try await networkService.fetchUser(id: id)
        cachedUsers[id] = user
        return user
    }
    
    func createUser(name: String, email: String) async throws -> User3 {
        let newUser = User3(id: Int.random(in: 1000...9999), name: name, email: email)
        let createdUser = try await networkService.createUser(newUser)
        cachedUsers[createdUser.id] = createdUser
        return createdUser
    }
    
    func updateUser(_ user: User3) async throws -> User3 {
        let updatedUser = try await networkService.updateUser(user)
        cachedUsers[user.id] = updatedUser
        return updatedUser
    }
    
    func deleteUser(id: Int) async throws {
        try await networkService.deleteUser(id: id)
        cachedUsers.removeValue(forKey: id)
    }
    
    func clearCache() {
        cachedUsers.removeAll()
    }
    
    var cacheCount: Int {
        return cachedUsers.count
    }
}

// Calculator class for testing mathematical operations
class Calculator3 {
    
    enum CalculatorError: Error {
        case divisionByZero
        case overflow
        case invalidOperation
    }
    
    func add(_ a: Double, _ b: Double) -> Double {
        return a + b
    }
    
    func subtract(_ a: Double, _ b: Double) -> Double {
        return a - b
    }
    
    func multiply(_ a: Double, _ b: Double) -> Double {
        return a * b
    }
    
    func divide(_ a: Double, _ b: Double) throws -> Double {
        guard b != 0 else {
            throw CalculatorError.divisionByZero
        }
        return a / b
    }
    
    func power(_ base: Double, _ exponent: Int) throws -> Double {
        let result = pow(base, Double(exponent))
        guard result.isFinite else {
            throw CalculatorError.overflow
        }
        return result
    }
    
    func factorial(_ n: Int) throws -> Int {
        guard n >= 0 else {
            throw CalculatorError.invalidOperation
        }
        guard n <= 20 else {
            throw CalculatorError.overflow
        }
        
        if n <= 1 { return 1 }
        return n * (try factorial(n - 1))
    }
}

// MARK: - Mock Objects for Testing

// Mock network service for testing
class MockNetworkService3: NetworkServiceProtocol3 {
    
    // Properties to track method calls
    var fetchUserCallCount = 0
    var createUserCallCount = 0
    var updateUserCallCount = 0
    var deleteUserCallCount = 0
    
    var fetchUserIds: [Int] = []
    var createdUsers: [User3] = []
    var updatedUsers: [User3] = []
    var deletedUserIds: [Int] = []
    
    // Properties to control mock behavior
    var shouldThrowError = false
    var errorToThrow: Error = NetworkService3.NetworkError.serverError(500)
    var fetchUserDelay: TimeInterval = 0
    
    func fetchUser(id: Int) async throws -> User3 {
        fetchUserCallCount += 1
        fetchUserIds.append(id)
        
        if fetchUserDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(fetchUserDelay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return User3(id: id, name: "Mock User \(id)", email: "mock\(id)@example.com")
    }
    
    func createUser(_ user: User3) async throws -> User3 {
        createUserCallCount += 1
        createdUsers.append(user)
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return user
    }
    
    func updateUser(_ user: User3) async throws -> User3 {
        updateUserCallCount += 1
        updatedUsers.append(user)
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return user
    }
    
    func deleteUser(id: Int) async throws {
        deleteUserCallCount += 1
        deletedUserIds.append(id)
        
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    func reset() {
        fetchUserCallCount = 0
        createUserCallCount = 0
        updateUserCallCount = 0
        deleteUserCallCount = 0
        
        fetchUserIds.removeAll()
        createdUsers.removeAll()
        updatedUsers.removeAll()
        deletedUserIds.removeAll()
        
        shouldThrowError = false
        fetchUserDelay = 0
    }
}

// MARK: - Unit Tests

class CalculatorTests3: XCTestCase {
    
    var calculator: Calculator3!
    
    // MARK: - Test Lifecycle
    override func setUp() {
        super.setUp()
        calculator = Calculator3()
        print("🧪 Setting up Calculator test")
    }
    
    override func tearDown() {
        calculator = nil
        print("🧹 Tearing down Calculator test")
        super.tearDown()
    }
    
    // MARK: - Basic Arithmetic Tests
    func testAddition() {
        // Given
        let a = 5.0
        let b = 3.0
        let expected = 8.0
        
        // When
        let result = calculator.add(a, b)
        
        // Then
        XCTAssertEqual(result, expected, accuracy: 0.001, "Addition should work correctly")
    }
    
    func testSubtraction() {
        // Given
        let a = 10.0
        let b = 4.0
        let expected = 6.0
        
        // When
        let result = calculator.subtract(a, b)
        
        // Then
        XCTAssertEqual(result, expected, accuracy: 0.001)
    }
    
    func testMultiplication() {
        // Given
        let a = 6.0
        let b = 7.0
        let expected = 42.0
        
        // When
        let result = calculator.multiply(a, b)
        
        // Then
        XCTAssertEqual(result, expected, accuracy: 0.001)
    }
    
    func testDivision() throws {
        // Given
        let a = 15.0
        let b = 3.0
        let expected = 5.0
        
        // When
        let result = try calculator.divide(a, b)
        
        // Then
        XCTAssertEqual(result, expected, accuracy: 0.001)
    }
    
    func testDivisionByZero() {
        // Given
        let a = 10.0
        let b = 0.0
        
        // When & Then
        XCTAssertThrowsError(try calculator.divide(a, b)) { error in
            XCTAssertEqual(error as? Calculator3.CalculatorError, .divisionByZero)
        }
    }
    
    // MARK: - Edge Cases
    func testPowerOperation() throws {
        // Test positive exponent
        let result1 = try calculator.power(2.0, 3)
        XCTAssertEqual(result1, 8.0, accuracy: 0.001)
        
        // Test zero exponent
        let result2 = try calculator.power(5.0, 0)
        XCTAssertEqual(result2, 1.0, accuracy: 0.001)
        
        // Test negative base
        let result3 = try calculator.power(-2.0, 2)
        XCTAssertEqual(result3, 4.0, accuracy: 0.001)
    }
    
    func testPowerOverflow() {
        // This should throw overflow error
        XCTAssertThrowsError(try calculator.power(10.0, 1000)) { error in
            XCTAssertEqual(error as? Calculator3.CalculatorError, .overflow)
        }
    }
    
    func testFactorial() throws {
        // Test basic factorial
        let result1 = try calculator.factorial(5)
        XCTAssertEqual(result1, 120)
        
        // Test edge case: 0! = 1
        let result2 = try calculator.factorial(0)
        XCTAssertEqual(result2, 1)
        
        // Test edge case: 1! = 1
        let result3 = try calculator.factorial(1)
        XCTAssertEqual(result3, 1)
    }
    
    func testFactorialInvalidInput() {
        // Negative number should throw error
        XCTAssertThrowsError(try calculator.factorial(-1)) { error in
            XCTAssertEqual(error as? Calculator3.CalculatorError, .invalidOperation)
        }
        
        // Too large number should throw overflow
        XCTAssertThrowsError(try calculator.factorial(25)) { error in
            XCTAssertEqual(error as? Calculator3.CalculatorError, .overflow)
        }
    }
}

// MARK: - Async Tests with Mocking
class UserManagerTests3: XCTestCase {
    
    var userManager: UserManager3!
    var mockNetworkService: MockNetworkService3!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService3()
        userManager = UserManager3(networkService: mockNetworkService)
        print("🧪 Setting up UserManager test with mock")
    }
    
    override func tearDown() {
        userManager = nil
        mockNetworkService = nil
        print("🧹 Tearing down UserManager test")
        super.tearDown()
    }
    
    // MARK: - Async Testing
    func testFetchUserSuccess() async throws {
        // Given
        let userId = 1
        
        // When
        let user = try await userManager.getUser(id: userId)
        
        // Then
        XCTAssertEqual(user.id, userId)
        XCTAssertEqual(user.name, "Mock User 1")
        XCTAssertEqual(mockNetworkService.fetchUserCallCount, 1)
        XCTAssertEqual(mockNetworkService.fetchUserIds, [userId])
    }
    
    func testFetchUserWithCaching() async throws {
        // Given
        let userId = 1
        
        // When - First call
        let user1 = try await userManager.getUser(id: userId)
        
        // When - Second call (should use cache)
        let user2 = try await userManager.getUser(id: userId, useCache: true)
        
        // Then
        XCTAssertEqual(user1.id, user2.id)
        XCTAssertEqual(mockNetworkService.fetchUserCallCount, 1, "Should only call network service once due to caching")
        XCTAssertEqual(userManager.cacheCount, 1)
    }
    
    func testFetchUserWithoutCaching() async throws {
        // Given
        let userId = 1
        
        // When - First call
        _ = try await userManager.getUser(id: userId)
        
        // When - Second call without cache
        _ = try await userManager.getUser(id: userId, useCache: false)
        
        // Then
        XCTAssertEqual(mockNetworkService.fetchUserCallCount, 2, "Should call network service twice when cache is disabled")
    }
    
    func testFetchUserFailure() async {
        // Given
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = NetworkService3.NetworkError.serverError(404)
        
        // When & Then
        do {
            _ = try await userManager.getUser(id: 1)
            XCTFail("Should have thrown an error")
        } catch let error as NetworkService3.NetworkError {
            XCTAssertEqual(error, .serverError(404))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCreateUser() async throws {
        // Given
        let name = "New User"
        let email = "new@example.com"
        
        // When
        let createdUser = try await userManager.createUser(name: name, email: email)
        
        // Then
        XCTAssertEqual(createdUser.name, name)
        XCTAssertEqual(createdUser.email, email)
        XCTAssertEqual(mockNetworkService.createUserCallCount, 1)
        XCTAssertEqual(userManager.cacheCount, 1, "Created user should be cached")
    }
    
    func testUpdateUser() async throws {
        // Given
        let originalUser = User3(id: 1, name: "Original", email: "original@example.com")
        let updatedUser = User3(id: 1, name: "Updated", email: "updated@example.com")
        
        // When
        let result = try await userManager.updateUser(updatedUser)
        
        // Then
        XCTAssertEqual(result.name, "Updated")
        XCTAssertEqual(mockNetworkService.updateUserCallCount, 1)
        XCTAssertEqual(mockNetworkService.updatedUsers.first?.name, "Updated")
    }
    
    func testDeleteUser() async throws {
        // Given
        let userId = 1
        
        // First, add user to cache
        _ = try await userManager.getUser(id: userId)
        XCTAssertEqual(userManager.cacheCount, 1)
        
        // When
        try await userManager.deleteUser(id: userId)
        
        // Then
        XCTAssertEqual(mockNetworkService.deleteUserCallCount, 1)
        XCTAssertEqual(mockNetworkService.deletedUserIds, [userId])
        XCTAssertEqual(userManager.cacheCount, 0, "User should be removed from cache")
    }
    
    func testClearCache() async throws {
        // Given - Add multiple users to cache
        _ = try await userManager.getUser(id: 1)
        _ = try await userManager.getUser(id: 2)
        XCTAssertEqual(userManager.cacheCount, 2)
        
        // When
        userManager.clearCache()
        
        // Then
        XCTAssertEqual(userManager.cacheCount, 0)
    }
}

// MARK: - Performance Tests
class PerformanceTests3: XCTestCase {
    
    var calculator: Calculator3!
    
    override func setUp() {
        super.setUp()
        calculator = Calculator3()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    func testCalculatorPerformance() {
        // Measure performance of basic operations
        measure {
            for i in 1...1000 {
                let result = calculator.add(Double(i), Double(i * 2))
                _ = calculator.multiply(result, 0.5)
            }
        }
    }
    
    func testFactorialPerformance() {
        measure {
            for i in 1...10 {
                _ = try? calculator.factorial(i)
            }
        }
    }
    
    func testAsyncNetworkPerformance() {
        let mockService = MockNetworkService3()
        mockService.fetchUserDelay = 0.01 // 10ms delay
        let userManager = UserManager3(networkService: mockService)
        
        measure {
            let expectation = expectation(description: "Async performance test")
            
            Task {
                for i in 1...10 {
                    _ = try? await userManager.getUser(id: i, useCache: false)
                }
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5.0)
        }
    }
}

// MARK: - Test Utilities and Helpers
class TestUtilities3 {
    
    // Helper to create test users
    static func createTestUser(id: Int = 1, name: String = "Test User", email: String = "test@example.com") -> User3 {
        return User3(id: id, name: name, email: email)
    }
    
    // Helper to create multiple test users
    static func createTestUsers(count: Int) -> [User3] {
        return (1...count).map { i in
            createTestUser(id: i, name: "User \(i)", email: "user\(i)@example.com")
        }
    }
    
    // Helper for async testing with timeout
    static func waitForAsync<T>(
        timeout: TimeInterval = 5.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TestError.timeout
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    enum TestError: Error {
        case timeout
    }
}

// MARK: - Integration Tests
class IntegrationTests3: XCTestCase {
    
    func testUserManagerWithRealNetworkService() async throws {
        // Given
        let networkService = NetworkService3()
        let userManager = UserManager3(networkService: networkService)
        
        // When
        let user = try await userManager.getUser(id: 1)
        
        // Then
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(userManager.cacheCount, 1)
    }
    
    func testUserManagerErrorHandling() async {
        // Given
        let networkService = NetworkService3()
        let userManager = UserManager3(networkService: networkService)
        
        // When & Then
        do {
            _ = try await userManager.getUser(id: 404)
            XCTFail("Should have thrown an error")
        } catch let error as NetworkService3.NetworkError {
            XCTAssertEqual(error, .serverError(404))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Parameterized Tests
class ParameterizedTests3: XCTestCase {
    
    var calculator: Calculator3!
    
    override func setUp() {
        super.setUp()
        calculator = Calculator3()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    func testAdditionWithMultipleValues() {
        let testCases: [(Double, Double, Double)] = [
            (1.0, 2.0, 3.0),
            (-1.0, 1.0, 0.0),
            (0.0, 0.0, 0.0),
            (10.5, 20.3, 30.8),
            (-5.5, -4.5, -10.0)
        ]
        
        for (a, b, expected) in testCases {
            let result = calculator.add(a, b)
            XCTAssertEqual(result, expected, accuracy: 0.001, "Failed for \(a) + \(b)")
        }
    }
    
    func testDivisionWithMultipleValues() {
        let testCases: [(Double, Double, Double)] = [
            (10.0, 2.0, 5.0),
            (15.0, 3.0, 5.0),
            (-10.0, 2.0, -5.0),
            (7.5, 2.5, 3.0)
        ]
        
        for (a, b, expected) in testCases {
            do {
                let result = try calculator.divide(a, b)
                XCTAssertEqual(result, expected, accuracy: 0.001, "Failed for \(a) / \(b)")
            } catch {
                XCTFail("Unexpected error for \(a) / \(b): \(error)")
            }
        }
    }
}

// MARK: - Test Doubles (Spy, Stub, Fake)
class SpyNetworkService3: NetworkServiceProtocol3 {
    
    // Spy: Records information about method calls
    private(set) var methodCalls: [String] = []
    private(set) var fetchUserParameters: [Int] = []
    
    func fetchUser(id: Int) async throws -> User3 {
        methodCalls.append("fetchUser")
        fetchUserParameters.append(id)
        return User3(id: id, name: "Spy User", email: "spy@example.com")
    }
    
    func createUser(_ user: User3) async throws -> User3 {
        methodCalls.append("createUser")
        return user
    }
    
    func updateUser(_ user: User3) async throws -> User3 {
        methodCalls.append("updateUser")
        return user
    }
    
    func deleteUser(id: Int) async throws {
        methodCalls.append("deleteUser")
    }
    
    func reset() {
        methodCalls.removeAll()
        fetchUserParameters.removeAll()
    }
}

class TestDoublesTests3: XCTestCase {
    
    func testWithSpyNetworkService() async throws {
        // Given
        let spyService = SpyNetworkService3()
        let userManager = UserManager3(networkService: spyService)
        
        // When
        _ = try await userManager.getUser(id: 1)
        _ = try await userManager.createUser(name: "Test", email: "test@example.com")
        
        // Then
        XCTAssertEqual(spyService.methodCalls.count, 2)
        XCTAssertEqual(spyService.methodCalls, ["fetchUser", "createUser"])
        XCTAssertEqual(spyService.fetchUserParameters, [1])
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **XCTest Framework Basics**:
    - XCTestCase: Base class for test cases
    - setUp()/tearDown(): Test lifecycle methods
    - XCTAssert family: Assertion methods for validation
    - Test method naming convention (testXXX)

 2. **Test Structure (Arrange-Act-Assert)**:
    - Given (Arrange): Set up test data and conditions
    - When (Act): Execute the code under test
    - Then (Assert): Verify the expected outcomes

 3. **Async Testing**:
    - async/await in test methods
    - Testing async functions with proper error handling
    - Performance testing with async operations
    - Timeout handling for async tests

 4. **Mocking and Test Doubles**:
    - Mock: Simulates behavior and verifies interactions
    - Spy: Records method calls and parameters
    - Stub: Provides predetermined responses
    - Fake: Working implementation with shortcuts

 5. **Dependency Injection for Testing**:
    - Protocol-based dependencies
    - Constructor injection for testability
    - Swapping real implementations with test doubles

 6. **Error Testing**:
    - XCTAssertThrowsError for testing exceptions
    - Testing specific error types and messages
    - Error propagation in async contexts

 7. **Performance Testing**:
    - measure() block for performance benchmarks
    - Testing async operation performance
    - Identifying performance regressions

 8. **Test Organization**:
    - Grouping related tests in test classes
    - Using helper methods and utilities
    - Parameterized testing with multiple inputs

 9. **Common Interview Questions**:
    - Q: What's the difference between Mock and Stub?
    - A: Mock verifies behavior, Stub provides data

    - Q: How do you test async code?
    - A: Use async/await in test methods, handle timeouts

    - Q: What is Test-Driven Development (TDD)?
    - A: Write tests first, then implement code to pass tests

    - Q: How do you make code testable?
    - A: Use dependency injection, protocols, and avoid singletons

 10. **Best Practices**:
     - Write independent tests (no shared state)
     - Use descriptive test names
     - Test one thing at a time
     - Use appropriate assertions
     - Mock external dependencies
     - Test edge cases and error conditions

 11. **Advanced Testing Concepts**:
     - Integration tests vs Unit tests
     - Test coverage and code quality metrics
     - Continuous Integration testing
     - UI testing with XCUITest
     - Snapshot testing for UI components

 12. **Common Pitfalls**:
     - Testing implementation details instead of behavior
     - Brittle tests that break with refactoring
     - Not testing error conditions
     - Shared test state causing flaky tests
     - Over-mocking leading to meaningless tests
*/ 