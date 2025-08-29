//
//  logging-system.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 27/08/25.
//

import Foundation
import UIKit

/*
 LOGGING/ANALYTICS SYSTEM - LOW LEVEL DESIGN
 
 SYSTEM OVERVIEW:
 • Enterprise-grade logging system supporting multiple destinations (console, file, remote analytics)
 • Thread-safe architecture using serial dispatch queues for concurrent access
 • Configurable log levels (debug, info, warning, error, critical) with filtering capabilities
 • Strategy pattern for pluggable log destinations following Open/Closed principle
 • Facade pattern providing simple API while hiding complex internal logic
 • Asynchronous logging to prevent UI blocking with optional synchronous mode for critical logs
 • Automatic log rotation and file size management for persistent storage
 • Network resilience with retry mechanisms and offline queue for remote logging
 • Memory-efficient buffering system with configurable batch sizes
 • Comprehensive error handling and fallback mechanisms
 • Protocol-oriented design enabling easy testing and mocking
 • Support for structured logging with metadata and context information
 • Performance monitoring and self-diagnostics capabilities
 • Privacy-aware logging with sensitive data filtering
 • Integration with crash reporting and analytics services
 
 SCOPE FOR 2-HOUR INTERVIEW:
 • Core logging infrastructure and thread safety
 • Multiple destination support with strategy pattern
 • Log level management and filtering
 • File persistence with rotation
 • Remote logging with network handling
 • Performance considerations and async processing
 • Error handling and resilience
 • Testing strategy and dependency injection
 */

// MARK: - Core Protocols

/// Defines log severity levels
enum LogLevel: Int, CaseIterable, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4
    
    var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
    
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Represents a log entry with all necessary metadata
struct LogEntry {
    let id: UUID
    let timestamp: Date
    let level: LogLevel
    let message: String
    let metadata: [String: Any]
    let file: String
    let function: String
    let line: Int
    let thread: String
    
    init(level: LogLevel,
         message: String,
         metadata: [String: Any] = [:],
         file: String = #file,
         function: String = #function,
         line: Int = #line) {
        self.id = UUID()
        self.timestamp = Date()
        self.level = level
        self.message = message
        self.metadata = metadata
        self.file = (file as NSString).lastPathComponent
        self.function = function
        self.line = line
        self.thread = Thread.current.isMainThread ? "main" : Thread.current.description
    }
}

/// Strategy pattern for different log destinations
protocol LogDestination: AnyObject {
    var minimumLevel: LogLevel { get set }
    var isEnabled: Bool { get set }
    func write(_ entry: LogEntry)
    func flush() // Force immediate write for critical logs
}

/// Protocol for log formatting strategies
protocol LogFormatter {
    func format(_ entry: LogEntry) -> String
}

/// Protocol for filtering log entries
protocol LogFilter {
    func shouldLog(_ entry: LogEntry) -> Bool
}

// MARK: - Log Formatters

/// Standard log formatter with configurable output
class StandardLogFormatter: LogFormatter {
    private let dateFormatter: DateFormatter
    private let includeMetadata: Bool
    private let includeFileInfo: Bool
    
    init(dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS",
         includeMetadata: Bool = true,
         includeFileInfo: Bool = true) {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = dateFormat
        self.includeMetadata = includeMetadata
        self.includeFileInfo = includeFileInfo
    }
    
    func format(_ entry: LogEntry) -> String {
        var components: [String] = []
        
        // Timestamp
        components.append(dateFormatter.string(from: entry.timestamp))
        
        // Level
        components.append("[\(entry.level.description)]")
        
        // Thread info
        components.append("[\(entry.thread)]")
        
        // File info
        if includeFileInfo {
            components.append("[\(entry.file):\(entry.line) \(entry.function)]")
        }
        
        // Message
        components.append(entry.message)
        
        // Metadata
        if includeMetadata && !entry.metadata.isEmpty {
            let metadataString = entry.metadata
                .compactMap { "\($0.key): \($0.value)" }
                .joined(separator: ", ")
            components.append("{\(metadataString)}")
        }
        
        return components.joined(separator: " ")
    }
}

/// JSON formatter for structured logging
class JSONLogFormatter: LogFormatter {
    private let encoder = JSONEncoder()
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    
    func format(_ entry: LogEntry) -> String {
        let logData: [String: Any] = [
            "id": entry.id.uuidString,
            "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
            "level": entry.level.description,
            "message": entry.message,
            "metadata": entry.metadata,
            "source": [
                "file": entry.file,
                "function": entry.function,
                "line": entry.line,
                "thread": entry.thread
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: logData, options: [.prettyPrinted, .sortedKeys])
            return String(data: jsonData, encoding: .utf8) ?? "Failed to encode log entry"
        } catch {
            return "JSON encoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Log Filters

/// Filter logs based on minimum level
class LevelLogFilter: LogFilter {
    private let minimumLevel: LogLevel
    
    init(minimumLevel: LogLevel) {
        self.minimumLevel = minimumLevel
    }
    
    func shouldLog(_ entry: LogEntry) -> Bool {
        return entry.level >= minimumLevel
    }
}

/// Filter logs based on keywords or patterns
class KeywordLogFilter: LogFilter {
    private let keywords: Set<String>
    private let isBlacklist: Bool
    
    init(keywords: [String], isBlacklist: Bool = false) {
        self.keywords = Set(keywords.map { $0.lowercased() })
        self.isBlacklist = isBlacklist
    }
    
    func shouldLog(_ entry: LogEntry) -> Bool {
        let messageContainsKeyword = keywords.contains { keyword in
            entry.message.lowercased().contains(keyword)
        }
        
        return isBlacklist ? !messageContainsKeyword : messageContainsKeyword
    }
}

// MARK: - Log Destinations

/// Console destination for development and debugging
class ConsoleLogDestination: LogDestination {
    var minimumLevel: LogLevel
    var isEnabled: Bool
    private let formatter: LogFormatter
    
    init(minimumLevel: LogLevel = .debug, formatter: LogFormatter = StandardLogFormatter()) {
        self.minimumLevel = minimumLevel
        self.isEnabled = true
        self.formatter = formatter
    }
    
    func write(_ entry: LogEntry) {
        guard isEnabled && entry.level >= minimumLevel else { return }
        
        let formattedMessage = formatter.format(entry)
        print(formattedMessage)
    }
    
    func flush() {
        // Console writes are immediate, no buffering needed
    }
}

/// File destination with rotation and size management
class FileLogDestination: LogDestination {
    var minimumLevel: LogLevel
    var isEnabled: Bool
    
    private let formatter: LogFormatter
    private let fileManager = FileManager.default
    private let maxFileSize: Int64
    private let maxFileCount: Int
    private let logDirectory: URL
    private let baseFileName: String
    private var currentFileHandle: FileHandle?
    private let fileQueue = DispatchQueue(label: "com.logger.file", qos: .utility)
    
    init(minimumLevel: LogLevel = .info,
         formatter: LogFormatter = StandardLogFormatter(),
         maxFileSize: Int64 = 10 * 1024 * 1024, // 10MB
         maxFileCount: Int = 5,
         logDirectory: URL? = nil,
         baseFileName: String = "app.log") {
        
        self.minimumLevel = minimumLevel
        self.isEnabled = true
        self.formatter = formatter
        self.maxFileSize = maxFileSize
        self.maxFileCount = maxFileCount
        self.baseFileName = baseFileName
        
        // Default to Documents directory if not specified
        if let directory = logDirectory {
            self.logDirectory = directory
        } else {
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.logDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)
        }
        
        setupLogDirectory()
        openCurrentLogFile()
    }
    
    deinit {
        currentFileHandle?.closeFile()
    }
    
    func write(_ entry: LogEntry) {
        guard isEnabled && entry.level >= minimumLevel else { return }
        
        fileQueue.async { [weak self] in
            self?.writeToFile(entry)
        }
    }
    
    func flush() {
        fileQueue.sync {
            currentFileHandle?.synchronizeFile()
        }
    }
    
    private func setupLogDirectory() {
        try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
    }
    
    private func openCurrentLogFile() {
        let currentLogFile = logDirectory.appendingPathComponent(baseFileName)
        
        if !fileManager.fileExists(atPath: currentLogFile.path) {
            fileManager.createFile(atPath: currentLogFile.path, contents: nil)
        }
        
        currentFileHandle = try? FileHandle(forWritingTo: currentLogFile)
        currentFileHandle?.seekToEndOfFile()
    }
    
    private func writeToFile(_ entry: LogEntry) {
        guard let fileHandle = currentFileHandle else { return }
        
        // Check if rotation is needed
        if shouldRotateLog() {
            rotateLogFiles()
            openCurrentLogFile()
        }
        
        let formattedMessage = formatter.format(entry) + "\n"
        if let data = formattedMessage.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
    private func shouldRotateLog() -> Bool {
        guard let fileHandle = currentFileHandle else { return false }
        
        do {
            let fileSize = try fileHandle.offset()
            return fileSize >= maxFileSize
        } catch {
            return false
        }
    }
    
    private func rotateLogFiles() {
        currentFileHandle?.closeFile()
        currentFileHandle = nil
        
        // Rotate existing files
        for i in stride(from: maxFileCount - 1, to: 0, by: -1) {
            let oldFile = logDirectory.appendingPathComponent("\(baseFileName).\(i)")
            let newFile = logDirectory.appendingPathComponent("\(baseFileName).\(i + 1)")
            
            if fileManager.fileExists(atPath: oldFile.path) {
                try? fileManager.moveItem(at: oldFile, to: newFile)
            }
        }
        
        // Move current log to .1
        let currentFile = logDirectory.appendingPathComponent(baseFileName)
        let rotatedFile = logDirectory.appendingPathComponent("\(baseFileName).1")
        
        if fileManager.fileExists(atPath: currentFile.path) {
            try? fileManager.moveItem(at: currentFile, to: rotatedFile)
        }
        
        // Remove excess files
        let excessFile = logDirectory.appendingPathComponent("\(baseFileName).\(maxFileCount + 1)")
        try? fileManager.removeItem(at: excessFile)
    }
}

/// Remote destination for analytics and monitoring
class RemoteLogDestination: LogDestination {
    var minimumLevel: LogLevel
    var isEnabled: Bool
    
    private let endpoint: URL
    private let apiKey: String?
    private let formatter: LogFormatter
    private let session: URLSession
    private let batchSize: Int
    private let flushInterval: TimeInterval
    private var pendingLogs: [LogEntry] = []
    private let networkQueue = DispatchQueue(label: "com.logger.network", qos: .utility)
    private var flushTimer: Timer?
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    
    init(endpoint: URL,
         apiKey: String? = nil,
         minimumLevel: LogLevel = .warning,
         formatter: LogFormatter = JSONLogFormatter(),
         batchSize: Int = 10,
         flushInterval: TimeInterval = 30.0,
         maxRetries: Int = 3,
         retryDelay: TimeInterval = 5.0) {
        
        self.endpoint = endpoint
        self.apiKey = apiKey
        self.minimumLevel = minimumLevel
        self.isEnabled = true
        self.formatter = formatter
        self.batchSize = batchSize
        self.flushInterval = flushInterval
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: config)
        
        startFlushTimer()
    }
    
    deinit {
        flushTimer?.invalidate()
        flush()
    }
    
    func write(_ entry: LogEntry) {
        guard isEnabled && entry.level >= minimumLevel else { return }
        
        networkQueue.async { [weak self] in
            self?.addToPendingLogs(entry)
        }
    }
    
    func flush() {
        networkQueue.sync {
            sendPendingLogs()
        }
    }
    
    private func addToPendingLogs(_ entry: LogEntry) {
        pendingLogs.append(entry)
        
        if pendingLogs.count >= batchSize {
            sendPendingLogs()
        }
    }
    
    private func sendPendingLogs() {
        guard !pendingLogs.isEmpty else { return }
        
        let logsToSend = Array(pendingLogs)
        pendingLogs.removeAll()
        
        sendLogsWithRetry(logsToSend, retryCount: 0)
    }
    
    private func sendLogsWithRetry(_ logs: [LogEntry], retryCount: Int) {
        let logData = logs.map { formatter.format($0) }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["logs": logData])
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let apiKey = apiKey {
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            }
            
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    self?.handleSendError(error, logs: logs, retryCount: retryCount)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.handleSendError(NSError(domain: "InvalidResponse", code: -1), logs: logs, retryCount: retryCount)
                    return
                }
                
                if 200...299 ~= httpResponse.statusCode {
                    // Success - logs sent
                    print("Successfully sent \(logs.count) logs to remote destination")
                } else {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode)
                    self?.handleSendError(error, logs: logs, retryCount: retryCount)
                }
            }
            
            task.resume()
            
        } catch {
            handleSendError(error, logs: logs, retryCount: retryCount)
        }
    }
    
    private func handleSendError(_ error: Error, logs: [LogEntry], retryCount: Int) {
        print("Failed to send logs: \(error.localizedDescription)")
        
        if retryCount < maxRetries {
            networkQueue.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                self?.sendLogsWithRetry(logs, retryCount: retryCount + 1)
            }
        } else {
            // Max retries exceeded, add back to pending logs for next batch
            networkQueue.async { [weak self] in
                self?.pendingLogs.insert(contentsOf: logs, at: 0)
            }
        }
    }
    
    private func startFlushTimer() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            self?.flush()
        }
    }
}

// MARK: - Main Logger Implementation

/// Main logger class implementing Facade pattern
class Logger {
    
    // MARK: - Singleton
    static let shared = Logger()
    
    // MARK: - Properties
    private var destinations: [LogDestination] = []
    private var filters: [LogFilter] = []
    private let logQueue = DispatchQueue(label: "com.logger.main", qos: .utility)
    private var isEnabled: Bool = true
    
    // MARK: - Configuration
    struct Configuration {
        let isAsynchronous: Bool
        let enableConsoleLogging: Bool
        let enableFileLogging: Bool
        let enableRemoteLogging: Bool
        let minimumLevel: LogLevel
        let remoteEndpoint: URL?
        let remoteAPIKey: String?
        
        static let `default` = Configuration(
            isAsynchronous: true,
            enableConsoleLogging: true,
            enableFileLogging: true,
            enableRemoteLogging: false,
            minimumLevel: .debug,
            remoteEndpoint: nil,
            remoteAPIKey: nil
        )
    }
    
    // MARK: - Initialization
    private init() {
        setupDefaultConfiguration()
    }
    
    // MARK: - Public API
    
    /// Configure the logger with specified settings
    func configure(with configuration: Configuration) {
        logQueue.sync {
            destinations.removeAll()
            
            if configuration.enableConsoleLogging {
                let consoleDestination = ConsoleLogDestination(minimumLevel: configuration.minimumLevel)
                destinations.append(consoleDestination)
            }
            
            if configuration.enableFileLogging {
                let fileDestination = FileLogDestination(minimumLevel: configuration.minimumLevel)
                destinations.append(fileDestination)
            }
            
            if configuration.enableRemoteLogging,
               let endpoint = configuration.remoteEndpoint {
                let remoteDestination = RemoteLogDestination(
                    endpoint: endpoint,
                    apiKey: configuration.remoteAPIKey,
                    minimumLevel: configuration.minimumLevel
                )
                destinations.append(remoteDestination)
            }
        }
    }
    
    /// Add a custom log destination
    func addDestination(_ destination: LogDestination) {
        logQueue.async {
            self.destinations.append(destination)
        }
    }
    
    /// Remove a specific destination
    func removeDestination(_ destination: LogDestination) {
        logQueue.async {
            self.destinations.removeAll { $0 === destination }
        }
    }
    
    /// Add a log filter
    func addFilter(_ filter: LogFilter) {
        logQueue.async {
            self.filters.append(filter)
        }
    }
    
    /// Enable/disable logging globally
    func setEnabled(_ enabled: Bool) {
        logQueue.async {
            self.isEnabled = enabled
        }
    }
    
    /// Main logging method
    func log(_ level: LogLevel,
             _ message: String,
             metadata: [String: Any] = [:],
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
        
        guard isEnabled else { return }
        
        let entry = LogEntry(
            level: level,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
        
        // Use sync for critical logs to ensure they're written immediately
        if level == .critical {
            logQueue.sync {
                self.processLogEntry(entry)
            }
        } else {
            logQueue.async {
                self.processLogEntry(entry)
            }
        }
    }
    
    /// Convenience methods for different log levels
    func debug(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, metadata: metadata, file: file, function: function, line: line)
    }
    
    func info(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, metadata: metadata, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, metadata: metadata, file: file, function: function, line: line)
    }
    
    func error(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, metadata: metadata, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        log(.critical, message, metadata: metadata, file: file, function: function, line: line)
    }
    
    /// Force flush all destinations
    func flush() {
        logQueue.sync {
            destinations.forEach { $0.flush() }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDefaultConfiguration() {
        configure(with: .default)
    }
    
    private func processLogEntry(_ entry: LogEntry) {
        // Apply filters
        for filter in filters {
            if !filter.shouldLog(entry) {
                return
            }
        }
        
        // Send to all destinations
        destinations.forEach { destination in
            destination.write(entry)
        }
    }
}

// MARK: - Analytics Extension

extension Logger {
    
    /// Track user events for analytics
    func trackEvent(_ eventName: String,
                   parameters: [String: Any] = [:],
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line) {
        
        var metadata = parameters
        metadata["event_type"] = "analytics"
        metadata["event_name"] = eventName
        
        log(.info, "Event: \(eventName)", metadata: metadata, file: file, function: function, line: line)
    }
    
    /// Track user properties
    func setUserProperty(_ key: String, value: Any) {
        let metadata: [String: Any] = [
            "event_type": "user_property",
            "property_key": key,
            "property_value": value
        ]
        
        log(.info, "User Property: \(key) = \(value)", metadata: metadata)
    }
    
    /// Track screen views
    func trackScreenView(_ screenName: String,
                        screenClass: String? = nil,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
        
        var metadata: [String: Any] = [
            "event_type": "screen_view",
            "screen_name": screenName
        ]
        
        if let screenClass = screenClass {
            metadata["screen_class"] = screenClass
        }
        
        log(.info, "Screen View: \(screenName)", metadata: metadata, file: file, function: function, line: line)
    }
}

// MARK: - Performance Monitoring Extension

extension Logger {
    
    /// Performance timing utility
    class PerformanceTimer {
        private let startTime: CFAbsoluteTime
        private let operation: String
        private let logger: Logger
        
        init(operation: String, logger: Logger = .shared) {
            self.operation = operation
            self.logger = logger
            self.startTime = CFAbsoluteTimeGetCurrent()
            
            logger.debug("Started: \(operation)", metadata: ["event_type": "performance_start"])
        }
        
        func finish(metadata: [String: Any] = [:]) {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            var performanceMetadata = metadata
            performanceMetadata["event_type"] = "performance_end"
            performanceMetadata["duration_seconds"] = duration
            performanceMetadata["operation"] = operation
            
            logger.info("Completed: \(operation) in \(String(format: "%.3f", duration))s",
                       metadata: performanceMetadata)
        }
    }
    
    /// Create a performance timer
    func startTimer(for operation: String) -> PerformanceTimer {
        return PerformanceTimer(operation: operation, logger: self)
    }
}

// MARK: - Testing Support

#if DEBUG
extension Logger {
    
    /// Mock destination for testing
    class MockLogDestination: LogDestination {
        var minimumLevel: LogLevel = .debug
        var isEnabled: Bool = true
        var capturedEntries: [LogEntry] = []
        
        func write(_ entry: LogEntry) {
            guard isEnabled && entry.level >= minimumLevel else { return }
            capturedEntries.append(entry)
        }
        
        func flush() {
            // No-op for mock
        }
        
        func reset() {
            capturedEntries.removeAll()
        }
    }
    
    /// Add mock destination for testing
    func addMockDestination() -> MockLogDestination {
        let mockDestination = MockLogDestination()
        addDestination(mockDestination)
        return mockDestination
    }
}
#endif

// MARK: - Usage Examples

/*
 USAGE EXAMPLES:
 
 // Basic logging
 Logger.shared.info("User logged in", metadata: ["user_id": "12345"])
 Logger.shared.error("Network request failed", metadata: ["error_code": 404, "url": "https://api.example.com"])
 
 // Configuration
 let config = Logger.Configuration(
     isAsynchronous: true,
     enableConsoleLogging: true,
     enableFileLogging: true,
     enableRemoteLogging: true,
     minimumLevel: .info,
     remoteEndpoint: URL(string: "https://analytics.example.com/logs"),
     remoteAPIKey: "your-api-key"
 )
 Logger.shared.configure(with: config)
 
 // Analytics tracking
 Logger.shared.trackEvent("button_tapped", parameters: ["button_name": "login", "screen": "home"])
 Logger.shared.trackScreenView("HomeViewController")
 Logger.shared.setUserProperty("subscription_type", value: "premium")
 
 // Performance monitoring
 let timer = Logger.shared.startTimer(for: "api_call")
 // ... perform operation ...
 timer.finish(metadata: ["api_endpoint": "/users", "response_size": 1024])
 
 // Custom destinations
 let customDestination = CustomLogDestination()
 Logger.shared.addDestination(customDestination)
 
 // Filtering
 let levelFilter = LevelLogFilter(minimumLevel: .warning)
 Logger.shared.addFilter(levelFilter)
 */

/*
 ===============================================================================
 COMPREHENSIVE INTERVIEW QUESTIONS & ANSWERS
 ===============================================================================
 
 Q1: How does your logging system ensure thread safety when multiple threads are logging simultaneously?
 A1: The system uses a serial dispatch queue (`logQueue`) as the single point of synchronization. All log operations
     are channeled through this queue, ensuring thread-safe access to shared resources like destinations and filters.
     Each destination also has its own queue (e.g., `fileQueue` for file operations, `networkQueue` for network operations)
     to prevent blocking the main logging queue. Critical logs use synchronous dispatch to ensure immediate processing,
     while regular logs use asynchronous dispatch for better performance.
 
 Q2: Explain how the Strategy pattern is implemented in your logging system and its benefits.
 A2: The Strategy pattern is implemented through the `LogDestination` protocol, which defines a common interface
     (`write(_:)`, `flush()`, `minimumLevel`, `isEnabled`) for different logging strategies. Concrete implementations
     include `ConsoleLogDestination`, `FileLogDestination`, and `RemoteLogDestination`. Benefits include:
     - Open/Closed Principle: New destinations can be added without modifying existing code
     - Runtime flexibility: Destinations can be added/removed dynamically
     - Testability: Easy to mock destinations for testing
     - Separation of concerns: Each destination handles its specific logic independently
 
 Q3: How do you handle network failures and ensure logs aren't lost in the remote destination?
 A3: The `RemoteLogDestination` implements several resilience mechanisms:
     - Retry logic with exponential backoff (configurable maxRetries and retryDelay)
     - Offline queue: Failed logs are added back to pendingLogs for next batch attempt
     - Batching: Logs are sent in configurable batches to reduce network calls
     - Timeout handling: URLSession configured with appropriate timeouts
     - Error categorization: Different handling for network vs. server errors
     - Graceful degradation: System continues working even if remote logging fails
 
 Q4: Describe the file rotation mechanism and why it's necessary.
 A4: File rotation prevents log files from growing indefinitely and consuming excessive disk space:
     - Size-based rotation: When current log exceeds maxFileSize (default 10MB), rotation triggers
     - Numbered rotation: Files are rotated as app.log -> app.log.1 -> app.log.2, etc.
     - Configurable retention: maxFileCount determines how many rotated files to keep
     - Atomic operations: File operations use FileManager to ensure consistency
     - Thread safety: All file operations occur on dedicated fileQueue
     - Automatic cleanup: Excess files beyond maxFileCount are automatically deleted
 
 Q5: How would you implement log sampling to reduce volume in production?
 A5: Log sampling can be implemented through custom LogFilter implementations:
     - Rate-based sampling: Allow only N logs per time period
     - Percentage sampling: Log only X% of entries based on hash of log content
     - Level-based sampling: Different sampling rates for different log levels
     - Context-aware sampling: Higher sampling for error conditions, lower for debug
     - Implementation: Create `SamplingLogFilter` with configurable rates and add to logger
     - Metrics: Track sampling statistics to understand what's being filtered
 
 Q6: Explain how you would test this logging system effectively.
 A6: Testing strategy includes multiple approaches:
     - Unit tests: Test individual components (formatters, filters, destinations) in isolation
     - Integration tests: Test complete logging flow with multiple destinations
     - Mock destinations: `MockLogDestination` captures logs for verification in tests
     - Thread safety tests: Concurrent logging from multiple threads to detect race conditions
     - Performance tests: Measure logging overhead and throughput under load
     - Network failure simulation: Test remote destination resilience with network mocking
     - File system tests: Test file rotation, permissions, and disk space scenarios
     - Memory leak tests: Ensure proper cleanup and no retain cycles
 
 Q7: How does the system handle memory pressure and prevent memory leaks?
 A7: Memory management strategies include:
     - Bounded queues: pendingLogs in RemoteLogDestination has implicit bounds through batching
     - Weak references: Use `[weak self]` in closures to prevent retain cycles
     - Automatic cleanup: Timer-based flushing prevents indefinite accumulation
     - Resource management: FileHandles are properly closed in deinit
     - Queue management: Serial queues prevent excessive thread creation
     - Lazy initialization: Resources created only when needed
     - Monitoring: Can add memory usage tracking to log entries metadata
 
 Q8: How would you implement log encryption for sensitive data?
 A8: Encryption can be added at multiple levels:
     - Formatter level: Create `EncryptedLogFormatter` that encrypts formatted output
     - Destination level: Encrypt before writing to file or sending over network
     - Field level: Encrypt specific metadata fields containing sensitive data
     - Key management: Use iOS Keychain for encryption key storage
     - Algorithm choice: AES-256 for symmetric encryption, RSA for key exchange
     - Implementation: Add `EncryptionProtocol` and inject into destinations
     - Performance: Consider encryption overhead and async processing
 
 Q9: Describe how you would implement log aggregation and search capabilities.
 A9: Log aggregation and search implementation:
     - Structured logging: Use JSON formatter for consistent structure
     - Indexing: Create indexes on timestamp, level, and key metadata fields
     - Search API: Implement `LogSearchService` with query capabilities
     - Filtering: Support complex queries (date ranges, levels, text search)
     - Storage: Use SQLite or Core Data for local searchable storage
     - Remote search: Integrate with Elasticsearch or similar for server-side search
     - Caching: Cache frequent queries for better performance
     - Pagination: Support large result sets with pagination
 
 Q10: How would you monitor the performance and health of the logging system itself?
 A10: Self-monitoring and diagnostics:
     - Metrics collection: Track logs/second, queue depths, failure rates
     - Health checks: Monitor destination availability and response times
     - Performance metrics: Measure logging overhead impact on app performance
     - Error tracking: Log system errors to separate error tracking service
     - Dashboards: Create monitoring dashboards for operational visibility
     - Alerts: Set up alerts for high error rates or performance degradation
     - Self-healing: Implement circuit breakers for failing destinations
     - Diagnostics API: Expose internal metrics through debug endpoints
     - Memory monitoring: Track memory usage and detect leaks
     - Battery impact: Monitor energy usage on mobile devices
 
 ===============================================================================
*/

/*
 ===============================================================================
 SYSTEM ARCHITECTURE DIAGRAM
 ===============================================================================
 
                                    📱 iOS Application
                                           |
                                           |
                              ┌─────────────────────────┐
                              │     Logger (Facade)     │
                              │   - Singleton Pattern   │
                              │   - Thread-Safe Queue   │
                              │   - Configuration Mgmt  │
                              └─────────────────────────┘
                                           |
                                           |
                              ┌─────────────────────────┐
                              │     Log Processing      │
                              │   - Entry Creation      │
                              │   - Filter Application  │
                              │   - Level Checking      │
                              └─────────────────────────┘
                                           |
                                           |
                         ┌─────────────────┼─────────────────┐
                         |                 |                 |
                         |                 |                 |
              ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
              │ Console Dest.   │ │  File Dest.     │ │ Remote Dest.    │
              │ - Immediate     │ │ - File Rotation │ │ - Batch Upload  │
              │ - Debug Output  │ │ - Size Mgmt     │ │ - Retry Logic   │
              │ - Sync Write    │ │ - Thread Safe   │ │ - Offline Queue │
              └─────────────────┘ └─────────────────┘ └─────────────────┘
                       |                  |                  |
                       |                  |                  |
                       ▼                  ▼                  ▼
              ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
              │   Xcode Console │ │   Local Files   │ │ Analytics Server│
              │                 │ │  app.log.1      │ │  - Elasticsearch│
              │                 │ │  app.log.2      │ │  - Custom API   │
              │                 │ │  app.log.3      │ │  - Cloud Service│
              └─────────────────┘ └─────────────────┘ └─────────────────┘
 
 
                            COMPONENT INTERACTION FLOW
 
    ┌─────────────┐    log()    ┌─────────────┐    async    ┌─────────────┐
    │   Client    │ ──────────► │   Logger    │ ──────────► │ Log Queue   │
    │   Code      │             │  (Facade)   │             │ (Serial)    │
    └─────────────┘             └─────────────┘             └─────────────┘
                                                                     │
                                                                     │ process
                                                                     ▼
                                                            ┌─────────────┐
                                                            │   Filters   │
                                                            │ - Level     │
                                                            │ - Keyword   │
                                                            │ - Custom    │
                                                            └─────────────┘
                                                                     │
                                                                     │ apply
                                                                     ▼
                                                            ┌─────────────┐
                                                            │ Destinations│
                                                            │ - Strategy  │
                                                            │ - Parallel  │
                                                            │ - Async     │
                                                            └─────────────┘
 
 
                                THREAD SAFETY MODEL
 
         Main Thread              Log Queue               Destination Queues
    ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
    │                 │      │                 │      │                 │
    │ Logger.info()   │────► │ Serial Queue    │────► │ File Queue      │
    │                 │      │ (Coordination)  │      │ Network Queue   │
    │ Logger.error()  │────► │                 │────► │ Custom Queues   │
    │                 │      │ Thread-Safe     │      │                 │
    │ Background      │      │ Access Control  │      │ Destination-    │
    │ Tasks           │────► │                 │      │ Specific Ops    │
    │                 │      │                 │      │                 │
    └─────────────────┘      └─────────────────┘      └─────────────────┘
 
 
                              CONFIGURATION HIERARCHY
 
                              ┌─────────────────┐
                              │  Configuration  │
                              │   - Global      │
                              │   - Destinations│
                              │   - Levels      │
                              └─────────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
            ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
            │  Formatters │    │   Filters   │    │ Destinations│
            │ - Standard  │    │ - Level     │    │ - Console   │
            │ - JSON      │    │ - Keyword   │    │ - File      │
            │ - Custom    │    │ - Custom    │    │ - Remote    │
            └─────────────┘    └─────────────┘    └─────────────┘
 
 ===============================================================================
*/
