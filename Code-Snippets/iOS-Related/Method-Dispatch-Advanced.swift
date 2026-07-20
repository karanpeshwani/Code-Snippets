//
//  Method-Dispatch-Advanced.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import UIKit

// MARK: - Method Dispatch Types Overview

/*
 Swift has three main types of method dispatch:
 
 1. Static Dispatch (Direct Call):
    - Fastest, resolved at compile time
    - Used for structs, enums, final classes, static methods
    - No runtime overhead
 
 2. Table Dispatch (Virtual Table):
    - Used for class methods, protocol methods
    - Runtime lookup through vtable/witness table
    - Moderate performance overhead
 
 3. Message Dispatch (Objective-C Runtime):
    - Used for @objc methods, NSObject subclasses
    - Slowest, full runtime resolution
    - Most flexible, supports method swizzling
*/

// MARK: - Static Dispatch Examples

struct StaticDispatchExample10 {
    
    // Static dispatch - resolved at compile time
    func performCalculation() -> Int {
        return 42 * 2
    }
    
    // Static dispatch - no inheritance possible
    static func staticMethod() -> String {
        return "Static method called"
    }
    
    // Static dispatch - final prevents overriding
    final func finalMethod() -> String {
        return "Final method called"
    }
}

// Enums also use static dispatch
enum StaticDispatchEnum10 {
    case value1
    case value2
    
    // Static dispatch
    func description() -> String {
        switch self {
        case .value1:
            return "Value 1"
        case .value2:
            return "Value 2"
        }
    }
}

// Extensions use static dispatch by default
extension StaticDispatchExample10 {
    // Static dispatch - cannot be overridden
    func extensionMethod() -> String {
        return "Extension method called"
    }
}

// MARK: - Table Dispatch (Virtual Table) Examples

class BaseClass10 {
    
    // Table dispatch - can be overridden
    func virtualMethod() -> String {
        return "BaseClass virtualMethod"
    }
    
    // Table dispatch - stored in vtable
    func anotherVirtualMethod() -> String {
        return "BaseClass anotherVirtualMethod"
    }
    
    // Static dispatch - cannot be overridden
    final func finalMethod() -> String {
        return "BaseClass finalMethod"
    }
    
    // Static dispatch - class methods use static dispatch
    class func classMethod() -> String {
        return "BaseClass classMethod"
    }
}

class DerivedClass10: BaseClass10 {
    
    // Table dispatch - overrides base implementation
    override func virtualMethod() -> String {
        return "DerivedClass virtualMethod"
    }
    
    // Table dispatch - new implementation
    override func anotherVirtualMethod() -> String {
        return "DerivedClass anotherVirtualMethod"
    }
    
    // Static dispatch - can override class methods
    override class func classMethod() -> String {
        return "DerivedClass classMethod"
    }
}

// MARK: - Protocol Dispatch (Witness Table)

protocol ProtocolWithMethods10 {
    func protocolMethod() -> String
    func anotherProtocolMethod() -> String
}

// Witness table dispatch for protocol methods
struct StructConformingToProtocol10: ProtocolWithMethods10 {
    
    // Witness table dispatch when called through protocol
    func protocolMethod() -> String {
        return "Struct protocolMethod"
    }
    
    // Witness table dispatch when called through protocol
    func anotherProtocolMethod() -> String {
        return "Struct anotherProtocolMethod"
    }
    
    // Static dispatch when called directly on struct
    func structSpecificMethod() -> String {
        return "Struct specific method"
    }
}

class ClassConformingToProtocol10: ProtocolWithMethods10 {
    
    // Table dispatch when called on class
    // Witness table dispatch when called through protocol
    func protocolMethod() -> String {
        return "Class protocolMethod"
    }
    
    func anotherProtocolMethod() -> String {
        return "Class anotherProtocolMethod"
    }
    
    // Table dispatch - can be overridden
    func classSpecificMethod() -> String {
        return "Class specific method"
    }
}

// MARK: - Message Dispatch (@objc and NSObject)

class MessageDispatchExample10: NSObject {
    
    // Message dispatch - uses Objective-C runtime
    @objc func objcMethod() -> String {
        return "Objective-C method"
    }
    
    // Message dispatch - dynamic keyword forces message dispatch
    @objc dynamic func dynamicMethod() -> String {
        return "Dynamic method"
    }
    
    // Table dispatch by default (Swift class method)
    func swiftMethod() -> String {
        return "Swift method"
    }
    
    // Message dispatch - NSObject methods use message dispatch
    override func description() -> String {
        return "MessageDispatchExample instance"
    }
}

// MARK: - Performance Comparison

class PerformanceComparison10 {
    
    private let iterations = 1_000_000
    
    func compareDispatchPerformance() {
        print("=== Method Dispatch Performance Comparison ===")
        
        // Static dispatch performance
        measureStaticDispatch()
        
        // Table dispatch performance
        measureTableDispatch()
        
        // Protocol dispatch performance
        measureProtocolDispatch()
        
        // Message dispatch performance
        measureMessageDispatch()
    }
    
    private func measureStaticDispatch() {
        let struct1 = StaticDispatchExample10()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = struct1.performCalculation()
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("🚀 Static Dispatch: \(String(format: "%.6f", timeElapsed))s")
    }
    
    private func measureTableDispatch() {
        let object: BaseClass10 = DerivedClass10()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = object.virtualMethod()
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("📋 Table Dispatch: \(String(format: "%.6f", timeElapsed))s")
    }
    
    private func measureProtocolDispatch() {
        let object: ProtocolWithMethods10 = StructConformingToProtocol10()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = object.protocolMethod()
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("🔄 Protocol Dispatch: \(String(format: "%.6f", timeElapsed))s")
    }
    
    private func measureMessageDispatch() {
        let object = MessageDispatchExample10()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = object.objcMethod()
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("📨 Message Dispatch: \(String(format: "%.6f", timeElapsed))s")
    }
}

// MARK: - Dispatch Optimization Techniques

class DispatchOptimization10 {
    
    func demonstrateOptimizationTechniques() {
        print("\n=== Dispatch Optimization Techniques ===")
        
        // 1. Using final to enable static dispatch
        demonstrateFinalOptimization()
        
        // 2. Using private to enable static dispatch
        demonstratePrivateOptimization()
        
        // 3. Whole Module Optimization
        demonstrateWMOOptimization()
        
        // 4. Protocol optimization
        demonstrateProtocolOptimization()
    }
    
    private func demonstrateFinalOptimization() {
        print("🔒 Final keyword optimization:")
        
        class OptimizedClass10 {
            // Table dispatch - can be overridden
            func regularMethod() -> String {
                return "Regular method"
            }
            
            // Static dispatch - cannot be overridden
            final func finalMethod() -> String {
                return "Final method"
            }
        }
        
        let obj = OptimizedClass10()
        
        // Measure performance difference
        let iterations = 100_000
        
        // Regular method (table dispatch)
        let start1 = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            _ = obj.regularMethod()
        }
        let time1 = CFAbsoluteTimeGetCurrent() - start1
        
        // Final method (static dispatch)
        let start2 = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            _ = obj.finalMethod()
        }
        let time2 = CFAbsoluteTimeGetCurrent() - start2
        
        print("Regular method: \(String(format: "%.6f", time1))s")
        print("Final method: \(String(format: "%.6f", time2))s")
        print("Speedup: \(String(format: "%.2f", time1/time2))x")
    }
    
    private func demonstratePrivateOptimization() {
        print("\n🔐 Private method optimization:")
        
        class PrivateOptimizedClass10 {
            // Private methods can be optimized to static dispatch
            // if the compiler can prove they're not overridden
            private func privateMethod() -> String {
                return "Private method"
            }
            
            func callPrivateMethod() -> String {
                return privateMethod()
            }
        }
        
        let obj = PrivateOptimizedClass10()
        _ = obj.callPrivateMethod()
        
        print("✅ Private methods can be optimized to static dispatch")
    }
    
    private func demonstrateWMOOptimization() {
        print("\n🌍 Whole Module Optimization (WMO):")
        
        // With WMO, the compiler can see all uses of a method
        // and optimize accordingly
        print("📊 WMO enables cross-file optimizations")
        print("🚀 Methods with no overrides can use static dispatch")
        print("⚡ Inlining across file boundaries")
        print("🔍 Dead code elimination")
    }
    
    private func demonstrateProtocolOptimization() {
        print("\n🔄 Protocol optimization techniques:")
        
        // Generic protocols can be optimized
        func genericProtocolCall<T: ProtocolWithMethods10>(_ obj: T) -> String {
            // This can be optimized to static dispatch in some cases
            return obj.protocolMethod()
        }
        
        let structObj = StructConformingToProtocol10()
        _ = genericProtocolCall(structObj)
        
        print("✅ Generic protocol calls can be optimized")
        print("🚀 Specialized versions created for each concrete type")
    }
}

// MARK: - Advanced Dispatch Scenarios

class AdvancedDispatchScenarios10 {
    
    func demonstrateAdvancedScenarios() {
        print("\n=== Advanced Dispatch Scenarios ===")
        
        // 1. Mixed dispatch in inheritance hierarchy
        demonstrateMixedDispatch()
        
        // 2. Protocol extensions and dispatch
        demonstrateProtocolExtensionDispatch()
        
        // 3. Generic specialization
        demonstrateGenericSpecialization()
        
        // 4. Existential containers
        demonstrateExistentialContainers()
    }
    
    private func demonstrateMixedDispatch() {
        print("🔀 Mixed dispatch in inheritance:")
        
        class MixedDispatchBase10 {
            func virtualMethod() -> String { return "Base virtual" }
            final func finalMethod() -> String { return "Base final" }
            @objc func objcMethod() -> String { return "Base objc" }
        }
        
        class MixedDispatchDerived10: MixedDispatchBase10 {
            override func virtualMethod() -> String { return "Derived virtual" }
            // Cannot override final method
            @objc override func objcMethod() -> String { return "Derived objc" }
        }
        
        let obj: MixedDispatchBase10 = MixedDispatchDerived10()
        
        print("Virtual: \(obj.virtualMethod())") // Table dispatch
        print("Final: \(obj.finalMethod())")     // Static dispatch
        print("ObjC: \(obj.objcMethod())")       // Message dispatch
    }
    
    private func demonstrateProtocolExtensionDispatch() {
        print("\n📋 Protocol extension dispatch:")
        
        protocol ExtendedProtocol10 {
            func protocolMethod() -> String
        }
        
        extension ExtendedProtocol10 {
            // Default implementation
            func protocolMethod() -> String {
                return "Default implementation"
            }
            
            // Extension method
            func extensionMethod() -> String {
                return "Extension method"
            }
        }
        
        struct ConformingStruct10: ExtendedProtocol10 {
            // Override protocol method
            func protocolMethod() -> String {
                return "Struct implementation"
            }
            
            // This method exists but won't be called through protocol!
            func extensionMethod() -> String {
                return "Struct extension method"
            }
        }
        
        let obj = ConformingStruct10()
        let protocolObj: ExtendedProtocol10 = obj
        
        print("Direct call: \(obj.extensionMethod())")
        print("Protocol call: \(protocolObj.extensionMethod())")
        
        print("⚠️ Protocol extension methods use static dispatch!")
        print("🔍 Only methods declared in protocol use witness table")
    }
    
    private func demonstrateGenericSpecialization() {
        print("\n🧬 Generic specialization:")
        
        func genericFunction<T: ProtocolWithMethods10>(_ obj: T) -> String {
            return obj.protocolMethod()
        }
        
        // The compiler can create specialized versions
        let structObj = StructConformingToProtocol10()
        let classObj = ClassConformingToProtocol10()
        
        _ = genericFunction(structObj) // Specialized for struct
        _ = genericFunction(classObj)  // Specialized for class
        
        print("✅ Compiler creates specialized versions for each type")
        print("🚀 Can optimize to static dispatch in specialized versions")
    }
    
    private func demonstrateExistentialContainers() {
        print("\n📦 Existential containers:")
        
        // Protocol type (existential container)
        let protocolArray: [ProtocolWithMethods10] = [
            StructConformingToProtocol10(),
            ClassConformingToProtocol10()
        ]
        
        // Each call goes through witness table
        for obj in protocolArray {
            _ = obj.protocolMethod() // Witness table dispatch
        }
        
        print("📋 Existential containers use witness tables")
        print("💾 Larger memory footprint for value types")
        print("🔄 Runtime type information stored")
    }
}

// MARK: - Real-World Dispatch Examples

// Example: Network client with different dispatch types
protocol NetworkClient10 {
    func performRequest() -> String
}

// Static dispatch implementation
struct StaticNetworkClient10: NetworkClient10 {
    func performRequest() -> String {
        return "Static network request"
    }
    
    // Static dispatch - struct method
    func cacheResponse() {
        print("Caching response")
    }
}

// Table dispatch implementation
class DynamicNetworkClient10: NetworkClient10 {
    func performRequest() -> String {
        return "Dynamic network request"
    }
    
    // Table dispatch - can be overridden
    func handleError() {
        print("Handling error")
    }
}

class SecureNetworkClient10: DynamicNetworkClient10 {
    override func performRequest() -> String {
        return "Secure network request"
    }
    
    override func handleError() {
        print("Handling secure error")
    }
}

// Message dispatch implementation
class ObjCNetworkClient10: NSObject, NetworkClient10 {
    @objc func performRequest() -> String {
        return "ObjC network request"
    }
    
    @objc dynamic func logRequest() {
        print("Logging request")
    }
}

// MARK: - Dispatch Analysis Tools

class DispatchAnalysis10 {
    
    func analyzeDispatchTypes() {
        print("\n=== Dispatch Type Analysis ===")
        
        // Create instances
        let staticClient = StaticNetworkClient10()
        let dynamicClient: DynamicNetworkClient10 = SecureNetworkClient10()
        let objcClient = ObjCNetworkClient10()
        
        // Protocol array (witness table dispatch)
        let clients: [NetworkClient10] = [staticClient, dynamicClient, objcClient]
        
        print("📊 Analyzing dispatch for each client type:")
        
        for (index, client) in clients.enumerated() {
            let result = client.performRequest()
            print("Client \(index): \(result)")
        }
        
        // Direct calls (different dispatch types)
        print("\n🔍 Direct method calls:")
        staticClient.cacheResponse()    // Static dispatch
        dynamicClient.handleError()     // Table dispatch
        objcClient.logRequest()         // Message dispatch
    }
    
    func demonstrateDispatchOverhead() {
        print("\n⚡ Dispatch overhead demonstration:")
        
        let iterations = 1_000_000
        
        // Static dispatch
        let staticClient = StaticNetworkClient10()
        let start1 = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            _ = staticClient.performRequest()
        }
        let staticTime = CFAbsoluteTimeGetCurrent() - start1
        
        // Table dispatch
        let dynamicClient: DynamicNetworkClient10 = SecureNetworkClient10()
        let start2 = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            _ = dynamicClient.performRequest()
        }
        let tableTime = CFAbsoluteTimeGetCurrent() - start2
        
        // Protocol dispatch
        let protocolClient: NetworkClient10 = StaticNetworkClient10()
        let start3 = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            _ = protocolClient.performRequest()
        }
        let protocolTime = CFAbsoluteTimeGetCurrent() - start3
        
        // Message dispatch
        let objcClient = ObjCNetworkClient10()
        let start4 = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            _ = objcClient.performRequest()
        }
        let messageTime = CFAbsoluteTimeGetCurrent() - start4
        
        print("Static dispatch: \(String(format: "%.6f", staticTime))s")
        print("Table dispatch: \(String(format: "%.6f", tableTime))s")
        print("Protocol dispatch: \(String(format: "%.6f", protocolTime))s")
        print("Message dispatch: \(String(format: "%.6f", messageTime))s")
        
        print("\nRelative performance (static = 1.0x):")
        print("Table: \(String(format: "%.2f", tableTime/staticTime))x")
        print("Protocol: \(String(format: "%.2f", protocolTime/staticTime))x")
        print("Message: \(String(format: "%.2f", messageTime/staticTime))x")
    }
}

// MARK: - Usage Examples

class MethodDispatchUsageExamples10 {
    
    func runAllExamples() {
        print("=== Method Dispatch Examples ===")
        
        // Performance comparison
        let performance = PerformanceComparison10()
        performance.compareDispatchPerformance()
        
        // Optimization techniques
        let optimization = DispatchOptimization10()
        optimization.demonstrateOptimizationTechniques()
        
        // Advanced scenarios
        let advanced = AdvancedDispatchScenarios10()
        advanced.demonstrateAdvancedScenarios()
        
        // Real-world analysis
        let analysis = DispatchAnalysis10()
        analysis.analyzeDispatchTypes()
        analysis.demonstrateDispatchOverhead()
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Three Types of Method Dispatch**:
    - Static Dispatch: Compile-time resolution, fastest
    - Table Dispatch: Runtime vtable lookup, moderate overhead
    - Message Dispatch: Objective-C runtime, slowest but most flexible

 2. **Static Dispatch**:
    - Used for: structs, enums, final classes, static methods, extensions
    - Resolved at compile time
    - No runtime overhead
    - Enables inlining and other optimizations

 3. **Table Dispatch (Virtual Table)**:
    - Used for: class methods, protocol methods
    - Runtime lookup through vtable or witness table
    - Moderate performance overhead
    - Supports polymorphism

 4. **Message Dispatch**:
    - Used for: @objc methods, NSObject subclasses
    - Uses Objective-C runtime
    - Slowest but most flexible
    - Supports method swizzling and runtime introspection

 5. **Performance Implications**:
    - Static > Table > Message (performance order)
    - Static dispatch can be inlined
    - Table dispatch has predictable overhead
    - Message dispatch has variable overhead

 6. **Optimization Techniques**:
    - Use `final` keyword to enable static dispatch
    - Use `private` for methods that won't be overridden
    - Whole Module Optimization (WMO) enables cross-file optimizations
    - Generic specialization can optimize protocol calls

 7. **Protocol Dispatch**:
    - Protocol methods use witness tables
    - Protocol extensions use static dispatch
    - Existential containers have memory overhead
    - Generic constraints can enable specialization

 8. **Common Interview Questions**:
    - Q: What are the types of method dispatch in Swift?
    - A: Static, Table (vtable), and Message dispatch

    - Q: When does Swift use static dispatch?
    - A: Structs, enums, final methods, static methods, extensions

    - Q: How can you optimize method dispatch?
    - A: Use final, private, WMO, avoid protocol types when possible

    - Q: What's the performance difference between dispatch types?
    - A: Static is fastest, table is moderate, message is slowest

 9. **Advanced Concepts**:
    - Witness tables for protocol conformance
    - Generic specialization and monomorphization
    - Existential containers for protocol types
    - Method inlining and devirtualization

 10. **Best Practices**:
     - Use final for classes that won't be subclassed
     - Prefer structs over classes when possible
     - Use private for internal methods
     - Enable Whole Module Optimization
     - Be mindful of protocol type overhead

 11. **Debugging and Analysis**:
     - Use SIL (Swift Intermediate Language) to analyze dispatch
     - Profile performance-critical code
     - Understand when protocols create overhead
     - Use Instruments to measure actual performance

 12. **Common Pitfalls**:
     - Assuming all method calls have same performance
     - Not understanding protocol extension dispatch
     - Overusing protocol types in performance-critical code
     - Not leveraging final keyword for optimization
     - Mixing dispatch types without understanding implications
*/ 