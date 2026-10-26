//
//  Class-Vs-Struct.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 24/06/26.
//

import Foundation

// MARK: - Basic Definitions & Mutability
class ClassVsStructDemo {
    
    // 1. Value Type vs Reference Type
    struct CarStruct {
        var make: String
        var year: Int
        
        // Structs require `mutating` keyword to modify their properties in instance methods
        mutating func updateYear(to newYear: Int) {
            self.year = newYear
        }
    }
    
    class CarClass {
        var make: String
        var year: Int
        
        // Classes must explicitly define an initializer if properties don't have default values
        init(make: String, year: Int) {
            self.make = make
            self.year = year
        }
        
        // Classes do not need `mutating` keyword
        func updateYear(to newYear: Int) {
            self.year = newYear
        }
    }
    
    func demonstrateValueVsReference() {
        print("=== Value Type (Struct) Demo ===")
        var myStruct1 = CarStruct(make: "Tesla", year: 2022) // Memberwise initializer automatically provided
        var myStruct2 = myStruct1 // A COPY is created
        
        myStruct2.year = 2024
        print("myStruct1 year: \(myStruct1.year)") // 2022
        print("myStruct2 year: \(myStruct2.year)") // 2024
        
        print("\n=== Reference Type (Class) Demo ===")
        let myClass1 = CarClass(make: "Honda", year: 2022)
        let myClass2 = myClass1 // Reference is copied, both point to same memory address
        
        myClass2.year = 2024
        print("myClass1 year: \(myClass1.year)") // 2024
        print("myClass2 year: \(myClass2.year)") // 2024
    }
}

// MARK: - Initializer Synthesis
struct UserStruct {
    let id: UUID
    var name: String
    
    // Swift automatically synthesizes a memberwise initializer:
    // init(id: UUID, name: String)
}

class UserClass {
    let id: UUID
    var name: String
    
    // Error without this: Class 'UserClass' has no initializers
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - Equatable & Hashable Synthesis
// Structs automatically get Equatable & Hashable synthesis if all properties conform to them.
struct PointStruct: Hashable {
    let x: Int
    let y: Int
}

// Classes DO NOT get automatic synthesis. You must write it manually.
class PointClass: Hashable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func == (lhs: PointClass, rhs: PointClass) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

// MARK: - Inheritance & Deinitializers
class Vehicle {
    var speed: Double
    init(speed: Double) {
        self.speed = speed
    }
    
    deinit {
        // Classes have deinitializers called when reference count reaches 0
        print("Vehicle is being deinitialized")
    }
}

// Classes support Inheritance
class Bike: Vehicle {
    var hasBell: Bool
    
    init(speed: Double, hasBell: Bool) {
        self.hasBell = hasBell
        super.init(speed: speed)
    }
}

// Structs CANNOT inherit from other structs or classes. 
// They can only adopt Protocols.
protocol Drivable {
    var speed: Double { get set }
}

struct Scooter: Drivable {
    var speed: Double
    // Structs DO NOT have deinitializers.
}

// MARK: - Identity Operators (===)
class PersonNode {
    let name: String
    init(name: String) { self.name = name }
}

func demonstrateIdentityOperator() {
    let person1 = PersonNode(name: "Alice")
    let person2 = person1
    let person3 = PersonNode(name: "Alice")
    
    // '===' checks if two variables point to the exact same memory address (Reference Identity)
    print(person1 === person2) // true
    print(person1 === person3) // false
    
    // Structs don't have '===' because they don't have reference identity.
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED (FAANG / GOOGLE):

 1. **Value vs Reference Types (The fundamental difference)**:
    - **Structs (Value Types)**: Copied when assigned to a new variable or passed into a function. Modifications to the copy don't affect the original.
    - **Classes (Reference Types)**: Passed by reference. Multiple variables can point to the same instance in memory. Modifications reflect everywhere.

 2. **Memory Allocation (Stack vs Heap)**:
    - **Structs**: Generally allocated on the Stack, which is fast and cheap. (Exceptions: when a struct contains reference types, or is captured in escaping closures, or wrapped in an existential/protocol container).
    - **Classes**: Allocated on the Heap. Requires memory allocation overhead and reference counting (ARC) overhead, which makes them slower to create and destroy than simple structs.

 3. **Method Dispatch (Static vs Dynamic)**:
    - **Structs**: Use Static Dispatch (Direct Dispatch) by default. Extremely fast because the compiler knows exactly which function to call at compile time.
    - **Classes**: Use Dynamic Dispatch (V-Table Dispatch) to support inheritance and overriding. Slower than static dispatch. (Using `final` class keyword can devirtualize it to static dispatch).

 4. **Inheritance**:
    - **Structs**: Cannot inherit from other structs. Use Protocol-Oriented Programming (POP) for sharing behavior.
    - **Classes**: Support inheritance. Allow creating base classes and subclasses.

 5. **Synthesis (Init, Hashable, Equatable)**:
    - **Structs**: Swift automatically provides a memberwise initializer. It also auto-synthesizes `Equatable`, `Hashable`, and `Codable` if all stored properties conform to them.
    - **Classes**: Require explicit initializers (if no defaults). Do NOT auto-synthesize `Equatable` or `Hashable`, you must manually implement `==` and `hash(into:)`.

 6. **Mutability (`mutating` keyword)**:
    - **Structs**: Need the `mutating` keyword on methods that modify their properties. If you declare a struct instance as `let`, you cannot modify any properties, even if they are declared as `var` inside the struct.
    - **Classes**: Can mutate properties inside methods without any special keyword. Even if a class instance is declared as `let`, you can still modify its `var` properties (the reference is constant, not the data).

 7. **Deinitializers (`deinit`)**:
    - **Structs**: No deinit. Memory is freed as soon as it pops off the stack.
    - **Classes**: Have `deinit` to execute cleanup code before ARC frees the heap memory.

 8. **Thread Safety & State Management**:
    - **Structs**: Inherently safer for concurrent environments because passing them around creates copies. Prevents shared mutable state data races (though mutating a single struct variable from multiple threads simultaneously is still a data race).
    - **Classes**: Highly prone to race conditions if multiple threads modify the shared instance. Require synchronization (DispatchQueue, Actors, NSLock) to be thread-safe.

 9. **Google Interview Tips**:
    - **"When to use which?"**: Default to Structs. Only use Classes when you NEED reference semantics (shared state, identity `===`), objective-c interoperability (`@objc`), or inheritance.
    - Be ready to discuss the performance implications of ARC overhead and Heap allocation vs Stack allocation.
    - Mention Protocol-Oriented Programming (POP) as Swift's alternative to Class inheritance.
*/
