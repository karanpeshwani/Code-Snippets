//
//  NotificationCenter-Usage.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import UIKit

// MARK: - Custom Notification Names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let dataDidUpdate = Notification.Name("dataDidUpdate")
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
    static let themeDidChange = Notification.Name("themeDidChange")
    static let cartItemAdded = Notification.Name("cartItemAdded")
    static let cartItemRemoved = Notification.Name("cartItemRemoved")
}

// MARK: - User Info Keys
struct NotificationUserInfoKey {
    static let userID = "userID"
    static let userName = "userName"
    static let dataType = "dataType"
    static let networkStatus = "networkStatus"
    static let themeName = "themeName"
    static let productID = "productID"
    static let quantity = "quantity"
    static let errorMessage = "errorMessage"
}

// MARK: - Data Models
struct User1 {
    let id: String
    let name: String
    let email: String
}

struct Product2 {
    let id: String
    let name: String
    let price: Double
}

enum NetworkStatus1 {
    case connected
    case disconnected
    case connecting
}

enum AppTheme1: String {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

// MARK: - Notification Publisher (Service Layer)
class NotificationPublisher1 {
    
    // MARK: - User Authentication Notifications
    func userDidLogin(_ user: User1) {
        let userInfo: [String: Any] = [
            NotificationUserInfoKey.userID: user.id,
            NotificationUserInfoKey.userName: user.name
        ]
        
        NotificationCenter.default.post(
            name: .userDidLogin,
            object: self,
            userInfo: userInfo
        )
        
        print("📤 Posted userDidLogin notification for: \(user.name)")
    }
    
    func userDidLogout() {
        NotificationCenter.default.post(
            name: .userDidLogout,
            object: self
        )
        
        print("📤 Posted userDidLogout notification")
    }
    
    // MARK: - Data Update Notifications
    func dataDidUpdate(dataType: String) {
        let userInfo: [String: Any] = [
            NotificationUserInfoKey.dataType: dataType
        ]
        
        NotificationCenter.default.post(
            name: .dataDidUpdate,
            object: self,
            userInfo: userInfo
        )
        
        print("📤 Posted dataDidUpdate notification for: \(dataType)")
    }
    
    // MARK: - Network Status Notifications
    func networkStatusChanged(to status: NetworkStatus1) {
        let userInfo: [String: Any] = [
            NotificationUserInfoKey.networkStatus: status
        ]
        
        NotificationCenter.default.post(
            name: .networkStatusChanged,
            object: self,
            userInfo: userInfo
        )
        
        print("📤 Posted networkStatusChanged notification: \(status)")
    }
    
    // MARK: - Theme Change Notifications
    func themeDidChange(to theme: AppTheme1) {
        let userInfo: [String: Any] = [
            NotificationUserInfoKey.themeName: theme.rawValue
        ]
        
        NotificationCenter.default.post(
            name: .themeDidChange,
            object: self,
            userInfo: userInfo
        )
        
        print("📤 Posted themeDidChange notification: \(theme.rawValue)")
    }
    
    // MARK: - Shopping Cart Notifications
    func cartItemAdded(_ product: Product2, quantity: Int) {
        let userInfo: [String: Any] = [
            NotificationUserInfoKey.productID: product.id,
            NotificationUserInfoKey.quantity: quantity
        ]
        
        NotificationCenter.default.post(
            name: .cartItemAdded,
            object: self,
            userInfo: userInfo
        )
        
        print("📤 Posted cartItemAdded notification: \(product.name) x\(quantity)")
    }
    
    func cartItemRemoved(_ productID: String) {
        let userInfo: [String: Any] = [
            NotificationUserInfoKey.productID: productID
        ]
        
        NotificationCenter.default.post(
            name: .cartItemRemoved,
            object: self,
            userInfo: userInfo
        )
        
        print("📤 Posted cartItemRemoved notification: \(productID)")
    }
}

// MARK: - Notification Observer (UI Layer)
class NotificationObserver1 {
    
    private var observers: [NSObjectProtocol] = []
    
    init() {
        setupNotificationObservers()
    }
    
    deinit {
        removeAllObservers()
    }
    
    // MARK: - Setup Observers
    private func setupNotificationObservers() {
        
        // User authentication observers
        let loginObserver = NotificationCenter.default.addObserver(
            forName: .userDidLogin,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleUserDidLogin(notification)
        }
        observers.append(loginObserver)
        
        let logoutObserver = NotificationCenter.default.addObserver(
            forName: .userDidLogout,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleUserDidLogout(notification)
        }
        observers.append(logoutObserver)
        
        // Data update observer
        let dataUpdateObserver = NotificationCenter.default.addObserver(
            forName: .dataDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleDataDidUpdate(notification)
        }
        observers.append(dataUpdateObserver)
        
        // Network status observer
        let networkObserver = NotificationCenter.default.addObserver(
            forName: .networkStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleNetworkStatusChanged(notification)
        }
        observers.append(networkObserver)
        
        // Theme change observer
        let themeObserver = NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleThemeDidChange(notification)
        }
        observers.append(themeObserver)
        
        // Shopping cart observers
        let cartAddObserver = NotificationCenter.default.addObserver(
            forName: .cartItemAdded,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleCartItemAdded(notification)
        }
        observers.append(cartAddObserver)
        
        let cartRemoveObserver = NotificationCenter.default.addObserver(
            forName: .cartItemRemoved,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleCartItemRemoved(notification)
        }
        observers.append(cartRemoveObserver)
        
        // System notifications
        setupSystemNotificationObservers()
    }
    
    // MARK: - System Notification Observers
    private func setupSystemNotificationObservers() {
        
        // App lifecycle notifications
        let willEnterForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppWillEnterForeground(notification)
        }
        observers.append(willEnterForegroundObserver)
        
        let didEnterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppDidEnterBackground(notification)
        }
        observers.append(didEnterBackgroundObserver)
        
        // Memory warning notification
        let memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleMemoryWarning(notification)
        }
        observers.append(memoryWarningObserver)
        
        // Keyboard notifications
        let keyboardWillShowObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardWillShow(notification)
        }
        observers.append(keyboardWillShowObserver)
        
        let keyboardWillHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardWillHide(notification)
        }
        observers.append(keyboardWillHideObserver)
    }
    
    // MARK: - Notification Handlers
    private func handleUserDidLogin(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let userID = userInfo[NotificationUserInfoKey.userID] as? String,
              let userName = userInfo[NotificationUserInfoKey.userName] as? String else {
            return
        }
        
        print("📥 Received userDidLogin: \(userName) (ID: \(userID))")
        
        // Update UI for logged in state
        updateUIForLoggedInUser(userID: userID, userName: userName)
    }
    
    private func handleUserDidLogout(_ notification: Notification) {
        print("📥 Received userDidLogout")
        
        // Update UI for logged out state
        updateUIForLoggedOutUser()
    }
    
    private func handleDataDidUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let dataType = userInfo[NotificationUserInfoKey.dataType] as? String else {
            return
        }
        
        print("📥 Received dataDidUpdate: \(dataType)")
        
        // Refresh specific data type
        refreshData(type: dataType)
    }
    
    private func handleNetworkStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let networkStatus = userInfo[NotificationUserInfoKey.networkStatus] as? NetworkStatus1 else {
            return
        }
        
        print("📥 Received networkStatusChanged: \(networkStatus)")
        
        // Update UI based on network status
        updateNetworkStatusUI(status: networkStatus)
    }
    
    private func handleThemeDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let themeName = userInfo[NotificationUserInfoKey.themeName] as? String,
              let theme = AppTheme1(rawValue: themeName) else {
            return
        }
        
        print("📥 Received themeDidChange: \(theme.rawValue)")
        
        // Apply new theme
        applyTheme(theme)
    }
    
    private func handleCartItemAdded(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let productID = userInfo[NotificationUserInfoKey.productID] as? String,
              let quantity = userInfo[NotificationUserInfoKey.quantity] as? Int else {
            return
        }
        
        print("📥 Received cartItemAdded: \(productID) x\(quantity)")
        
        // Update cart UI
        updateCartUI(productAdded: productID, quantity: quantity)
    }
    
    private func handleCartItemRemoved(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let productID = userInfo[NotificationUserInfoKey.productID] as? String else {
            return
        }
        
        print("📥 Received cartItemRemoved: \(productID)")
        
        // Update cart UI
        updateCartUI(productRemoved: productID)
    }
    
    // MARK: - System Notification Handlers
    private func handleAppWillEnterForeground(_ notification: Notification) {
        print("📥 App will enter foreground")
        
        // Refresh data when app becomes active
        refreshAppData()
    }
    
    private func handleAppDidEnterBackground(_ notification: Notification) {
        print("📥 App did enter background")
        
        // Save data when app goes to background
        saveAppData()
    }
    
    private func handleMemoryWarning(_ notification: Notification) {
        print("📥 Memory warning received")
        
        // Free up memory
        freeUpMemory()
    }
    
    private func handleKeyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        print("📥 Keyboard will show: height = \(keyboardFrame.height)")
        
        // Adjust UI for keyboard
        adjustUIForKeyboard(height: keyboardFrame.height, duration: duration, show: true)
    }
    
    private func handleKeyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        print("📥 Keyboard will hide")
        
        // Adjust UI for keyboard hiding
        adjustUIForKeyboard(height: 0, duration: duration, show: false)
    }
    
    // MARK: - Cleanup
    private func removeAllObservers() {
        observers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
        
        print("🧹 Removed all notification observers")
    }
    
    // MARK: - UI Update Methods (Placeholder implementations)
    private func updateUIForLoggedInUser(userID: String, userName: String) {
        // Update UI elements for logged in state
        print("🎨 Updating UI for logged in user: \(userName)")
    }
    
    private func updateUIForLoggedOutUser() {
        // Update UI elements for logged out state
        print("🎨 Updating UI for logged out state")
    }
    
    private func refreshData(type: String) {
        // Refresh specific type of data
        print("🔄 Refreshing \(type) data")
    }
    
    private func updateNetworkStatusUI(status: NetworkStatus1) {
        // Update network status indicator
        print("🌐 Updating network status UI: \(status)")
    }
    
    private func applyTheme(_ theme: AppTheme1) {
        // Apply theme to UI elements
        print("🎨 Applying theme: \(theme.rawValue)")
    }
    
    private func updateCartUI(productAdded productID: String, quantity: Int) {
        // Update cart badge/UI
        print("🛒 Updated cart UI - added: \(productID) x\(quantity)")
    }
    
    private func updateCartUI(productRemoved productID: String) {
        // Update cart badge/UI
        print("🛒 Updated cart UI - removed: \(productID)")
    }
    
    private func refreshAppData() {
        // Refresh app data when returning from background
        print("🔄 Refreshing app data")
    }
    
    private func saveAppData() {
        // Save app data when going to background
        print("💾 Saving app data")
    }
    
    private func freeUpMemory() {
        // Free up memory during memory warnings
        print("🧹 Freeing up memory")
    }
    
    private func adjustUIForKeyboard(height: CGFloat, duration: Double, show: Bool) {
        // Adjust UI layout for keyboard
        print("⌨️ Adjusting UI for keyboard: height=\(height), show=\(show)")
    }
}

// MARK: - Advanced Notification Patterns
class AdvancedNotificationPatterns1 {
    
    private var observers: [NSObjectProtocol] = []
    
    // MARK: - Conditional Observation
    func setupConditionalObserver() {
        // Only observe notifications from specific objects
        let observer = NotificationCenter.default.addObserver(
            forName: .dataDidUpdate,
            object: nil, // Set to specific object to filter
            queue: .main
        ) { notification in
            // Only handle if notification comes from expected source
            if let source = notification.object as? NotificationPublisher1 {
                print("📥 Received notification from expected source")
            }
        }
        observers.append(observer)
    }
    
    // MARK: - Background Queue Observation
    func setupBackgroundQueueObserver() {
        let backgroundQueue = OperationQueue()
        backgroundQueue.maxConcurrentOperationCount = 1
        
        let observer = NotificationCenter.default.addObserver(
            forName: .dataDidUpdate,
            object: nil,
            queue: backgroundQueue // Process on background queue
        ) { notification in
            // Heavy processing on background queue
            print("🔄 Processing notification on background queue")
            
            // Switch to main queue for UI updates
            DispatchQueue.main.async {
                print("🎨 Updating UI on main queue")
            }
        }
        observers.append(observer)
    }
    
    // MARK: - Notification Coalescing
    private var coalesceTimer: Timer?
    
    func setupCoalescingObserver() {
        let observer = NotificationCenter.default.addObserver(
            forName: .dataDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            // Coalesce multiple rapid notifications
            self?.coalesceTimer?.invalidate()
            self?.coalesceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self?.handleCoalescedDataUpdate()
            }
        }
        observers.append(observer)
    }
    
    private func handleCoalescedDataUpdate() {
        print("📥 Handling coalesced data update")
    }
    
    // MARK: - Custom Notification Center
    func demonstrateCustomNotificationCenter() {
        let customCenter = NotificationCenter()
        
        // Use custom notification center for specific purposes
        let observer = customCenter.addObserver(
            forName: .dataDidUpdate,
            object: nil,
            queue: .main
        ) { notification in
            print("📥 Custom notification center notification")
        }
        
        // Post to custom center
        customCenter.post(name: .dataDidUpdate, object: nil)
        
        // Cleanup
        customCenter.removeObserver(observer)
    }
    
    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        coalesceTimer?.invalidate()
    }
}

// MARK: - NotificationCenter Best Practices
class NotificationCenterBestPractices1 {
    
    // MARK: - Proper Observer Management
    private var observations: [NSKeyValueObservation] = []
    private var notificationObservers: [NSObjectProtocol] = []
    
    func setupProperObserverManagement() {
        // Store observer tokens for proper cleanup
        let observer = NotificationCenter.default.addObserver(
            forName: .userDidLogin,
            object: nil,
            queue: .main
        ) { notification in
            print("📥 User logged in")
        }
        
        notificationObservers.append(observer)
    }
    
    // MARK: - Avoid Retain Cycles
    func avoidRetainCycles() {
        // Use weak self to avoid retain cycles
        let observer = NotificationCenter.default.addObserver(
            forName: .userDidLogout,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleUserLogout()
        }
        
        notificationObservers.append(observer)
    }
    
    private func handleUserLogout() {
        print("📥 Handling user logout")
    }
    
    // MARK: - Proper Cleanup
    deinit {
        // Remove all observers in deinit
        notificationObservers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        notificationObservers.removeAll()
        
        observations.forEach { $0.invalidate() }
        observations.removeAll()
        
        print("🧹 Cleaned up all observers")
    }
}

// MARK: - Usage Example
class NotificationCenterDemo1 {
    
    private let publisher = NotificationPublisher1()
    private let observer = NotificationObserver1()
    private let advancedPatterns = AdvancedNotificationPatterns1()
    
    func demonstrateNotificationCenter() {
        print("=== NotificationCenter Demo ===\n")
        
        // Simulate user login
        let user = User1(id: "123", name: "John Doe", email: "john@example.com")
        publisher.userDidLogin(user)
        
        // Simulate data updates
        publisher.dataDidUpdate(dataType: "userProfile")
        publisher.dataDidUpdate(dataType: "posts")
        
        // Simulate network status changes
        publisher.networkStatusChanged(to: .connected)
        
        // Simulate theme change
        publisher.themeDidChange(to: .dark)
        
        // Simulate shopping cart actions
        let product = Product2(id: "P001", name: "iPhone", price: 999.99)
        publisher.cartItemAdded(product, quantity: 2)
        publisher.cartItemRemoved("P001")
        
        // Simulate user logout
        publisher.userDidLogout()
        
        // Demonstrate advanced patterns
        advancedPatterns.setupConditionalObserver()
        advancedPatterns.setupBackgroundQueueObserver()
        advancedPatterns.setupCoalescingObserver()
        advancedPatterns.demonstrateCustomNotificationCenter()
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **NotificationCenter Basics**:
    - Observer pattern implementation
    - Decoupled communication between objects
    - One-to-many broadcasting
    - Synchronous by default (unless using queues)

 2. **Notification Components**:
    - Name: Identifier for notification type
    - Object: Sender of the notification (optional)
    - UserInfo: Additional data dictionary (optional)
    - Queue: Which queue to handle notification on

 3. **Observer Management**:
    - addObserver methods (block-based and target-action)
    - removeObserver for cleanup
    - Store observer tokens for proper cleanup
    - Remove observers in deinit to prevent crashes

 4. **Memory Management**:
    - Use weak self in blocks to avoid retain cycles
    - Remove observers before object deallocation
    - NotificationCenter holds weak references to observers
    - Automatic cleanup when observer is deallocated

 5. **Best Practices**:
    - Use extension for custom notification names
    - Define constants for userInfo keys
    - Handle notifications on appropriate queues
    - Validate userInfo data before using
    - Use meaningful notification names

 6. **Common Pitfalls**:
    - Forgetting to remove observers (can cause crashes)
    - Retain cycles with strong self references
    - Not handling notifications on main queue for UI updates
    - Over-using notifications (prefer delegates for 1-to-1)

 7. **Performance Considerations**:
    - Notifications are synchronous by default
    - Use background queues for heavy processing
    - Consider coalescing rapid notifications
    - Don't post notifications too frequently

 8. **Common Interview Questions**:
    - Q: When to use NotificationCenter vs Delegate?
    - A: NotificationCenter for 1-to-many, Delegate for 1-to-1
    
    - Q: How to prevent retain cycles with notifications?
    - A: Use weak self in observer blocks
    
    - Q: What happens if you don't remove observers?
    - A: Can cause crashes when notification is posted after deallocation
    
    - Q: Are notifications synchronous or asynchronous?
    - A: Synchronous by default, can specify queue for async handling

 9. **Advanced Patterns**:
    - Custom NotificationCenter instances
    - Notification coalescing for performance
    - Conditional observation based on sender
    - Background queue processing

 10. **System Notifications**:
     - App lifecycle notifications
     - Keyboard show/hide notifications
     - Memory warning notifications
     - Device orientation changes
     - Network status changes
*/ 