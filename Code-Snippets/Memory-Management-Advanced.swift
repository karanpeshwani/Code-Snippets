//
//  Memory-Management-Advanced.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import UIKit
import Combine

// MARK: - ARC (Automatic Reference Counting) Basics

class ARCBasics9 {
    
    // Strong references (default)
    var strongReference: Person9?
    
    // Weak references (don't increase retain count)
    weak var weakReference: Person9?
    
    // Unowned references (assume object exists)
    unowned var unownedReference: Person9
    
    init(person: Person9) {
        self.unownedReference = person
        print("🏗️ ARCBasics initialized")
    }
    
    deinit {
        print("🗑️ ARCBasics deallocated")
    }
    
    func demonstrateReferenceCounting() {
        print("=== Reference Counting Demo ===")
        
        // Create person (retain count = 1)
        var person1: Person9? = Person9(name: "Alice")
        print("Person created, retain count: 1")
        
        // Create another strong reference (retain count = 2)
        var person2: Person9? = person1
        print("Second strong reference, retain count: 2")
        
        // Create weak reference (retain count still = 2)
        weak var weakPerson: Person9? = person1
        print("Weak reference created, retain count still: 2")
        
        // Remove first strong reference (retain count = 1)
        person1 = nil
        print("First reference removed, retain count: 1")
        print("Weak reference still valid: \(weakPerson != nil)")
        
        // Remove second strong reference (retain count = 0)
        person2 = nil
        print("Second reference removed, retain count: 0")
        print("Weak reference now nil: \(weakPerson == nil)")
    }
}

class Person9 {
    let name: String
    var apartment: Apartment9?
    
    init(name: String) {
        self.name = name
        print("👤 Person \(name) initialized")
    }
    
    deinit {
        print("👤 Person \(name) deallocated")
    }
}

class Apartment9 {
    let unit: String
    weak var tenant: Person9? // Weak to break retain cycle
    
    init(unit: String) {
        self.unit = unit
        print("🏠 Apartment \(unit) initialized")
    }
    
    deinit {
        print("🏠 Apartment \(unit) deallocated")
    }
}

// MARK: - Retain Cycles and Solutions

class RetainCycleExamples9 {
    
    // MARK: - Strong Reference Cycle (Memory Leak)
    func demonstrateStrongReferenceCycle() {
        print("\n=== Strong Reference Cycle (BAD) ===")
        
        class BadParent {
            let name: String
            var children: [BadChild] = []
            
            init(name: String) {
                self.name = name
                print("👨‍👦 BadParent \(name) initialized")
            }
            
            deinit {
                print("👨‍👦 BadParent \(name) deallocated")
            }
        }
        
        class BadChild {
            let name: String
            var parent: BadParent? // Strong reference - causes cycle!
            
            init(name: String) {
                self.name = name
                print("👶 BadChild \(name) initialized")
            }
            
            deinit {
                print("👶 BadChild \(name) deallocated")
            }
        }
        
        var parent: BadParent? = BadParent(name: "John")
        var child: BadChild? = BadChild(name: "Jane")
        
        // Create retain cycle
        parent?.children.append(child!)
        child?.parent = parent
        
        // Setting to nil won't deallocate due to retain cycle
        parent = nil
        child = nil
        
        print("❌ Objects not deallocated - memory leak!")
    }
    
    // MARK: - Weak Reference Solution
    func demonstrateWeakReferenceSolution() {
        print("\n=== Weak Reference Solution (GOOD) ===")
        
        class GoodParent {
            let name: String
            var children: [GoodChild] = []
            
            init(name: String) {
                self.name = name
                print("👨‍👦 GoodParent \(name) initialized")
            }
            
            deinit {
                print("👨‍👦 GoodParent \(name) deallocated")
            }
        }
        
        class GoodChild {
            let name: String
            weak var parent: GoodParent? // Weak reference - breaks cycle!
            
            init(name: String) {
                self.name = name
                print("👶 GoodChild \(name) initialized")
            }
            
            deinit {
                print("👶 GoodChild \(name) deallocated")
            }
        }
        
        var parent: GoodParent? = GoodParent(name: "John")
        var child: GoodChild? = GoodChild(name: "Jane")
        
        // Create relationship without retain cycle
        parent?.children.append(child!)
        child?.parent = parent
        
        // Objects will be deallocated properly
        parent = nil
        child = nil
        
        print("✅ Objects deallocated properly - no memory leak!")
    }
    
    // MARK: - Unowned Reference Example
    func demonstrateUnownedReference() {
        print("\n=== Unowned Reference Example ===")
        
        class Customer9 {
            let name: String
            var card: CreditCard9?
            
            init(name: String) {
                self.name = name
                print("💳 Customer \(name) initialized")
            }
            
            deinit {
                print("💳 Customer \(name) deallocated")
            }
        }
        
        class CreditCard9 {
            let number: UInt64
            unowned let customer: Customer9 // Unowned - customer always exists
            
            init(number: UInt64, customer: Customer9) {
                self.number = number
                self.customer = customer
                print("💳 CreditCard \(number) initialized")
            }
            
            deinit {
                print("💳 CreditCard \(number) deallocated")
            }
        }
        
        var customer: Customer9? = Customer9(name: "Alice")
        customer?.card = CreditCard9(number: 1234_5678_9012_3456, customer: customer!)
        
        // Customer and card will be deallocated together
        customer = nil
        
        print("✅ Both objects deallocated properly")
    }
}

// MARK: - Closure Retain Cycles

class ClosureRetainCycles9 {
    
    var name: String
    var onComplete: (() -> Void)?
    
    init(name: String) {
        self.name = name
        print("🔄 ClosureRetainCycles \(name) initialized")
    }
    
    deinit {
        print("🔄 ClosureRetainCycles \(name) deallocated")
    }
    
    // MARK: - Strong Capture (BAD)
    func demonstrateStrongCapture() {
        print("\n=== Strong Capture in Closures (BAD) ===")
        
        // This creates a retain cycle!
        onComplete = {
            print("Task completed for \(self.name)") // Strong capture of self
        }
        
        // Even setting onComplete to nil won't help because
        // the closure still holds a strong reference to self
        print("❌ Retain cycle created with closure")
    }
    
    // MARK: - Weak Capture (GOOD)
    func demonstrateWeakCapture() {
        print("\n=== Weak Capture in Closures (GOOD) ===")
        
        onComplete = { [weak self] in
            guard let self = self else {
                print("Self was deallocated")
                return
            }
            print("Task completed for \(self.name)")
        }
        
        print("✅ No retain cycle - using weak self")
    }
    
    // MARK: - Unowned Capture
    func demonstrateUnownedCapture() {
        print("\n=== Unowned Capture in Closures ===")
        
        onComplete = { [unowned self] in
            print("Task completed for \(self.name)")
        }
        
        print("✅ No retain cycle - using unowned self")
        print("⚠️ Warning: unowned can crash if self is deallocated")
    }
    
    // MARK: - Capture Lists with Multiple Variables
    func demonstrateCaptureList() {
        print("\n=== Complex Capture Lists ===")
        
        let manager = TaskManager9(name: "MainManager")
        let helper = TaskHelper9(name: "Helper")
        
        onComplete = { [weak self, weak manager, unowned helper] in
            guard let self = self else { return }
            
            print("Task completed for \(self.name)")
            
            if let manager = manager {
                manager.logCompletion()
            } else {
                print("Manager was deallocated")
            }
            
            helper.assist() // Assuming helper always exists
        }
        
        print("✅ Complex capture list with mixed reference types")
    }
}

class TaskManager9 {
    let name: String
    
    init(name: String) {
        self.name = name
        print("📋 TaskManager \(name) initialized")
    }
    
    deinit {
        print("📋 TaskManager \(name) deallocated")
    }
    
    func logCompletion() {
        print("📋 \(name) logged task completion")
    }
}

class TaskHelper9 {
    let name: String
    
    init(name: String) {
        self.name = name
        print("🤝 TaskHelper \(name) initialized")
    }
    
    deinit {
        print("🤝 TaskHelper \(name) deallocated")
    }
    
    func assist() {
        print("🤝 \(name) provided assistance")
    }
}

// MARK: - Combine and Memory Management

class CombineMemoryManagement9: ObservableObject {
    @Published var value = 0
    private var cancellables = Set<AnyCancellable>()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init() {
        print("📡 CombineMemoryManagement initialized")
        setupSubscriptions()
    }
    
    deinit {
        print("📡 CombineMemoryManagement deallocated")
    }
    
    private func setupSubscriptions() {
        // MARK: - Proper Combine Memory Management
        
        // Good: Using weak self to prevent retain cycle
        timer
            .sink { [weak self] _ in
                self?.value += 1
            }
            .store(in: &cancellables)
        
        // Good: Automatic cancellation when cancellables is deallocated
        $value
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                self?.processValue(newValue)
            }
            .store(in: &cancellables)
        
        // Example of potential retain cycle (BAD):
        // timer.sink { _ in
        //     self.value += 1  // Strong capture of self
        // }
    }
    
    private func processValue(_ value: Int) {
        print("📊 Processing value: \(value)")
    }
    
    // Manual cleanup if needed
    func cleanup() {
        cancellables.removeAll()
        print("🧹 Manual cleanup performed")
    }
}

// MARK: - Autorelease Pool

class AutoreleasePoolExamples9 {
    
    func demonstrateAutoreleasePool() {
        print("\n=== Autorelease Pool Examples ===")
        
        // Without autorelease pool - memory builds up
        func processLargeDatasetBad() {
            print("Processing without autorelease pool...")
            
            for i in 0..<1000 {
                let data = NSData(bytes: malloc(1024 * 1024), length: 1024 * 1024) // 1MB
                // Memory accumulates until next runloop cycle
                _ = data.description // Force some processing
                free(UnsafeMutableRawPointer(mutating: data.bytes))
            }
            
            print("❌ Memory peaked during processing")
        }
        
        // With autorelease pool - memory released periodically
        func processLargeDatasetGood() {
            print("Processing with autorelease pool...")
            
            for i in 0..<1000 {
                autoreleasepool {
                    let data = NSData(bytes: malloc(1024 * 1024), length: 1024 * 1024) // 1MB
                    _ = data.description // Force some processing
                    free(UnsafeMutableRawPointer(mutating: data.bytes))
                    // Memory released at end of autoreleasepool block
                }
            }
            
            print("✅ Memory released periodically")
        }
        
        processLargeDatasetBad()
        processLargeDatasetGood()
    }
    
    // Real-world example: Image processing
    func processImagesWithAutoreleasePool(imageURLs: [URL]) {
        print("\n=== Image Processing with Autorelease Pool ===")
        
        for url in imageURLs {
            autoreleasepool {
                // Load and process image
                guard let imageData = try? Data(contentsOf: url) else { return }
                guard let image = UIImage(data: imageData) else { return }
                
                // Perform image processing
                let processedImage = processImage(image)
                
                // Save processed image
                saveProcessedImage(processedImage, url: url)
                
                // Autorelease pool ensures temporary objects are released
                print("📸 Processed image: \(url.lastPathComponent)")
            }
        }
        
        print("✅ All images processed with controlled memory usage")
    }
    
    private func processImage(_ image: UIImage) -> UIImage {
        // Simulate image processing that creates temporary objects
        return image
    }
    
    private func saveProcessedImage(_ image: UIImage, url: URL) {
        // Simulate saving processed image
    }
}

// MARK: - Memory Debugging and Profiling

class MemoryDebugging9 {
    
    private var allocatedObjects: [AnyObject] = []
    
    func demonstrateMemoryDebugging() {
        print("\n=== Memory Debugging Techniques ===")
        
        // 1. Track object allocation
        trackObjectAllocation()
        
        // 2. Monitor memory usage
        printMemoryUsage()
        
        // 3. Detect potential leaks
        detectPotentialLeaks()
        
        // 4. Use weak references for observation
        setupWeakObservation()
    }
    
    private func trackObjectAllocation() {
        print("📊 Tracking object allocation...")
        
        // Create objects and track them
        for i in 0..<100 {
            let obj = TrackableObject9(id: i)
            allocatedObjects.append(obj)
        }
        
        print("Created \(allocatedObjects.count) objects")
        
        // Clear half of them
        allocatedObjects.removeFirst(50)
        
        print("Removed 50 objects, \(allocatedObjects.count) remaining")
    }
    
    private func printMemoryUsage() {
        print("📏 Current memory usage:")
        
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryUsage = info.resident_size / (1024 * 1024) // Convert to MB
            print("💾 Memory usage: \(memoryUsage) MB")
        }
    }
    
    private func detectPotentialLeaks() {
        print("🔍 Detecting potential memory leaks...")
        
        // Create objects that might leak
        let leakyObject = PotentiallyLeakyObject9()
        leakyObject.setupRetainCycle()
        
        // In a real app, you'd use Instruments or similar tools
        print("⚠️ Use Instruments to detect actual leaks in production")
    }
    
    private func setupWeakObservation() {
        print("👁️ Setting up weak observation...")
        
        var strongObject: ObservableObject9? = ObservableObject9(name: "Observed")
        weak var weakObserver = strongObject
        
        print("Strong object exists: \(strongObject != nil)")
        print("Weak observer valid: \(weakObserver != nil)")
        
        strongObject = nil
        
        print("After setting strong to nil:")
        print("Strong object exists: \(strongObject != nil)")
        print("Weak observer valid: \(weakObserver != nil)")
    }
}

class TrackableObject9 {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    deinit {
        print("🗑️ TrackableObject \(id) deallocated")
    }
}

class PotentiallyLeakyObject9 {
    var closure: (() -> Void)?
    
    init() {
        print("⚠️ PotentiallyLeakyObject created")
    }
    
    func setupRetainCycle() {
        // This would create a retain cycle
        closure = {
            print("Closure executed") // Captures self strongly
        }
    }
    
    deinit {
        print("🗑️ PotentiallyLeakyObject deallocated")
    }
}

class ObservableObject9 {
    let name: String
    
    init(name: String) {
        self.name = name
        print("👁️ ObservableObject \(name) created")
    }
    
    deinit {
        print("👁️ ObservableObject \(name) deallocated")
    }
}

// MARK: - Memory Optimization Techniques

class MemoryOptimization9 {
    
    // MARK: - Lazy Loading
    private lazy var expensiveResource: ExpensiveResource9 = {
        print("💰 Creating expensive resource...")
        return ExpensiveResource9()
    }()
    
    // MARK: - Object Pooling
    private var objectPool: [ReusableObject9] = []
    private let maxPoolSize = 10
    
    func demonstrateMemoryOptimization() {
        print("\n=== Memory Optimization Techniques ===")
        
        // 1. Lazy loading
        demonstrateLazyLoading()
        
        // 2. Object pooling
        demonstrateObjectPooling()
        
        // 3. Copy-on-write
        demonstrateCopyOnWrite()
        
        // 4. Memory-mapped files
        demonstrateMemoryMapping()
    }
    
    private func demonstrateLazyLoading() {
        print("📦 Lazy loading demonstration:")
        print("Expensive resource not yet created")
        
        // Resource is created only when first accessed
        let resource = expensiveResource
        print("Now expensive resource is created: \(resource.id)")
    }
    
    private func demonstrateObjectPooling() {
        print("🏊‍♂️ Object pooling demonstration:")
        
        // Get object from pool (or create new one)
        let obj1 = getReusableObject()
        let obj2 = getReusableObject()
        
        print("Got objects: \(obj1.id), \(obj2.id)")
        
        // Return objects to pool
        returnReusableObject(obj1)
        returnReusableObject(obj2)
        
        // Reuse pooled objects
        let obj3 = getReusableObject()
        print("Reused object: \(obj3.id)")
    }
    
    private func getReusableObject() -> ReusableObject9 {
        if let pooledObject = objectPool.popLast() {
            pooledObject.reset()
            print("♻️ Reused object from pool")
            return pooledObject
        } else {
            print("🆕 Created new object")
            return ReusableObject9()
        }
    }
    
    private func returnReusableObject(_ object: ReusableObject9) {
        if objectPool.count < maxPoolSize {
            objectPool.append(object)
            print("📥 Returned object to pool")
        } else {
            print("🗑️ Pool full, object will be deallocated")
        }
    }
    
    private func demonstrateCopyOnWrite() {
        print("📝 Copy-on-write demonstration:")
        
        let buffer1 = CopyOnWriteBuffer9(data: [1, 2, 3, 4, 5])
        let buffer2 = buffer1 // Shares same underlying storage
        
        print("Buffer1 and Buffer2 share storage: \(buffer1.sharesStorage(with: buffer2))")
        
        var mutableBuffer = buffer1
        mutableBuffer.append(6) // Triggers copy
        
        print("After mutation, sharing: \(buffer1.sharesStorage(with: mutableBuffer))")
    }
    
    private func demonstrateMemoryMapping() {
        print("🗺️ Memory mapping demonstration:")
        
        // Create a temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_data.bin")
        let data = Data(repeating: 0xFF, count: 1024 * 1024) // 1MB of data
        
        do {
            try data.write(to: tempURL)
            
            // Memory-map the file
            let mappedData = try Data(contentsOf: tempURL, options: .mappedIfSafe)
            print("📁 Memory-mapped \(mappedData.count) bytes")
            
            // Cleanup
            try FileManager.default.removeItem(at: tempURL)
            
        } catch {
            print("❌ Memory mapping failed: \(error)")
        }
    }
}

class ExpensiveResource9 {
    let id = UUID()
    private let largeData: [Int]
    
    init() {
        // Simulate expensive initialization
        largeData = Array(0..<100000)
        print("💰 ExpensiveResource initialized with \(largeData.count) elements")
    }
    
    deinit {
        print("💰 ExpensiveResource deallocated")
    }
}

class ReusableObject9 {
    let id = UUID()
    private var data: [String] = []
    
    init() {
        print("🔄 ReusableObject \(id) created")
    }
    
    func reset() {
        data.removeAll()
        print("🔄 ReusableObject \(id) reset")
    }
    
    deinit {
        print("🔄 ReusableObject \(id) deallocated")
    }
}

// Copy-on-write buffer implementation
struct CopyOnWriteBuffer9 {
    private var storage: Storage
    
    init(data: [Int]) {
        storage = Storage(data: data)
    }
    
    mutating func append(_ element: Int) {
        if !isKnownUniquelyReferenced(&storage) {
            print("📝 Triggering copy-on-write")
            storage = Storage(data: storage.data)
        }
        storage.data.append(element)
    }
    
    func sharesStorage(with other: CopyOnWriteBuffer9) -> Bool {
        return storage === other.storage
    }
    
    private class Storage {
        var data: [Int]
        
        init(data: [Int]) {
            self.data = data
            print("📦 Storage created with \(data.count) elements")
        }
        
        deinit {
            print("📦 Storage deallocated")
        }
    }
}

// MARK: - Usage Examples

class MemoryManagementUsageExamples9 {
    
    func runAllExamples() {
        print("=== Memory Management Examples ===")
        
        // Basic ARC
        let arcBasics = ARCBasics9(person: Person9(name: "Test"))
        arcBasics.demonstrateReferenceCounting()
        
        // Retain cycles
        let retainCycles = RetainCycleExamples9()
        retainCycles.demonstrateStrongReferenceCycle()
        retainCycles.demonstrateWeakReferenceSolution()
        retainCycles.demonstrateUnownedReference()
        
        // Closure retain cycles
        let closureExample = ClosureRetainCycles9(name: "ClosureTest")
        closureExample.demonstrateStrongCapture()
        closureExample.demonstrateWeakCapture()
        closureExample.demonstrateUnownedCapture()
        closureExample.demonstrateCaptureList()
        
        // Combine memory management
        let combineExample = CombineMemoryManagement9()
        // combineExample will be deallocated and demonstrate proper cleanup
        
        // Autorelease pools
        let autoreleaseExample = AutoreleasePoolExamples9()
        autoreleaseExample.demonstrateAutoreleasePool()
        
        // Memory debugging
        let debuggingExample = MemoryDebugging9()
        debuggingExample.demonstrateMemoryDebugging()
        
        // Memory optimization
        let optimizationExample = MemoryOptimization9()
        optimizationExample.demonstrateMemoryOptimization()
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Automatic Reference Counting (ARC)**:
    - Tracks object references automatically
    - Deallocates objects when reference count reaches zero
    - Strong, weak, and unowned reference types
    - Works at compile time, not runtime

 2. **Reference Types**:
    - Strong: Default, increases retain count
    - Weak: Optional, doesn't increase retain count, becomes nil when object deallocates
    - Unowned: Non-optional, doesn't increase retain count, assumes object exists

 3. **Retain Cycles**:
    - Occur when objects hold strong references to each other
    - Prevent deallocation and cause memory leaks
    - Solved with weak or unowned references
    - Common in parent-child relationships

 4. **Closure Retain Cycles**:
    - Closures capture self strongly by default
    - Use capture lists [weak self] or [unowned self]
    - Guard let pattern for weak self
    - Multiple captures in single capture list

 5. **Memory Management Patterns**:
    - Delegate pattern: weak delegate references
    - Observer pattern: weak observer references
    - Callback closures: weak self capture
    - Timer callbacks: weak target references

 6. **Autorelease Pools**:
    - Manage temporary object lifetime
    - Useful for loops creating many temporary objects
    - Explicit autoreleasepool blocks
    - Automatic in main runloop

 7. **Memory Optimization**:
    - Lazy loading for expensive resources
    - Object pooling for frequently created objects
    - Copy-on-write for shared data structures
    - Memory mapping for large files

 8. **Common Interview Questions**:
    - Q: What is ARC and how does it work?
    - A: Automatic reference counting tracks object references at compile time

    - Q: When do you use weak vs unowned?
    - A: Weak when reference might become nil, unowned when it should always exist

    - Q: How do you break retain cycles?
    - A: Use weak or unowned references, capture lists in closures

    - Q: What causes memory leaks in iOS?
    - A: Retain cycles, strong delegate references, closure captures

 9. **Debugging Memory Issues**:
    - Instruments for leak detection
    - Memory graph debugger
    - Allocation tracking
    - Weak reference monitoring

 10. **Best Practices**:
     - Use weak for delegates and observers
     - Capture weak self in closures
     - Avoid strong reference cycles
     - Use autoreleasepool for batch operations
     - Profile memory usage regularly

 11. **Advanced Concepts**:
     - Copy-on-write optimization
     - Memory mapping for large data
     - Object pooling for performance
     - Lazy initialization patterns
     - Memory pressure handling

 12. **Common Pitfalls**:
     - Forgetting weak self in closures
     - Using unowned when object might be nil
     - Creating retain cycles in data structures
     - Not using autoreleasepool in loops
     - Holding strong references to temporary objects
*/ 