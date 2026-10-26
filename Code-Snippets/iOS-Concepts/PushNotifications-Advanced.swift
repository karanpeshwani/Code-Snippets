//
//  PushNotifications-Advanced.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import UserNotifications
import UIKit
import SwiftUI

// MARK: - Notification Manager

class NotificationManager: NSObject, ObservableObject {
    
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var notificationSettings: UNNotificationSettings?
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        
        let options: UNAuthorizationOptions = [
            .alert,
            .badge,
            .sound,
            .criticalAlert,
            .provisional,
            .providesAppNotificationSettings,
            .announcement
        ]
        
        let granted = try await center.requestAuthorization(options: options)
        
        await MainActor.run {
            self.authorizationStatus = granted ? .authorized : .denied
        }
        
        if granted {
            await registerForRemoteNotifications()
        }
        
        return granted
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.notificationSettings = settings
            }
        }
    }
    
    @MainActor
    private func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Local Notifications
    func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String,
        timeInterval: TimeInterval,
        repeats: Bool = false,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any] = [:]
    ) throws {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.userInfo = userInfo
        
        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: repeats
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled: \(identifier)")
            }
        }
    }
    
    func scheduleCalendarNotification(
        title: String,
        body: String,
        identifier: String,
        dateComponents: DateComponents,
        repeats: Bool = false
    ) throws {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: repeats
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling calendar notification: \(error)")
            } else {
                print("✅ Calendar notification scheduled: \(identifier)")
            }
        }
    }
    
    func scheduleLocationNotification(
        title: String,
        body: String,
        identifier: String,
        region: UNLocationNotificationTrigger,
        repeats: Bool = false
    ) throws {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: region
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling location notification: \(error)")
            } else {
                print("✅ Location notification scheduled: \(identifier)")
            }
        }
    }
    
    // MARK: - Rich Notifications
    func scheduleRichNotification(
        title: String,
        body: String,
        identifier: String,
        imageURL: String? = nil,
        videoURL: String? = nil,
        audioURL: String? = nil,
        timeInterval: TimeInterval = 5
    ) throws {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Add media attachment
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            let attachment = try UNNotificationAttachment(
                identifier: "image",
                url: url,
                options: [
                    UNNotificationAttachmentOptionsTypeHintKey: "public.jpeg"
                ]
            )
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling rich notification: \(error)")
            } else {
                print("✅ Rich notification scheduled: \(identifier)")
            }
        }
    }
    
    // MARK: - Notification Categories and Actions
    func setupNotificationCategories() {
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_ACTION",
            title: "Accept",
            options: [.foreground]
        )
        
        let declineAction = UNNotificationAction(
            identifier: "DECLINE_ACTION",
            title: "Decline",
            options: [.destructive]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze",
            options: []
        )
        
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your reply..."
        )
        
        // Meeting invitation category
        let meetingCategory = UNNotificationCategory(
            identifier: "MEETING_INVITATION",
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Reminder category
        let reminderCategory = UNNotificationCategory(
            identifier: "REMINDER",
            actions: [snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Message category
        let messageCategory = UNNotificationCategory(
            identifier: "MESSAGE",
            actions: [replyAction],
            intentIdentifiers: [],
            options: [.allowInCarPlay]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            meetingCategory,
            reminderCategory,
            messageCategory
        ])
        
        print("✅ Notification categories configured")
    }
    
    // MARK: - Notification Management
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await UNUserNotificationCenter.current().deliveredNotifications()
    }
    
    func removePendingNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Removed pending notifications: \(identifiers)")
    }
    
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        print("🗑️ Removed delivered notifications: \(identifiers)")
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Removed all pending notifications")
    }
    
    func removeAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("🗑️ Removed all delivered notifications")
    }
    
    // MARK: - Badge Management
    func updateBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func clearBadge() {
        updateBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        print("📱 Notification received in foreground: \(notification.request.content.title)")
        
        // Determine presentation options based on notification content
        let options: UNNotificationPresentationOptions
        
        if notification.request.content.categoryIdentifier == "CRITICAL" {
            options = [.banner, .sound, .badge, .list]
        } else {
            options = [.banner, .sound]
        }
        
        completionHandler(options)
    }
    
    // Called when user interacts with notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        let notification = response.notification
        let actionIdentifier = response.actionIdentifier
        
        print("👆 User interacted with notification: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "ACCEPT_ACTION":
            handleAcceptAction(notification: notification)
            
        case "DECLINE_ACTION":
            handleDeclineAction(notification: notification)
            
        case "SNOOZE_ACTION":
            handleSnoozeAction(notification: notification)
            
        case "REPLY_ACTION":
            if let textResponse = response as? UNTextInputNotificationResponse {
                handleReplyAction(notification: notification, text: textResponse.userText)
            }
            
        case UNNotificationDefaultActionIdentifier:
            handleDefaultAction(notification: notification)
            
        case UNNotificationDismissActionIdentifier:
            handleDismissAction(notification: notification)
            
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Action Handlers
    private func handleAcceptAction(notification: UNNotification) {
        print("✅ User accepted: \(notification.request.content.title)")
        // Handle meeting acceptance logic
    }
    
    private func handleDeclineAction(notification: UNNotification) {
        print("❌ User declined: \(notification.request.content.title)")
        // Handle meeting decline logic
    }
    
    private func handleSnoozeAction(notification: UNNotification) {
        print("😴 User snoozed: \(notification.request.content.title)")
        
        // Reschedule notification for 10 minutes later
        let newIdentifier = "\(notification.request.identifier)_snoozed"
        
        do {
            try scheduleLocalNotification(
                title: notification.request.content.title,
                body: notification.request.content.body,
                identifier: newIdentifier,
                timeInterval: 600 // 10 minutes
            )
        } catch {
            print("❌ Error rescheduling snoozed notification: \(error)")
        }
    }
    
    private func handleReplyAction(notification: UNNotification, text: String) {
        print("💬 User replied: \(text)")
        // Handle reply logic (send message, etc.)
    }
    
    private func handleDefaultAction(notification: UNNotification) {
        print("📱 User tapped notification: \(notification.request.content.title)")
        
        // Navigate to appropriate screen based on notification content
        if let userInfo = notification.request.content.userInfo as? [String: Any] {
            navigateToScreen(userInfo: userInfo)
        }
    }
    
    private func handleDismissAction(notification: UNNotification) {
        print("🚫 User dismissed notification: \(notification.request.content.title)")
        // Handle dismissal logic
    }
    
    private func navigateToScreen(userInfo: [String: Any]) {
        guard let screenIdentifier = userInfo["screen"] as? String else { return }
        
        switch screenIdentifier {
        case "chat":
            if let chatId = userInfo["chatId"] as? String {
                print("🧭 Navigating to chat: \(chatId)")
                // Navigate to chat screen
            }
            
        case "profile":
            if let userId = userInfo["userId"] as? String {
                print("🧭 Navigating to profile: \(userId)")
                // Navigate to profile screen
            }
            
        case "settings":
            print("🧭 Navigating to settings")
            // Navigate to settings screen
            
        default:
            print("🧭 Unknown screen identifier: \(screenIdentifier)")
        }
    }
}

// MARK: - Remote Notifications

class RemoteNotificationManager7: NSObject {
    
    static let shared = RemoteNotificationManager7()
    
    private var deviceToken: String?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Device Token Management
    func handleDeviceTokenRegistration(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        
        print("📱 Device token received: \(tokenString)")
        
        // Send token to your server
        sendTokenToServer(tokenString)
    }
    
    func handleDeviceTokenRegistrationError(_ error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
        
        // Handle registration failure
        // Maybe fallback to local notifications or show user message
    }
    
    private func sendTokenToServer(_ token: String) {
        // Implementation to send token to your backend server
        print("📤 Sending device token to server: \(token)")
        
        // Example API call structure:
        /*
        let url = URL(string: "https://your-api.com/device-tokens")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["deviceToken": token, "userId": getCurrentUserId()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle response
        }.resume()
        */
    }
    
    // MARK: - Remote Notification Handling
    func handleRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
        print("📬 Remote notification received: \(userInfo)")
        
        // Extract notification data
        guard let aps = userInfo["aps"] as? [String: Any] else {
            completionHandler(.noData)
            return
        }
        
        // Handle different types of remote notifications
        if let contentAvailable = aps["content-available"] as? Int, contentAvailable == 1 {
            // Silent notification - perform background work
            handleSilentNotification(userInfo: userInfo, completionHandler: completionHandler)
        } else {
            // Regular notification
            handleRegularRemoteNotification(userInfo: userInfo, completionHandler: completionHandler)
        }
    }
    
    private func handleSilentNotification(
        userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
        print("🔇 Processing silent notification")
        
        // Perform background tasks like:
        // - Sync data with server
        // - Update local database
        // - Prefetch content
        
        // Simulate background work
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // Simulate successful data fetch
            let success = Bool.random()
            
            if success {
                print("✅ Silent notification processing completed")
                completionHandler(.newData)
            } else {
                print("❌ Silent notification processing failed")
                completionHandler(.failed)
            }
        }
    }
    
    private func handleRegularRemoteNotification(
        userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        
        print("📢 Processing regular remote notification")
        
        // Extract custom data
        if let customData = userInfo["customData"] as? [String: Any] {
            processCustomData(customData)
        }
        
        completionHandler(.newData)
    }
    
    private func processCustomData(_ data: [String: Any]) {
        // Process custom notification data
        // Update app state, cache data, etc.
        
        if let messageId = data["messageId"] as? String {
            print("💬 New message ID: \(messageId)")
            // Handle new message
        }
        
        if let updateType = data["updateType"] as? String {
            print("🔄 Update type: \(updateType)")
            // Handle different update types
        }
    }
}

// MARK: - Notification Scheduling Service

class NotificationSchedulingService7 {
    
    private let notificationManager = NotificationManager.shared
    
    // MARK: - Reminder Notifications
    func scheduleReminder(
        title: String,
        body: String,
        date: Date,
        repeatInterval: ReminderRepeatInterval = .none
    ) throws {
        
        let identifier = "reminder_\(UUID().uuidString)"
        let calendar = Calendar.current
        
        switch repeatInterval {
        case .none:
            let timeInterval = date.timeIntervalSinceNow
            guard timeInterval > 0 else {
                throw NotificationError7.invalidDate
            }
            
            try notificationManager.scheduleLocalNotification(
                title: title,
                body: body,
                identifier: identifier,
                timeInterval: timeInterval,
                categoryIdentifier: "REMINDER"
            )
            
        case .daily:
            let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
            try notificationManager.scheduleCalendarNotification(
                title: title,
                body: body,
                identifier: identifier,
                dateComponents: dateComponents,
                repeats: true
            )
            
        case .weekly:
            let dateComponents = calendar.dateComponents([.weekday, .hour, .minute], from: date)
            try notificationManager.scheduleCalendarNotification(
                title: title,
                body: body,
                identifier: identifier,
                dateComponents: dateComponents,
                repeats: true
            )
            
        case .monthly:
            let dateComponents = calendar.dateComponents([.day, .hour, .minute], from: date)
            try notificationManager.scheduleCalendarNotification(
                title: title,
                body: body,
                identifier: identifier,
                dateComponents: dateComponents,
                repeats: true
            )
        }
        
        print("⏰ Reminder scheduled: \(title) at \(date)")
    }
    
    // MARK: - Event Notifications
    func scheduleEventNotification(
        event: Event7,
        reminderMinutes: [Int] = [15, 60] // 15 minutes and 1 hour before
    ) throws {
        
        for minutes in reminderMinutes {
            let reminderDate = event.startDate.addingTimeInterval(-TimeInterval(minutes * 60))
            let identifier = "event_\(event.id)_\(minutes)min"
            
            let timeInterval = reminderDate.timeIntervalSinceNow
            guard timeInterval > 0 else { continue }
            
            let title = "Upcoming Event"
            let body = "\(event.title) starts in \(minutes) minutes"
            
            try notificationManager.scheduleLocalNotification(
                title: title,
                body: body,
                identifier: identifier,
                timeInterval: timeInterval,
                categoryIdentifier: "MEETING_INVITATION",
                userInfo: [
                    "eventId": event.id,
                    "screen": "event",
                    "eventTitle": event.title
                ]
            )
        }
        
        print("📅 Event notifications scheduled for: \(event.title)")
    }
    
    // MARK: - Location-based Notifications
    func scheduleLocationReminder(
        title: String,
        body: String,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance = 100,
        notifyOnEntry: Bool = true,
        notifyOnExit: Bool = false
    ) throws {
        
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: "location_\(UUID().uuidString)"
        )
        
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        
        let trigger = UNLocationNotificationTrigger(
            region: region,
            repeats: false
        )
        
        let identifier = "location_reminder_\(UUID().uuidString)"
        
        try notificationManager.scheduleLocationNotification(
            title: title,
            body: body,
            identifier: identifier,
            region: trigger
        )
        
        print("📍 Location reminder scheduled: \(title)")
    }
}

// MARK: - Supporting Types

enum ReminderRepeatInterval {
    case none
    case daily
    case weekly
    case monthly
}

struct Event7 {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
}

enum NotificationError7: Error {
    case invalidDate
    case authorizationDenied
    case invalidConfiguration
}

import CoreLocation

// MARK: - SwiftUI Integration

struct NotificationSettingsView7: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingScheduleSheet = false
    @State private var pendingNotifications: [UNNotificationRequest] = []
    @State private var deliveredNotifications: [UNNotification] = []
    
    var body: some View {
        NavigationView {
            List {
                Section("Authorization Status") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(authorizationStatusString)
                            .foregroundColor(statusColor)
                    }
                    
                    if notificationManager.authorizationStatus == .notDetermined {
                        Button("Request Permission") {
                            Task {
                                do {
                                    let granted = try await notificationManager.requestAuthorization()
                                    print("Permission granted: \(granted)")
                                } catch {
                                    print("Error requesting permission: \(error)")
                                }
                            }
                        }
                    }
                }
                
                Section("Quick Actions") {
                    Button("Schedule Test Notification") {
                        scheduleTestNotification()
                    }
                    
                    Button("Schedule Rich Notification") {
                        scheduleRichNotification()
                    }
                    
                    Button("Clear Badge") {
                        notificationManager.clearBadge()
                    }
                }
                
                Section("Pending Notifications (\(pendingNotifications.count))") {
                    ForEach(pendingNotifications, id: \.identifier) { notification in
                        VStack(alignment: .leading) {
                            Text(notification.content.title)
                                .font(.headline)
                            Text(notification.content.body)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deletePendingNotifications)
                    
                    if !pendingNotifications.isEmpty {
                        Button("Remove All Pending") {
                            notificationManager.removeAllPendingNotifications()
                            loadNotifications()
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section("Delivered Notifications (\(deliveredNotifications.count))") {
                    ForEach(deliveredNotifications, id: \.request.identifier) { notification in
                        VStack(alignment: .leading) {
                            Text(notification.request.content.title)
                                .font(.headline)
                            Text(notification.request.content.body)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteDeliveredNotifications)
                    
                    if !deliveredNotifications.isEmpty {
                        Button("Remove All Delivered") {
                            notificationManager.removeAllDeliveredNotifications()
                            loadNotifications()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schedule") {
                        showingScheduleSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingScheduleSheet) {
                NotificationScheduleView7()
            }
            .onAppear {
                loadNotifications()
            }
        }
    }
    
    private var authorizationStatusString: String {
        switch notificationManager.authorizationStatus {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized, .provisional: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        case .ephemeral: return .blue
        @unknown default: return .gray
        }
    }
    
    private func scheduleTestNotification() {
        do {
            try notificationManager.scheduleLocalNotification(
                title: "Test Notification",
                body: "This is a test notification scheduled from the app",
                identifier: "test_\(Date().timeIntervalSince1970)",
                timeInterval: 5
            )
            loadNotifications()
        } catch {
            print("Error scheduling test notification: \(error)")
        }
    }
    
    private func scheduleRichNotification() {
        do {
            try notificationManager.scheduleRichNotification(
                title: "Rich Notification",
                body: "This notification includes an image attachment",
                identifier: "rich_\(Date().timeIntervalSince1970)",
                imageURL: "https://via.placeholder.com/300x200.jpg"
            )
            loadNotifications()
        } catch {
            print("Error scheduling rich notification: \(error)")
        }
    }
    
    private func loadNotifications() {
        Task {
            let pending = await notificationManager.getPendingNotifications()
            let delivered = await notificationManager.getDeliveredNotifications()
            
            await MainActor.run {
                self.pendingNotifications = pending
                self.deliveredNotifications = delivered
            }
        }
    }
    
    private func deletePendingNotifications(at offsets: IndexSet) {
        let identifiers = offsets.map { pendingNotifications[$0].identifier }
        notificationManager.removePendingNotifications(withIdentifiers: identifiers)
        loadNotifications()
    }
    
    private func deleteDeliveredNotifications(at offsets: IndexSet) {
        let identifiers = offsets.map { deliveredNotifications[$0].request.identifier }
        notificationManager.removeDeliveredNotifications(withIdentifiers: identifiers)
        loadNotifications()
    }
}

struct NotificationScheduleView7: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var body = ""
    @State private var selectedDate = Date().addingTimeInterval(60) // 1 minute from now
    @State private var repeatInterval = ReminderRepeatInterval.none
    
    private let notificationService = NotificationSchedulingService7()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notification Content") {
                    TextField("Title", text: $title)
                    TextField("Body", text: $body, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Timing") {
                    DatePicker("Date & Time", selection: $selectedDate, in: Date()...)
                    
                    Picker("Repeat", selection: $repeatInterval) {
                        Text("None").tag(ReminderRepeatInterval.none)
                        Text("Daily").tag(ReminderRepeatInterval.daily)
                        Text("Weekly").tag(ReminderRepeatInterval.weekly)
                        Text("Monthly").tag(ReminderRepeatInterval.monthly)
                    }
                }
            }
            .navigationTitle("Schedule Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schedule") {
                        scheduleNotification()
                    }
                    .disabled(title.isEmpty || body.isEmpty)
                }
            }
        }
    }
    
    private func scheduleNotification() {
        do {
            try notificationService.scheduleReminder(
                title: title,
                body: body,
                date: selectedDate,
                repeatInterval: repeatInterval
            )
            dismiss()
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
}

// MARK: - Usage Examples

class NotificationUsageExamples7 {
    
    private let notificationManager = NotificationManager.shared
    private let remoteManager = RemoteNotificationManager7.shared
    private let schedulingService = NotificationSchedulingService7()
    
    func demonstrateNotificationSetup() {
        print("=== Notification Setup ===")
        
        // Setup notification categories
        notificationManager.setupNotificationCategories()
        
        // Request authorization
        Task {
            do {
                let granted = try await notificationManager.requestAuthorization()
                print("Authorization granted: \(granted)")
            } catch {
                print("Authorization error: \(error)")
            }
        }
    }
    
    func demonstrateLocalNotifications() {
        print("=== Local Notifications ===")
        
        // Simple notification
        do {
            try notificationManager.scheduleLocalNotification(
                title: "Simple Notification",
                body: "This is a simple local notification",
                identifier: "simple_1",
                timeInterval: 10
            )
        } catch {
            print("Error: \(error)")
        }
        
        // Repeating notification
        do {
            try notificationManager.scheduleLocalNotification(
                title: "Daily Reminder",
                body: "Don't forget to check your tasks!",
                identifier: "daily_reminder",
                timeInterval: 86400, // 24 hours
                repeats: true,
                categoryIdentifier: "REMINDER"
            )
        } catch {
            print("Error: \(error)")
        }
        
        // Calendar-based notification
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        do {
            try notificationManager.scheduleCalendarNotification(
                title: "Good Morning!",
                body: "Time to start your day",
                identifier: "morning_greeting",
                dateComponents: dateComponents,
                repeats: true
            )
        } catch {
            print("Error: \(error)")
        }
    }
    
    func demonstrateRichNotifications() {
        print("=== Rich Notifications ===")
        
        do {
            try notificationManager.scheduleRichNotification(
                title: "New Photo Available",
                body: "Check out this amazing sunset photo!",
                identifier: "photo_notification",
                imageURL: "https://example.com/sunset.jpg"
            )
        } catch {
            print("Error: \(error)")
        }
    }
    
    func demonstrateEventNotifications() {
        print("=== Event Notifications ===")
        
        let event = Event7(
            id: "meeting_123",
            title: "Team Standup",
            startDate: Date().addingTimeInterval(3600), // 1 hour from now
            endDate: Date().addingTimeInterval(5400), // 1.5 hours from now
            location: "Conference Room A"
        )
        
        do {
            try schedulingService.scheduleEventNotification(
                event: event,
                reminderMinutes: [15, 60] // 15 minutes and 1 hour before
            )
        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Notification Types**:
    - Local Notifications: Scheduled by the app locally
    - Remote Notifications: Sent from server via APNs
    - Silent Notifications: Background updates without user interaction
    - Rich Notifications: Include media attachments

 2. **Authorization and Permissions**:
    - UNAuthorizationOptions: alert, badge, sound, criticalAlert, provisional
    - Request authorization before scheduling notifications
    - Handle different authorization states
    - Provisional authorization for quiet delivery

 3. **Notification Triggers**:
    - UNTimeIntervalNotificationTrigger: Time-based scheduling
    - UNCalendarNotificationTrigger: Calendar-based scheduling
    - UNLocationNotificationTrigger: Location-based notifications
    - Push notifications from server

 4. **Notification Categories and Actions**:
    - UNNotificationCategory: Group related notifications
    - UNNotificationAction: Interactive buttons
    - UNTextInputNotificationAction: Text input responses
    - Custom action handling

 5. **Rich Notifications**:
    - UNNotificationAttachment: Media attachments
    - Supported formats: images, audio, video
    - Notification Service Extensions for processing
    - Custom UI with Notification Content Extensions

 6. **Remote Notifications (APNs)**:
    - Device token registration and management
    - Silent notifications with content-available
    - Background app refresh capabilities
    - Server-side integration requirements

 7. **Notification Management**:
    - Pending vs delivered notifications
    - Removing specific notifications
    - Badge count management
    - Notification settings inspection

 8. **UNUserNotificationCenterDelegate**:
    - willPresent: Handle foreground presentation
    - didReceive: Handle user interactions
    - Action-specific response handling
    - Deep linking and navigation

 9. **Common Interview Questions**:
    - Q: Difference between local and remote notifications?
    - A: Local scheduled by app, remote sent from server via APNs

    - Q: How do you handle notifications when app is in foreground?
    - A: Implement willPresent delegate method

    - Q: What are silent notifications?
    - A: Background notifications with content-available flag

    - Q: How do you add interactive actions?
    - A: Create UNNotificationCategory with UNNotificationAction

 10. **Best Practices**:
     - Request permission at appropriate time
     - Provide clear opt-out mechanisms
     - Handle all authorization states
     - Use meaningful notification content
     - Implement proper deep linking

 11. **Advanced Features**:
     - Notification grouping and threading
     - Critical alerts for emergency notifications
     - Provisional authorization for less intrusive delivery
     - Notification Service Extensions for content modification
     - Notification Content Extensions for custom UI

 12. **Common Pitfalls**:
     - Not handling authorization properly
     - Scheduling notifications without permission
     - Not removing delivered notifications
     - Poor notification content and timing
     - Missing delegate method implementations
*/ 
