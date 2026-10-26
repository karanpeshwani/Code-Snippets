//
//  SwiftUI-OnTap-LazyVStack.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import SwiftUI

// MARK: - Data Models
struct SwiftUIItem1: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
    var isFavorite: Bool = false
    var tapCount: Int = 0
}

// MARK: - Main Demo View
struct SwiftUIGesturesDemo1: View {
    @State private var items: [SwiftUIItem1] = []
    @State private var selectedItem: SwiftUIItem1?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with statistics
                HeaderStatsView1(itemCount: items.count, favoriteCount: items.filter(\.isFavorite).count)
                
                // Main content with LazyVStack
                LazyVStackDemoView1(
                    items: $items,
                    selectedItem: $selectedItem,
                    onItemAction: handleItemAction
                )
            }
            .navigationTitle("SwiftUI Gestures")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Items") {
                        addSampleItems()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        items.removeAll()
                    }
                }
            }
            .alert("Action Performed", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if items.isEmpty {
                    addSampleItems()
                }
            }
        }
    }
    
    private func addSampleItems() {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .teal, .yellow]
        let newItems = (1...50).map { index in
            SwiftUIItem1(
                title: "Item \(index)",
                subtitle: "This is item number \(index) with some description",
                color: colors[index % colors.count]
            )
        }
        items.append(contentsOf: newItems)
    }
    
    private func handleItemAction(_ action: ItemAction1, for item: SwiftUIItem1) {
        switch action {
        case .tap:
            alertMessage = "Tapped on \(item.title)"
            showAlert = true
        case .doubleTap:
            alertMessage = "Double tapped on \(item.title)"
            showAlert = true
        case .longPress:
            alertMessage = "Long pressed on \(item.title)"
            showAlert = true
        case .favorite:
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].isFavorite.toggle()
            }
        }
    }
}

// MARK: - Header Stats View
struct HeaderStatsView1: View {
    let itemCount: Int
    let favoriteCount: Int
    
    var body: some View {
        HStack {
            StatCard1(title: "Total Items", value: "\(itemCount)", color: .blue)
            StatCard1(title: "Favorites", value: "\(favoriteCount)", color: .red)
            StatCard1(title: "Ratio", value: itemCount > 0 ? "\(Int(Double(favoriteCount)/Double(itemCount) * 100))%" : "0%", color: .green)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct StatCard1: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - LazyVStack Demo View
struct LazyVStackDemoView1: View {
    @Binding var items: [SwiftUIItem1]
    @Binding var selectedItem: SwiftUIItem1?
    let onItemAction: (ItemAction1, SwiftUIItem1) -> Void
    
    var body: some View {
        ScrollView {
            // LazyVStack for performance with large datasets
            LazyVStack(spacing: 12) {
                ForEach(items.indices, id: \.self) { index in
                    SwiftUIItemRow1(
                        item: $items[index],
                        onAction: { action in
                            onItemAction(action, items[index])
                        }
                    )
                    .id(items[index].id) // Ensure proper updates
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Item Row View with Gestures
struct SwiftUIItemRow1: View {
    @Binding var item: SwiftUIItem1
    let onAction: (ItemAction1) -> Void
    
    @State private var isPressed = false
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        HStack {
            // Leading content
            Circle()
                .fill(item.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(item.tapCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Favorite button with tap gesture
            Button(action: {
                onAction(.favorite)
            }) {
                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(item.isFavorite ? .red : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle()) // Prevent interference with other gestures
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(dragOffset)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
        // MARK: - Gesture Implementations
        .onTapGesture {
            // Single tap gesture
            item.tapCount += 1
            onAction(.tap)
            
            // Visual feedback
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .onTapGesture(count: 2) {
            // Double tap gesture (must be placed AFTER single tap)
            onAction(.doubleTap)
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            // Long press gesture
            onAction(.longPress)
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        .gesture(
            // Drag gesture for swipe-like interactions
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        dragOffset = .zero
                    }
                    
                    // Handle swipe actions based on drag distance
                    if abs(value.translation.x) > 100 {
                        if value.translation.x > 0 {
                            // Swiped right - mark as favorite
                            onAction(.favorite)
                        } else {
                            // Swiped left - could implement delete or other action
                            print("Swiped left on \(item.title)")
                        }
                    }
                }
        )
        // Simultaneous gesture for complex interactions
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    // This runs simultaneously with other gestures
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPressed = false
                        }
                    }
                }
        )
    }
}

// MARK: - Action Types
enum ItemAction1 {
    case tap
    case doubleTap
    case longPress
    case favorite
}

// MARK: - Advanced Gesture Examples
struct AdvancedGesturesDemo1: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var position = CGSize.zero
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Advanced Gestures Demo")
                .font(.title)
                .padding()
            
            // Multi-gesture interactive view
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .offset(position)
                .gesture(
                    // Simultaneous gestures
                    SimultaneousGesture(
                        RotationGesture()
                            .onChanged { value in
                                rotation = value.degrees
                            },
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                    )
                    .simultaneously(with:
                        DragGesture()
                            .onChanged { value in
                                position = value.translation
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    // Reset to original state
                    withAnimation(.spring()) {
                        rotation = 0
                        scale = 1.0
                        position = .zero
                    }
                }
            
            Text("Drag, rotate, pinch to zoom\nDouble tap to reset")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - LazyVStack Performance Demo
struct LazyVStackPerformanceDemo1: View {
    @State private var items: [Int] = Array(1...10000) // Large dataset
    @State private var visibleItems: Set<Int> = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Visible Items: \(visibleItems.count)")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    LazyVStack {
                        ForEach(items, id: \.self) { item in
                            LazyItemView1(
                                item: item,
                                onAppear: { visibleItems.insert(item) },
                                onDisappear: { visibleItems.remove(item) }
                            )
                        }
                    }
                }
            }
            .navigationTitle("LazyVStack Performance")
        }
    }
}

struct LazyItemView1: View {
    let item: Int
    let onAppear: () -> Void
    let onDisappear: () -> Void
    
    var body: some View {
        HStack {
            Text("Item \(item)")
                .font(.headline)
            
            Spacer()
            
            Text("Loaded")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **SwiftUI Gesture System**:
    - onTapGesture(): Single and double tap recognition
    - onLongPressGesture(): Long press with customizable duration
    - DragGesture(): Drag and swipe interactions
    - MagnificationGesture(): Pinch to zoom
    - RotationGesture(): Rotation gestures
    - SimultaneousGesture(): Multiple gestures at once

 2. **LazyVStack vs VStack**:
    - LazyVStack: Views created only when needed (lazy loading)
    - VStack: All views created immediately
    - Performance: LazyVStack better for large datasets
    - Memory usage: LazyVStack uses less memory
    - Use LazyVStack when dealing with 100+ items

 3. **Gesture Priority and Conflicts**:
    - Order matters: Double tap must come AFTER single tap
    - simultaneousGesture(): Run gestures together
    - highPriorityGesture(): Override other gestures
    - Gesture composition with SimultaneousGesture

 4. **State Management in SwiftUI**:
    - @State for local view state
    - @Binding for two-way data binding
    - Proper state updates trigger view redraws
    - Animation with state changes

 5. **Performance Optimization**:
    - LazyVStack for large lists (only visible items rendered)
    - Proper use of id() for list updates
    - onAppear/onDisappear for tracking visibility
    - Avoiding unnecessary view recreation

 6. **Animation Integration**:
    - withAnimation() for explicit animations
    - Implicit animations with .animation() modifier
    - Spring animations for natural feel
    - Timing curves: .easeInOut, .linear, .spring

 7. **Accessibility Considerations**:
    - Proper gesture handling for VoiceOver
    - Alternative interaction methods
    - Semantic descriptions for gestures

 8. **Common Interview Questions**:
    - Q: When to use LazyVStack vs VStack?
    - A: LazyVStack for large datasets, VStack for small fixed content
    
    - Q: How to handle gesture conflicts?
    - A: Use gesture priority modifiers and proper ordering
    
    - Q: How does onTapGesture work internally?
    - A: Creates a TapGesture and attaches it to the view
    
    - Q: Performance implications of LazyVStack?
    - A: Better memory usage but slightly more complex rendering

 9. **Advanced Concepts**:
    - Custom gesture recognizers
    - Gesture state management
    - Complex gesture combinations
    - Platform-specific gesture handling

 10. **Best Practices**:
     - Use LazyVStack for scrollable content > 50 items
     - Implement proper gesture feedback (haptics, animations)
     - Handle gesture conflicts explicitly
     - Test gestures on different devices and orientations
     - Consider accessibility when implementing custom gestures
*/ 