//
//  RunLoop-Advanced-Concepts.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import UIKit

// MARK: - RunLoop Basics

/*
 RunLoop is a fundamental part of iOS/macOS that:
 
 1. Manages threads and their event processing
 2. Handles input sources (timers, network, user input)
 3. Coordinates with the system for efficient CPU usage
 4. Provides different modes for different scenarios
 5. Integrates with UI framework for smooth animations
 
 Key Components:
 - Input Sources: Port-based, custom sources
 - Timer Sources: NSTimer, scheduled timers
 - Observers: Monitor run loop state changes
 - Modes: Different configurations for different scenarios
*/

class RunLoopBasics11 {
    
    func demonstrateBasicRunLoop() {
        print("=== RunLoop Basics ===")
        
        // Get current run loop
        let currentRunLoop = RunLoop.current
        let mainRunLoop = RunLoop.main
        
        print("📍 Current RunLoop: \(currentRunLoop)")
        print("📍 Main RunLoop: \(mainRunLoop)")
        print("📍 Are they same? \(currentRunLoop === mainRunLoop)")
        
        // Run loop modes
        demonstrateRunLoopModes()
        
        // Run loop sources
        demonstrateRunLoopSources()
    }
    
    private func demonstrateRunLoopModes() {
        print("\n🔄 RunLoop Modes:")
        
        // Common modes
        print("Default Mode: \(RunLoop.Mode.default)")
        print("Common Modes: \(RunLoop.Mode.common)")
        print("Tracking Mode: \(RunLoop.Mode.tracking)")
        
        // Custom mode
        let customMode = RunLoop.Mode("com.app.customMode")
        print("Custom Mode: \(customMode)")
        
        // Current mode
        let currentMode = RunLoop.current.currentMode
        print("Current Mode: \(currentMode?.rawValue ?? "None")")
    }
    
    private func demonstrateRunLoopSources() {
        print("\n📡 RunLoop Sources:")
        
        // Timer source
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            print("⏰ Timer fired!")
        }
        
        print("✅ Timer source added to run loop")
        
        // Port source (for demonstration)
        let port = Port()
        RunLoop.current.add(port, forMode: .default)
        print("✅ Port source added to run loop")
        
        // Remove sources
        timer.invalidate()
        RunLoop.current.remove(port, forMode: .default)
        print("🗑️ Sources removed from run loop")
    }
}

// MARK: - RunLoop Modes in Detail

class RunLoopModes11 {
    
    private var timer1: Timer?
    private var timer2: Timer?
    
    func demonstrateRunLoopModes() {
        print("\n=== RunLoop Modes Demonstration ===")
        
        // Create timers for different modes
        setupTimersForDifferentModes()
        
        // Demonstrate mode switching
        demonstrateModeSpecificBehavior()
        
        // Common modes demonstration
        demonstrateCommonModes()
    }
    
    private func setupTimersForDifferentModes() {
        print("🔧 Setting up timers for different modes:")
        
        // Timer for default mode only
        timer1 = Timer(timeInterval: 1.0, repeats: true) { _ in
            print("⏰ Default mode timer fired")
        }
        RunLoop.current.add(timer1!, forMode: .default)
        
        // Timer for common modes (default + tracking)
        timer2 = Timer(timeInterval: 1.5, repeats: true) { _ in
            print("⏰ Common modes timer fired")
        }
        RunLoop.current.add(timer2!, forMode: .common)
        
        print("✅ Timers configured for different modes")
    }
    
    private func demonstrateModeSpecificBehavior() {
        print("\n🎯 Mode-specific behavior:")
        
        // Simulate running in default mode
        print("Running in default mode for 3 seconds...")
        let endTime = Date().addingTimeInterval(3)
        
        while Date() < endTime {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }
        
        print("✅ Default mode demonstration completed")
    }
    
    private func demonstrateCommonModes() {
        print("\n🌐 Common modes behavior:")
        
        // Common modes include both default and tracking
        print("Common modes includes:")
        print("- Default mode (normal operation)")
        print("- Tracking mode (UI interaction like scrolling)")
        
        // Timer in common modes will fire in both default and tracking modes
        print("✅ Common modes timer will fire during UI interactions")
    }
    
    deinit {
        timer1?.invalidate()
        timer2?.invalidate()
    }
}

// MARK: - RunLoop Observers

class RunLoopObservers11 {
    
    private var observer: CFRunLoopObserver?
    
    func demonstrateRunLoopObservers() {
        print("\n=== RunLoop Observers ===")
        
        setupRunLoopObserver()
        performSomeWork()
        removeRunLoopObserver()
    }
    
    private func setupRunLoopObserver() {
        print("👁️ Setting up RunLoop observer:")
        
        // Create observer context
        var context = CFRunLoopObserverContext(
            version: 0,
            info: nil,
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        // Create observer
        observer = CFRunLoopObserverCreate(
            kCFAllocatorDefault,
            CFRunLoopActivity.allActivities.rawValue,
            true, // repeats
            0,    // order
            { (observer, activity, info) in
                let activityName = RunLoopObservers11.activityName(for: activity)
                print("🔍 RunLoop activity: \(activityName)")
            },
            &context
        )
        
        // Add observer to current run loop
        if let observer = observer {
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, CFRunLoopMode.defaultMode)
            print("✅ RunLoop observer added")
        }
    }
    
    private func performSomeWork() {
        print("\n🔄 Performing work to trigger run loop activities:")
        
        // Schedule a timer to trigger run loop activity
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            print("⚡ Timer work completed")
        }
        
        // Run the run loop briefly to process the timer
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
    }
    
    private func removeRunLoopObserver() {
        if let observer = observer {
            CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, CFRunLoopMode.defaultMode)
            print("🗑️ RunLoop observer removed")
        }
    }
    
    static func activityName(for activity: CFRunLoopActivity) -> String {
        switch activity {
        case .entry:
            return "Entry"
        case .beforeTimers:
            return "Before Timers"
        case .beforeSources:
            return "Before Sources"
        case .beforeWaiting:
            return "Before Waiting"
        case .afterWaiting:
            return "After Waiting"
        case .exit:
            return "Exit"
        default:
            return "Unknown"
        }
    }
}

// MARK: - Custom RunLoop Sources

class CustomRunLoopSource11 {
    
    private var customSource: CFRunLoopSource?
    private var isSourceSignaled = false
    
    func demonstrateCustomRunLoopSource() {
        print("\n=== Custom RunLoop Source ===")
        
        createCustomSource()
        addSourceToRunLoop()
        signalSource()
        removeSourceFromRunLoop()
    }
    
    private func createCustomSource() {
        print("🔧 Creating custom RunLoop source:")
        
        // Create source context
        var context = CFRunLoopSourceContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil,
            equal: nil,
            hash: nil,
            schedule: { (info, runLoop, mode) in
                print("📅 Custom source scheduled")
            },
            cancel: { (info, runLoop, mode) in
                print("❌ Custom source cancelled")
            },
            perform: { (info) in
                print("⚡ Custom source performed!")
                if let sourcePtr = info {
                    let source = Unmanaged<CustomRunLoopSource11>.fromOpaque(sourcePtr).takeUnretainedValue()
                    source.handleSourceEvent()
                }
            }
        )
        
        // Create the source
        customSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context)
        print("✅ Custom source created")
    }
    
    private func addSourceToRunLoop() {
        guard let source = customSource else { return }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, CFRunLoopMode.defaultMode)
        print("✅ Custom source added to run loop")
    }
    
    private func signalSource() {
        guard let source = customSource else { return }
        
        print("📡 Signaling custom source...")
        CFRunLoopSourceSignal(source)
        CFRunLoopWakeUp(CFRunLoopGetCurrent())
        
        // Run the loop to process the source
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
    }
    
    private func removeSourceFromRunLoop() {
        guard let source = customSource else { return }
        
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, CFRunLoopMode.defaultMode)
        print("🗑️ Custom source removed from run loop")
    }
    
    private func handleSourceEvent() {
        print("🎯 Handling custom source event")
        isSourceSignaled = true
    }
}

// MARK: - RunLoop and Threading

class RunLoopThreading11 {
    
    private var backgroundThread: Thread?
    private var shouldKeepRunning = true
    
    func demonstrateRunLoopThreading() {
        print("\n=== RunLoop and Threading ===")
        
        // Main thread run loop
        demonstrateMainThreadRunLoop()
        
        // Background thread run loop
        demonstrateBackgroundThreadRunLoop()
        
        // Thread communication via run loop
        demonstrateThreadCommunication()
    }
    
    private func demonstrateMainThreadRunLoop() {
        print("🎯 Main thread RunLoop:")
        
        let mainRunLoop = RunLoop.main
        print("Main RunLoop: \(mainRunLoop)")
        print("Is main thread: \(Thread.isMainThread)")
        
        // Schedule work on main run loop
        mainRunLoop.perform {
            print("⚡ Work performed on main run loop")
        }
    }
    
    private func demonstrateBackgroundThreadRunLoop() {
        print("\n🔄 Background thread RunLoop:")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        backgroundThread = Thread {
            print("🧵 Background thread started")
            
            let runLoop = RunLoop.current
            print("Background RunLoop: \(runLoop)")
            
            // Add a timer to keep the run loop alive
            let timer = Timer(timeInterval: 1.0, repeats: true) { _ in
                print("⏰ Background timer fired")
            }
            runLoop.add(timer, forMode: .default)
            
            // Signal that setup is complete
            semaphore.signal()
            
            // Run the loop
            while self.shouldKeepRunning && runLoop.run(mode: .default, before: Date().addingTimeInterval(0.1)) {
                // Keep running
            }
            
            timer.invalidate()
            print("🧵 Background thread finished")
        }
        
        backgroundThread?.start()
        
        // Wait for background thread setup
        semaphore.wait()
        
        // Let it run for a bit
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.shouldKeepRunning = false
        }
    }
    
    private func demonstrateThreadCommunication() {
        print("\n📡 Thread communication via RunLoop:")
        
        // Perform selector on background thread
        backgroundThread?.perform(#selector(backgroundWork), with: nil, waitUntilDone: false)
        
        // Schedule work on main thread from background
        DispatchQueue.global().async {
            RunLoop.main.perform {
                print("⚡ Work scheduled on main thread from background")
            }
        }
    }
    
    @objc private func backgroundWork() {
        print("🔧 Background work executed via performSelector")
    }
}

// MARK: - RunLoop and UI Integration

class RunLoopUIIntegration11 {
    
    func demonstrateUIIntegration() {
        print("\n=== RunLoop and UI Integration ===")
        
        // UI event handling
        demonstrateUIEventHandling()
        
        // Animation integration
        demonstrateAnimationIntegration()
        
        // Scroll view integration
        demonstrateScrollViewIntegration()
        
        // CADisplayLink integration
        demonstrateDisplayLinkIntegration()
    }
    
    private func demonstrateUIEventHandling() {
        print("🎮 UI Event Handling:")
        
        print("📱 Touch events are processed in default mode")
        print("🔄 UI updates happen during run loop cycles")
        print("⏱️ Event processing is synchronized with display refresh")
        
        // Simulate UI event processing
        let timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: false) { _ in
            print("📺 Simulated 60fps UI update")
        }
    }
    
    private func demonstrateAnimationIntegration() {
        print("\n🎬 Animation Integration:")
        
        print("🎨 Core Animation integrates with run loop")
        print("📺 Animations are synchronized with display refresh")
        print("🔄 CADisplayLink provides display-synchronized callbacks")
        
        // Create a display link (conceptual - would need actual view)
        if let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback)) {
            displayLink.add(to: .main, forMode: .common)
            
            // Remove after demonstration
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                displayLink.invalidate()
                print("🗑️ Display link invalidated")
            }
        }
    }
    
    @objc private func displayLinkCallback() {
        print("📺 Display link callback - 60fps")
    }
    
    private func demonstrateScrollViewIntegration() {
        print("\n📜 ScrollView Integration:")
        
        print("🔄 Scroll views use tracking mode during scrolling")
        print("⏸️ Default mode timers pause during scrolling")
        print("🌐 Common mode timers continue during scrolling")
        
        // Demonstrate with timer modes
        let defaultTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            print("⏰ Default mode timer (pauses during scroll)")
        }
        RunLoop.current.add(defaultTimer, forMode: .default)
        
        let commonTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            print("⏰ Common mode timer (continues during scroll)")
        }
        RunLoop.current.add(commonTimer, forMode: .common)
        
        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            defaultTimer.invalidate()
            commonTimer.invalidate()
        }
    }
    
    private func demonstrateDisplayLinkIntegration() {
        print("\n📺 CADisplayLink Integration:")
        
        var frameCount = 0
        let displayLink = CADisplayLink(target: self, selector: #selector(frameUpdate))
        
        displayLink.add(to: .main, forMode: .common)
        
        // Stop after a few frames
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            displayLink.invalidate()
            print("🎬 Recorded \(frameCount) frames")
        }
    }
    
    @objc private func frameUpdate() {
        // This would be called at display refresh rate (60fps/120fps)
        print("🎞️ Frame update")
    }
}

// MARK: - RunLoop Performance and Optimization

class RunLoopPerformance11 {
    
    func demonstratePerformanceOptimization() {
        print("\n=== RunLoop Performance Optimization ===")
        
        // Efficient timer usage
        demonstrateEfficientTimers()
        
        // Batch operations
        demonstrateBatchOperations()
        
        // Run loop monitoring
        demonstrateRunLoopMonitoring()
        
        // Common performance issues
        demonstrateCommonIssues()
    }
    
    private func demonstrateEfficientTimers() {
        print("⏱️ Efficient Timer Usage:")
        
        // Bad: Multiple individual timers
        print("❌ Creating multiple individual timers (inefficient)")
        let timers = (0..<5).map { index in
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                print("Timer \(index) fired")
            }
        }
        
        // Good: Single timer with batch processing
        print("✅ Using single timer with batch processing (efficient)")
        let batchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Process all tasks in batch
            for i in 0..<5 {
                print("Batch processing task \(i)")
            }
        }
        
        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            timers.forEach { $0.invalidate() }
            batchTimer.invalidate()
        }
    }
    
    private func demonstrateBatchOperations() {
        print("\n📦 Batch Operations:")
        
        // Batch UI updates
        print("🎨 Batching UI updates for better performance")
        
        // Use perform to batch operations
        RunLoop.main.perform {
            // Batch multiple UI updates together
            print("🔄 Batched UI update 1")
            print("🔄 Batched UI update 2")
            print("🔄 Batched UI update 3")
        }
    }
    
    private func demonstrateRunLoopMonitoring() {
        print("\n📊 RunLoop Monitoring:")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Monitor run loop performance
        let observer = CFRunLoopObserverCreateWithHandler(
            kCFAllocatorDefault,
            CFRunLoopActivity.beforeWaiting.rawValue,
            true
        ) { (observer, activity) in
            let currentTime = CFAbsoluteTimeGetCurrent()
            let cycleTime = currentTime - startTime
            
            if cycleTime > 0.016 { // 16ms = 60fps threshold
                print("⚠️ Long run loop cycle: \(String(format: "%.3f", cycleTime * 1000))ms")
            }
        }
        
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, CFRunLoopMode.defaultMode)
        
        // Simulate some work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer!, CFRunLoopMode.defaultMode)
        }
    }
    
    private func demonstrateCommonIssues() {
        print("\n⚠️ Common Performance Issues:")
        
        print("1. 🐌 Blocking main run loop with synchronous operations")
        print("2. ⏰ Too many timers causing overhead")
        print("3. 🔄 Excessive run loop source additions/removals")
        print("4. 📱 Not using appropriate run loop modes")
        print("5. 🧵 Improper thread-run loop coordination")
        
        // Example of what NOT to do
        print("\n❌ Example of blocking operation (don't do this):")
        // Thread.sleep(forTimeInterval: 1.0) // This would block the run loop!
        
        print("✅ Better: Use async operations")
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1.0)
            DispatchQueue.main.async {
                print("✅ Async operation completed without blocking run loop")
            }
        }
    }
}

// MARK: - Real-World RunLoop Examples

class RealWorldRunLoopExamples11 {
    
    func demonstrateRealWorldUsage() {
        print("\n=== Real-World RunLoop Usage ===")
        
        // Network request handling
        demonstrateNetworkIntegration()
        
        // Custom event loop
        demonstrateCustomEventLoop()
        
        // Background processing
        demonstrateBackgroundProcessing()
    }
    
    private func demonstrateNetworkIntegration() {
        print("🌐 Network Integration:")
        
        // URLSession integrates with run loop
        let url = URL(string: "https://httpbin.org/delay/1")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("📡 Network request completed on run loop")
        }
        
        task.resume()
        print("✅ Network request scheduled on run loop")
    }
    
    private func demonstrateCustomEventLoop() {
        print("\n🔄 Custom Event Loop:")
        
        class CustomEventProcessor {
            private var events: [String] = []
            private let queue = DispatchQueue(label: "events")
            
            func addEvent(_ event: String) {
                queue.async {
                    self.events.append(event)
                    self.processEvents()
                }
            }
            
            private func processEvents() {
                RunLoop.main.perform {
                    while !self.events.isEmpty {
                        let event = self.events.removeFirst()
                        print("🎯 Processing event: \(event)")
                    }
                }
            }
        }
        
        let processor = CustomEventProcessor()
        processor.addEvent("User Login")
        processor.addEvent("Data Sync")
        processor.addEvent("UI Update")
    }
    
    private func demonstrateBackgroundProcessing() {
        print("\n🔄 Background Processing:")
        
        // Background queue with run loop
        DispatchQueue.global(qos: .background).async {
            let runLoop = RunLoop.current
            
            // Add a timer to keep run loop alive
            let timer = Timer(timeInterval: 2.0, repeats: false) { _ in
                print("⚡ Background processing completed")
            }
            runLoop.add(timer, forMode: .default)
            
            // Run the loop
            runLoop.run(until: Date().addingTimeInterval(3))
        }
    }
}

// MARK: - Usage Examples

class RunLoopUsageExamples11 {
    
    func runAllExamples() {
        print("=== RunLoop Advanced Examples ===")
        
        // Basics
        let basics = RunLoopBasics11()
        basics.demonstrateBasicRunLoop()
        
        // Modes
        let modes = RunLoopModes11()
        modes.demonstrateRunLoopModes()
        
        // Observers
        let observers = RunLoopObservers11()
        observers.demonstrateRunLoopObservers()
        
        // Custom sources
        let customSource = CustomRunLoopSource11()
        customSource.demonstrateCustomRunLoopSource()
        
        // Threading
        let threading = RunLoopThreading11()
        threading.demonstrateRunLoopThreading()
        
        // UI integration
        let uiIntegration = RunLoopUIIntegration11()
        uiIntegration.demonstrateUIIntegration()
        
        // Performance
        let performance = RunLoopPerformance11()
        performance.demonstratePerformanceOptimization()
        
        // Real-world examples
        let realWorld = RealWorldRunLoopExamples11()
        realWorld.demonstrateRealWorldUsage()
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **RunLoop Fundamentals**:
    - Event processing loop that manages threads
    - Handles input sources, timers, and observers
    - Coordinates with system for efficient CPU usage
    - Essential for UI responsiveness and event handling

 2. **RunLoop Modes**:
    - Default Mode: Normal operation
    - Common Mode: Includes default + tracking
    - Tracking Mode: UI interactions (scrolling)
    - Custom modes for specific scenarios

 3. **RunLoop Sources**:
    - Input Sources: Port-based, custom sources
    - Timer Sources: NSTimer, scheduled timers
    - Version 0 vs Version 1 sources
    - Source scheduling and removal

 4. **RunLoop Observers**:
    - Monitor run loop state changes
    - Activities: entry, before timers, before sources, etc.
    - Useful for performance monitoring
    - Custom observer creation and management

 5. **Threading and RunLoop**:
    - Main thread has automatic run loop
    - Background threads need manual run loop setup
    - Thread communication via performSelector
    - Run loop keeps threads alive

 6. **UI Framework Integration**:
    - Touch events processed in default mode
    - Animations synchronized with display refresh
    - ScrollView uses tracking mode
    - CADisplayLink for display-synchronized callbacks

 7. **Performance Considerations**:
    - Don't block main run loop
    - Use appropriate modes for timers
    - Batch operations when possible
    - Monitor run loop cycle time

 8. **Common Interview Questions**:
    - Q: What is a RunLoop and why is it important?
    - A: Event processing loop that manages thread execution and UI responsiveness

    - Q: What happens to timers during scrolling?
    - A: Default mode timers pause, common mode timers continue

    - Q: How do you keep a background thread alive?
    - A: Add a run loop source (like timer) and run the loop

    - Q: What's the difference between run loop modes?
    - A: Different modes handle different types of events and sources

 9. **Advanced Concepts**:
    - Custom run loop sources
    - Run loop observers for monitoring
    - Mode-specific timer behavior
    - Integration with Core Animation

 10. **Best Practices**:
     - Never block the main run loop
     - Use common modes for timers that should run during UI interaction
     - Monitor run loop performance in production
     - Understand mode switching behavior

 11. **Common Pitfalls**:
     - Blocking main thread with synchronous operations
     - Not understanding timer mode behavior
     - Creating run loop retain cycles
     - Improper background thread run loop management

 12. **Real-World Applications**:
     - Network request handling
     - Custom event processing systems
     - Animation timing and synchronization
     - Background task coordination
     - UI responsiveness optimization
*/ 