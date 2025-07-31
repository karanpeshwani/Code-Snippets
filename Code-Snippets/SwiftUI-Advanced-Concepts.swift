//
//  SwiftUI-Advanced-Concepts.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import SwiftUI
import Combine
import Foundation

// MARK: - @ViewBuilder Advanced Usage

struct ViewBuilderExamples8: View {
    
    @State private var showAdvanced = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Basic ViewBuilder usage
            conditionalContent
            
            Divider()
            
            // Advanced ViewBuilder with generic content
            CustomContainer8 {
                Text("First item")
                Text("Second item")
                if showAdvanced {
                    Text("Advanced item")
                        .foregroundColor(.blue)
                }
            }
            
            Toggle("Show Advanced", isOn: $showAdvanced)
                .padding()
        }
    }
    
    // ViewBuilder computed property
    @ViewBuilder
    private var conditionalContent: some View {
        if selectedTab == 0 {
            VStack {
                Text("Home Content")
                    .font(.title)
                Button("Go to Settings") {
                    selectedTab = 1
                }
            }
        } else {
            VStack {
                Text("Settings Content")
                    .font(.title)
                Button("Go to Home") {
                    selectedTab = 0
                }
            }
        }
    }
}

// Custom container using @ViewBuilder
struct CustomContainer8<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Custom Container")
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            content
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
}

// Advanced ViewBuilder with result builder
struct FlexibleLayout8<Content: View>: View {
    let content: Content
    let axis: Axis
    
    init(axis: Axis = .vertical, @ViewBuilder content: () -> Content) {
        self.axis = axis
        self.content = content()
    }
    
    var body: some View {
        Group {
            if axis == .vertical {
                VStack(spacing: 8) {
                    content
                }
            } else {
                HStack(spacing: 8) {
                    content
                }
            }
        }
    }
}

// MARK: - Environment Variables and EnvironmentObject

// Custom Environment Key
private struct ThemeEnvironmentKey8: EnvironmentKey {
    static let defaultValue = Theme8.light
}

extension EnvironmentValues {
    var theme8: Theme8 {
        get { self[ThemeEnvironmentKey8.self] }
        set { self[ThemeEnvironmentKey8.self] = newValue }
    }
}

struct Theme8 {
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    
    static let light = Theme8(
        backgroundColor: .white,
        textColor: .black,
        accentColor: .blue
    )
    
    static let dark = Theme8(
        backgroundColor: .black,
        textColor: .white,
        accentColor: .orange
    )
}

// Environment Object for global state
class AppSettings8: ObservableObject {
    @Published var isDarkMode = false
    @Published var fontSize: Double = 16
    @Published var language = "en"
    @Published var notifications = true
    
    var currentTheme: Theme8 {
        return isDarkMode ? .dark : .light
    }
}

// User preferences environment object
class UserPreferences8: ObservableObject {
    @Published var favoriteColor = Color.blue
    @Published var username = "User"
    @Published var profileImage: String?
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadPreferences()
    }
    
    private func loadPreferences() {
        // Load from UserDefaults
        username = userDefaults.string(forKey: "username") ?? "User"
        notifications = userDefaults.bool(forKey: "notifications")
    }
    
    func savePreferences() {
        userDefaults.set(username, forKey: "username")
        userDefaults.set(notifications, forKey: "notifications")
    }
    
    @Published var notifications = true
}

// Environment demonstration view
struct EnvironmentDemoView8: View {
    @Environment(\.theme8) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var appSettings: AppSettings8
    @EnvironmentObject private var userPreferences: UserPreferences8
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Environment Demo")
                .font(.title)
                .foregroundColor(theme.textColor)
            
            Text("Hello, \(userPreferences.username)!")
                .font(.system(size: appSettings.fontSize))
                .foregroundColor(theme.textColor)
            
            HStack {
                Text("Theme:")
                Text(colorScheme == .dark ? "Dark" : "Light")
                    .foregroundColor(theme.accentColor)
            }
            
            Button("Toggle Dark Mode") {
                appSettings.isDarkMode.toggle()
            }
            .foregroundColor(theme.accentColor)
            
            Slider(value: $appSettings.fontSize, in: 12...24) {
                Text("Font Size")
            }
            
            Toggle("Notifications", isOn: $userPreferences.notifications)
        }
        .padding()
        .background(theme.backgroundColor)
        .environment(\.theme8, appSettings.currentTheme)
    }
}

// MARK: - Custom View Modifiers

// Basic custom modifier
struct BorderedModifier8: ViewModifier {
    let color: Color
    let width: CGFloat
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: width)
            )
    }
}

// Animated modifier
struct PulseModifier8: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// Conditional modifier
struct ConditionalModifier8<TrueContent: ViewModifier, FalseContent: ViewModifier>: ViewModifier {
    let condition: Bool
    let trueModifier: TrueContent
    let falseModifier: FalseContent
    
    func body(content: Content) -> some View {
        Group {
            if condition {
                content.modifier(trueModifier)
            } else {
                content.modifier(falseModifier)
            }
        }
    }
}

// Responsive modifier
struct ResponsiveModifier8: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func body(content: Content) -> some View {
        content
            .padding(horizontalSizeClass == .compact ? 8 : 16)
            .font(horizontalSizeClass == .compact ? .body : .title2)
    }
}

// Extension for easier modifier usage
extension View {
    func bordered(color: Color = .blue, width: CGFloat = 2, cornerRadius: CGFloat = 8) -> some View {
        modifier(BorderedModifier8(color: color, width: width, cornerRadius: cornerRadius))
    }
    
    func pulse() -> some View {
        modifier(PulseModifier8())
    }
    
    func conditional<T: ViewModifier, F: ViewModifier>(
        _ condition: Bool,
        trueModifier: T,
        falseModifier: F
    ) -> some View {
        modifier(ConditionalModifier8(
            condition: condition,
            trueModifier: trueModifier,
            falseModifier: falseModifier
        ))
    }
    
    func responsive() -> some View {
        modifier(ResponsiveModifier8())
    }
}

// MARK: - Advanced State Management

// State management with Combine
class AdvancedViewModel8: ObservableObject {
    @Published var items: [Item8] = []
    @Published var searchText = ""
    @Published var selectedCategory: Category8 = .all
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var filteredItems: [Item8] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    private func setupBindings() {
        // Combine search text and category selection for filtering
        Publishers.CombineLatest3($items, $searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { items, searchText, category in
                self.filterItems(items, searchText: searchText, category: category)
            }
            .assign(to: &$filteredItems)
    }
    
    private func filterItems(_ items: [Item8], searchText: String, category: Category8) -> [Item8] {
        var filtered = items
        
        // Filter by category
        if category != .all {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    func loadInitialData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate async data loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.items = [
                Item8(name: "iPhone", description: "Smartphone", category: .electronics, price: 999),
                Item8(name: "MacBook", description: "Laptop computer", category: .electronics, price: 1299),
                Item8(name: "Swift Programming", description: "Programming book", category: .books, price: 49),
                Item8(name: "Coffee Mug", description: "Ceramic mug", category: .home, price: 15),
                Item8(name: "Running Shoes", description: "Athletic footwear", category: .sports, price: 120)
            ]
            self.isLoading = false
        }
    }
    
    func addItem(_ item: Item8) {
        items.append(item)
    }
    
    func removeItem(at index: Int) {
        guard index < filteredItems.count else { return }
        let itemToRemove = filteredItems[index]
        items.removeAll { $0.id == itemToRemove.id }
    }
}

struct Item8: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let category: Category8
    let price: Double
}

enum Category8: String, CaseIterable {
    case all = "All"
    case electronics = "Electronics"
    case books = "Books"
    case home = "Home"
    case sports = "Sports"
}

// MARK: - Performance Optimization

// LazyVStack with performance monitoring
struct PerformantListView8: View {
    @StateObject private var viewModel = AdvancedViewModel8()
    @State private var renderCount = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Performance indicator
                HStack {
                    Text("Renders: \(renderCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Search and filter controls
                SearchAndFilterView8(
                    searchText: $viewModel.searchText,
                    selectedCategory: $viewModel.selectedCategory
                )
                
                // Performant list
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredItems) { item in
                            ItemRowView8(item: item)
                                .onAppear {
                                    // Track when items appear (for analytics)
                                    print("Item appeared: \(item.name)")
                                }
                        }
                        .onDelete(perform: viewModel.removeItem)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Performant List")
            .onAppear {
                renderCount += 1
            }
        }
    }
}

// Optimized search and filter view
struct SearchAndFilterView8: View {
    @Binding var searchText: String
    @Binding var selectedCategory: Category8
    
    var body: some View {
        VStack(spacing: 12) {
            // Search field
            TextField("Search items...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Category picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(Category8.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
    }
}

// Optimized item row view
struct ItemRowView8: View {
    let item: Item8
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(item.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Text("$\(item.price, specifier: "%.0f")")
                .font(.title3)
                .bold()
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// MARK: - Custom Shapes and Animations

struct CustomShapes8: View {
    @State private var animationProgress: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Custom triangle shape
            Triangle8()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(animationProgress * 360))
            
            // Custom star shape
            Star8(points: 5)
                .stroke(Color.yellow, lineWidth: 2)
                .frame(width: 80, height: 80)
                .scaleEffect(1 + animationProgress * 0.5)
            
            // Custom wave shape
            Wave8(animationProgress: animationProgress)
                .fill(
                    LinearGradient(
                        colors: [.blue, .green],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 100)
            
            Button("Animate") {
                withAnimation(.easeInOut(duration: 2)) {
                    animationProgress = isAnimating ? 0 : 1
                    isAnimating.toggle()
                }
            }
        }
        .padding()
    }
}

// Custom triangle shape
struct Triangle8: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// Custom star shape
struct Star8: Shape {
    let points: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        
        let angleIncrement = .pi * 2 / Double(points * 2)
        var angle = -Double.pi / 2
        
        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            angle += angleIncrement
        }
        
        path.closeSubpath()
        return path
    }
}

// Animated wave shape
struct Wave8: Shape {
    var animationProgress: Double
    
    var animatableData: Double {
        get { animationProgress }
        set { animationProgress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waveHeight: CGFloat = 20
        let waveLength = rect.width / 4
        let phase = animationProgress * .pi * 2
        
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / waveLength
            let sine = sin(relativeX * .pi * 2 + phase)
            let y = rect.midY + sine * waveHeight
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// MARK: - Advanced Gesture Handling

struct AdvancedGestures8: View {
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Angle = .zero
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        VStack(spacing: 40) {
            // Multi-gesture view
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.7))
                .frame(width: 150, height: 150)
                .scaleEffect(scale)
                .rotationEffect(rotation)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        // Drag gesture
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    offset = .zero
                                }
                            },
                        
                        // Magnification and rotation
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                    }
                                },
                            
                            RotationGesture()
                                .onChanged { value in
                                    rotation = value
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        rotation = .zero
                                    }
                                }
                        )
                    )
                )
            
            // Custom swipe gesture
            SwipeableCard8()
        }
        .padding()
    }
}

struct SwipeableCard8: View {
    @State private var offset = CGSize.zero
    @State private var isRemoved = false
    
    var body: some View {
        if !isRemoved {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.green.opacity(0.7))
                .frame(width: 200, height: 120)
                .overlay(
                    Text("Swipe to dismiss")
                        .foregroundColor(.white)
                        .bold()
                )
                .offset(offset)
                .rotationEffect(.degrees(Double(offset.width / 10)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > 100 {
                                // Swipe threshold reached
                                withAnimation(.easeOut(duration: 0.3)) {
                                    offset = CGSize(
                                        width: value.translation.width > 0 ? 500 : -500,
                                        height: value.translation.height
                                    )
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isRemoved = true
                                }
                            } else {
                                // Snap back
                                withAnimation(.spring()) {
                                    offset = .zero
                                }
                            }
                        }
                )
        } else {
            Button("Reset Card") {
                withAnimation {
                    isRemoved = false
                    offset = .zero
                }
            }
        }
    }
}

// MARK: - Navigation and Presentation

struct AdvancedNavigation8: View {
    @State private var navigationPath = NavigationPath()
    @State private var showingSheet = false
    @State private var showingFullScreen = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) {
                Text("Advanced Navigation")
                    .font(.title)
                
                // Programmatic navigation
                Button("Navigate to Detail") {
                    navigationPath.append("detail")
                }
                
                Button("Navigate Deep") {
                    navigationPath.append("detail")
                    navigationPath.append("settings")
                    navigationPath.append("profile")
                }
                
                Button("Show Sheet") {
                    showingSheet = true
                }
                
                Button("Show Full Screen") {
                    showingFullScreen = true
                }
                
                Button("Clear Navigation Stack") {
                    navigationPath = NavigationPath()
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: String.self) { destination in
                NavigationDestinationView8(destination: destination)
            }
            .sheet(isPresented: $showingSheet) {
                SheetView8()
            }
            .fullScreenCover(isPresented: $showingFullScreen) {
                FullScreenView8()
            }
        }
    }
}

struct NavigationDestinationView8: View {
    let destination: String
    
    var body: some View {
        VStack {
            Text("Destination: \(destination.capitalized)")
                .font(.title)
            
            NavigationLink("Go Deeper", value: "deeper")
        }
        .navigationTitle(destination.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SheetView8: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sheet Content")
                    .font(.title)
                
                Button("Dismiss") {
                    dismiss()
                }
            }
            .navigationTitle("Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FullScreenView8: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Full Screen Content")
                    .font(.title)
                    .foregroundColor(.white)
                
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Main Demo View

struct SwiftUIAdvancedDemo8: View {
    @StateObject private var appSettings = AppSettings8()
    @StateObject private var userPreferences = UserPreferences8()
    
    var body: some View {
        TabView {
            ViewBuilderExamples8()
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
                    Text("ViewBuilder")
                }
            
            EnvironmentDemoView8()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Environment")
                }
            
            PerformantListView8()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Performance")
                }
            
            CustomShapes8()
                .tabItem {
                    Image(systemName: "star")
                    Text("Shapes")
                }
            
            AdvancedGestures8()
                .tabItem {
                    Image(systemName: "hand.draw")
                    Text("Gestures")
                }
            
            AdvancedNavigation8()
                .tabItem {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond")
                    Text("Navigation")
                }
        }
        .environmentObject(appSettings)
        .environmentObject(userPreferences)
    }
}

// MARK: - Usage Examples

class SwiftUIUsageExamples8 {
    
    func demonstrateViewBuilder() {
        print("=== ViewBuilder Examples ===")
        
        // ViewBuilder allows conditional content
        // Multiple views can be returned without explicit containers
        // Enables flexible UI composition
        
        print("✅ ViewBuilder enables conditional and flexible UI composition")
    }
    
    func demonstrateEnvironment() {
        print("=== Environment Examples ===")
        
        // Environment provides dependency injection for SwiftUI
        // EnvironmentObject for observable objects
        // Custom environment keys for custom values
        
        print("✅ Environment provides clean dependency injection")
    }
    
    func demonstrateCustomModifiers() {
        print("=== Custom Modifiers ===")
        
        // ViewModifier protocol for reusable styling
        // Conditional modifiers for responsive design
        // Animated modifiers for enhanced UX
        
        print("✅ Custom modifiers enable reusable styling")
    }
    
    func demonstratePerformanceOptimization() {
        print("=== Performance Optimization ===")
        
        // LazyVStack for large lists
        // Proper state management to minimize redraws
        // Debouncing for search and filtering
        
        print("✅ Performance optimization through lazy loading and state management")
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **@ViewBuilder**:
    - Result builder for composing SwiftUI views
    - Enables conditional content without explicit containers
    - Used in custom view containers and computed properties
    - Allows multiple views to be returned from functions

 2. **Environment System**:
    - Environment values for passing data down view hierarchy
    - EnvironmentObject for observable objects
    - Custom environment keys for app-specific values
    - Dependency injection pattern in SwiftUI

 3. **Custom View Modifiers**:
    - ViewModifier protocol for reusable styling
    - Conditional modifiers for responsive design
    - Animated modifiers for enhanced user experience
    - Extension methods for easier usage

 4. **Performance Optimization**:
    - LazyVStack/LazyHStack for large datasets
    - Proper state management to minimize redraws
    - Debouncing for search and real-time updates
    - View identity and structural identity

 5. **Advanced State Management**:
    - Combine integration with @Published
    - Complex state transformations
    - Debouncing and reactive programming
    - State normalization and derived state

 6. **Custom Shapes and Animations**:
    - Shape protocol for custom drawings
    - Animatable protocol for smooth transitions
    - Path manipulation and bezier curves
    - Complex gesture interactions

 7. **Navigation Patterns**:
    - NavigationStack with programmatic navigation
    - NavigationPath for type-safe navigation
    - Sheet and full screen presentations
    - Deep linking and state restoration

 8. **Gesture Handling**:
    - Simultaneous gestures for complex interactions
    - Custom gesture recognizers
    - Gesture state management
    - Animation coordination with gestures

 9. **Common Interview Questions**:
    - Q: What is @ViewBuilder and when do you use it?
    - A: Result builder for composing views, used in custom containers

    - Q: How do you pass data between views in SwiftUI?
    - A: @State, @Binding, @ObservedObject, @EnvironmentObject, Environment

    - Q: How do you optimize SwiftUI performance?
    - A: LazyVStack, proper state management, view identity

    - Q: What's the difference between @ObservedObject and @StateObject?
    - A: @StateObject creates and owns, @ObservedObject observes existing

 10. **Advanced Patterns**:
     - Preference keys for child-to-parent communication
     - View builders with generic constraints
     - Custom property wrappers
     - Coordinator pattern for complex navigation

 11. **Best Practices**:
     - Minimize state and derived computations
     - Use appropriate property wrappers
     - Extract reusable components
     - Implement proper accessibility
     - Handle edge cases and loading states

 12. **Common Pitfalls**:
     - Creating too many @StateObject instances
     - Not using LazyVStack for large lists
     - Improper environment object injection
     - Complex view hierarchies causing performance issues
     - Not handling view lifecycle properly
*/ 