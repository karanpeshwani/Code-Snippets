//
//  TCA-Composable-Architecture.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import SwiftUI
import Foundation

// MARK: - Basic TCA Implementation (Simplified for Demo)

// MARK: - State
struct CounterState1: Equatable {
    var count = 0
    var isLoading = false
    var alert: AlertState1?
}

struct AlertState1: Equatable {
    let title: String
    let message: String
    let primaryButton: String
    let secondaryButton: String?
    
    init(title: String, message: String, primaryButton: String = "OK", secondaryButton: String? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

// MARK: - Actions
enum CounterAction1: Equatable {
    case increment
    case decrement
    case reset
    case factorialButtonTapped
    case factorialResponse(Int)
    case alertDismissed
    case alertPrimaryButtonTapped
    case alertSecondaryButtonTapped
}

// MARK: - Environment (Dependencies)
struct CounterEnvironment1 {
    let factorial: (Int) -> Effect1<Int>
    let mainQueue: DispatchQueue
    
    static let live = CounterEnvironment1(
        factorial: { number in
            Effect1.future { callback in
                DispatchQueue.global().async {
                    let result = (1...max(1, number)).reduce(1, *)
                    Thread.sleep(forTimeInterval: 1) // Simulate delay
                    callback(.success(result))
                }
            }
        },
        mainQueue: .main
    )
    
    static let mock = CounterEnvironment1(
        factorial: { number in
            Effect1.just(120) // Mock factorial result
        },
        mainQueue: .main
    )
}

// MARK: - Effects (Simplified Implementation)
struct Effect1<Value> {
    let run: (@escaping (Value) -> Void) -> Void
    
    static func just(_ value: Value) -> Effect1<Value> {
        return Effect1 { callback in
            callback(value)
        }
    }
    
    static func future(_ work: @escaping (@escaping (Result<Value, Error>) -> Void) -> Void) -> Effect1<Value> {
        return Effect1 { callback in
            work { result in
                switch result {
                case .success(let value):
                    callback(value)
                case .failure:
                    // Handle error appropriately in real implementation
                    break
                }
            }
        }
    }
    
    func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Effect1<NewValue> {
        return Effect1<NewValue> { callback in
            self.run { value in
                callback(transform(value))
            }
        }
    }
}

// MARK: - Reducer
func counterReducer1(
    state: inout CounterState1,
    action: CounterAction1,
    environment: CounterEnvironment1
) -> Effect1<CounterAction1>? {
    
    switch action {
    case .increment:
        state.count += 1
        return nil
        
    case .decrement:
        state.count -= 1
        return nil
        
    case .reset:
        state.count = 0
        state.alert = AlertState1(
            title: "Reset Complete",
            message: "Counter has been reset to 0"
        )
        return nil
        
    case .factorialButtonTapped:
        state.isLoading = true
        return environment.factorial(state.count)
            .map(CounterAction1.factorialResponse)
        
    case .factorialResponse(let result):
        state.isLoading = false
        state.alert = AlertState1(
            title: "Factorial Result",
            message: "Factorial of \(state.count) is \(result)",
            primaryButton: "OK",
            secondaryButton: "Reset"
        )
        return nil
        
    case .alertDismissed:
        state.alert = nil
        return nil
        
    case .alertPrimaryButtonTapped:
        state.alert = nil
        return nil
        
    case .alertSecondaryButtonTapped:
        state.alert = nil
        return Effect1.just(.reset)
    }
}

// MARK: - Store (Simplified Implementation)
class Store1<State, Action>: ObservableObject {
    @Published private(set) var state: State
    
    private let reducer: (inout State, Action, CounterEnvironment1) -> Effect1<Action>?
    private let environment: CounterEnvironment1
    
    init(
        initialState: State,
        reducer: @escaping (inout State, Action, CounterEnvironment1) -> Effect1<Action>?,
        environment: CounterEnvironment1
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }
    
    func send(_ action: Action) {
        DispatchQueue.main.async {
            let effect = self.reducer(&self.state, action, self.environment)
            
            effect?.run { resultAction in
                DispatchQueue.main.async {
                    self.send(resultAction)
                }
            }
        }
    }
}

// MARK: - Counter View
struct CounterView1: View {
    let store: Store1<CounterState1, CounterAction1>
    
    var body: some View {
        WithViewStore1(store) { viewStore in
            VStack(spacing: 20) {
                Text("TCA Counter Example")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(viewStore.count)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 20) {
                    Button("-") {
                        viewStore.send(.decrement)
                    }
                    .buttonStyle(CounterButtonStyle1(color: .red))
                    
                    Button("+") {
                        viewStore.send(.increment)
                    }
                    .buttonStyle(CounterButtonStyle1(color: .green))
                }
                
                Button("Reset") {
                    viewStore.send(.reset)
                }
                .buttonStyle(CounterButtonStyle1(color: .orange))
                
                Button("Calculate Factorial") {
                    viewStore.send(.factorialButtonTapped)
                }
                .buttonStyle(CounterButtonStyle1(color: .blue))
                .disabled(viewStore.isLoading)
                
                if viewStore.isLoading {
                    ProgressView("Calculating...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
            .alert(
                item: Binding<AlertItem1?>(
                    get: { viewStore.alert.map(AlertItem1.init) },
                    set: { _ in viewStore.send(.alertDismissed) }
                )
            ) { alertItem in
                Alert(
                    title: Text(alertItem.alert.title),
                    message: Text(alertItem.alert.message),
                    primaryButton: .default(Text(alertItem.alert.primaryButton)) {
                        viewStore.send(.alertPrimaryButtonTapped)
                    },
                    secondaryButton: alertItem.alert.secondaryButton.map { buttonTitle in
                        .default(Text(buttonTitle)) {
                            viewStore.send(.alertSecondaryButtonTapped)
                        }
                    }
                )
            }
        }
    }
}

// MARK: - ViewStore (Simplified Implementation)
struct WithViewStore1<State, Action, Content: View>: View {
    let store: Store1<State, Action>
    let content: (ViewStore1<State, Action>) -> Content
    
    init(
        _ store: Store1<State, Action>,
        @ViewBuilder content: @escaping (ViewStore1<State, Action>) -> Content
    ) {
        self.store = store
        self.content = content
    }
    
    var body: some View {
        content(ViewStore1(store: store))
    }
}

struct ViewStore1<State, Action> {
    private let store: Store1<State, Action>
    
    init(store: Store1<State, Action>) {
        self.store = store
    }
    
    var state: State {
        store.state
    }
    
    func send(_ action: Action) {
        store.send(action)
    }
}

// Helper for alert presentation
struct AlertItem1: Identifiable {
    let id = UUID()
    let alert: AlertState1
}

// MARK: - Custom Button Style
struct CounterButtonStyle1: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(color)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Todo List Example (More Complex TCA Usage)

// MARK: - Todo Models
struct Todo1: Equatable, Identifiable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
    var createdAt = Date()
}

// MARK: - Todo State
struct TodoState1: Equatable {
    var todos: [Todo1] = []
    var newTodoText = ""
    var filter: TodoFilter1 = .all
    var isLoading = false
}

enum TodoFilter1: String, CaseIterable, Equatable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

// MARK: - Todo Actions
enum TodoAction1: Equatable {
    case newTodoTextChanged(String)
    case addTodoButtonTapped
    case todoToggled(UUID)
    case todoDeleted(UUID)
    case filterChanged(TodoFilter1)
    case clearCompletedButtonTapped
    case loadTodos
    case todosLoaded([Todo1])
}

// MARK: - Todo Environment
struct TodoEnvironment1 {
    let saveTodos: ([Todo1]) -> Effect1<Void>
    let loadTodos: () -> Effect1<[Todo1]>
    let uuid: () -> UUID
    let date: () -> Date
    
    static let live = TodoEnvironment1(
        saveTodos: { todos in
            Effect1.future { callback in
                // Simulate saving to persistence
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    callback(.success(()))
                }
            }
        },
        loadTodos: {
            Effect1.future { callback in
                // Simulate loading from persistence
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    let mockTodos = [
                        Todo1(text: "Learn TCA", isCompleted: false),
                        Todo1(text: "Build awesome apps", isCompleted: false)
                    ]
                    callback(.success(mockTodos))
                }
            }
        },
        uuid: UUID.init,
        date: Date.init
    )
}

// MARK: - Todo Reducer
func todoReducer1(
    state: inout TodoState1,
    action: TodoAction1,
    environment: TodoEnvironment1
) -> Effect1<TodoAction1>? {
    
    switch action {
    case .newTodoTextChanged(let text):
        state.newTodoText = text
        return nil
        
    case .addTodoButtonTapped:
        let trimmedText = state.newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return nil }
        
        let newTodo = Todo1(
            text: trimmedText,
            isCompleted: false,
            createdAt: environment.date()
        )
        state.todos.insert(newTodo, at: 0)
        state.newTodoText = ""
        
        return environment.saveTodos(state.todos)
            .map { _ in TodoAction1.loadTodos }
        
    case .todoToggled(let id):
        if let index = state.todos.firstIndex(where: { $0.id == id }) {
            state.todos[index].isCompleted.toggle()
        }
        return environment.saveTodos(state.todos)
            .map { _ in TodoAction1.loadTodos }
        
    case .todoDeleted(let id):
        state.todos.removeAll { $0.id == id }
        return environment.saveTodos(state.todos)
            .map { _ in TodoAction1.loadTodos }
        
    case .filterChanged(let filter):
        state.filter = filter
        return nil
        
    case .clearCompletedButtonTapped:
        state.todos.removeAll { $0.isCompleted }
        return environment.saveTodos(state.todos)
            .map { _ in TodoAction1.loadTodos }
        
    case .loadTodos:
        state.isLoading = true
        return environment.loadTodos()
            .map(TodoAction1.todosLoaded)
        
    case .todosLoaded(let todos):
        state.isLoading = false
        state.todos = todos
        return nil
    }
}

// MARK: - Todo View
struct TodoView1: View {
    let store: Store1<TodoState1, TodoAction1>
    
    var body: some View {
        WithViewStore1(store) { viewStore in
            NavigationView {
                VStack {
                    // Add todo section
                    HStack {
                        TextField("Enter new todo", text: viewStore.binding(
                            get: \.newTodoText,
                            send: TodoAction1.newTodoTextChanged
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Add") {
                            viewStore.send(.addTodoButtonTapped)
                        }
                        .disabled(viewStore.newTodoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                    
                    // Filter picker
                    Picker("Filter", selection: viewStore.binding(
                        get: \.filter,
                        send: TodoAction1.filterChanged
                    )) {
                        ForEach(TodoFilter1.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Todo list
                    List {
                        ForEach(filteredTodos(viewStore.todos, filter: viewStore.filter)) { todo in
                            TodoRowView1(
                                todo: todo,
                                onToggle: { viewStore.send(.todoToggled(todo.id)) },
                                onDelete: { viewStore.send(.todoDeleted(todo.id)) }
                            )
                        }
                    }
                    
                    // Clear completed button
                    if viewStore.todos.contains(where: \.isCompleted) {
                        Button("Clear Completed") {
                            viewStore.send(.clearCompletedButtonTapped)
                        }
                        .padding()
                    }
                }
                .navigationTitle("TCA Todos")
                .onAppear {
                    viewStore.send(.loadTodos)
                }
            }
        }
    }
    
    private func filteredTodos(_ todos: [Todo1], filter: TodoFilter1) -> [Todo1] {
        switch filter {
        case .all:
            return todos
        case .active:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { \.isCompleted }
        }
    }
}

// MARK: - Todo Row View
struct TodoRowView1: View {
    let todo: Todo1
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            
            Text(todo.text)
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ViewStore Binding Extension
extension ViewStore1 {
    func binding<Value>(
        get: @escaping (State) -> Value,
        send: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { get(self.state) },
            set: { self.send(send($0)) }
        )
    }
}

// MARK: - Main TCA Demo View
struct TCADemoView1: View {
    var body: some View {
        TabView {
            CounterView1(
                store: Store1(
                    initialState: CounterState1(),
                    reducer: counterReducer1,
                    environment: .live
                )
            )
            .tabItem {
                Image(systemName: "plus.minus")
                Text("Counter")
            }
            
            TodoView1(
                store: Store1(
                    initialState: TodoState1(),
                    reducer: todoReducer1,
                    environment: .live
                )
            )
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Todos")
            }
        }
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **TCA Core Concepts**:
    - State: Single source of truth for app state
    - Actions: All possible ways state can change
    - Reducers: Pure functions that evolve state
    - Effects: Handle side effects and async operations
    - Environment: Dependency injection container

 2. **State Management**:
    - Unidirectional data flow
    - Predictable state changes
    - Immutable state updates
    - Centralized state management
    - State composition and modularity

 3. **Actions and Reducers**:
    - Actions are enum cases describing what happened
    - Reducers are pure functions (State, Action) -> (State, Effect)
    - No side effects in reducers
    - Testable business logic
    - Composable reducers

 4. **Effects System**:
    - Handle async operations
    - Network requests, timers, location services
    - Convert effects back to actions
    - Cancellable operations
    - Effect composition

 5. **Environment (Dependencies)**:
    - Dependency injection pattern
    - Easy testing with mock environments
    - API clients, date providers, UUID generators
    - Environment composition
    - Live vs mock implementations

 6. **View Integration**:
    - Store connects state to views
    - ViewStore provides bindings
    - Automatic UI updates on state changes
    - SwiftUI integration
    - Scoped stores for performance

 7. **Benefits of TCA**:
    - Predictable state management
    - Excellent testability
    - Time-travel debugging
    - Modular architecture
    - Side effect management

 8. **Common Interview Questions**:
    - Q: What problems does TCA solve?
    - A: Predictable state management, testability, side effect handling
    
    - Q: How does TCA compare to Redux?
    - A: Similar concepts, but Swift-specific with better type safety
    
    - Q: When would you use TCA?
    - A: Complex state management, team collaboration, testability requirements
    
    - Q: What are TCA's main components?
    - A: State, Actions, Reducers, Effects, Environment

 9. **Testing Benefits**:
    - Pure functions are easy to test
    - Mock environments for dependencies
    - Predictable state transitions
    - Effect testing capabilities
    - Integration test support

 10. **Performance Considerations**:
     - State changes trigger view updates
     - Use scoped stores for large apps
     - Optimize reducer performance
     - Effect cancellation for cleanup
     - Memory management with proper cleanup

 11. **Advanced Patterns**:
     - State composition with multiple reducers
     - Effect cancellation and cleanup
     - Dependency injection patterns
     - Navigation with TCA
     - Error handling strategies

 12. **Real-world Usage**:
     - Large-scale app architecture
     - Team development benefits
     - Debugging and development tools
     - State persistence patterns
     - Modular feature development
*/ 