//
//  Protocols-Generics-Advanced.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Basic Protocol with Associated Types

protocol Container4 {
    associatedtype Item
    
    var count: Int { get }
    var isEmpty: Bool { get }
    
    mutating func append(_ item: Item)
    subscript(i: Int) -> Item { get }
    
    // Associated type constraints
    func allItems() -> [Item]
}

// Default implementation using protocol extension
extension Container4 {
    var isEmpty: Bool {
        return count == 0
    }
    
    func allItems() -> [Item] {
        var items: [Item] = []
        for i in 0..<count {
            items.append(self[i])
        }
        return items
    }
}

// Concrete implementation
struct IntStack4: Container4 {
    typealias Item = Int
    
    private var items: [Int] = []
    
    var count: Int {
        return items.count
    }
    
    mutating func append(_ item: Int) {
        items.append(item)
    }
    
    subscript(i: Int) -> Int {
        return items[i]
    }
}

// Generic implementation
struct Stack4<Element>: Container4 {
    typealias Item = Element
    
    private var items: [Element] = []
    
    var count: Int {
        return items.count
    }
    
    mutating func append(_ item: Element) {
        items.append(item)
    }
    
    subscript(i: Int) -> Element {
        return items[i]
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
    
    func peek() -> Element? {
        return items.last
    }
}

// MARK: - Protocol with Multiple Associated Types

protocol Graph4 {
    associatedtype Vertex: Hashable
    associatedtype Edge
    
    var vertices: Set<Vertex> { get }
    var edges: [Edge] { get }
    
    func addVertex(_ vertex: Vertex)
    func addEdge(_ edge: Edge)
    func neighbors(of vertex: Vertex) -> [Vertex]
    func hasPath(from source: Vertex, to destination: Vertex) -> Bool
}

// Concrete implementation
struct SimpleGraph4: Graph4 {
    typealias Vertex = String
    typealias Edge = (from: String, to: String)
    
    private(set) var vertices: Set<String> = []
    private(set) var edges: [(from: String, to: String)] = []
    private var adjacencyList: [String: Set<String>] = [:]
    
    mutating func addVertex(_ vertex: String) {
        vertices.insert(vertex)
        if adjacencyList[vertex] == nil {
            adjacencyList[vertex] = Set<String>()
        }
    }
    
    mutating func addEdge(_ edge: (from: String, to: String)) {
        edges.append(edge)
        addVertex(edge.from)
        addVertex(edge.to)
        adjacencyList[edge.from]?.insert(edge.to)
    }
    
    func neighbors(of vertex: String) -> [String] {
        return Array(adjacencyList[vertex] ?? [])
    }
    
    func hasPath(from source: String, to destination: String) -> Bool {
        var visited: Set<String> = []
        var queue: [String] = [source]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if current == destination {
                return true
            }
            
            if !visited.contains(current) {
                visited.insert(current)
                queue.append(contentsOf: neighbors(of: current))
            }
        }
        
        return false
    }
}

// MARK: - Protocol Inheritance and Composition

protocol Drawable4 {
    func draw()
}

protocol Transformable4 {
    mutating func translate(x: Double, y: Double)
    mutating func rotate(angle: Double)
    mutating func scale(factor: Double)
}

protocol Colorable4 {
    var color: UIColor { get set }
    func applyColor(_ color: UIColor)
}

// Protocol composition
protocol Shape4: Drawable4, Transformable4, Colorable4 {
    var area: Double { get }
    var perimeter: Double { get }
    var center: CGPoint { get set }
}

// Implementation
struct Circle4: Shape4 {
    var center: CGPoint
    var radius: Double
    var color: UIColor
    
    var area: Double {
        return Double.pi * radius * radius
    }
    
    var perimeter: Double {
        return 2 * Double.pi * radius
    }
    
    func draw() {
        print("🔵 Drawing circle at \(center) with radius \(radius)")
    }
    
    mutating func translate(x: Double, y: Double) {
        center.x += x
        center.y += y
        print("📍 Circle translated to \(center)")
    }
    
    mutating func rotate(angle: Double) {
        print("🔄 Circle rotated by \(angle) degrees")
    }
    
    mutating func scale(factor: Double) {
        radius *= factor
        print("📏 Circle scaled by factor \(factor), new radius: \(radius)")
    }
    
    func applyColor(_ color: UIColor) {
        print("🎨 Circle color changed to \(color)")
    }
}

// MARK: - Generic Protocols with Constraints

protocol Comparable4 {
    static func < (lhs: Self, rhs: Self) -> Bool
}

protocol SortableContainer4 {
    associatedtype Element: Comparable4
    
    var elements: [Element] { get set }
    
    mutating func sort()
    mutating func insert(_ element: Element)
    func isSorted() -> Bool
}

extension SortableContainer4 {
    mutating func sort() {
        elements.sort { $0 < $1 }
    }
    
    mutating func insert(_ element: Element) {
        elements.append(element)
        sort()
    }
    
    func isSorted() -> Bool {
        for i in 1..<elements.count {
            if elements[i-1] > elements[i] {
                return false
            }
        }
        return true
    }
}

struct SortedArray4<T: Comparable>: SortableContainer4 {
    typealias Element = T
    var elements: [T] = []
    
    init(_ elements: [T] = []) {
        self.elements = elements.sorted()
    }
}

// MARK: - Protocol-Oriented Programming Example

protocol Fetchable4 {
    associatedtype DataType
    associatedtype ErrorType: Error
    
    func fetch() async throws -> DataType
}

protocol Cacheable4 {
    associatedtype CacheKey: Hashable
    associatedtype CacheValue
    
    func cache(_ value: CacheValue, for key: CacheKey)
    func getCached(for key: CacheKey) -> CacheValue?
    func clearCache()
}

protocol Repository4: Fetchable4, Cacheable4 where CacheKey == String, CacheValue == DataType {
    func fetchWithCache(key: String) async throws -> DataType
}

extension Repository4 {
    func fetchWithCache(key: String) async throws -> DataType {
        // Check cache first
        if let cached = getCached(for: key) {
            print("📦 Retrieved from cache: \(key)")
            return cached
        }
        
        // Fetch from source
        let data = try await fetch()
        cache(data, for: key)
        print("🌐 Fetched and cached: \(key)")
        return data
    }
}

// Concrete implementation
struct UserRepository4: Repository4 {
    typealias DataType = User4
    typealias ErrorType = NetworkError4
    typealias CacheKey = String
    typealias CacheValue = User4
    
    private var cache: [String: User4] = [:]
    private let networkService: NetworkService4
    
    init(networkService: NetworkService4) {
        self.networkService = networkService
    }
    
    func fetch() async throws -> User4 {
        return try await networkService.fetchUser()
    }
    
    func cache(_ value: User4, for key: String) {
        cache[key] = value
    }
    
    func getCached(for key: String) -> User4? {
        return cache[key]
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

// Supporting types
struct User4: Codable {
    let id: String
    let name: String
    let email: String
}

enum NetworkError4: Error {
    case noData
    case invalidResponse
    case serverError(Int)
}

class NetworkService4 {
    func fetchUser() async throws -> User4 {
        // Simulate network call
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return User4(id: "1", name: "John Doe", email: "john@example.com")
    }
}

// MARK: - Type Erasure

// Problem: We can't use protocols with associated types as concrete types
// Solution: Type erasure

struct AnyContainer4<T> {
    private let _count: () -> Int
    private let _isEmpty: () -> Bool
    private let _append: (T) -> Void
    private let _subscript: (Int) -> T
    private let _allItems: () -> [T]
    
    init<C: Container4>(_ container: C) where C.Item == T {
        var mutableContainer = container
        
        _count = { container.count }
        _isEmpty = { container.isEmpty }
        _append = { mutableContainer.append($0) }
        _subscript = { container[$0] }
        _allItems = { container.allItems() }
    }
    
    var count: Int { _count() }
    var isEmpty: Bool { _isEmpty() }
    
    func append(_ item: T) { _append(item) }
    subscript(i: Int) -> T { _subscript(i) }
    func allItems() -> [T] { _allItems() }
}

// Alternative: Using a base class for type erasure
class AnyContainerBase4<T> {
    var count: Int { fatalError("Must override") }
    var isEmpty: Bool { fatalError("Must override") }
    
    func append(_ item: T) { fatalError("Must override") }
    subscript(i: Int) -> T { fatalError("Must override") }
    func allItems() -> [T] { fatalError("Must override") }
}

class ContainerBox4<C: Container4>: AnyContainerBase4<C.Item> {
    private var container: C
    
    init(_ container: C) {
        self.container = container
    }
    
    override var count: Int { container.count }
    override var isEmpty: Bool { container.isEmpty }
    
    override func append(_ item: C.Item) { container.append(item) }
    override subscript(i: Int) -> C.Item { container[i] }
    override func allItems() -> [C.Item] { container.allItems() }
}

// MARK: - Advanced Protocol Patterns

// Phantom Types with Protocols
protocol State4 {}
struct Open4: State4 {}
struct Closed4: State4 {}

struct Door4<S: State4> {
    private let id: String
    
    init(id: String) {
        self.id = id
    }
    
    // Only available when door is open
    func close() -> Door4<Closed4> where S == Open4 {
        print("🚪 Closing door \(id)")
        return Door4<Closed4>(id: id)
    }
    
    // Only available when door is closed
    func open() -> Door4<Open4> where S == Closed4 {
        print("🚪 Opening door \(id)")
        return Door4<Open4>(id: id)
    }
}

// Factory function
func createDoor(id: String) -> Door4<Closed4> {
    return Door4<Closed4>(id: id)
}

// MARK: - Protocol with Self Requirements

protocol Copyable4 {
    func copy() -> Self
}

protocol Equatable4 {
    static func == (lhs: Self, rhs: Self) -> Bool
}

protocol Comparable5: Equatable4 {
    static func < (lhs: Self, rhs: Self) -> Bool
}

extension Comparable5 {
    static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        return !(lhs <= rhs)
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool {
        return !(lhs < rhs)
    }
}

struct Point4: Comparable5, Copyable4 {
    let x: Double
    let y: Double
    
    static func == (lhs: Point4, rhs: Point4) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func < (lhs: Point4, rhs: Point4) -> Bool {
        if lhs.x != rhs.x {
            return lhs.x < rhs.x
        }
        return lhs.y < rhs.y
    }
    
    func copy() -> Point4 {
        return Point4(x: x, y: y)
    }
    
    func distance(to other: Point4) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Protocol-Based Dependency Injection

protocol Logger4 {
    func log(_ message: String, level: LogLevel4)
}

enum LogLevel4: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

struct ConsoleLogger4: Logger4 {
    func log(_ message: String, level: LogLevel4) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("[\(timestamp)] [\(level.rawValue)] \(message)")
    }
}

struct FileLogger4: Logger4 {
    private let fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func log(_ message: String, level: LogLevel4) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "[\(timestamp)] [\(level.rawValue)] \(message)\n"
        
        do {
            try logEntry.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write to log file: \(error)")
        }
    }
}

class ServiceManager4 {
    private let logger: Logger4
    
    init(logger: Logger4) {
        self.logger = logger
    }
    
    func performOperation() {
        logger.log("Starting operation", level: .info)
        
        // Simulate work
        Thread.sleep(forTimeInterval: 0.1)
        
        logger.log("Operation completed successfully", level: .info)
    }
    
    func handleError(_ error: Error) {
        logger.log("Error occurred: \(error.localizedDescription)", level: .error)
    }
}

// MARK: - Generic Protocol with Where Clauses

protocol Collection4 {
    associatedtype Element
    associatedtype Index: Comparable
    
    var startIndex: Index { get }
    var endIndex: Index { get }
    
    subscript(position: Index) -> Element { get }
    func index(after i: Index) -> Index
}

extension Collection4 {
    func forEach(_ body: (Element) throws -> Void) rethrows {
        var index = startIndex
        while index < endIndex {
            try body(self[index])
            index = self.index(after: index)
        }
    }
}

extension Collection4 where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        var index = startIndex
        while index < endIndex {
            if self[index] == element {
                return true
            }
            index = self.index(after: index)
        }
        return false
    }
    
    func firstIndex(of element: Element) -> Index? {
        var index = startIndex
        while index < endIndex {
            if self[index] == element {
                return index
            }
            index = self.index(after: index)
        }
        return nil
    }
}

extension Collection4 where Element: Comparable {
    func min() -> Element? {
        guard startIndex < endIndex else { return nil }
        
        var minElement = self[startIndex]
        var index = self.index(after: startIndex)
        
        while index < endIndex {
            if self[index] < minElement {
                minElement = self[index]
            }
            index = self.index(after: index)
        }
        
        return minElement
    }
    
    func max() -> Element? {
        guard startIndex < endIndex else { return nil }
        
        var maxElement = self[startIndex]
        var index = self.index(after: startIndex)
        
        while index < endIndex {
            if self[index] > maxElement {
                maxElement = self[index]
            }
            index = self.index(after: index)
        }
        
        return maxElement
    }
}

// MARK: - Protocol-Oriented Architecture Example

protocol ViewModelProtocol4: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func send(_ action: Action)
}

protocol StateProtocol4 {
    associatedtype LoadingState
    associatedtype ErrorState
    
    var isLoading: Bool { get }
    var error: ErrorState? { get }
}

struct TodoState4: StateProtocol4 {
    typealias LoadingState = Bool
    typealias ErrorState = String
    
    var todos: [Todo4] = []
    var isLoading: Bool = false
    var error: String? = nil
}

enum TodoAction4 {
    case loadTodos
    case addTodo(String)
    case toggleTodo(UUID)
    case deleteTodo(UUID)
    case setLoading(Bool)
    case setError(String?)
}

struct Todo4: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
}

class TodoViewModel4: ViewModelProtocol4 {
    typealias State = TodoState4
    typealias Action = TodoAction4
    
    @Published private(set) var state = TodoState4()
    
    func send(_ action: TodoAction4) {
        switch action {
        case .loadTodos:
            state.isLoading = true
            state.error = nil
            // Simulate loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.state.todos = [
                    Todo4(title: "Learn SwiftUI"),
                    Todo4(title: "Practice Protocols"),
                    Todo4(title: "Build an App")
                ]
                self.state.isLoading = false
            }
            
        case .addTodo(let title):
            let newTodo = Todo4(title: title)
            state.todos.append(newTodo)
            
        case .toggleTodo(let id):
            if let index = state.todos.firstIndex(where: { $0.id == id }) {
                state.todos[index].isCompleted.toggle()
            }
            
        case .deleteTodo(let id):
            state.todos.removeAll { $0.id == id }
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setError(let error):
            state.error = error
        }
    }
}

// MARK: - Usage Examples

class ProtocolUsageExamples4 {
    
    func demonstrateBasicProtocols() {
        print("=== Basic Protocol Usage ===")
        
        var intStack = IntStack4()
        intStack.append(1)
        intStack.append(2)
        intStack.append(3)
        
        print("IntStack count: \(intStack.count)")
        print("IntStack isEmpty: \(intStack.isEmpty)")
        print("IntStack items: \(intStack.allItems())")
        
        var stringStack = Stack4<String>()
        stringStack.append("Hello")
        stringStack.append("World")
        
        print("StringStack count: \(stringStack.count)")
        print("StringStack top: \(stringStack.peek() ?? "nil")")
    }
    
    func demonstrateProtocolComposition() {
        print("\n=== Protocol Composition ===")
        
        var circle = Circle4(center: CGPoint(x: 0, y: 0), radius: 5.0, color: .blue)
        
        circle.draw()
        print("Area: \(circle.area)")
        print("Perimeter: \(circle.perimeter)")
        
        circle.translate(x: 10, y: 10)
        circle.scale(factor: 2.0)
        circle.rotate(angle: 45)
    }
    
    func demonstrateTypeErasure() {
        print("\n=== Type Erasure ===")
        
        let intStack = Stack4<Int>()
        let stringStack = Stack4<String>()
        
        let anyIntContainer = AnyContainer4(intStack)
        let anyStringContainer = AnyContainer4(stringStack)
        
        print("AnyContainer count: \(anyIntContainer.count)")
        print("AnyContainer isEmpty: \(anyIntContainer.isEmpty)")
    }
    
    func demonstratePhantomTypes() {
        print("\n=== Phantom Types ===")
        
        let closedDoor = createDoor(id: "main-door")
        let openDoor = closedDoor.open()
        let closedAgain = openDoor.close()
        
        // This won't compile - door is already closed:
        // let invalid = closedAgain.close()
    }
    
    func demonstrateProtocolOrientedArchitecture() {
        print("\n=== Protocol-Oriented Architecture ===")
        
        let consoleLogger = ConsoleLogger4()
        let serviceManager = ServiceManager4(logger: consoleLogger)
        
        serviceManager.performOperation()
        serviceManager.handleError(NSError(domain: "TestError", code: 1, userInfo: nil))
    }
    
    func demonstrateAdvancedCollections() {
        print("\n=== Advanced Collections ===")
        
        let numbers = [1, 2, 3, 4, 5]
        let strings = ["apple", "banana", "cherry"]
        
        // Using protocol extensions with constraints
        print("Numbers contains 3: \(numbers.contains(3))")
        print("Min number: \(numbers.min() ?? 0)")
        print("Max string: \(strings.max() ?? "")")
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Associated Types**:
    - Placeholder types in protocols (like generics for protocols)
    - Defined with `associatedtype` keyword
    - Can have constraints and where clauses
    - Resolved when protocol is adopted

 2. **Protocol Extensions**:
    - Provide default implementations
    - Add functionality to all conforming types
    - Can have constraints with where clauses
    - Enable protocol-oriented programming

 3. **Protocol Composition**:
    - Combine multiple protocols with &
    - Create more specific requirements
    - Better than class inheritance for flexibility
    - Supports multiple inheritance of behavior

 4. **Type Erasure**:
    - Solves the problem of protocols with associated types
    - Uses wrapper types or base classes
    - Hides concrete type information
    - Examples: AnySequence, AnyPublisher, AnyView

 5. **Protocol-Oriented Programming (POP)**:
    - Prefer protocols over classes
    - Use protocol extensions for shared behavior
    - Compose protocols for complex requirements
    - Better testability and flexibility

 6. **Generic Constraints**:
    - Restrict generic types with where clauses
    - Apply to associated types in protocols
    - Enable conditional conformance
    - Provide type-specific functionality

 7. **Self Requirements**:
    - Protocols that reference Self type
    - Used for operations that return same type
    - Common in Equatable, Comparable, Copyable
    - Enable fluent interfaces and method chaining

 8. **Phantom Types**:
    - Types that carry compile-time information
    - Used for state machines and type safety
    - Prevent invalid operations at compile time
    - Zero runtime cost

 9. **Common Interview Questions**:
    - Q: Difference between protocols and classes?
    - A: Protocols define interface, support multiple inheritance, value types

    - Q: What are associated types?
    - A: Placeholder types in protocols, resolved when adopted

    - Q: When to use type erasure?
    - A: When you need to store protocols with associated types

    - Q: What is protocol-oriented programming?
    - A: Design paradigm favoring protocols over inheritance

 10. **Advanced Patterns**:
     - Conditional conformance with where clauses
     - Protocol inheritance hierarchies
     - Generic protocols with multiple constraints
     - Protocol-based dependency injection

 11. **Best Practices**:
     - Start with protocols, not classes
     - Use protocol extensions for default behavior
     - Prefer composition over inheritance
     - Use associated types for flexible APIs
     - Apply type erasure when needed

 12. **Performance Considerations**:
     - Protocol dispatch can be slower than direct calls
     - Generic specialization optimizes performance
     - Existential types have overhead
     - Consider static dispatch when possible

 13. **Common Pitfalls**:
     - Overusing protocols where simple types suffice
     - Not understanding protocol dispatch
     - Circular protocol dependencies
     - Incorrect use of Self requirements
     - Missing where clause constraints
*/ 