//
//  Combine-Advanced-Framework.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import Combine
import UIKit
import SwiftUI

// MARK: - Basic Publisher Examples

class CombineBasics {
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Subject Publishers
    func demonstrateSubjects() {
        print("\n=== Subject Publishers ===")
        
        // PassthroughSubject - doesn't hold current value
        let passthroughSubject = PassthroughSubject<String, Never>()
        
        passthroughSubject
            .sink { value in
                print("📡 PassthroughSubject: \(value)")
            }
            .store(in: &cancellables)
        
        passthroughSubject.send("First message")
        passthroughSubject.send("Second message")
        // Output: 📡 PassthroughSubject: First message
        //         📡 PassthroughSubject: Second message
        
        // CurrentValueSubject - holds and emits current value
        let currentValueSubject = CurrentValueSubject<Int, Never>(0)
        
        currentValueSubject
            .sink { value in
                print("💾 CurrentValueSubject: \(value)")
            }
            .store(in: &cancellables)
        
        currentValueSubject.send(10)
        currentValueSubject.send(20)
        // Output: 💾 CurrentValueSubject: 0
        //         💾 CurrentValueSubject: 10
        //         💾 CurrentValueSubject: 20
        
        print("Current value: \(currentValueSubject.value)")
        // Output: Current value: 20
    }
    
    // MARK: - Simple Publishers
    func demonstrateBasicPublishers() {
        print("=== Basic Publishers ===")
        
        // Just publisher - emits single value then completes
        Just("Hello, Combine!")
            .sink { value in
                print("📦 Just: \(value)")
            }
            .store(in: &cancellables)
        // Output: 📦 Just: Hello, Combine!
        
        // Empty publisher - completes immediately without emitting values
        Empty<String, Never>()
            .sink(
                receiveCompletion: { completion in
                    print("🏁 Empty completed: \(completion)")
                },
                receiveValue: { value in
                    print("📦 Empty value: \(value)")
                }
            )
            .store(in: &cancellables)
        // Output: 🏁 Empty completed: finished
        
        // Fail publisher - immediately fails with error
        Fail<String, CustomError>(error: CustomError.networkError)
            .sink(
                receiveCompletion: { completion in
                    print("❌ Fail completed: \(completion)")
                },
                receiveValue: { value in
                    print("📦 Fail value: \(value)")
                }
            )
            .store(in: &cancellables)
        // Output: ❌ Fail completed: failure(__lldb_expr_XX.CustomError.networkError)
        
        // Sequence publisher - emits values from a sequence
        [1, 2, 3].publisher
            .sink { value in
                print("🔢 Sequence: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔢 Sequence: 1
        //         🔢 Sequence: 2
        //         🔢 Sequence: 3
    }
    
    // MARK: - Timer Publishers
    func demonstrateTimerPublishers() {
        print("\n=== Timer Publishers ===")
        
        // Timer publisher
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .prefix(5) // Only take first 5 values
            .sink { date in
                print("⏰ Timer: \(DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium))")
            }
            .store(in: &cancellables)
        // Output: ⏰ Timer: 3:45:23 PM (first emission after 1 second)
        //         ⏰ Timer: 3:45:24 PM (second emission after 2 seconds)
        //         ... and so on for 5 total emissions
    }
}

enum CustomError: Error {
    case networkError
    case parsingError
    case validationError(String)
}

// MARK: - Advanced Operators

class CombineOperators {
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Transformation Operators
    func demonstrateTransformationOperators() {
        print("=== Transformation Operators ===")
        
        let numbers = [1, 2, 3].publisher
        
        // Map - transform each value
        numbers
            .map { $0 * 2 }
            .sink { value in
                print("🔄 Map (x2): \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔄 Map (x2): 2
        //         🔄 Map (x2): 4
        //         🔄 Map (x2): 6
        
        // FlatMap - flatten nested publishers
        let stringNumbers = ["1", "2", "3"].publisher
        
        stringNumbers
            .flatMap { string in
                Just(Int(string) ?? 0)
            }
            .sink { value in
                print("🔄 FlatMap: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔄 FlatMap: 1
        //         🔄 FlatMap: 2
        //         🔄 FlatMap: 3
        
        // CompactMap - transform and remove nils
        let mixedStrings = ["1", "two", "3", "four", "5"].publisher
        
        mixedStrings
            .compactMap { Int($0) }
            .sink { value in
                print("🔄 CompactMap: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔄 CompactMap: 1
        //         🔄 CompactMap: 3
        //         🔄 CompactMap: 5
        
        // Scan - accumulate values
        numbers
            .scan(0, +)
            .sink { value in
                print("🔄 Scan (running sum): \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔄 Scan (running sum): 1
        //         🔄 Scan (running sum): 3
        //         🔄 Scan (running sum): 6
        //         🔄 Scan (running sum): 10
        //         🔄 Scan (running sum): 15
    }
    
    // MARK: - Filtering Operators
    func demonstrateFilteringOperators() {
        print("\n=== Filtering Operators ===")
        
        let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].publisher
        
        // Filter - only emit values that pass condition
        numbers
            .filter { $0 % 2 == 0 }
            .sink { value in
                print("🔍 Filter (even): \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔍 Filter (even): 2
        //         🔍 Filter (even): 4
        //         🔍 Filter (even): 6
        //         🔍 Filter (even): 8
        //         🔍 Filter (even): 10
        
        // RemoveDuplicates - remove consecutive duplicates
        [1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 4, 5].publisher
            .removeDuplicates()
            .sink { value in
                print("🔍 RemoveDuplicates: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔍 RemoveDuplicates: 1
        //         🔍 RemoveDuplicates: 2
        //         🔍 RemoveDuplicates: 3
        //         🔍 RemoveDuplicates: 4
        //         🔍 RemoveDuplicates: 5
        
        // DropFirst/DropLast - skip values
        numbers
            .dropFirst(3)
            .dropLast(2)
            .sink { value in
                print("🔍 Drop first 3, last 2: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔍 Drop first 3, last 2: 4
        //         🔍 Drop first 3, last 2: 5
        //         🔍 Drop first 3, last 2: 6
        //         🔍 Drop first 3, last 2: 7
        //         🔍 Drop first 3, last 2: 8
        
        // Prefix/PrefixWhile - take values
        numbers
            .prefix(5)
            .sink { value in
                print("🔍 Prefix (first 5): \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔍 Prefix (first 5): 1
        //         🔍 Prefix (first 5): 2
        //         🔍 Prefix (first 5): 3
        //         🔍 Prefix (first 5): 4
        //         🔍 Prefix (first 5): 5
        
        numbers
            .prefix(while: { $0 < 6 })
            .sink { value in
                print("🔍 PrefixWhile (< 6): \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔍 PrefixWhile (< 6): 1
        //         🔍 PrefixWhile (< 6): 2
        //         🔍 PrefixWhile (< 6): 3
        //         🔍 PrefixWhile (< 6): 4
        //         🔍 PrefixWhile (< 6): 5
    }
    
    // MARK: - Combining Operators
    func demonstrateCombiningOperators() {
        print("\n=== Combining Operators ===")
        
        let publisher1 = [1, 2, 3].publisher
        let publisher2 = ["A", "B", "C"].publisher
        
        // Zip - combine latest values from multiple publishers
        publisher1
            .zip(publisher2)
            .sink { number, letter in
                print("🤝 Zip: \(number)-\(letter)")
            }
            .store(in: &cancellables)
        // Output: 🤝 Zip: 1-A
        //         🤝 Zip: 2-B
        //         🤝 Zip: 3-C
        
        // CombineLatest - combine latest values (emits when any publisher emits)
        let subject1 = PassthroughSubject<Int, Never>()
        let subject2 = PassthroughSubject<String, Never>()
        
        subject1
            .combineLatest(subject2)
            .sink { number, string in
                print("🤝 CombineLatest: \(number)-\(string)")
            }
            .store(in: &cancellables)
        
        subject1.send(1)
        subject2.send("A")
        subject1.send(2)
        subject2.send("B")
        // Output: 🤝 CombineLatest: 1-A (after both have emitted at least once)
        //         🤝 CombineLatest: 2-A (when subject1 emits 2)
        //         🤝 CombineLatest: 2-B (when subject2 emits B)
        
        // Merge - combine multiple publishers of same type
        let publisher3 = [10, 20, 30].publisher
        let publisher4 = [100, 200, 300].publisher
        
        publisher3
            .merge(with: publisher4)
            .sink { value in
                print("🤝 Merge: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🤝 Merge: 10
        //         🤝 Merge: 100
        //         🤝 Merge: 20
        //         🤝 Merge: 200
        //         🤝 Merge: 30
        //         🤝 Merge: 300
        // Note: Order may vary as publishers emit simultaneously
    }
    
    // MARK: - Error Handling Operators
    func demonstrateErrorHandling() {
        print("\n=== Error Handling ===")
        
        let failingPublisher = Fail<String, CustomError>(error: CustomError.networkError)
        
        // Catch - replace error with another publisher
        failingPublisher
            .catch { error in
                Just("Default value after error: \(error)")
            }
            .sink { value in
                print("🛡️ Catch: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🛡️ Catch: Default value after error: networkError
        
        // Retry - retry failed publisher
        let retryPublisher = PassthroughSubject<String, CustomError>()
        
        retryPublisher
            .retry(2)
            .sink(
                receiveCompletion: { completion in
                    print("🛡️ Retry completion: \(completion)")
                },
                receiveValue: { value in
                    print("🛡️ Retry value: \(value)")
                }
            )
            .store(in: &cancellables)
        
        retryPublisher.send("Success")
        retryPublisher.send(completion: .failure(.networkError))
        // Output: 🛡️ Retry value: Success
        //         🛡️ Retry completion: failure(__lldb_expr_XX.CustomError.networkError)
        //         (After 2 retry attempts fail)
        
        // ReplaceError - replace error with default value
        Fail<String, CustomError>(error: CustomError.parsingError)
            .replaceError(with: "Error replaced with default")
            .sink { value in
                print("🛡️ ReplaceError: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🛡️ ReplaceError: Error replaced with default
    }
    
    // MARK: - Timing Operators
    func demonstrateTimingOperators() {
        print("\n=== Timing Operators ===")
        
        let publisher = [1, 2, 3, 4, 5].publisher
        
        // Delay - delay emission of values
        publisher
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { value in
                print("⏱️ Delayed: \(value)")
            }
            .store(in: &cancellables)
        // Output: ⏱️ Delayed: 1 (after 1 second delay)
        //         ⏱️ Delayed: 2 (immediately after first)
        //         ... and so on
        
        // Throttle - emit at most one value per time interval
        let subject = PassthroughSubject<String, Never>()
        
        subject
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sink { value in
                print("⏱️ Throttle: \(value)")
            }
            .store(in: &cancellables)
        
        // Simulate rapid emissions
        subject.send("A")
        subject.send("B")
        subject.send("C")
        // Output: ⏱️ Throttle: A (immediately)
        //         ⏱️ Throttle: C (after throttle period, latest value)
        
        // Debounce - emit only after specified time of silence
        subject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { value in
                print("⏱️ Debounce: \(value)")
            }
            .store(in: &cancellables)
        // Output: ⏱️ Debounce: C (only after 0.5 seconds of silence)
    }
}

// MARK: - Custom Publishers

struct CountdownPublisher: Publisher {
    typealias Output = Int
    typealias Failure = Never
    
    let start: Int
    let interval: TimeInterval
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = CountdownSubscription(
            subscriber: subscriber,
            start: start,
            interval: interval
        )
        subscriber.receive(subscription: subscription)
    }
}

class CountdownSubscription<S: Subscriber>: Subscription where S.Input == Int, S.Failure == Never {
    private var subscriber: S?
    private var current: Int
    private let interval: TimeInterval
    private var timer: Timer?
    
    init(subscriber: S, start: Int, interval: TimeInterval) {
        self.subscriber = subscriber
        self.current = start
        self.interval = interval
    }
    
    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self, let subscriber = self.subscriber else { return }
            
            if self.current >= 0 {
                _ = subscriber.receive(self.current)
                self.current -= 1
            } else {
                subscriber.receive(completion: .finished)
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
        subscriber = nil
    }
}

// MARK: - Schedulers

class CombineSchedulers {
    
    private var cancellables = Set<AnyCancellable>()
    
    func demonstrateSchedulers() {
        print("=== Schedulers ===")
        
        let publisher = [1, 2, 3, 4, 5].publisher
        
        // DispatchQueue scheduler
        publisher
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { value in
                print("🔄 Processing \(value) on: \(Thread.current)")
                return value * 2
            }
            .receive(on: DispatchQueue.main)
            .sink { value in
                print("📱 Received \(value) on main thread: \(Thread.isMainThread)")
            }
            .store(in: &cancellables)
        // Output: 🔄 Processing 1 on: <NSThread: 0x... background thread>
        //         📱 Received 2 on main thread: true
        //         🔄 Processing 2 on: <NSThread: 0x... background thread>
        //         📱 Received 4 on main thread: true
        //         ... and so on
        
        // RunLoop scheduler
        publisher
            .subscribe(on: RunLoop.current)
            .sink { value in
                print("🔄 RunLoop: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔄 RunLoop: 1
        //         🔄 RunLoop: 2
        //         ... and so on
        
        // OperationQueue scheduler
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        
        publisher
            .subscribe(on: operationQueue)
            .sink { value in
                print("⚙️ OperationQueue: \(value)")
            }
            .store(in: &cancellables)
        // Output: ⚙️ OperationQueue: 1
        //         ⚙️ OperationQueue: 2
        //         ... and so on (may be in different order due to concurrency)
    }
}

// MARK: - Real-World Examples

// MARK: - Network Service with Combine
class NetworkService {
    
    private let session = URLSession.shared
    
    func fetchUser(id: Int) -> AnyPublisher<User, Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users/\(id)")!
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchPosts(for userId: Int) -> AnyPublisher<[Post], Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts?userId=\(userId)")!
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchUserWithPosts(id: Int) -> AnyPublisher<UserWithPosts6, Error> {
        return fetchUser(id: id)
            .flatMap { user in
                self.fetchPosts(for: user.id)
                    .map { posts in
                        UserWithPosts6(user: user, posts: posts)
                    }
            }
            .eraseToAnyPublisher()
    }
}

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let username: String
}

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct UserWithPosts6 {
    let user: User
    let posts: [Post]
}

// MARK: - Search with Debouncing
class SearchViewModel6: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [String] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let searchService = SearchService6()
    
    init() {
        setupSearch()
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(query: searchText)
            }
            .store(in: &cancellables)
        // Output: Triggers search 500ms after user stops typing
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        
        searchService.search(query: query)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Search error: \(error)")
                    }
                },
                receiveValue: { [weak self] results in
                    self?.searchResults = results
                }
            )
            .store(in: &cancellables)
    }
}

class SearchService6 {
    func search(query: String) -> AnyPublisher<[String], Error> {
        // Simulate network search
        return Just(mockSearchResults(for: query))
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.global())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func mockSearchResults(for query: String) -> [String] {
        let allResults = [
            "Apple", "Banana", "Cherry", "Date", "Elderberry",
            "Fig", "Grape", "Honeydew", "Kiwi", "Lemon"
        ]
        
        return allResults.filter { $0.lowercased().contains(query.lowercased()) }
    }
    // Example: search("ap") would return ["Apple", "Grape"]
}

// MARK: - Form Validation with Combine
class FormViewModel6: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    @Published var isPasswordConfirmed = false
    @Published var isFormValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        // Email validation
        $email
            .map { email in
                email.contains("@") && email.contains(".")
            }
            .assign(to: &$isEmailValid)
        // Output: Updates isEmailValid as user types email
        
        // Password validation
        $password
            .map { password in
                password.count >= 8
            }
            .assign(to: &$isPasswordValid)
        // Output: Updates isPasswordValid when password length >= 8
        
        // Password confirmation
        Publishers.CombineLatest($password, $confirmPassword)
            .map { password, confirmPassword in
                !password.isEmpty && password == confirmPassword
            }
            .assign(to: &$isPasswordConfirmed)
        // Output: Updates isPasswordConfirmed when passwords match
        
        // Overall form validation
        Publishers.CombineLatest3($isEmailValid, $isPasswordValid, $isPasswordConfirmed)
            .map { emailValid, passwordValid, passwordConfirmed in
                emailValid && passwordValid && passwordConfirmed
            }
            .assign(to: &$isFormValid)
        // Output: Updates isFormValid when all validation criteria are met
    }
}

// MARK: - Data Binding with Combine
class DataBindingExample: ObservableObject {
    @Published var items: [Item] = []
    @Published var filteredItems: [Item] = []
    @Published var filterText = ""
    @Published var sortAscending = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadInitialData()
        setupDataBinding()
    }
    
    private func loadInitialData() {
        items = [
            Item(name: "Apple", category: "Fruit", price: 1.50),
            Item(name: "Banana", category: "Fruit", price: 0.80),
            Item(name: "Carrot", category: "Vegetable", price: 0.60),
            Item(name: "Broccoli", category: "Vegetable", price: 2.00),
            Item(name: "Chicken", category: "Meat", price: 8.00)
        ]
    }
    
    private func setupDataBinding() {
        // Combine filtering and sorting
        Publishers.CombineLatest3($items, $filterText, $sortAscending)
            .map { items, filterText, sortAscending in
                let filtered = filterText.isEmpty ? items : items.filter {
                    $0.name.lowercased().contains(filterText.lowercased()) ||
                    $0.category.lowercased().contains(filterText.lowercased())
                }
                
                return filtered.sorted { item1, item2 in
                    sortAscending ? item1.name < item2.name : item1.name > item2.name
                }
            }
            .assign(to: &$filteredItems)
        // Output: Updates filteredItems whenever items, filterText, or sortAscending changes
        // Example: filterText="fruit" would show Apple, Banana (sorted by name)
    }
    
    func addItem(_ item: Item) {
        items.append(item)
    }
    
    func removeItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
    }
}

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let price: Double
}

// MARK: - Combine with SwiftUI
struct CombineSwiftUIExample: View {
    @StateObject private var searchViewModel = SearchViewModel6()
    @StateObject private var formViewModel = FormViewModel6()
    @StateObject private var dataViewModel = DataBindingExample()
    
    var body: some View {
        NavigationView {
            List {
                Section("Search Example") {
                    TextField("Search...", text: $searchViewModel.searchText)
                    
                    if searchViewModel.isLoading {
                        ProgressView("Searching...")
                    } else {
                        ForEach(searchViewModel.searchResults, id: \.self) { result in
                            Text(result)
                        }
                    }
                }
                
                Section("Form Validation") {
                    TextField("Email", text: $formViewModel.email)
                        .foregroundColor(formViewModel.isEmailValid ? .green : .red)
                    
                    SecureField("Password", text: $formViewModel.password)
                        .foregroundColor(formViewModel.isPasswordValid ? .green : .red)
                    
                    SecureField("Confirm Password", text: $formViewModel.confirmPassword)
                        .foregroundColor(formViewModel.isPasswordConfirmed ? .green : .red)
                    
                    Button("Submit") {
                        print("Form submitted!")
                    }
                    .disabled(!formViewModel.isFormValid)
                }
                
                Section("Data Binding") {
                    HStack {
                        TextField("Filter items...", text: $dataViewModel.filterText)
                        Toggle("Sort A-Z", isOn: $dataViewModel.sortAscending)
                    }
                    
                    ForEach(dataViewModel.filteredItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.category)
                                .foregroundColor(.secondary)
                            Text("$\(item.price, specifier: "%.2f")")
                                .bold()
                        }
                    }
                }
            }
            .navigationTitle("Combine Examples")
        }
    }
}

// MARK: - Advanced Combine Patterns

class AdvancedCombinePatterns6 {
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Backpressure Handling
    func demonstrateBackpressure() {
        print("=== Backpressure Handling ===")
        
        let fastPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Int.random(in: 1...1000) }
        
        // Buffer - collect values when downstream is slow
        fastPublisher
            .buffer(size: 5, prefetch: .keepFull, whenFull: .dropOldest)
            .sink { values in
                print("📦 Buffered: \(values)")
            }
            .store(in: &cancellables)
        // Output: 📦 Buffered: [random numbers] (first buffer of 5)
        //         📦 Buffered: [random numbers] (second buffer of 5)
        //         ... and so on every 0.5 seconds (5 * 0.1)
        
        // Throttle - limit emission rate
        fastPublisher
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sink { value in
                print("⏱️ Throttled: \(value)")
            }
            .store(in: &cancellables)
        // Output: ⏱️ Throttled: 542 (first emission immediately)
        //         ⏱️ Throttled: 789 (latest value after 1 second)
        //         ... and so on every 1 second
    }
    
    // MARK: - Memory Management
    func demonstrateMemoryManagement() {
        print("=== Memory Management ===")
        
        class DataProcessor {
            private var cancellables = Set<AnyCancellable>()
            
            init() {
                // Weak self to avoid retain cycles
                Timer.publish(every: 1.0, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] date in
                        self?.processData(at: date)
                    }
                    .store(in: &cancellables)
            }
            
            private func processData(at date: Date) {
                print("Processing data at: \(date)")
            }
            
            deinit {
                print("DataProcessor deallocated")
            }
        }
        
        var processor: DataProcessor? = DataProcessor()
        
        // Simulate deallocation after some time
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            processor = nil
        }
        // Output: Processing data at: 2023-07-31 15:45:23 +0000 (first emission)
        //         Processing data at: 2023-07-31 15:45:24 +0000 (second emission)
        //         Processing data at: 2023-07-31 15:45:25 +0000 (third emission)
        //         DataProcessor deallocated (after 3 seconds)
    }
    
    // MARK: - Custom Operators
    func demonstrateCustomOperators() {
        print("=== Custom Operators ===")
        
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].publisher
            .evenNumbers()
            .multiplyBy(3)
            .sink { value in
                print("🔧 Custom operators result: \(value)")
            }
            .store(in: &cancellables)
        // Output: 🔧 Custom operators result: 6 (2 * 3)
        //         🔧 Custom operators result: 12 (4 * 3)
        //         🔧 Custom operators result: 18 (6 * 3)
        //         🔧 Custom operators result: 24 (8 * 3)
        //         🔧 Custom operators result: 30 (10 * 3)
    }
}

// Custom operator extensions
extension Publisher where Output == Int {
    func evenNumbers() -> Publishers.Filter<Self> {
        return filter { $0 % 2 == 0 }
    }
    
    func multiplyBy(_ factor: Int) -> Publishers.Map<Self, Int> {
        return map { $0 * factor }
    }
}

// MARK: - Usage Examples

class CombineUsageExamples {
    
    private var cancellables = Set<AnyCancellable>()
    
    func runAllExamples() {
        let basics = CombineBasics()
        basics.demonstrateBasicPublishers()
        basics.demonstrateSubjects()
        basics.demonstrateTimerPublishers()
        
        let operators = CombineOperators()
        operators.demonstrateTransformationOperators()
        operators.demonstrateFilteringOperators()
        operators.demonstrateCombiningOperators()
        operators.demonstrateErrorHandling()
        operators.demonstrateTimingOperators()
        
        let schedulers = CombineSchedulers()
        schedulers.demonstrateSchedulers()
        
        // Custom publisher example
        CountdownPublisher(start: 5, interval: 1.0)
            .sink(
                receiveCompletion: { completion in
                    print("🚀 Countdown completed: \(completion)")
                },
                receiveValue: { value in
                    print("🚀 Countdown: \(value)")
                }
            )
            .store(in: &cancellables)
        // Output: 🚀 Countdown: 5 (immediately)
        //         🚀 Countdown: 4 (after 1 second)
        //         🚀 Countdown: 3 (after 2 seconds)
        //         🚀 Countdown: 2 (after 3 seconds)
        //         🚀 Countdown: 1 (after 4 seconds)
        //         🚀 Countdown: 0 (after 5 seconds)
        //         🚀 Countdown completed: finished (after 6 seconds)
        
        // Network example
        let networkService = NetworkService()
        networkService.fetchUserWithPosts(id: 1)
            .sink(
                receiveCompletion: { completion in
                    print("🌐 Network completion: \(completion)")
                },
                receiveValue: { userWithPosts in
                    print("🌐 User: \(userWithPosts.user.name), Posts: \(userWithPosts.posts.count)")
                }
            )
            .store(in: &cancellables)
        // Output: 🌐 User: Leanne Graham, Posts: 10 (example with successful API response)
        //         🌐 Network completion: finished
        // Or on error: 🌐 Network completion: failure(URLError(.notConnectedToInternet))
        
        let advancedPatterns = AdvancedCombinePatterns6()
        advancedPatterns.demonstrateBackpressure()
        advancedPatterns.demonstrateMemoryManagement()
        advancedPatterns.demonstrateCustomOperators()
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Core Combine Concepts**:
    - Publisher: Declares that a type can transmit values over time
    - Subscriber: Receives values from publishers
    - Subscription: Connection between publisher and subscriber
    - Cancellable: Allows cancellation of subscriptions

 2. **Publisher Types**:
    - Just: Emits single value then completes
    - Empty: Completes immediately without values
    - Fail: Immediately fails with error
    - Future: Asynchronous operation that emits single value
    - PassthroughSubject: Doesn't hold current value
    - CurrentValueSubject: Holds and emits current value

 3. **Key Operators**:
    - Transformation: map, flatMap, compactMap, scan
    - Filtering: filter, removeDuplicates, prefix, dropFirst
    - Combining: zip, combineLatest, merge
    - Error Handling: catch, retry, replaceError
    - Timing: delay, throttle, debounce

 4. **Schedulers**:
    - Control where and when work is performed
    - DispatchQueue: GCD-based scheduling
    - RunLoop: Run loop-based scheduling
    - OperationQueue: Operation queue-based scheduling
    - ImmediateScheduler: Immediate execution

 5. **Memory Management**:
    - Use Set<AnyCancellable> to store subscriptions
    - Weak self in closures to avoid retain cycles
    - Automatic cancellation when AnyCancellable is deallocated
    - Store subscriptions properly to prevent early deallocation

 6. **Error Handling**:
    - Publishers can have failure type (Never for no errors)
    - Catch operator replaces errors with fallback publisher
    - Retry operator attempts failed operation multiple times
    - ReplaceError provides default value on error

 7. **SwiftUI Integration**:
    - @Published property wrapper creates publisher
    - ObservableObject protocol for view models
    - Automatic UI updates when published values change
    - assign(to:) for direct property assignment

 8. **Common Patterns**:
    - Search with debouncing
    - Form validation with multiple inputs
    - Network requests with error handling
    - Data transformation pipelines

 9. **Common Interview Questions**:
    - Q: What's the difference between PassthroughSubject and CurrentValueSubject?
    - A: CurrentValueSubject holds current value, PassthroughSubject doesn't

    - Q: How do you prevent retain cycles in Combine?
    - A: Use weak self in closures and store cancellables properly

    - Q: What's the difference between flatMap and map?
    - A: flatMap flattens nested publishers, map transforms values

    - Q: How do you handle backpressure in Combine?
    - A: Use buffer, throttle, or debounce operators

 10. **Advanced Topics**:
     - Custom publishers and subscribers
     - Backpressure handling
     - Custom operators
     - Performance optimization
     - Testing Combine code

 11. **Best Practices**:
     - Store cancellables in Set<AnyCancellable>
     - Use appropriate schedulers for different operations
     - Handle errors gracefully
     - Use weak self to prevent retain cycles
     - Choose right operators for data transformation

 12. **Performance Considerations**:
     - Avoid creating too many subscriptions
     - Use appropriate schedulers
     - Cancel subscriptions when not needed
     - Be mindful of operator chaining complexity
     - Profile memory usage with instruments
*/ 

