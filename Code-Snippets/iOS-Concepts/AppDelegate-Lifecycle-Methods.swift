//
//  AppDelegate-Lifecycle-Methods.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import UIKit
import UserNotifications
import BackgroundTasks

// MARK: - Main App Delegate
class AppDelegate1: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: - App Launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        print("🚀 App finished launching")
        
        // Initialize app components
        setupAppearance()
        setupNotifications()
        setupBackgroundTasks()
        
        // Check launch options
        if let launchOptions = launchOptions {
            handleLaunchOptions(launchOptions)
        }
        
        // Setup window (for apps without Scene Delegate)
        setupWindow()
        
        return true
    }
    
    // MARK: - App State Changes
    func applicationWillResignActive(_ application: UIApplication) {
        print("⏸️ App will resign active")
        
        // Pause ongoing tasks
        pauseGameOrVideo()
        saveUserData()
        
        // Disable timers
        disableIdleTimer()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 App entered background")
        
        // Save application state
        saveApplicationState()
        
        // Start background task if needed
        startBackgroundTask()
        
        // Invalidate timers
        invalidateTimers()
        
        // Prepare for app suspension
        prepareForSuspension()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("🌅 App will enter foreground")
        
        // Prepare for active state
        prepareForActive()
        
        // Refresh data if needed
        refreshDataIfNeeded()
        
        // Restart timers
        restartTimers()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("✅ App became active")
        
        // Resume paused tasks
        resumeGameOrVideo()
        
        // Restart animations
        restartAnimations()
        
        // Enable idle timer
        enableIdleTimer()
        
        // Check for app updates
        checkForAppUpdates()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("❌ App will terminate")
        
        // Save critical data
        saveCriticalData()
        
        // Clean up resources
        cleanupResources()
        
        // Note: This is not always called (especially in iOS 13+)
        // Most cleanup should happen in applicationDidEnterBackground
    }
    
    // MARK: - Memory Management
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("⚠️ App received memory warning")
        
        // Free up memory
        clearImageCache()
        releaseNonEssentialResources()
        
        // Notify view controllers
        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    // MARK: - URL Handling
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        
        print("🔗 App opened with URL: \(url)")
        
        // Handle different URL schemes
        if url.scheme == "myapp" {
            return handleCustomURL(url)
        } else if url.scheme == "https" {
            return handleUniversalLink(url)
        }
        
        return false
    }
    
    // MARK: - Push Notifications
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device token: \(tokenString)")
        
        // Send token to server
        sendTokenToServer(tokenString)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error)")
        
        // Handle registration failure
        handleNotificationRegistrationFailure(error)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
        print("📬 Received remote notification: \(userInfo)")
        
        // Process notification
        processRemoteNotification(userInfo) { result in
            completionHandler(result)
        }
    }
    
    // MARK: - Background Processing
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
        print("🔄 Performing background fetch")
        
        // Perform background data fetch
        performBackgroundDataFetch { result in
            completionHandler(result)
        }
    }
    
    // MARK: - Handoff and Continuity
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        
        print("🔄 Continuing user activity: \(userActivity.activityType)")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                return handleUniversalLink(url)
            }
        }
        
        return false
    }
    
    // MARK: - State Restoration
    func application(
        _ application: UIApplication,
        shouldSaveApplicationState coder: NSCoder
    ) -> Bool {
        print("💾 Should save application state")
        return true
    }
    
    func application(
        _ application: UIApplication,
        shouldRestoreApplicationState coder: NSCoder
    ) -> Bool {
        print("📂 Should restore application state")
        return true
    }
    
    func application(
        _ application: UIApplication,
        viewControllerWithRestorationIdentifierPath identifierComponents: [String],
        coder: NSCoder
    ) -> UIViewController? {
        
        print("🔄 Restoring view controller: \(identifierComponents)")
        
        // Return appropriate view controller for restoration
        return createViewControllerForRestoration(identifierComponents: identifierComponents)
    }
}

// MARK: - Helper Methods
extension AppDelegate1 {
    
    private func setupAppearance() {
        // Configure app-wide appearance
        UINavigationBar.appearance().tintColor = .systemBlue
        UITabBar.appearance().tintColor = .systemBlue
        
        // Configure window
        if #available(iOS 13.0, *) {
            // Scene delegate handles window setup in iOS 13+
        } else {
            window?.tintColor = .systemBlue
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                print("✅ Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("❌ Notification permission denied")
            }
        }
    }
    
    private func setupBackgroundTasks() {
        // Register background tasks (iOS 13+)
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.app.background-refresh",
                using: nil
            ) { task in
                self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    private func setupWindow() {
        // For apps without Scene Delegate (iOS 12 and below)
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.backgroundColor = .systemBackground
            
            // Set root view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = storyboard.instantiateInitialViewController()
            window?.makeKeyAndVisible()
        }
    }
    
    private func handleLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]) {
        // Handle different launch scenarios
        
        if let url = launchOptions[.url] as? URL {
            print("🔗 Launched with URL: \(url)")
            // Handle URL launch
        }
        
        if let notification = launchOptions[.remoteNotification] as? [AnyHashable: Any] {
            print("📬 Launched from remote notification: \(notification)")
            // Handle notification launch
        }
        
        if let localNotification = launchOptions[.localNotification] as? UILocalNotification {
            print("📱 Launched from local notification")
            // Handle local notification launch
        }
        
        if let shortcutItem = launchOptions[.shortcutItem] as? UIApplicationShortcutItem {
            print("⚡ Launched from shortcut: \(shortcutItem.type)")
            // Handle shortcut launch
        }
    }
    
    // MARK: - State Management
    private func saveApplicationState() {
        print("💾 Saving application state...")
        
        // Save user preferences
        UserDefaults.standard.set(Date(), forKey: "lastBackgroundTime")
        UserDefaults.standard.synchronize()
        
        // Save Core Data context
        saveCoreDataContext()
    }
    
    private func saveCriticalData() {
        print("💾 Saving critical data...")
        
        // Save any critical user data
        saveCoreDataContext()
        
        // Save current user session
        saveUserSession()
    }
    
    private func prepareForSuspension() {
        print("😴 Preparing for suspension...")
        
        // Close network connections
        closeNetworkConnections()
        
        // Stop location services if not needed
        stopLocationServices()
        
        // Minimize memory usage
        minimizeMemoryUsage()
    }
    
    private func prepareForActive() {
        print("🌅 Preparing for active state...")
        
        // Restore network connections
        restoreNetworkConnections()
        
        // Update UI if needed
        updateUIForActiveState()
    }
    
    // MARK: - Background Tasks
    private func startBackgroundTask() {
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "DataSync") {
            // Clean up when time expires
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        // Perform background work
        DispatchQueue.global().async {
            // Do background work here
            self.syncDataInBackground()
            
            // End background task
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    @available(iOS 13.0, *)
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // Schedule next background refresh
        scheduleBackgroundRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform background refresh
        performBackgroundDataFetch { result in
            task.setTaskCompleted(success: result == .newData)
        }
    }
    
    @available(iOS 13.0, *)
    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.app.background-refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        try? BGTaskScheduler.shared.submit(request)
    }
    
    // MARK: - URL Handling
    private func handleCustomURL(_ url: URL) -> Bool {
        print("🔗 Handling custom URL: \(url)")
        
        // Parse URL components
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        // Handle different paths
        switch components.path {
        case "/profile":
            navigateToProfile()
            return true
        case "/settings":
            navigateToSettings()
            return true
        default:
            return false
        }
    }
    
    private func handleUniversalLink(_ url: URL) -> Bool {
        print("🌐 Handling universal link: \(url)")
        
        // Parse and handle universal link
        // Navigate to appropriate screen
        
        return true
    }
    
    // MARK: - Notification Handling
    private func sendTokenToServer(_ token: String) {
        // Send device token to your server
        print("📤 Sending token to server: \(token)")
    }
    
    private func handleNotificationRegistrationFailure(_ error: Error) {
        // Handle registration failure
        print("❌ Notification registration failed: \(error)")
    }
    
    private func processRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
        // Process notification payload
        if let aps = userInfo["aps"] as? [String: Any] {
            print("📬 APS payload: \(aps)")
        }
        
        // Perform data fetch based on notification
        fetchDataBasedOnNotification(userInfo) { success in
            completion(success ? .newData : .failed)
        }
    }
    
    // MARK: - Data Operations
    private func performBackgroundDataFetch(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        // Simulate background data fetch
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // Simulate success/failure
            let success = Bool.random()
            completion(success ? .newData : .noData)
        }
    }
    
    private func refreshDataIfNeeded() {
        let lastBackgroundTime = UserDefaults.standard.object(forKey: "lastBackgroundTime") as? Date
        let now = Date()
        
        // Refresh if app was in background for more than 5 minutes
        if let lastTime = lastBackgroundTime,
           now.timeIntervalSince(lastTime) > 300 {
            print("🔄 Refreshing data after background time")
            refreshApplicationData()
        }
    }
    
    // MARK: - Placeholder Methods (implement based on your app's needs)
    private func pauseGameOrVideo() { /* Pause ongoing media */ }
    private func resumeGameOrVideo() { /* Resume paused media */ }
    private func saveUserData() { /* Save user data */ }
    private func saveCoreDataContext() { /* Save Core Data */ }
    private func saveUserSession() { /* Save session data */ }
    private func disableIdleTimer() { UIApplication.shared.isIdleTimerDisabled = false }
    private func enableIdleTimer() { UIApplication.shared.isIdleTimerDisabled = true }
    private func invalidateTimers() { /* Stop timers */ }
    private func restartTimers() { /* Restart timers */ }
    private func restartAnimations() { /* Restart animations */ }
    private func checkForAppUpdates() { /* Check for updates */ }
    private func clearImageCache() { /* Clear image cache */ }
    private func releaseNonEssentialResources() { /* Free memory */ }
    private func closeNetworkConnections() { /* Close connections */ }
    private func restoreNetworkConnections() { /* Restore connections */ }
    private func stopLocationServices() { /* Stop location */ }
    private func minimizeMemoryUsage() { /* Minimize memory */ }
    private func updateUIForActiveState() { /* Update UI */ }
    private func syncDataInBackground() { /* Sync data */ }
    private func navigateToProfile() { /* Navigate to profile */ }
    private func navigateToSettings() { /* Navigate to settings */ }
    private func fetchDataBasedOnNotification(_ userInfo: [AnyHashable: Any], completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    private func refreshApplicationData() { /* Refresh app data */ }
    private func cleanupResources() { /* Cleanup resources */ }
    private func createViewControllerForRestoration(identifierComponents: [String]) -> UIViewController? {
        return nil
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate1: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        print("📱 Will present notification: \(notification.request.content.title)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        print("👆 User tapped notification: \(response.notification.request.content.title)")
        
        // Handle notification tap
        handleNotificationResponse(response)
        
        completionHandler()
    }
    
    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        // Navigate based on notification content
        if let screen = userInfo["screen"] as? String {
            navigateToScreen(screen)
        }
    }
    
    private func navigateToScreen(_ screen: String) {
        // Navigate to specific screen based on notification
        print("🧭 Navigating to screen: \(screen)")
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **App Lifecycle Methods**:
    - didFinishLaunchingWithOptions: App startup, setup
    - applicationWillResignActive: App losing focus
    - applicationDidEnterBackground: App in background
    - applicationWillEnterForeground: App returning to foreground
    - applicationDidBecomeActive: App is active and ready
    - applicationWillTerminate: App terminating (not always called)

 2. **State Transitions**:
    - Not Running → Inactive → Active (app launch)
    - Active → Inactive → Background → Suspended (backgrounding)
    - Suspended → Background → Inactive → Active (foregrounding)
    - Background/Suspended → Terminated (system termination)

 3. **Background Processing**:
    - Background App Refresh (iOS 7+)
    - Background Tasks (iOS 13+)
    - Silent Push Notifications
    - Limited execution time in background

 4. **URL Handling**:
    - Custom URL schemes (myapp://)
    - Universal Links (https://)
    - Launch options handling
    - Deep linking navigation

 5. **Push Notifications**:
    - Registration for remote notifications
    - Device token handling
    - Notification payload processing
    - Foreground notification presentation

 6. **Memory Management**:
    - Memory warning handling
    - Resource cleanup in background
    - State preservation and restoration
    - Critical data saving

 7. **Common Interview Questions**:
    - Q: What happens when app goes to background?
    - A: applicationDidEnterBackground called, limited execution time
    
    - Q: Difference between inactive and background states?
    - A: Inactive: brief transition state, Background: app not visible
    
    - Q: When is applicationWillTerminate called?
    - A: Not always called, especially in iOS 13+, save data in background
    
    - Q: How to handle app launch from notification?
    - A: Check launch options in didFinishLaunchingWithOptions

 8. **Best Practices**:
    - Save data in applicationDidEnterBackground, not willTerminate
    - Handle memory warnings appropriately
    - Use background tasks for critical operations
    - Implement proper state restoration
    - Handle all possible launch scenarios

 9. **iOS 13+ Changes**:
    - Scene Delegate for multi-window support
    - Background Task Scheduler
    - App lifecycle tied to scenes, not app
    - Different handling for iPad multitasking

 10. **Performance Considerations**:
     - Quick app launch (< 20 seconds)
     - Efficient background processing
     - Memory management during warnings
     - Proper resource cleanup
     - State preservation for better UX
*/ 