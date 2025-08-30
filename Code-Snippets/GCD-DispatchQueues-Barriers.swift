//
//  GCD-DispatchQueues-Barriers.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation

// MARK: - GCD Concepts Demo Class
class GCDConceptsDemo1 {
    
    // MARK: - Basic Queue Types
    func demonstrateBasicQueues() {
        print("=== Basic Queue Types Demo ===")
        
        // 1. Main Queue (Serial, UI Updates)
        DispatchQueue.main.async {
            print("🎯 Main Queue: UI updates happen here")
            // Update UI elements here
        }
        
        // 2. Global Concurrent Queues (Different QoS levels)
        DispatchQueue.global(qos: .userInteractive).async {
            print("🔥 User Interactive: Highest priority (animations, event handling)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("⚡ User Initiated: High priority background work")
        }
        
        DispatchQueue.global(qos: .default).async {
            print("📋 Default: Standard background work")
        }
        
        DispatchQueue.global(qos: .utility).async {
            print("🔧 Utility: Long-running tasks (downloads, processing)")
        }
        
        DispatchQueue.global(qos: .background).async {
            print("💤 Background: Lowest priority (cleanup, maintenance)")
        }
        
        // 3. Custom Queues
        let customSerialQueue = DispatchQueue(label: "com.app.serial-queue")
        let customConcurrentQueue = DispatchQueue(label: "com.app.concurrent-queue", qos: .utility, attributes: .concurrent)
        
        customSerialQueue.async {
            print("🔗 Custom Serial Queue: Tasks execute one after another")
        }
        
        customConcurrentQueue.async {
            print("🌊 Custom Concurrent Queue: Tasks can execute simultaneously")
        }
    }
    
    // MARK: - Dispatch Barriers
    func demonstrateDispatchBarriers() {
        print("\n=== Dispatch Barriers Demo ===")
        
        let concurrentQueue = DispatchQueue(label: "com.app.barrier-demo", attributes: .concurrent)
        
        // Multiple readers can execute concurrently
        for i in 1...3 {
            concurrentQueue.async {
                print("📖 Reader \(i) started")
                Thread.sleep(forTimeInterval: 1)
                print("📖 Reader \(i) finished")
            }
        }
        
        // Barrier ensures exclusive access (like a writer)
        concurrentQueue.async(flags: .barrier) {
            print("✍️ Writer started (BARRIER)")
            Thread.sleep(forTimeInterval: 2)
            print("✍️ Writer finished (BARRIER)")
        }
        
        // More readers after barrier
        for i in 4...6 {
            concurrentQueue.async {
                print("📖 Reader \(i) started")
                Thread.sleep(forTimeInterval: 1)
                print("📖 Reader \(i) finished")
            }
        }
    }
    
    // MARK: - Dispatch Groups
    func demonstrateDispatchGroups() {
        print("\n=== Dispatch Groups Demo ===")
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        // Task 1
        group.enter()
        queue.async {
            print("🚀 Task 1 started")
            Thread.sleep(forTimeInterval: 2)
            print("✅ Task 1 completed")
            group.leave()
        }
        
        // Task 2
        group.enter()
        queue.async {
            print("🚀 Task 2 started")
            Thread.sleep(forTimeInterval: 1.5)
            print("✅ Task 2 completed")
            group.leave()
        }
        
        // Task 3 using async(group:)
        queue.async(group: group) {
            print("🚀 Task 3 started")
            Thread.sleep(forTimeInterval: 1)
            print("✅ Task 3 completed")
        }
        
        // Wait for all tasks to complete
        group.notify(queue: DispatchQueue.main) {
            print("🎉 All tasks completed!")
        }
        
        // Alternative: Synchronous wait (blocks current thread)
        // group.wait() // Blocks until all tasks complete
        // print("All tasks finished (synchronous)")
    }
    
    // MARK: - Dispatch Semaphores
    func demonstrateDispatchSemaphores() {
        print("\n=== Dispatch Semaphores Demo ===")
        
        // Semaphore with capacity of 2 (max 2 concurrent tasks)
        let semaphore = DispatchSemaphore(value: 2)
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        for i in 1...5 {
            queue.async {
                semaphore.wait() // Acquire semaphore
                print("🎫 Task \(i) acquired semaphore")
                
                // Simulate work
                Thread.sleep(forTimeInterval: 2)
                print("✅ Task \(i) releasing semaphore")
                
                semaphore.signal() // Release semaphore
            }
        }
    }
    
    // MARK: - Dispatch Work Items
    func demonstrateDispatchWorkItems() {
        print("\n=== Dispatch Work Items Demo ===")
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        // Create work item
        let workItem = DispatchWorkItem(qos: .userInitiated, flags: .enforceQoS) {
            for i in 1...5 {
                print("🔄 Work item progress: \(i)/5")
                Thread.sleep(forTimeInterval: 0.5)
            }
            print("✅ Work item completed")
        }
        
        // Execute work item
        queue.async(execute: workItem)
        
        // You can cancel work items if needed
        // workItem.cancel()
        
        // Wait for work item completion
        workItem.notify(queue: DispatchQueue.main) {
            print("📢 Work item notification received")
        }
    }
    
    // MARK: - Dispatch Sources (Timers)
    func demonstrateDispatchSources() {
        print("\n=== Dispatch Sources (Timer) Demo ===")
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        var counter = 0
        
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler {
            counter += 1
            print("⏰ Timer tick: \(counter)")
            
            if counter >= 5 {
                timer.cancel()
                print("⏹️ Timer cancelled")
            }
        }
        
        timer.resume()
    }
    
    // MARK: - Real-world Example: Image Processing Pipeline
    func demonstrateImageProcessingPipeline() {
        print("\n=== Image Processing Pipeline Demo ===")
        
        let processingQueue = DispatchQueue(label: "com.app.image-processing", attributes: .concurrent)
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 3) // Limit concurrent processing
        
        let imageNames = ["image1.jpg", "image2.jpg", "image3.jpg", "image4.jpg", "image5.jpg"]
        
        for imageName in imageNames {
            group.enter()
            processingQueue.async {
                semaphore.wait() // Limit concurrent processing
                
                print("🖼️ Processing \(imageName)")
                
                // Simulate image processing
                self.simulateImageProcessing(imageName: imageName)
                
                print("✅ Completed \(imageName)")
                
                semaphore.signal()
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("🎨 All images processed successfully!")
        }
    }
    
    private func simulateImageProcessing(imageName: String) {
        // Simulate processing time
        Thread.sleep(forTimeInterval: Double.random(in: 1...3))
    }
    
    // MARK: - Thread Safety with Barriers (Reader-Writer Problem)
    func demonstrateThreadSafetyWithBarriers() {
        print("\n=== Thread Safety with Barriers Demo ===")
        
        let dataQueue = DispatchQueue(label: "com.app.data-queue", attributes: .concurrent)
        var sharedData: [String] = []
        
        // Multiple readers
        for i in 1...3 {
            dataQueue.async {
                let data = sharedData // Safe concurrent read
                print("📖 Reader \(i): Current data count = \(data.count)")
            }
        }
        
        // Writer with barrier (exclusive access)
        dataQueue.async(flags: .barrier) {
            sharedData.append("New Data Item")
            print("✍️ Writer: Added new item. Total count = \(sharedData.count)")
        }
        
        // More readers after write
        for i in 4...6 {
            dataQueue.async {
                let data = sharedData
                print("📖 Reader \(i): Current data count = \(data.count)")
            }
        }
    }
    
    // MARK: - Quality of Service (QoS) Examples
    func demonstrateQualityOfService() {
        print("\n=== Quality of Service Demo ===")
        
        // Different QoS levels affect execution priority
        DispatchQueue.global(qos: .background).async {
            print("💤 Background task started")
            Thread.sleep(forTimeInterval: 1)
            print("💤 Background task finished")
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            print("🔥 User Interactive task started")
            Thread.sleep(forTimeInterval: 1)
            print("🔥 User Interactive task finished")
        }
        
        DispatchQueue.global(qos: .utility).async {
            print("🔧 Utility task started")
            Thread.sleep(forTimeInterval: 1)
            print("🔧 Utility task finished")
        }
    }
    
    // MARK: - Deadlock Prevention Example
    func demonstrateDeadlockPrevention() {
        print("\n=== Deadlock Prevention Demo ===")
        
        let queue1 = DispatchQueue(label: "queue1")
        let queue2 = DispatchQueue(label: "queue2")
        
        // WRONG: This can cause deadlock if reverse dependecy in there somewhere else in the code.
        // queue1.sync {
        //     queue2.sync {
        //         print("This might deadlock")
        //     }
        // }
        
        // CORRECT: Use async to prevent deadlock
        queue1.async {
            print("🔄 Task 1 started")
            queue2.async {
                print("🔄 Task 2 started (no deadlock)")
            }
        }
    }
    
    // MARK: - Main Queue vs Global Queue Example
    func demonstrateMainVsGlobalQueue() {
        print("\n=== Main vs Global Queue Demo ===")
        
        // Background work
        DispatchQueue.global(qos: .userInitiated).async {
            print("🔄 Performing background calculation...")
            
            // Simulate heavy computation
            var result = 0
            for i in 1...1000000 {
                result += i
            }
            
            // Update UI on main queue
            DispatchQueue.main.async {
                print("🎯 Updating UI with result: \(result)")
                // Update UI elements here
            }
        }
    }
}

// MARK: - Thread-Safe Data Structure Example
class ThreadSafeArray1<T> {
    private var array: [T] = []
    private let queue = DispatchQueue(label: "com.app.thread-safe-array", attributes: .concurrent)
    
    func append(_ element: T) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    func get(at index: Int) -> T? {
        return queue.sync {
            return index < array.count ? array[index] : nil
        }
    }
    
    var count: Int {
        return queue.sync {
            return array.count
        }
    }
    
    var all: [T] {
        return queue.sync {
            return array
        }
    }
}

// MARK: - Network Request Manager with GCD
class NetworkManager1 {
    private let requestQueue = DispatchQueue(label: "com.app.network", attributes: .concurrent)
    private let semaphore = DispatchSemaphore(value: 5) // Max 5 concurrent requests
    
    func performRequest(url: String, completion: @escaping (String) -> Void) {
        requestQueue.async {
            self.semaphore.wait() // Acquire semaphore
            
            print("🌐 Starting request to: \(url)")
            
            // Simulate network request
            Thread.sleep(forTimeInterval: Double.random(in: 0.5...2.0))
            
            let result = "Response from \(url)"
            
            // Return to main queue for completion
            DispatchQueue.main.async {
                completion(result)
            }
            
            self.semaphore.signal() // Release semaphore
        }
    }
}

// MARK: - Usage Examples
class GCDUsageExamples1 {
    
    func runAllExamples() {
        let demo = GCDConceptsDemo1()
        
        demo.demonstrateBasicQueues()
        demo.demonstrateDispatchBarriers()
        demo.demonstrateDispatchGroups()
        demo.demonstrateDispatchSemaphores()
        demo.demonstrateDispatchWorkItems()
        demo.demonstrateDispatchSources()
        demo.demonstrateImageProcessingPipeline()
        demo.demonstrateThreadSafetyWithBarriers()
        demo.demonstrateQualityOfService()
        demo.demonstrateDeadlockPrevention()
        demo.demonstrateMainVsGlobalQueue()
        
        // Thread-safe array example
        let threadSafeArray = ThreadSafeArray1<Int>()
        
        for i in 1...10 {
            DispatchQueue.global().async {
                threadSafeArray.append(i)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Thread-safe array contents: \(threadSafeArray.all)")
        }
        
        // Network manager example
        let networkManager = NetworkManager1()
        let urls = ["api.example.com/users", "api.example.com/posts", "api.example.com/comments"]
        
        for url in urls {
            networkManager.performRequest(url: url) { response in
                print("📡 Received: \(response)")
            }
        }
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Queue Types**:
    - Serial Queues: Execute tasks one at a time (FIFO)
    - Concurrent Queues: Execute multiple tasks simultaneously
    - Main Queue: Serial queue for UI updates (main thread)
    - Global Queues: System-provided concurrent queues with different QoS

 2. **Quality of Service (QoS)**:
    - .userInteractive: Highest priority (UI, animations)
    - .userInitiated: High priority (user-requested tasks)
    - .default: Standard priority
    - .utility: Long-running tasks (downloads, processing)
    - .background: Lowest priority (cleanup, maintenance)

 3. **Dispatch Barriers**:
    - Provide exclusive access in concurrent queues
    - Perfect for reader-writer scenarios
    - All previously submitted tasks complete before barrier
    - No new tasks start until barrier completes

 4. **Dispatch Groups**:
    - Coordinate multiple asynchronous tasks
    - enter()/leave() for manual control
    - async(group:) for automatic management
    - notify() for completion callbacks
    - wait() for synchronous waiting

 5. **Dispatch Semaphores**:
    - Control access to finite resources
    - Counting semaphore (value = max concurrent access)
    - wait() decrements counter (blocks if zero)
    - signal() increments counter

 6. **Thread Safety Patterns**:
    - Concurrent reads, exclusive writes with barriers
    - Semaphores for resource limiting
    - Serial queues for simple synchronization
    - Atomic operations for simple data

 7. **Common Pitfalls**:
    - Deadlocks: sync calls on same queue or circular waits
    - UI updates must happen on main queue
    - Retain cycles with closures (use weak self)
    - Blocking main thread with sync calls

 8. **Performance Considerations**:
    - Concurrent queues for CPU-intensive tasks
    - Limit concurrency with semaphores
    - Use appropriate QoS levels
    - Avoid creating too many queues

 9. **Common Interview Questions**:
    - Q: Difference between sync and async?
    - A: sync blocks calling thread, async doesn't
    
    - Q: When to use barriers?
    - A: Reader-writer scenarios for thread-safe data access
    
    - Q: How to prevent deadlocks?
    - A: Avoid sync calls on same queue, use async when possible
    
    - Q: What's the purpose of QoS?
    - A: System priority management for better resource allocation

 10. **Best Practices**:
     - Use main queue only for UI updates
     - Prefer async over sync when possible
     - Use appropriate QoS for task priority
     - Implement proper error handling
     - Consider using higher-level APIs (async/await) when available
     - Profile and measure performance impact
*/ 
