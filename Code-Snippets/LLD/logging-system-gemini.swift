//
//  logging-system-gemini.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 27/08/25.
//

import Foundation

// MARK: - System Overview & Design
/**
 *
 * ## System Overview: A Scalable and Extensible Logging/Analytics Utility
 *
 * - **Purpose:** To provide a unified, thread-safe, and extensible interface for logging events, messages, and errors
 * from anywhere within an iOS application.
 * - **Core Principle (Open/Closed):** The system is open for extension (adding new logging destinations) but closed
 * for modification (the core `Logger` class doesn't need to change to support new destinations).
 * - **Key Components:**
 * - `Logger`: A singleton facade that provides a simple, app-wide entry point for logging (`Logger.shared.log(...)`).
 * It manages a collection of log destinations and dispatches log messages to them.
 * - `LogDestination`: A protocol (the "Strategy") that defines a common interface for any destination where logs
 * can be sent (e.g., console, file, remote server). Any class conforming to this protocol can be added to the logger.
 * - `Concrete Destinations`: Implementations of `LogDestination`, such as `ConsoleDestination`, `FileDestination`,
 * and `APIDestination`. Each handles the specific logic for its target.
 * - `LogEntry`: A struct representing a single log message, containing details like the message itself, level, timestamp,
 * file, function, and line number. This standardizes the data passed through the system.
 * - **Thread Safety:** Achieved by using a dedicated serial `DispatchQueue`. All logging operations are dispatched onto
 * this queue, ensuring that concurrent calls from different threads are processed sequentially, preventing race conditions
 * and data corruption.
 * - **Asynchronous Operations:** Logging is performed asynchronously on the dedicated queue to prevent blocking the calling
 * thread (especially the main UI thread), ensuring the app remains responsive.
 * - **Configurability:** The system is configured at startup by adding desired destinations. Log levels allow for filtering
 * messages, so only relevant information is processed (e.g., showing `debug` logs in development but only `error` logs
 * in production).
 * - **Scalability & Maintenance:** Adding a new third-party analytics service is as simple as creating a new class that
 * conforms to `LogDestination` and adding an instance of it to the `Logger`. No existing code needs to be touched.
 *
 */

// MARK: - 1. Log Destination Protocol (Strategy Pattern)

/// Defines the contract for any log destination.
/// This is the key to making the system extensible (Open/Closed Principle).
/// Any class that conforms to this protocol can be added as a destination to the main Logger.
public protocol LogDestination {
    /// A unique identifier for the destination.
    var identifier: String { get }

    /// The minimum log level this destination will process.
    /// For example, a console destination might log `.debug` and up,
    /// while a remote server might only log `.warning` and up.
    var minimumLogLevel: Logger.LogLevel { get set }

    /// Processes the log entry. This is where the actual logging happens.
    /// - Parameter entry: The `LogEntry` to be recorded.
    func process(entry: Logger.LogEntry)
}

// MARK: - 2. The Logger Facade (Facade & Singleton Pattern)

public final class Logger {

    // MARK: - Public Properties

    /// Singleton instance for global access.
    public static let shared = Logger()

    // MARK: - Private Properties

    /// A collection of all destinations where logs will be sent.
    private var destinations: [String: LogDestination] = [:]

    /// A dedicated serial queue to ensure thread-safe access to destinations
    /// and sequential processing of log messages.
    private let logQueue = DispatchQueue(label: "com.company.app.loggerQueue", qos: .utility)

    // MARK: - Initialization

    /// Private initializer to enforce the singleton pattern.
    private init() {}

    // MARK: - Configuration

    /// Adds a `LogDestination` to the logger.
    /// - Parameter destination: The destination to add.
    /// - Returns: `true` if the destination was added, `false` if a destination with the same identifier already exists.
    @discardableResult
    public func add(destination: LogDestination) -> Bool {
        // Using sync operation on our queue to ensure thread-safe modification of the destinations dictionary.
        var result = false
        logQueue.sync {
            if destinations[destination.identifier] == nil {
                destinations[destination.identifier] = destination
                result = true
            } else {
                // Using print here as the logger itself might not be fully configured.
                print("Logger Warning: Destination with identifier '\(destination.identifier)' already exists.")
                result = false
            }
        }
        return result
    }

    /// Removes a `LogDestination` by its identifier.
    /// - Parameter identifier: The identifier of the destination to remove.
    public func remove(identifier: String) {
        logQueue.async {
            self.destinations.removeValue(forKey: identifier)
        }
    }

    /// Removes all logging destinations.
    public func removeAllDestinations() {
        logQueue.async {
            self.destinations.removeAll()
        }
    }

    // MARK: - The Core Logging Method

    /// The primary method for logging a message.
    /// This is the clean, simple API exposed to the rest of the app.
    /// - Parameters:
    ///   - level: The severity level of the log.
    ///   - message: The main log message. Can be a string, or any object that can be converted to a string.
    ///   - file: The file where the log was triggered (defaults to the caller's file).
    ///   - function: The function where the log was triggered (defaults to the caller's function).
    ///   - line: The line number where the log was triggered (defaults to the caller's line).
    public func log(
        _ level: LogLevel,
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let entry = LogEntry(
            message: String(describing: message()),
            level: level,
            timestamp: Date(),
            file: file,
            function: function,
            line: line
        )

        // Dispatch asynchronously to the serial queue.
        // This ensures the calling thread is not blocked and logs are processed in order.
        logQueue.async {
            for destination in self.destinations.values {
                // Check if the destination's minimum level is met before processing.
                if entry.level.rawValue >= destination.minimumLogLevel.rawValue {
                    destination.process(entry: entry)
                }
            }
        }
    }

    // MARK: - Convenience Methods

    public func debug(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.debug, message(), file: file, function: function, line: line)
    }

    public func info(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.info, message(), file: file, function: function, line: line)
    }

    public func warning(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.warning, message(), file: file, function: function, line: line)
    }

    public func error(_ message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: UInt = #line) {
        log(.error, message(), file: file, function: function, line: line)
    }
}


// MARK: - 3. Data Structures (Log Level and Log Entry)

extension Logger {
    /// Defines the severity of a log message.
    /// `Comparable` allows us to easily filter levels (e.g., log everything >= .info).
    public enum LogLevel: Int, Comparable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3

        public static func < (lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        var emoji: String {
            switch self {
            case .debug: return "🐛" // Debug
            case .info: return "ℹ️" // Info
            case .warning: return "⚠️" // Warning
            case .error: return "🔥" // Error
            }
        }
    }

    /// A struct representing a single log event.
    /// This standardizes the data that flows through the logging system.
    public struct LogEntry {
        public let message: String
        public let level: LogLevel
        public let timestamp: Date
        public let file: String
        public let function: String
        public let line: UInt

        /// Computed property to get just the file name from the full path.
        public var fileName: String {
            return (file as NSString).lastPathComponent
        }
    }
}


// MARK: - 4. Concrete Destination Implementations

/// A destination that prints logs to the Xcode console.
public class ConsoleDestination: LogDestination {
    public let identifier = "com.company.app.consoleDestination"
    public var minimumLogLevel: Logger.LogLevel = .debug

    private let dateFormatter: DateFormatter

    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }

    public func process(entry: Logger.LogEntry) {
        let formattedMessage = format(entry: entry)
        print(formattedMessage)
    }

    /// Formats the log entry into a readable string.
    private func format(entry: Logger.LogEntry) -> String {
        let dateString = dateFormatter.string(from: entry.timestamp)
        return "\(dateString) \(entry.level.emoji) [\(entry.fileName):\(entry.line)] \(entry.function) -> \(entry.message)"
    }
}

/// A destination that writes logs to a file on disk.
public class FileDestination: LogDestination {
    public let identifier = "com.company.app.fileDestination"
    public var minimumLogLevel: Logger.LogLevel = .info

    private let fileHandle: FileHandle
    private let logFileURL: URL

    public init?(logFileName: String = "app.log") {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory.")
            return nil
        }
        self.logFileURL = documentsDirectory.appendingPathComponent(logFileName)

        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
        }

        do {
            self.fileHandle = try FileHandle(forWritingTo: logFileURL)
            self.fileHandle.seekToEndOfFile() // Start writing at the end of the file
        } catch {
            print("Error: Could not open file handle for writing at \(logFileURL). Error: \(error)")
            return nil
        }
    }

    deinit {
        fileHandle.closeFile()
    }

    public func process(entry: Logger.LogEntry) {
        let formattedMessage = "\(entry.timestamp) [\(entry.level)] \(entry.message)\n"
        if let data = formattedMessage.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
}


/// A mock destination that "sends" logs to a remote API.
/// In a real app, this would use URLSession to send a network request.
public class APIDestination: LogDestination {
    public let identifier = "com.company.app.apiDestination"
    public var minimumLogLevel: Logger.LogLevel = .warning

    private let apiEndpoint: URL

    public init(apiEndpoint: URL) {
        self.apiEndpoint = apiEndpoint
    }

    public func process(entry: Logger.LogEntry) {
        // In a real implementation, you would serialize the entry to JSON
        // and send it using URLSession.
        // For this example, we just simulate the process.
        let payload: [String: Any] = [
            "level": entry.level.rawValue,
            "message": entry.message,
            "timestamp": entry.timestamp.timeIntervalSince1970,
            "context": [
                "file": entry.fileName,
                "function": entry.function,
                "line": entry.line
            ]
        ]

        print("📡 Sending log to API at \(apiEndpoint): \(payload)")
        // let data = try? JSONSerialization.data(withJSONObject: payload)
        // var request = URLRequest(url: apiEndpoint)
        // request.httpMethod = "POST"
        // request.httpBody = data
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // URLSession.shared.dataTask(with: request).resume()
    }
}


// MARK: - 5. Usage Example

/*
// In your AppDelegate or SceneDelegate's didFinishLaunchingWithOptions:
func setupLogger() {
    let console = ConsoleDestination()
    Logger.shared.add(destination: console)

    if let file = FileDestination() {
        file.minimumLogLevel = .info
        Logger.shared.add(destination: file)
    }

    if let apiURL = URL(string: "https://api.example.com/logs") {
        let api = APIDestination(apiEndpoint: apiURL)
        api.minimumLogLevel = .error // Only send errors to the remote server
        Logger.shared.add(destination: api)
    }
}

// From anywhere in the app:
func someUserAction() {
    Logger.shared.info("User tapped the login button.")

    // Simulate a network call
    DispatchQueue.global().async {
        Logger.shared.debug("Starting network request on background thread.")
        // ... network call happens ...
        let success = false
        if !success {
            Logger.shared.error("Failed to fetch user profile.")
        }
    }
}
*/


/*
 
 
 +--------------------------------------------------------------------------------+
 |                                  Your App Code                                 |
 | (e.g., ViewController, ViewModel, Service Layer)                               |
 +--------------------------------------------------------------------------------+
        |
        | 1. Calls a simple, static method
        |    e.g., Logger.shared.info("User action")
        |
 +------v-------------------------------------------------------------------------+
 |  Logger (Singleton Facade)                                                     |
 |  - Manages a dictionary of [String: LogDestination]                            |
 |  - Provides a single, clean entry point (`.log`, `.info`, etc.)                |
 |  - Creates a `LogEntry` struct with message, level, timestamp, etc.            |
 |                                                                                |
 |  2. Dispatches the `LogEntry` asynchronously to its private serial queue.      |
 |     +--------------------------------------------------------------------+     |
 |     |  logQueue (Serial DispatchQueue)                                   |     |
 |     |  - Ensures thread safety and sequential processing.                |     |
 |     +--------------------------------------------------------------------+     |
 +--------------------------------------------------------------------------------+
        |
        | 3. On the logQueue, the Logger iterates through its destinations.
        |    For each destination, it checks if `entry.level >= dest.minLevel`.
        |
 +------v-------------------------------------------------------------------------+
 |  for destination in destinations.values {                                      |
 |      destination.process(entry: entry)                                         |
 |  }                                                                             |
 +--------------------------------------------------------------------------------+
        |
        | 4. The call is forwarded to the `process()` method of each eligible
        |    destination, based on the `LogDestination` protocol (Strategy Pattern).
        |
 +--------------------------+---------------------------+-------------------------+
 |                          |                           |                         |
 v                          v                           v                         v
 +------------------+ +-----------------+ +-----------------+ +---------------------+
 | ConsoleDestination | | FileDestination | |  APIDestination | | NewCustomDestination|
 | (implements      | | (implements    | | (implements    | | (implements        |
 |  LogDestination) | |  LogDestination)| |  LogDestination)| |  LogDestination)    |
 |------------------| |-----------------| |-----------------| |---------------------|
 | - Prints to      | | - Writes to a   | | - Serializes to | | - Sends to a new    |
 |   Xcode console. | |   file on disk. | |   JSON & sends  | |   analytics service.|
 |                  | |                 | |   network req.  | |                     |
 +------------------+ +-----------------+ +-----------------+ +---------------------+
 
 
 */
