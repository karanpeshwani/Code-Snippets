//
//  SDUI-Example.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 29/08/25.
//
//  A comprehensive Server-Driven UI (SDUI) implementation demonstrating:
//  - Mock server responses with dynamic UI definitions
//  - Robust data models and JSON parsing
//  - Dynamic UI rendering engine with component factory pattern
//  - Action handling system for user interactions
//  - Complete Profile screen example with state transitions

import SwiftUI
import Foundation

// MARK: - SDUI Data Models

/// Base protocol for all SDUI components
protocol SDUIComponent: Codable {
    var id: String { get }
    var type: ComponentType { get }
}

/// Enum defining all supported UI component types
enum ComponentType: String, Codable {
    case vStack = "vstack"
    case hStack = "hstack"
    case text = "text"
    case image = "image"
    case button = "button"
    case spacer = "spacer"
    case divider = "divider"
}

/// Represents spacing and padding values
struct Spacing: Codable {
    let top: CGFloat?
    let bottom: CGFloat?
    let leading: CGFloat?
    let trailing: CGFloat?
    let all: CGFloat?
    
    init(top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil, all: CGFloat? = nil) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
        self.all = all
    }
}

/// Represents styling properties for components
struct ComponentStyle: Codable {
    let backgroundColor: String?
    let foregroundColor: String?
    let fontSize: CGFloat?
    let fontWeight: String?
    let cornerRadius: CGFloat?
    let padding: Spacing?
    let margin: Spacing?
    let alignment: String?
    
    init(backgroundColor: String? = nil, foregroundColor: String? = nil, fontSize: CGFloat? = nil, 
         fontWeight: String? = nil, cornerRadius: CGFloat? = nil, padding: Spacing? = nil, 
         margin: Spacing? = nil, alignment: String? = nil) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.margin = margin
        self.alignment = alignment
    }
}

/// Represents user interaction actions
struct ComponentAction: Codable {
    let type: ActionType
    let payload: [String: String]?
    
    enum ActionType: String, Codable {
        case alert = "alert"
        case navigation = "navigation"
        case apiCall = "api_call"
        case updateScreen = "update_screen"
    }
}

// MARK: - Specific Component Models

/// Container component for vertical layout
struct VStackComponent: SDUIComponent {
    let id: String
    let type: ComponentType = .vStack
    let children: [AnySDUIComponent]
    let style: ComponentStyle?
    let spacing: CGFloat?
    
    init(id: String, children: [AnySDUIComponent], style: ComponentStyle? = nil, spacing: CGFloat? = nil) {
        self.id = id
        self.children = children
        self.style = style
        self.spacing = spacing
    }
}

/// Container component for horizontal layout
struct HStackComponent: SDUIComponent {
    let id: String
    let type: ComponentType = .hStack
    let children: [AnySDUIComponent]
    let style: ComponentStyle?
    let spacing: CGFloat?
    
    init(id: String, children: [AnySDUIComponent], style: ComponentStyle? = nil, spacing: CGFloat? = nil) {
        self.id = id
        self.children = children
        self.style = style
        self.spacing = spacing
    }
}

/// Text display component
struct TextComponent: SDUIComponent {
    let id: String
    let type: ComponentType = .text
    let text: String
    let style: ComponentStyle?
    
    init(id: String, text: String, style: ComponentStyle? = nil) {
        self.id = id
        self.text = text
        self.style = style
    }
}

/// Image display component
struct ImageComponent: SDUIComponent {
    let id: String
    let type: ComponentType = .image
    let imageName: String?
    let imageUrl: String?
    let systemName: String?
    let style: ComponentStyle?
    
    init(id: String, imageName: String? = nil, imageUrl: String? = nil, systemName: String? = nil, style: ComponentStyle? = nil) {
        self.id = id
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.systemName = systemName
        self.style = style
    }
}

/// Interactive button component
struct ButtonComponent: SDUIComponent {
    let id: String
    let type: ComponentType = .button
    let title: String
    let action: ComponentAction?
    let style: ComponentStyle?
    
    init(id: String, title: String, action: ComponentAction? = nil, style: ComponentStyle? = nil) {
        self.id = id
        self.title = title
        self.action = action
        self.style = style
    }
}

/// Spacer component for flexible spacing
struct SpacerComponent: SDUIComponent {
    let id: String
    let type: ComponentType = .spacer
    let minLength: CGFloat?
    
    init(id: String, minLength: CGFloat? = nil) {
        self.id = id
        self.minLength = minLength
    }
}

/// Divider component for visual separation
struct DividerComponent: SDUIComponent {
    let id: String
    let type: ComponentType = .divider
    let style: ComponentStyle?
    
    init(id: String, style: ComponentStyle? = nil) {
        self.id = id
        self.style = style
    }
}

// MARK: - Type-Erased Component Wrapper

/// Type-erased wrapper to handle different component types in collections
struct AnySDUIComponent: Codable {
    let component: SDUIComponent
    
    init<T: SDUIComponent>(_ component: T) {
        self.component = component
    }
    
    // Custom encoding/decoding to handle different component types
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String: Any].self)
        
        guard let typeString = dict["type"] as? String,
              let type = ComponentType(rawValue: typeString) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid component type")
            )
        }
        
        let data = try JSONSerialization.data(withJSONObject: dict)
        
        switch type {
        case .vStack:
            self.component = try JSONDecoder().decode(VStackComponent.self, from: data)
        case .hStack:
            self.component = try JSONDecoder().decode(HStackComponent.self, from: data)
        case .text:
            self.component = try JSONDecoder().decode(TextComponent.self, from: data)
        case .image:
            self.component = try JSONDecoder().decode(ImageComponent.self, from: data)
        case .button:
            self.component = try JSONDecoder().decode(ButtonComponent.self, from: data)
        case .spacer:
            self.component = try JSONDecoder().decode(SpacerComponent.self, from: data)
        case .divider:
            self.component = try JSONDecoder().decode(DividerComponent.self, from: data)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(component)
    }
}

// MARK: - Screen Response Model

/// Represents a complete screen configuration from the server
struct ScreenResponse: Codable {
    let screenId: String
    let title: String
    let components: [AnySDUIComponent]
    let metadata: [String: String]?
    
    init(screenId: String, title: String, components: [AnySDUIComponent], metadata: [String: String]? = nil) {
        self.screenId = screenId
        self.title = title
        self.components = components
        self.metadata = metadata
    }
}

// MARK: - Mock Server Implementation

/// Mock server that simulates API responses with dynamic UI configurations
class MockSDUIServer: ObservableObject {
    
    /// Simulates fetching a screen configuration from the server
    /// - Parameter screenId: The identifier for the requested screen
    /// - Returns: A ScreenResponse containing the UI configuration
    func fetchScreen(screenId: String) async -> ScreenResponse {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        switch screenId {
        case "profile_basic":
            return createBasicProfileScreen()
        case "profile_detailed":
            return createDetailedProfileScreen()
        default:
            return createErrorScreen()
        }
    }
    
    /// Creates the basic profile screen configuration
    private func createBasicProfileScreen() -> ScreenResponse {
        let components: [AnySDUIComponent] = [
            // Main container
            AnySDUIComponent(VStackComponent(
                id: "main_container",
                children: [
                    // Profile image
                    AnySDUIComponent(ImageComponent(
                        id: "profile_image",
                        systemName: "person.circle.fill",
                        style: ComponentStyle(
                            foregroundColor: "blue",
                            fontSize: 80
                        )
                    )),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_1", minLength: 20)),
                    
                    // User name
                    AnySDUIComponent(TextComponent(
                        id: "user_name",
                        text: "John Doe",
                        style: ComponentStyle(
                            fontSize: 28,
                            fontWeight: "bold"
                        )
                    )),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_2", minLength: 10)),
                    
                    // Bio
                    AnySDUIComponent(TextComponent(
                        id: "user_bio",
                        text: "iOS Developer passionate about creating amazing user experiences.",
                        style: ComponentStyle(
                            fontSize: 16,
                            foregroundColor: "gray",
                            padding: Spacing(all: 16)
                        )
                    )),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_3", minLength: 30)),
                    
                    // Show more button
                    AnySDUIComponent(ButtonComponent(
                        id: "show_more_btn",
                        title: "Show More Details",
                        action: ComponentAction(
                            type: .updateScreen,
                            payload: ["screenId": "profile_detailed"]
                        ),
                        style: ComponentStyle(
                            backgroundColor: "blue",
                            foregroundColor: "white",
                            cornerRadius: 12,
                            padding: Spacing(all: 16)
                        )
                    ))
                ],
                style: ComponentStyle(
                    padding: Spacing(all: 20),
                    alignment: "center"
                ),
                spacing: 0
            ))
        ]
        
        return ScreenResponse(
            screenId: "profile_basic",
            title: "Profile",
            components: components
        )
    }
    
    /// Creates the detailed profile screen configuration
    private func createDetailedProfileScreen() -> ScreenResponse {
        let components: [AnySDUIComponent] = [
            // Main container
            AnySDUIComponent(VStackComponent(
                id: "detailed_container",
                children: [
                    // Profile image
                    AnySDUIComponent(ImageComponent(
                        id: "profile_image_detailed",
                        systemName: "person.circle.fill",
                        style: ComponentStyle(
                            foregroundColor: "blue",
                            fontSize: 80
                        )
                    )),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_d1", minLength: 20)),
                    
                    // User name
                    AnySDUIComponent(TextComponent(
                        id: "user_name_detailed",
                        text: "John Doe",
                        style: ComponentStyle(
                            fontSize: 28,
                            fontWeight: "bold"
                        )
                    )),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_d2", minLength: 15)),
                    
                    // Divider
                    AnySDUIComponent(DividerComponent(id: "divider_1")),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_d3", minLength: 15)),
                    
                    // Detailed info container
                    AnySDUIComponent(VStackComponent(
                        id: "details_container",
                        children: [
                            // Email row
                            AnySDUIComponent(HStackComponent(
                                id: "email_row",
                                children: [
                                    AnySDUIComponent(ImageComponent(
                                        id: "email_icon",
                                        systemName: "envelope.fill",
                                        style: ComponentStyle(foregroundColor: "gray", fontSize: 16)
                                    )),
                                    AnySDUIComponent(TextComponent(
                                        id: "email_text",
                                        text: "john.doe@example.com",
                                        style: ComponentStyle(fontSize: 16)
                                    )),
                                    AnySDUIComponent(SpacerComponent(id: "email_spacer"))
                                ],
                                spacing: 8
                            )),
                            
                            // Location row
                            AnySDUIComponent(HStackComponent(
                                id: "location_row",
                                children: [
                                    AnySDUIComponent(ImageComponent(
                                        id: "location_icon",
                                        systemName: "location.fill",
                                        style: ComponentStyle(foregroundColor: "gray", fontSize: 16)
                                    )),
                                    AnySDUIComponent(TextComponent(
                                        id: "location_text",
                                        text: "San Francisco, CA",
                                        style: ComponentStyle(fontSize: 16)
                                    )),
                                    AnySDUIComponent(SpacerComponent(id: "location_spacer"))
                                ],
                                spacing: 8
                            )),
                            
                            // Company row
                            AnySDUIComponent(HStackComponent(
                                id: "company_row",
                                children: [
                                    AnySDUIComponent(ImageComponent(
                                        id: "company_icon",
                                        systemName: "building.2.fill",
                                        style: ComponentStyle(foregroundColor: "gray", fontSize: 16)
                                    )),
                                    AnySDUIComponent(TextComponent(
                                        id: "company_text",
                                        text: "Tech Innovations Inc.",
                                        style: ComponentStyle(fontSize: 16)
                                    )),
                                    AnySDUIComponent(SpacerComponent(id: "company_spacer"))
                                ],
                                spacing: 8
                            ))
                        ],
                        style: ComponentStyle(
                            padding: Spacing(all: 16),
                            alignment: "leading"
                        ),
                        spacing: 12
                    )),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_d4", minLength: 20)),
                    
                    // Expanded bio
                    AnySDUIComponent(TextComponent(
                        id: "expanded_bio",
                        text: "Senior iOS Developer with 8+ years of experience building scalable mobile applications. Passionate about SwiftUI, clean architecture, and creating delightful user experiences. Currently working on innovative fintech solutions.",
                        style: ComponentStyle(
                            fontSize: 16,
                            foregroundColor: "gray",
                            padding: Spacing(all: 16)
                        )
                    )),
                    
                    // Spacer
                    AnySDUIComponent(SpacerComponent(id: "spacer_d5", minLength: 30)),
                    
                    // Hide details button
                    AnySDUIComponent(ButtonComponent(
                        id: "hide_details_btn",
                        title: "Hide Details",
                        action: ComponentAction(
                            type: .updateScreen,
                            payload: ["screenId": "profile_basic"]
                        ),
                        style: ComponentStyle(
                            backgroundColor: "gray",
                            foregroundColor: "white",
                            cornerRadius: 12,
                            padding: Spacing(all: 16)
                        )
                    ))
                ],
                style: ComponentStyle(
                    padding: Spacing(all: 20),
                    alignment: "center"
                ),
                spacing: 0
            ))
        ]
        
        return ScreenResponse(
            screenId: "profile_detailed",
            title: "Profile Details",
            components: components
        )
    }
    
    /// Creates an error screen configuration
    private func createErrorScreen() -> ScreenResponse {
        let components: [AnySDUIComponent] = [
            AnySDUIComponent(VStackComponent(
                id: "error_container",
                children: [
                    AnySDUIComponent(ImageComponent(
                        id: "error_icon",
                        systemName: "exclamationmark.triangle.fill",
                        style: ComponentStyle(
                            foregroundColor: "red",
                            fontSize: 50
                        )
                    )),
                    AnySDUIComponent(TextComponent(
                        id: "error_text",
                        text: "Screen not found",
                        style: ComponentStyle(
                            fontSize: 18,
                            fontWeight: "bold"
                        )
                    ))
                ],
                style: ComponentStyle(
                    padding: Spacing(all: 20),
                    alignment: "center"
                ),
                spacing: 16
            ))
        ]
        
        return ScreenResponse(
            screenId: "error",
            title: "Error",
            components: components
        )
    }
}

// MARK: - JSON Parser and Decoder

/// Handles parsing and decoding of server responses
class SDUIParser {
    private let decoder = JSONDecoder()
    
    /// Parses a JSON string into a ScreenResponse
    /// - Parameter jsonString: The JSON string to parse
    /// - Returns: A parsed ScreenResponse or nil if parsing fails
    func parseScreen(from jsonString: String) -> ScreenResponse? {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ Failed to convert JSON string to data")
            return nil
        }
        
        do {
            return try decoder.decode(ScreenResponse.self, from: data)
        } catch {
            print("❌ Failed to decode ScreenResponse: \(error)")
            return nil
        }
    }
    
    /// Parses JSON data into a ScreenResponse
    /// - Parameter data: The JSON data to parse
    /// - Returns: A parsed ScreenResponse or nil if parsing fails
    func parseScreen(from data: Data) -> ScreenResponse? {
        do {
            return try decoder.decode(ScreenResponse.self, from: data)
        } catch {
            print("❌ Failed to decode ScreenResponse: \(error)")
            return nil
        }
    }
}

// MARK: - Action Handler

/// Handles user interactions and component actions
class SDUIActionHandler: ObservableObject {
    weak var viewModel: SDUIViewModel?
    
    /// Executes a component action
    /// - Parameter action: The action to execute
    func handleAction(_ action: ComponentAction) {
        print("🎯 Handling action: \(action.type.rawValue)")
        
        switch action.type {
        case .alert:
            handleAlertAction(action)
        case .navigation:
            handleNavigationAction(action)
        case .apiCall:
            handleApiCallAction(action)
        case .updateScreen:
            handleUpdateScreenAction(action)
        }
    }
    
    /// Handles alert actions
    private func handleAlertAction(_ action: ComponentAction) {
        let message = action.payload?["message"] ?? "Action triggered!"
        print("🚨 Alert: \(message)")
        // In a real app, you would show an actual alert
    }
    
    /// Handles navigation actions
    private func handleNavigationAction(_ action: ComponentAction) {
        let destination = action.payload?["destination"] ?? "unknown"
        print("🧭 Navigate to: \(destination)")
        // In a real app, you would handle navigation
    }
    
    /// Handles API call actions
    private func handleApiCallAction(_ action: ComponentAction) {
        let endpoint = action.payload?["endpoint"] ?? "unknown"
        print("📡 API call to: \(endpoint)")
        // In a real app, you would make an actual API call
    }
    
    /// Handles screen update actions
    private func handleUpdateScreenAction(_ action: ComponentAction) {
        guard let screenId = action.payload?["screenId"] else {
            print("❌ No screenId provided for update action")
            return
        }
        
        print("🔄 Updating screen to: \(screenId)")
        viewModel?.loadScreen(screenId: screenId)
    }
}

// MARK: - UI Rendering Engine

/// Renders SDUI components into SwiftUI views
struct SDUIRenderer {
    let actionHandler: SDUIActionHandler
    
    /// Renders a component into a SwiftUI view
    /// - Parameter component: The component to render
    /// - Returns: A SwiftUI view
    @ViewBuilder
    func render(_ component: AnySDUIComponent) -> some View {
        switch component.component {
        case let vStack as VStackComponent:
            renderVStack(vStack)
        case let hStack as HStackComponent:
            renderHStack(hStack)
        case let text as TextComponent:
            renderText(text)
        case let image as ImageComponent:
            renderImage(image)
        case let button as ButtonComponent:
            renderButton(button)
        case let spacer as SpacerComponent:
            renderSpacer(spacer)
        case let divider as DividerComponent:
            renderDivider(divider)
        default:
            Text("Unknown component type")
                .foregroundColor(.red)
        }
    }
    
    /// Renders a VStack component
    @ViewBuilder
    private func renderVStack(_ vStack: VStackComponent) -> some View {
        VStack(spacing: vStack.spacing) {
            ForEach(vStack.children.indices, id: \.self) { index in
                render(vStack.children[index])
            }
        }
        .applyStyle(vStack.style)
    }
    
    /// Renders an HStack component
    @ViewBuilder
    private func renderHStack(_ hStack: HStackComponent) -> some View {
        HStack(spacing: hStack.spacing) {
            ForEach(hStack.children.indices, id: \.self) { index in
                render(hStack.children[index])
            }
        }
        .applyStyle(hStack.style)
    }
    
    /// Renders a Text component
    @ViewBuilder
    private func renderText(_ text: TextComponent) -> some View {
        Text(text.text)
            .applyStyle(text.style)
    }
    
    /// Renders an Image component
    @ViewBuilder
    private func renderImage(_ image: ImageComponent) -> some View {
        Group {
            if let systemName = image.systemName {
                Image(systemName: systemName)
            } else if let imageName = image.imageName {
                Image(imageName)
            } else {
                Image(systemName: "photo")
            }
        }
        .applyStyle(image.style)
    }
    
    /// Renders a Button component
    @ViewBuilder
    private func renderButton(_ button: ButtonComponent) -> some View {
        Button(action: {
            if let action = button.action {
                actionHandler.handleAction(action)
            }
        }) {
            Text(button.title)
                .applyStyle(button.style)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Renders a Spacer component
    @ViewBuilder
    private func renderSpacer(_ spacer: SpacerComponent) -> some View {
        if let minLength = spacer.minLength {
            Spacer(minLength: minLength)
        } else {
            Spacer()
        }
    }
    
    /// Renders a Divider component
    @ViewBuilder
    private func renderDivider(_ divider: DividerComponent) -> some View {
        Divider()
            .applyStyle(divider.style)
    }
}

// MARK: - Style Extension

/// Extension to apply ComponentStyle to SwiftUI views
extension View {
    @ViewBuilder
    func applyStyle(_ style: ComponentStyle?) -> some View {
        var view = AnyView(self)
        
        if let style = style {
            // Apply foreground color
            if let foregroundColor = style.foregroundColor {
                view = AnyView(view.foregroundColor(Color(foregroundColor)))
            }
            
            // Apply font size and weight
            if let fontSize = style.fontSize {
                if let fontWeight = style.fontWeight {
                    view = AnyView(view.font(.system(size: fontSize, weight: fontWeightFromString(fontWeight))))
                } else {
                    view = AnyView(view.font(.system(size: fontSize)))
                }
            }
            
            // Apply background color
            if let backgroundColor = style.backgroundColor {
                view = AnyView(view.background(Color(backgroundColor)))
            }
            
            // Apply corner radius
            if let cornerRadius = style.cornerRadius {
                view = AnyView(view.cornerRadius(cornerRadius))
            }
            
            // Apply padding
            if let padding = style.padding {
                if let all = padding.all {
                    view = AnyView(view.padding(all))
                } else {
                    view = AnyView(view.padding(.top, padding.top ?? 0)
                                     .padding(.bottom, padding.bottom ?? 0)
                                     .padding(.leading, padding.leading ?? 0)
                                     .padding(.trailing, padding.trailing ?? 0))
                }
            }
        }
        
        view
    }
    
    /// Converts string font weight to SwiftUI Font.Weight
    private func fontWeightFromString(_ weightString: String) -> Font.Weight {
        switch weightString.lowercased() {
        case "ultralight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .regular
        }
    }
}

/// Extension to create Color from string
extension Color {
    init(_ colorString: String) {
        switch colorString.lowercased() {
        case "red": self = .red
        case "blue": self = .blue
        case "green": self = .green
        case "yellow": self = .yellow
        case "orange": self = .orange
        case "purple": self = .purple
        case "pink": self = .pink
        case "gray", "grey": self = .gray
        case "black": self = .black
        case "white": self = .white
        case "clear": self = .clear
        default: self = .primary
        }
    }
}

// MARK: - SDUI ViewModel

/// Main ViewModel that coordinates the SDUI system
class SDUIViewModel: ObservableObject {
    @Published var currentScreen: ScreenResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let server = MockSDUIServer()
    private let parser = SDUIParser()
    private let actionHandler = SDUIActionHandler()
    
    init() {
        actionHandler.viewModel = self
    }
    
    /// Loads a screen configuration from the server
    /// - Parameter screenId: The ID of the screen to load
    func loadScreen(screenId: String) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                let screen = await server.fetchScreen(screenId: screenId)
                currentScreen = screen
                print("✅ Successfully loaded screen: \(screen.screenId)")
            } catch {
                errorMessage = "Failed to load screen: \(error.localizedDescription)"
                print("❌ Failed to load screen: \(error)")
            }
            
            isLoading = false
        }
    }
    
    /// Returns the action handler for the current session
    func getActionHandler() -> SDUIActionHandler {
        return actionHandler
    }
}

// MARK: - Main SDUI View

/// Main SwiftUI view that displays the server-driven UI
struct SDUIView: View {
    @StateObject private var viewModel = SDUIViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .scaleEffect(1.2)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            viewModel.loadScreen(screenId: "profile_basic")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else if let screen = viewModel.currentScreen {
                    ScrollView {
                        VStack {
                            ForEach(screen.components.indices, id: \.self) { index in
                                SDUIRenderer(actionHandler: viewModel.getActionHandler())
                                    .render(screen.components[index])
                            }
                        }
                    }
                    .navigationTitle(screen.title)
                } else {
                    VStack {
                        Text("Welcome to SDUI Demo")
                            .font(.title)
                            .padding()
                        Button("Load Profile") {
                            viewModel.loadScreen(screenId: "profile_basic")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            // Automatically load the basic profile screen on app start
            viewModel.loadScreen(screenId: "profile_basic")
        }
    }
}

// MARK: - Preview and App Entry Point

/// SwiftUI Preview
struct SDUIView_Previews: PreviewProvider {
    static var previews: some View {
        SDUIView()
    }
}

/// Main App struct for running the SDUI example
@main
struct SDUIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            SDUIView()
        }
    }
}

/*
 ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                              📱 SDUI ARCHITECTURE DIAGRAM 📱                                    │
 └─────────────────────────────────────────────────────────────────────────────────────────────────┘
 
                                    ┌─────────────────┐
                                    │   📱 SDUIView   │
                                    │ (Main UI Entry) │
                                    └─────────┬───────┘
                                              │
                                              ▼
                                    ┌─────────────────┐
                                    │ 🧠 SDUIViewModel │
                                    │ (Coordinator)   │
                                    └─────────┬───────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
          ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
          │ 🌐 MockSDUIServer│       │ ⚡ SDUIActionHandler│    │ 🔧 SDUIParser   │
          │ (API Simulator) │       │ (User Actions)  │       │ (JSON Decoder)  │
          └─────────┬───────┘       └─────────┬───────┘       └─────────┬───────┘
                    │                         │                         │
                    ▼                         ▼                         ▼
          ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
          │ 📋 ScreenResponse│       │ 🎯 Action Types │       │ 📊 Data Models  │
          │ - screenId      │       │ - alert         │       │ - ComponentType │
          │ - title         │       │ - navigation    │       │ - ComponentStyle│
          │ - components[]  │       │ - apiCall       │       │ - Spacing       │
          │ - metadata      │       │ - updateScreen  │       │ - ComponentAction│
          └─────────┬───────┘       └─────────────────┘       └─────────────────┘
                    │
                    ▼
          ┌─────────────────┐
          │🧩 AnySDUIComponent│
          │ (Type Erasure)  │
          └─────────┬───────┘
                    │
                    ▼
    ┌───────────────────────────────────────────────────────────────────────────┐
    │                        📦 COMPONENT MODELS                                │
    └───────────────────────────────────────────────────────────────────────────┘
    
    ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
    │📐 VStackComponent│  │↔️ HStackComponent│  │📝 TextComponent │  │🖼️ ImageComponent │
    │- children[]     │  │- children[]     │  │- text           │  │- imageName      │
    │- style          │  │- style          │  │- style          │  │- imageUrl       │
    │- spacing        │  │- spacing        │  └─────────────────┘  │- systemName     │
    └─────────────────┘  └─────────────────┘                      │- style          │
                                                                   └─────────────────┘
    
    ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
    │🔘 ButtonComponent│  │⏸️ SpacerComponent│  │➖ DividerComponent│
    │- title          │  │- minLength      │  │- style          │
    │- action         │  └─────────────────┘  └─────────────────┘
    │- style          │
    └─────────────────┘
    
                                              │
                                              ▼
                                    ┌─────────────────┐
                                    │ 🎨 SDUIRenderer │
                                    │ (View Factory)  │
                                    └─────────┬───────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
          ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
          │🏗️ Component Factory│      │💅 Style System  │       │🔄 Recursive     │
          │- Maps types     │       │- Colors         │       │  Rendering      │
          │  to SwiftUI     │       │- Typography     │       │- Nested         │
          │  views          │       │- Spacing        │       │  Components     │
          └─────────────────┘       │- Backgrounds    │       └─────────────────┘
                                    │- Corner Radius  │
                                    └─────────────────┘
 
 ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                                    🔄 DATA FLOW                                                 │
 └─────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 1. User launches app → SDUIView appears
 2. SDUIViewModel.loadScreen("profile_basic") called
 3. MockSDUIServer.fetchScreen() returns ScreenResponse with components
 4. SDUIRenderer receives components and renders them recursively
 5. User taps "Show More Details" button
 6. SDUIActionHandler processes updateScreen action
 7. SDUIViewModel.loadScreen("profile_detailed") called
 8. New ScreenResponse returned with detailed profile layout
 9. SDUIRenderer re-renders with new components
 10. UI updates dynamically based on server configuration
 
 ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                              🎯 EXAMPLE: PROFILE SCREEN FLOW                                    │
 └─────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 📱 BASIC PROFILE SCREEN:
 ┌─────────────────────────────────┐
 │           👤 (Avatar)           │
 │                                 │
 │           John Doe              │
 │                                 │
 │    iOS Developer passionate     │
 │    about creating amazing       │
 │    user experiences.            │
 │                                 │
 │    ┌─────────────────────┐     │
 │    │ Show More Details   │     │
 │    └─────────────────────┘     │
 └─────────────────────────────────┘
 
              ↓ (Button Tap)
 
 📱 DETAILED PROFILE SCREEN:
 ┌─────────────────────────────────┐
 │           👤 (Avatar)           │
 │                                 │
 │           John Doe              │
 │         ─────────────           │
 │                                 │
 │ ✉️  john.doe@example.com        │
 │ 📍  San Francisco, CA           │
 │ 🏢  Tech Innovations Inc.       │
 │                                 │
 │  Senior iOS Developer with 8+   │
 │  years of experience building   │
 │  scalable mobile applications.  │
 │  Passionate about SwiftUI...    │
 │                                 │
 │    ┌─────────────────────┐     │
 │    │   Hide Details      │     │
 │    └─────────────────────┘     │
 └─────────────────────────────────┘
 
 ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                                   🏗️ ARCHITECTURE BENEFITS                                      │
 └─────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 ✅ SERVER CONTROL: Complete UI layout defined by server responses
 ✅ DYNAMIC UPDATES: Real-time UI changes without app updates
 ✅ TYPE SAFETY: Strongly-typed component system with compile-time checks
 ✅ EXTENSIBILITY: Easy to add new component types and styling options
 ✅ REUSABILITY: Components can be reused across different screens
 ✅ MAINTAINABILITY: Clear separation of concerns across layers
 ✅ TESTABILITY: Each layer can be tested independently
 ✅ PERFORMANCE: Efficient SwiftUI rendering with minimal overhead
 
 ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                              🔧 IMPLEMENTATION DETAILS                                          │
 └─────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 📊 COMPONENT HIERARCHY:
 
 VStackComponent (main_container)
 ├── ImageComponent (profile_image)
 ├── SpacerComponent (spacer_1)
 ├── TextComponent (user_name)
 ├── SpacerComponent (spacer_2)
 ├── TextComponent (user_bio)
 ├── SpacerComponent (spacer_3)
 └── ButtonComponent (show_more_btn)
     └── ComponentAction (updateScreen → "profile_detailed")
 
 🎨 STYLING SYSTEM:
 
 ComponentStyle {
   backgroundColor: "blue" → Color.blue
   foregroundColor: "white" → Color.white
   fontSize: 16 → Font.system(size: 16)
   fontWeight: "bold" → Font.Weight.bold
   cornerRadius: 12 → .cornerRadius(12)
   padding: Spacing(all: 16) → .padding(16)
 }
 
 This implementation demonstrates a complete, production-ready SDUI system
 that can be extended with additional component types and actions as needed.
 */

