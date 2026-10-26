//
//  Swift-Generics.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation

// MARK: - Basic Generic Functions
class GenericFunctions1 {
    
    // MARK: - Simple Generic Function
    func swapValues<T>(_ a: inout T, _ b: inout T) {
        let temp = a
        a = b
        b = temp
    }
    
    // MARK: - Generic Function with Multiple Types
    func pair<T, U>(_ first: T, _ second: U) -> (T, U) {
        return (first, second)
    }
    
    // MARK: - Generic Function with Constraints
    func findMaximum<T: Comparable>(_ array: [T]) -> T? {
        guard !array.isEmpty else { return nil }
        
        var maximum = array[0]
        for element in array {
            if element > maximum {
                maximum = element
            }
        }
        return maximum
    }
    
    // MARK: - Generic Function with Protocol Constraints
    func processItems<T: CustomStringConvertible>(_ items: [T]) -> [String] {
        return items.map { $0.description }
    }
    
    // MARK: - Generic Function with Where Clause
    func elementsEqual<T: Sequence, U: Sequence>(_ first: T, _ second: U) -> Bool
    where T.Element: Equatable, T.Element == U.Element {
        let firstArray = Array(first)
        let secondArray = Array(second)
        
        guard firstArray.count == secondArray.count else { return false }
        
        for (index, element) in firstArray.enumerated() {
            if element != secondArray[index] {
                return false
            }
        }
        return true
    }
    
    func demonstrateGenericFunctions() {
        print("=== Generic Functions Demo ===")
        
        // Swap values
        var x = 10
        var y = 20
        swapValues(&x, &y)
        print("After swap: x = \(x), y = \(y)")
        
        var str1 = "Hello"
        var str2 = "World"
        swapValues(&str1, &str2)
        print("After swap: str1 = \(str1), str2 = \(str2)")
        
        // Pair function
        let intStringPair = pair(42, "Answer")
        print("Pair: \(intStringPair)")
        
        // Find maximum
        let numbers = [3, 7, 2, 9, 1]
        if let max = findMaximum(numbers) {
            print("Maximum: \(max)")
        }
        
        let strings = ["Apple", "Banana", "Cherry"]
        if let maxString = findMaximum(strings) {
            print("Maximum string: \(maxString)")
        }
        
        // Process items
        let processedNumbers = processItems([1, 2, 3, 4, 5])
        print("Processed numbers: \(processedNumbers)")
        
        // Elements equal
        let array1 = [1, 2, 3]
        let array2 = [1, 2, 3]
        let array3 = [1, 2, 4]
        print("Arrays equal: \(elementsEqual(array1, array2))")
        print("Arrays equal: \(elementsEqual(array1, array3))")
    }
}

// MARK: - Generic Types
struct Stack1<Element> {
    private var items: [Element] = []
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var count: Int {
        return items.count
    }
    
    var top: Element? {
        return items.last
    }
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    @discardableResult
    mutating func pop() -> Element? {
        return items.popLast()
    }
    
    func peek() -> Element? {
        return items.last
    }
}

// MARK: - Generic Class with Constraints
class Repository1<T: Codable & Identifiable> {
    private var items: [T.ID: T] = [:]
    
    func save(_ item: T) {
        items[item.id] = item
        print("💾 Saved item with ID: \(item.id)")
    }
    
    func find(by id: T.ID) -> T? {
        return items[id]
    }
    
    func findAll() -> [T] {
        return Array(items.values)
    }
    
    func delete(by id: T.ID) -> T? {
        let deletedItem = items.removeValue(forKey: id)
        if deletedItem != nil {
            print("🗑️ Deleted item with ID: \(id)")
        }
        return deletedItem
    }
    
    func count() -> Int {
        return items.count
    }
}

// MARK: - Associated Types with Protocols
protocol Container1 {
    associatedtype Item
    
    var count: Int { get }
    var isEmpty: Bool { get }
    
    mutating func append(_ item: Item)
    subscript(index: Int) -> Item { get }
}

// Implementation of Container protocol
struct IntContainer1: Container1 {
    typealias Item = Int // Explicit type alias (optional)
    
    private var items: [Int] = []
    
    var count: Int {
        return items.count
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    mutating func append(_ item: Int) {
        items.append(item)
    }
    
    subscript(index: Int) -> Int {
        return items[index]
    }
}

// Generic implementation of Container protocol
struct GenericContainer1<T>: Container1 {
    private var items: [T] = []
    
    var count: Int {
        return items.count
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    mutating func append(_ item: T) {
        items.append(item)
    }
    
    subscript(index: Int) -> T {
        return items[index]
    }
}

// MARK: - Protocol with Associated Types and Constraints
protocol Summable1 {
    associatedtype Element: Numeric
    
    var elements: [Element] { get }
    func sum() -> Element
}

struct NumberCollection1<T: Numeric>: Summable1 {
    let elements: [T]
    
    func sum() -> T {
        return elements.reduce(0, +)
    }
}

// MARK: - Generic Protocols with Where Clauses
protocol Equatable1 {
    associatedtype Element
    
    func isEqual<Other: Equatable1>(to other: Other) -> Bool
    where Other.Element == Element, Element: Equatable
}

struct Wrapper1<T: Equatable>: Equatable1 {
    let value: T
    
    func isEqual<Other: Equatable1>(to other: Other) -> Bool
    where Other.Element == T {
        if let otherWrapper = other as? Wrapper1<T> {
            return value == otherWrapper.value
        }
        return false
    }
}

// MARK: - Advanced Generic Patterns
class NetworkClient1<ResponseType: Codable> {
    
    func request<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // Simulate network request
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Simulate success/failure
            if Bool.random() {
                // In real implementation, you would decode actual data
                // For demo, we'll create a mock response
                completion(.failure(.noData))
            } else {
                completion(.failure(.invalidResponse))
            }
        }
    }
    
    func requestAsync<T: Codable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        // Simulate async network request
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if Bool.random() {
            throw NetworkError.serverError
        }
        
        // In real implementation, decode and return actual data
        throw NetworkError.noData // For demo purposes
    }
}

enum NetworkError: Error {
    case serverError
    case noData
    case invalidResponse
}

// MARK: - Generic Result Type
enum Result1<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
    
    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result1<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func flatMap<NewSuccess>(_ transform: (Success) -> Result1<NewSuccess, Failure>) -> Result1<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Generic Builder Pattern
class QueryBuilder1<T> {
    private var conditions: [String] = []
    private var sortFields: [String] = []
    private var limitValue: Int?
    
    func where1(_ condition: String) -> QueryBuilder1<T> {
        conditions.append(condition)
        return self
    }
    
    func orderBy(_ field: String) -> QueryBuilder1<T> {
        sortFields.append(field)
        return self
    }
    
    func limit(_ count: Int) -> QueryBuilder1<T> {
        limitValue = count
        return self
    }
    
    func build() -> String {
        var query = "SELECT * FROM \(T.self)"
        
        if !conditions.isEmpty {
            query += " WHERE " + conditions.joined(separator: " AND ")
        }
        
        if !sortFields.isEmpty {
            query += " ORDER BY " + sortFields.joined(separator: ", ")
        }
        
        if let limit = limitValue {
            query += " LIMIT \(limit)"
        }
        
        return query
    }
}

// MARK: - Type Erasure Pattern
protocol Animal1 {
    associatedtype Food
    
    func eat(_ food: Food)
    func makeSound() -> String
}

struct AnyAnimal1<Food> {
    private let _eat: (Food) -> Void
    private let _makeSound: () -> String
    
    init<A: Animal1>(_ animal: A) where A.Food == Food {
        _eat = animal.eat
        _makeSound = animal.makeSound
    }
    
    func eat(_ food: Food) {
        _eat(food)
    }
    
    func makeSound() -> String {
        return _makeSound()
    }
}

struct Dog1: Animal1 {
    func eat(_ food: String) {
        print("🐕 Dog eating: \(food)")
    }
    
    func makeSound() -> String {
        return "Woof!"
    }
}

struct Cat1: Animal1 {
    func eat(_ food: String) {
        print("🐱 Cat eating: \(food)")
    }
    
    func makeSound() -> String {
        return "Meow!"
    }
}

// MARK: - Generic Extensions
extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

extension Optional {
    
    func orThrow<E: Error>(_ error: E) throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            throw error
        }
    }
    
    func apply<Result>(_ transform: (Wrapped) -> Result) -> Result? {
        return map(transform)
    }
}

// MARK: - Demo Models
struct User1: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

struct Product1: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
}

// MARK: - Usage Examples
class GenericsUsageExamples1 {
    
    func demonstrateAllConcepts() {
        print("=== Swift Generics Comprehensive Demo ===\n")
        
        // Generic functions
        let genericFunctions = GenericFunctions1()
        genericFunctions.demonstrateGenericFunctions()
        
        print("\n=== Generic Stack Demo ===")
        demonstrateGenericStack()
        
        print("\n=== Generic Repository Demo ===")
        demonstrateGenericRepository()
        
        print("\n=== Container Protocol Demo ===")
        demonstrateContainerProtocol()
        
        print("\n=== Summable Protocol Demo ===")
        demonstrateSummableProtocol()
        
        print("\n=== Query Builder Demo ===")
        demonstrateQueryBuilder()
        
        print("\n=== Type Erasure Demo ===")
        demonstrateTypeErasure()
        
        print("\n=== Generic Extensions Demo ===")
        demonstrateGenericExtensions()
    }
    
    private func demonstrateGenericStack() {
        var intStack = Stack1<Int>()
        intStack.push(1)
        intStack.push(2)
        intStack.push(3)
        
        print("Stack count: \(intStack.count)")
        print("Top element: \(intStack.top ?? 0)")
        
        while !intStack.isEmpty {
            if let popped = intStack.pop() {
                print("Popped: \(popped)")
            }
        }
        
        var stringStack = Stack1<String>()
        stringStack.push("Hello")
        stringStack.push("World")
        print("String stack top: \(stringStack.top ?? "")")
    }
    
    private func demonstrateGenericRepository() {
        let userRepository = Repository1<User1>()
        let user1 = User1(id: 1, name: "Alice", email: "alice@example.com")
        let user2 = User1(id: 2, name: "Bob", email: "bob@example.com")
        
        userRepository.save(user1)
        userRepository.save(user2)
        
        if let foundUser = userRepository.find(by: 1) {
            print("Found user: \(foundUser.name)")
        }
        
        print("Total users: \(userRepository.count())")
        
        let productRepository = Repository1<Product1>()
        let product = Product1(id: "P001", name: "iPhone", price: 999.99)
        productRepository.save(product)
        
        print("Total products: \(productRepository.count())")
    }
    
    private func demonstrateContainerProtocol() {
        var intContainer = IntContainer1()
        intContainer.append(1)
        intContainer.append(2)
        intContainer.append(3)
        
        print("Int container count: \(intContainer.count)")
        print("First element: \(intContainer[0])")
        
        var stringContainer = GenericContainer1<String>()
        stringContainer.append("A")
        stringContainer.append("B")
        stringContainer.append("C")
        
        print("String container count: \(stringContainer.count)")
        print("First element: \(stringContainer[0])")
    }
    
    private func demonstrateSummableProtocol() {
        let intCollection = NumberCollection1(elements: [1, 2, 3, 4, 5])
        print("Sum of integers: \(intCollection.sum())")
        
        let doubleCollection = NumberCollection1(elements: [1.5, 2.5, 3.5])
        print("Sum of doubles: \(doubleCollection.sum())")
    }
    
    private func demonstrateQueryBuilder() {
        let userQuery = QueryBuilder1<User1>()
            .where1("age > 18")
            .where1("active = true")
            .orderBy("name")
            .limit(10)
            .build()
        
        print("Generated query: \(userQuery)")
    }
    
    private func demonstrateTypeErasure() {
        let dog = Dog1()
        let cat = Cat1()
        
        let animals: [AnyAnimal1<String>] = [
            AnyAnimal1(dog),
            AnyAnimal1(cat)
        ]
        
        for animal in animals {
            print("Animal says: \(animal.makeSound())")
            animal.eat("food")
        }
    }
    
    private func demonstrateGenericExtensions() {
        let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let chunks = numbers.chunked(into: 3)
        print("Chunked array: \(chunks)")
        
        let users = [
            User1(id: 1, name: "Alice", email: "alice@example.com"),
            User1(id: 2, name: "Bob", email: "bob@example.com"),
            User1(id: 1, name: "Alice Duplicate", email: "alice2@example.com")
        ]
        
        let uniqueUsers = users.unique(by: \.id)
        print("Unique users count: \(uniqueUsers.count)")
        
        // Optional extensions
        let optionalValue: String? = "Hello"
        let result = optionalValue.apply { $0.uppercased() }
        print("Applied transform: \(result ?? "nil")")
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Generic Functions**:
    - Type parameters in angle brackets <T>
    - Multiple type parameters <T, U>
    - Type constraints with : protocol
    - Where clauses for complex constraints
    - Generic functions reduce code duplication

 2. **Generic Types**:
    - Generic structs, classes, and enums
    - Type parameters become concrete when instantiated
    - Can have multiple type parameters
    - Type constraints ensure type safety

 3. **Associated Types**:
    - Used in protocols to define placeholder types
    - Implemented by conforming types
    - Can have constraints and where clauses
    - Enable protocol-oriented programming

 4. **Type Constraints**:
    - : Equatable, : Comparable for basic constraints
    - : Protocol for protocol conformance
    - where clauses for complex relationships
    - Multiple constraints with &

 5. **Advanced Patterns**:
    - Type erasure with AnyType wrappers
    - Generic builder patterns
    - Result types for error handling
    - Generic network clients

 6. **Performance Considerations**:
    - Generics are resolved at compile time
    - No runtime overhead for type checking
    - Code specialization for each concrete type
    - Better than Any/AnyObject for type safety

 7. **Common Interview Questions**:
    - Q: What are generics and why use them?
    - A: Type-safe code reuse without sacrificing performance
    
    - Q: Difference between generics and Any?
    - A: Generics maintain type safety, Any loses type information
    
    - Q: What are associated types?
    - A: Placeholder types in protocols, defined by conforming types
    
    - Q: When to use type constraints?
    - A: When generic code needs specific capabilities from types

 8. **Best Practices**:
    - Use meaningful type parameter names (Element, not T)
    - Apply constraints to enable required operations
    - Prefer protocols over concrete types in constraints
    - Use where clauses for complex relationships

 9. **Common Pitfalls**:
    - Over-constraining generic types
    - Not using type erasure when needed
    - Confusing associated types with generic parameters
    - Forgetting about type inference

 10. **Real-world Applications**:
     - Collection types (Array, Dictionary)
     - Network clients with different response types
     - Repository patterns for different entities
     - Builder patterns for type-safe APIs
     - Result types for error handling
*/ 
