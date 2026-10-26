//
//  SOLID-Principles-iOS.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Single Responsibility Principle (SRP)

// ❌ BAD: Class with multiple responsibilities
class BadUserManager5 {
    func createUser(name: String, email: String) -> User5 {
        let user = User5(name: name, email: email)
        
        // Database operations
        saveToDatabase(user)
        
        // Email operations
        sendWelcomeEmail(to: user.email)
        
        // Logging
        logUserCreation(user)
        
        return user
    }
    
    private func saveToDatabase(_ user: User5) {
        print("Saving user to database...")
    }
    
    private func sendWelcomeEmail(to email: String) {
        print("Sending welcome email to \(email)")
    }
    
    private func logUserCreation(_ user: User5) {
        print("User created: \(user.name)")
    }
}

// ✅ GOOD: Separate responsibilities into different classes
struct User5 {
    let id: UUID
    let name: String
    let email: String
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
    }
}

protocol UserRepository5 {
    func save(_ user: User5) throws
    func findById(_ id: UUID) throws -> User5?
    func findAll() throws -> [User5]
}

class CoreDataUserRepository5: UserRepository5 {
    func save(_ user: User5) throws {
        print("💾 Saving user \(user.name) to Core Data")
        // Core Data implementation
    }
    
    func findById(_ id: UUID) throws -> User5? {
        print("🔍 Finding user by ID: \(id)")
        // Core Data fetch implementation
        return nil
    }
    
    func findAll() throws -> [User5] {
        print("📋 Fetching all users from Core Data")
        // Core Data fetch implementation
        return []
    }
}

protocol EmailService5 {
    func sendWelcomeEmail(to email: String) throws
    func sendPasswordResetEmail(to email: String) throws
}

class SMTPEmailService5: EmailService5 {
    func sendWelcomeEmail(to email: String) throws {
        print("📧 Sending welcome email to \(email) via SMTP")
        // SMTP implementation
    }
    
    func sendPasswordResetEmail(to email: String) throws {
        print("🔒 Sending password reset email to \(email) via SMTP")
        // SMTP implementation
    }
}

protocol Logger5 {
    func log(_ message: String, level: LogLevel5)
}

enum LogLevel5: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class ConsoleLogger5: Logger5 {
    func log(_ message: String, level: LogLevel5) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("[\(timestamp)] [\(level.rawValue)] \(message)")
    }
}

// Good UserManager with single responsibility
class UserManager5 {
    private let repository: UserRepository5
    private let emailService: EmailService5
    private let logger: Logger5
    
    init(repository: UserRepository5, emailService: EmailService5, logger: Logger5) {
        self.repository = repository
        self.emailService = emailService
        self.logger = logger
    }
    
    func createUser(name: String, email: String) throws -> User5 {
        let user = User5(name: name, email: email)
        
        try repository.save(user)
        try emailService.sendWelcomeEmail(to: user.email)
        logger.log("User created: \(user.name)", level: .info)
        
        return user
    }
}

// MARK: - Open/Closed Principle (OCP)

// ✅ GOOD: Open for extension, closed for modification
protocol PaymentProcessor5 {
    func processPayment(amount: Double) throws -> PaymentResult5
    var processorName: String { get }
}

struct PaymentResult5 {
    let transactionId: String
    let isSuccessful: Bool
    let message: String
}

class CreditCardProcessor5: PaymentProcessor5 {
    let processorName = "Credit Card"
    
    func processPayment(amount: Double) throws -> PaymentResult5 {
        print("💳 Processing credit card payment of $\(amount)")
        
        // Credit card processing logic
        let transactionId = UUID().uuidString
        return PaymentResult5(
            transactionId: transactionId,
            isSuccessful: true,
            message: "Credit card payment successful"
        )
    }
}

class PayPalProcessor5: PaymentProcessor5 {
    let processorName = "PayPal"
    
    func processPayment(amount: Double) throws -> PaymentResult5 {
        print("💰 Processing PayPal payment of $\(amount)")
        
        // PayPal processing logic
        let transactionId = "PP_\(UUID().uuidString)"
        return PaymentResult5(
            transactionId: transactionId,
            isSuccessful: true,
            message: "PayPal payment successful"
        )
    }
}

class ApplePayProcessor5: PaymentProcessor5 {
    let processorName = "Apple Pay"
    
    func processPayment(amount: Double) throws -> PaymentResult5 {
        print("🍎 Processing Apple Pay payment of $\(amount)")
        
        // Apple Pay processing logic
        let transactionId = "AP_\(UUID().uuidString)"
        return PaymentResult5(
            transactionId: transactionId,
            isSuccessful: true,
            message: "Apple Pay payment successful"
        )
    }
}

// Payment manager that's closed for modification but open for extension
class PaymentManager5 {
    private var processors: [String: PaymentProcessor5] = [:]
    
    func registerProcessor(_ processor: PaymentProcessor5) {
        processors[processor.processorName] = processor
    }
    
    func processPayment(amount: Double, using processorName: String) throws -> PaymentResult5 {
        guard let processor = processors[processorName] else {
            throw PaymentError5.processorNotFound
        }
        
        return try processor.processPayment(amount: amount)
    }
    
    func availableProcessors() -> [String] {
        return Array(processors.keys)
    }
}

enum PaymentError5: Error {
    case processorNotFound
    case invalidAmount
    case processingFailed
}

// MARK: - Liskov Substitution Principle (LSP)

// ✅ GOOD: Subtypes should be substitutable for their base types
protocol Shape5 {
    var area: Double { get }
    var perimeter: Double { get }
    func draw()
}

class Rectangle5: Shape5 {
    let width: Double
    let height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    var area: Double {
        return width * height
    }
    
    var perimeter: Double {
        return 2 * (width + height)
    }
    
    func draw() {
        print("📐 Drawing rectangle: \(width) x \(height)")
    }
}

class Square5: Shape5 {
    let side: Double
    
    init(side: Double) {
        self.side = side
    }
    
    var area: Double {
        return side * side
    }
    
    var perimeter: Double {
        return 4 * side
    }
    
    func draw() {
        print("⬜ Drawing square: \(side) x \(side)")
    }
}

class Circle5: Shape5 {
    let radius: Double
    
    init(radius: Double) {
        self.radius = radius
    }
    
    var area: Double {
        return Double.pi * radius * radius
    }
    
    var perimeter: Double {
        return 2 * Double.pi * radius
    }
    
    func draw() {
        print("🔵 Drawing circle with radius: \(radius)")
    }
}

// Shape manager that works with any Shape5 conforming type
class ShapeManager5 {
    func calculateTotalArea(shapes: [Shape5]) -> Double {
        return shapes.reduce(0) { $0 + $1.area }
    }
    
    func drawAllShapes(_ shapes: [Shape5]) {
        shapes.forEach { $0.draw() }
    }
    
    func findLargestShape(in shapes: [Shape5]) -> Shape5? {
        return shapes.max { $0.area < $1.area }
    }
}

// MARK: - Interface Segregation Principle (ISP)

// ❌ BAD: Fat interface that forces unnecessary implementations
protocol BadWorker5 {
    func work()
    func eat()
    func sleep()
    func code()
    func design()
}

// ✅ GOOD: Segregated interfaces
protocol Worker5 {
    func work()
}

protocol Eater5 {
    func eat()
}

protocol Sleeper5 {
    func sleep()
}

protocol Coder5 {
    func code()
}

protocol Designer5 {
    func design()
}

// Specific worker types implement only relevant interfaces
class Developer5: Worker5, Eater5, Sleeper5, Coder5 {
    func work() {
        print("👨‍💻 Developer is working")
    }
    
    func eat() {
        print("🍕 Developer is eating")
    }
    
    func sleep() {
        print("😴 Developer is sleeping")
    }
    
    func code() {
        print("⌨️ Developer is coding")
    }
}

class Designer6: Worker5, Eater5, Sleeper5, Designer5 {
    func work() {
        print("🎨 Designer is working")
    }
    
    func eat() {
        print("🥗 Designer is eating")
    }
    
    func sleep() {
        print("😴 Designer is sleeping")
    }
    
    func design() {
        print("🖌️ Designer is designing")
    }
}

class Robot5: Worker5, Coder5 {
    func work() {
        print("🤖 Robot is working")
    }
    
    func code() {
        print("⚡ Robot is coding")
    }
    
    // Robot doesn't need to eat or sleep
}

// MARK: - Dependency Inversion Principle (DIP)

// ❌ BAD: High-level module depends on low-level module
class BadNotificationService5 {
    private let emailSender = EmailSender5() // Direct dependency
    
    func sendNotification(message: String, to recipient: String) {
        emailSender.sendEmail(message: message, to: recipient)
    }
}

class EmailSender5 {
    func sendEmail(message: String, to recipient: String) {
        print("📧 Sending email to \(recipient): \(message)")
    }
}

// ✅ GOOD: Both depend on abstraction
protocol NotificationSender5 {
    func send(message: String, to recipient: String)
}

class EmailNotificationSender5: NotificationSender5 {
    func send(message: String, to recipient: String) {
        print("📧 Sending email to \(recipient): \(message)")
    }
}

class SMSNotificationSender5: NotificationSender5 {
    func send(message: String, to recipient: String) {
        print("📱 Sending SMS to \(recipient): \(message)")
    }
}

class PushNotificationSender5: NotificationSender5 {
    func send(message: String, to recipient: String) {
        print("🔔 Sending push notification to \(recipient): \(message)")
    }
}

class NotificationService5 {
    private let senders: [NotificationSender5]
    
    init(senders: [NotificationSender5]) {
        self.senders = senders
    }
    
    func sendNotification(message: String, to recipient: String) {
        senders.forEach { sender in
            sender.send(message: message, to: recipient)
        }
    }
}

// MARK: - Real-World iOS Example: User Authentication

// Following all SOLID principles
protocol AuthenticationRepository5 {
    func saveCredentials(_ credentials: UserCredentials5) throws
    func getCredentials(for username: String) throws -> UserCredentials5?
    func deleteCredentials(for username: String) throws
}

protocol PasswordValidator5 {
    func validate(_ password: String) -> ValidationResult5
}

protocol BiometricAuthenticator5 {
    func authenticateWithBiometrics() async throws -> Bool
}

protocol TokenManager5 {
    func generateToken(for user: User5) throws -> String
    func validateToken(_ token: String) throws -> Bool
    func refreshToken(_ token: String) throws -> String
}

struct UserCredentials5 {
    let username: String
    let hashedPassword: String
    let salt: String
}

struct ValidationResult5 {
    let isValid: Bool
    let errors: [String]
}

enum AuthenticationError5: Error {
    case invalidCredentials
    case biometricNotAvailable
    case tokenExpired
    case accountLocked
}

// Concrete implementations
class KeychainAuthRepository5: AuthenticationRepository5 {
    func saveCredentials(_ credentials: UserCredentials5) throws {
        print("🔐 Saving credentials to Keychain for user: \(credentials.username)")
        // Keychain implementation
    }
    
    func getCredentials(for username: String) throws -> UserCredentials5? {
        print("🔍 Retrieving credentials from Keychain for user: \(username)")
        // Keychain implementation
        return nil
    }
    
    func deleteCredentials(for username: String) throws {
        print("🗑️ Deleting credentials from Keychain for user: \(username)")
        // Keychain implementation
    }
}

class StrongPasswordValidator5: PasswordValidator5 {
    func validate(_ password: String) -> ValidationResult5 {
        var errors: [String] = []
        
        if password.count < 8 {
            errors.append("Password must be at least 8 characters long")
        }
        
        if !password.contains(where: { $0.isUppercase }) {
            errors.append("Password must contain at least one uppercase letter")
        }
        
        if !password.contains(where: { $0.isLowercase }) {
            errors.append("Password must contain at least one lowercase letter")
        }
        
        if !password.contains(where: { $0.isNumber }) {
            errors.append("Password must contain at least one number")
        }
        
        return ValidationResult5(isValid: errors.isEmpty, errors: errors)
    }
}

class TouchIDAuthenticator5: BiometricAuthenticator5 {
    func authenticateWithBiometrics() async throws -> Bool {
        print("👆 Authenticating with Touch ID")
        // Touch ID implementation
        return true
    }
}

class JWTTokenManager5: TokenManager5 {
    func generateToken(for user: User5) throws -> String {
        print("🎫 Generating JWT token for user: \(user.name)")
        return "jwt_token_\(user.id)"
    }
    
    func validateToken(_ token: String) throws -> Bool {
        print("✅ Validating JWT token: \(token)")
        return true
    }
    
    func refreshToken(_ token: String) throws -> String {
        print("🔄 Refreshing JWT token: \(token)")
        return "refreshed_\(token)"
    }
}

// Main authentication service following DIP
class AuthenticationService5 {
    private let repository: AuthenticationRepository5
    private let passwordValidator: PasswordValidator5
    private let biometricAuth: BiometricAuthenticator5
    private let tokenManager: TokenManager5
    
    init(
        repository: AuthenticationRepository5,
        passwordValidator: PasswordValidator5,
        biometricAuth: BiometricAuthenticator5,
        tokenManager: TokenManager5
    ) {
        self.repository = repository
        self.passwordValidator = passwordValidator
        self.biometricAuth = biometricAuth
        self.tokenManager = tokenManager
    }
    
    func register(username: String, password: String) throws -> User5 {
        // Validate password
        let validation = passwordValidator.validate(password)
        guard validation.isValid else {
            throw AuthenticationError5.invalidCredentials
        }
        
        // Hash password and save
        let salt = UUID().uuidString
        let hashedPassword = hashPassword(password, salt: salt)
        let credentials = UserCredentials5(username: username, hashedPassword: hashedPassword, salt: salt)
        
        try repository.saveCredentials(credentials)
        
        let user = User5(name: username, email: "\(username)@example.com")
        print("✅ User registered successfully: \(username)")
        return user
    }
    
    func login(username: String, password: String) throws -> String {
        guard let credentials = try repository.getCredentials(for: username) else {
            throw AuthenticationError5.invalidCredentials
        }
        
        let hashedPassword = hashPassword(password, salt: credentials.salt)
        guard hashedPassword == credentials.hashedPassword else {
            throw AuthenticationError5.invalidCredentials
        }
        
        let user = User5(name: username, email: "\(username)@example.com")
        return try tokenManager.generateToken(for: user)
    }
    
    func loginWithBiometrics() async throws -> String {
        let isAuthenticated = try await biometricAuth.authenticateWithBiometrics()
        guard isAuthenticated else {
            throw AuthenticationError5.biometricNotAvailable
        }
        
        // For demo purposes, create a dummy user
        let user = User5(name: "BiometricUser", email: "biometric@example.com")
        return try tokenManager.generateToken(for: user)
    }
    
    private func hashPassword(_ password: String, salt: String) -> String {
        return "\(password)_\(salt)_hashed"
    }
}

// MARK: - SOLID Principles in SwiftUI

// Following SRP: Separate view logic from business logic
struct UserProfileView5: View {
    @StateObject private var viewModel = UserProfileViewModel5()
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                UserInfoView5(user: viewModel.user)
                UserStatsView5(stats: viewModel.stats)
                
                Button("Refresh") {
                    viewModel.refreshUserData()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            viewModel.loadUserData()
        }
    }
}

// Separate view components (SRP)
struct UserInfoView5: View {
    let user: User5?
    
    var body: some View {
        VStack {
            if let user = user {
                Text(user.name)
                    .font(.title)
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No user data")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct UserStatsView5: View {
    let stats: UserStats5?
    
    var body: some View {
        HStack {
            if let stats = stats {
                VStack {
                    Text("\(stats.postsCount)")
                        .font(.title2)
                        .bold()
                    Text("Posts")
                        .font(.caption)
                }
                
                VStack {
                    Text("\(stats.followersCount)")
                        .font(.title2)
                        .bold()
                    Text("Followers")
                        .font(.caption)
                }
                
                VStack {
                    Text("\(stats.followingCount)")
                        .font(.title2)
                        .bold()
                    Text("Following")
                        .font(.caption)
                }
            }
        }
    }
}

struct UserStats5 {
    let postsCount: Int
    let followersCount: Int
    let followingCount: Int
}

// ViewModel following SRP and DIP
class UserProfileViewModel5: ObservableObject {
    @Published var user: User5?
    @Published var stats: UserStats5?
    @Published var isLoading = false
    
    private let userService: UserService5
    private let statsService: UserStatsService5
    
    init(userService: UserService5 = DefaultUserService5(), statsService: UserStatsService5 = DefaultUserStatsService5()) {
        self.userService = userService
        self.statsService = statsService
    }
    
    func loadUserData() {
        isLoading = true
        
        Task {
            do {
                async let userResult = userService.getCurrentUser()
                async let statsResult = statsService.getUserStats()
                
                let (loadedUser, loadedStats) = try await (userResult, statsResult)
                
                await MainActor.run {
                    self.user = loadedUser
                    self.stats = loadedStats
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Error loading user data: \(error)")
                }
            }
        }
    }
    
    func refreshUserData() {
        loadUserData()
    }
}

// Service protocols (ISP and DIP)
protocol UserService5 {
    func getCurrentUser() async throws -> User5
    func updateUser(_ user: User5) async throws
}

protocol UserStatsService5 {
    func getUserStats() async throws -> UserStats5
}

class DefaultUserService5: UserService5 {
    func getCurrentUser() async throws -> User5 {
        // Simulate network call
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return User5(name: "John Doe", email: "john@example.com")
    }
    
    func updateUser(_ user: User5) async throws {
        // Update user implementation
        print("Updating user: \(user.name)")
    }
}

class DefaultUserStatsService5: UserStatsService5 {
    func getUserStats() async throws -> UserStats5 {
        // Simulate network call
        try await Task.sleep(nanoseconds: 800_000_000)
        return UserStats5(postsCount: 42, followersCount: 1337, followingCount: 256)
    }
}

// MARK: - Usage Examples

class SOLIDExamples5 {
    
    func demonstrateSRP() {
        print("=== Single Responsibility Principle ===")
        
        let repository = CoreDataUserRepository5()
        let emailService = SMTPEmailService5()
        let logger = ConsoleLogger5()
        
        let userManager = UserManager5(
            repository: repository,
            emailService: emailService,
            logger: logger
        )
        
        do {
            let user = try userManager.createUser(name: "Alice", email: "alice@example.com")
            print("✅ Created user: \(user.name)")
        } catch {
            print("❌ Error creating user: \(error)")
        }
    }
    
    func demonstrateOCP() {
        print("\n=== Open/Closed Principle ===")
        
        let paymentManager = PaymentManager5()
        
        // Register different payment processors
        paymentManager.registerProcessor(CreditCardProcessor5())
        paymentManager.registerProcessor(PayPalProcessor5())
        paymentManager.registerProcessor(ApplePayProcessor5())
        
        print("Available processors: \(paymentManager.availableProcessors())")
        
        do {
            let result = try paymentManager.processPayment(amount: 99.99, using: "Apple Pay")
            print("✅ Payment result: \(result.message)")
        } catch {
            print("❌ Payment error: \(error)")
        }
    }
    
    func demonstrateLSP() {
        print("\n=== Liskov Substitution Principle ===")
        
        let shapes: [Shape5] = [
            Rectangle5(width: 10, height: 5),
            Square5(side: 7),
            Circle5(radius: 3)
        ]
        
        let shapeManager = ShapeManager5()
        
        print("Total area: \(shapeManager.calculateTotalArea(shapes: shapes))")
        shapeManager.drawAllShapes(shapes)
        
        if let largest = shapeManager.findLargestShape(in: shapes) {
            print("Largest shape area: \(largest.area)")
        }
    }
    
    func demonstrateISP() {
        print("\n=== Interface Segregation Principle ===")
        
        let developer = Developer5()
        let designer = Designer6()
        let robot = Robot5()
        
        let workers: [Worker5] = [developer, designer, robot]
        
        workers.forEach { worker in
            worker.work()
        }
        
        // Only some workers can code
        let coders: [Coder5] = [developer, robot]
        coders.forEach { coder in
            coder.code()
        }
    }
    
    func demonstrateDIP() {
        print("\n=== Dependency Inversion Principle ===")
        
        let senders: [NotificationSender5] = [
            EmailNotificationSender5(),
            SMSNotificationSender5(),
            PushNotificationSender5()
        ]
        
        let notificationService = NotificationService5(senders: senders)
        notificationService.sendNotification(
            message: "Welcome to our app!",
            to: "user@example.com"
        )
    }
    
    func demonstrateRealWorldExample() {
        print("\n=== Real-World Authentication Example ===")
        
        let authService = AuthenticationService5(
            repository: KeychainAuthRepository5(),
            passwordValidator: StrongPasswordValidator5(),
            biometricAuth: TouchIDAuthenticator5(),
            tokenManager: JWTTokenManager5()
        )
        
        do {
            let user = try authService.register(username: "testuser", password: "SecurePass123")
            print("✅ User registered: \(user.name)")
            
            let token = try authService.login(username: "testuser", password: "SecurePass123")
            print("✅ Login successful, token: \(token)")
            
        } catch {
            print("❌ Authentication error: \(error)")
        }
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Single Responsibility Principle (SRP)**:
    - Each class should have only one reason to change
    - Separate concerns into different classes
    - Easier to test, maintain, and understand
    - Example: UserManager, Repository, EmailService

 2. **Open/Closed Principle (OCP)**:
    - Open for extension, closed for modification
    - Use protocols and polymorphism
    - Add new functionality without changing existing code
    - Example: PaymentProcessor protocol with different implementations

 3. **Liskov Substitution Principle (LSP)**:
    - Subtypes must be substitutable for their base types
    - Derived classes should extend, not replace behavior
    - Maintain behavioral compatibility
    - Example: Shape hierarchy with consistent interface

 4. **Interface Segregation Principle (ISP)**:
    - Clients shouldn't depend on interfaces they don't use
    - Create specific, focused protocols
    - Avoid fat interfaces with unnecessary methods
    - Example: Separate Worker, Eater, Sleeper protocols

 5. **Dependency Inversion Principle (DIP)**:
    - High-level modules shouldn't depend on low-level modules
    - Both should depend on abstractions
    - Use dependency injection
    - Example: NotificationService depends on NotificationSender protocol

 6. **iOS-Specific Applications**:
    - Repository pattern for data access
    - Service layer for business logic
    - Protocol-based dependency injection
    - SwiftUI view composition following SRP

 7. **Benefits of SOLID Principles**:
    - Maintainable and scalable code
    - Easier testing with dependency injection
    - Reduced coupling between components
    - Better code reusability

 8. **Common Interview Questions**:
    - Q: What are SOLID principles?
    - A: Five design principles for maintainable OOP code

    - Q: How does DIP help with testing?
    - A: Allows injection of mock dependencies

    - Q: Give an example of violating SRP?
    - A: Class that handles both business logic and UI updates

    - Q: How do you apply OCP in iOS?
    - A: Use protocols and extensions to add functionality

 9. **Architectural Patterns**:
    - Repository pattern for data access
    - Service layer for business logic
    - Factory pattern for object creation
    - Strategy pattern for algorithms

 10. **Best Practices**:
     - Use protocols for abstraction
     - Inject dependencies through initializers
     - Keep classes focused on single responsibility
     - Prefer composition over inheritance
     - Write testable code with mocked dependencies

 11. **Common Violations**:
     - Massive view controllers doing everything
     - Tight coupling to concrete implementations
     - Fat interfaces with unused methods
     - Direct instantiation of dependencies

 12. **Testing Benefits**:
     - Mock dependencies for unit testing
     - Test individual components in isolation
     - Verify behavior through protocol contracts
     - Easy setup and teardown in tests
*/ 