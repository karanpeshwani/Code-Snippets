//
//  Swift-Some-Keyword-Opaque-Types.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 26/10/26.
//

import Foundation
import SwiftUI

// =============================================================================
// MARK: - 1. Protocol Foundation
// =============================================================================

/// A baseline protocol representing an animal.
/// Protocols define a blueprint of methods, properties, and other requirements.
protocol Animal {
    var name: String { get }
    func makeSound() -> String
}

/// A concrete type conforming to `Animal`.
struct Dog: Animal {
    let name: String
    
    init(name: String = "Dog") {
        self.name = name
    }
    
    func makeSound() -> String {
        return "Woof!"
    }
    
    /// Dog-specific method not declared in `Animal`.
    func fetchBall() -> String {
        return "\(name) fetched the ball!"
    }
}

/// Another concrete type conforming to `Animal`.
struct Cat: Animal {
    let name: String
    
    init(name: String = "Cat") {
        self.name = name
    }
    
    func makeSound() -> String {
        return "Meow!"
    }
    
    /// Cat-specific method not declared in `Animal`.
    func climbTree() -> String {
        return "\(name) climbed a tree!"
    }
}

/// A third concrete type conforming to `Animal`.
struct Bird: Animal {
    let name: String
    
    init(name: String = "Bird") {
        self.name = name
    }
    
    func makeSound() -> String {
        return "Chirp!"
    }
}


// =============================================================================
// MARK: - 2. Using `some` as a Function Return Type (Opaque Return Types - SE-0244)
// =============================================================================

class OpaqueReturnTypeDemo {
    
    // MARK: - Basic Opaque Return Type
    /// Returns a specific underlying type conforming to `Animal`.
    /// The caller only knows it conforms to `Animal`, but the concrete type
    /// (`Dog`) is hidden from the public API while preserving type identity.
    func makeAnimal() -> some Animal {
        return Dog(name: "Buddy")
    }
    
    // MARK: - Why Hide the Concrete Type?
    /// 1. Encapsulation: Prevents clients from depending on internal concrete types.
    /// 2. Flexibility: You can change the underlying return type later without breaking the public API contract.
    /// 3. Performance: The compiler knows the exact concrete type at compile time,
    ///    enabling full static optimization, inlining, and zero boxing overhead.
    func makeSecretAnimal() -> some Animal {
        // We could swap this with another type tomorrow, provided all returns remain that same type.
        return Dog(name: "Undercover Dog")
    }
    
    // MARK: - The Golden Rule: `some` Must Return ONE Underlying Type Across All Branches
    
    // ❌ COMPILE ERROR (Commented out):
    // The code below does NOT compile because Swift requires opaque return types
    // to resolve to a SINGLE concrete type known at compile time.
    /*
    func invalidConditionalAnimal(isDog: Bool) -> some Animal {
        if isDog {
            return Dog(name: "Buddy")
        } else {
            return Cat(name: "Whiskers") // Error: Return statements have mismatching underlying types!
        }
    }
    */
    
    // ✅ VALID CONDITIONAL WITH `some`:
    // Different branches are allowed, but ALL return statements MUST evaluate
    // to the EXACT SAME underlying concrete type (here: `Dog`).
    func validConditionalAnimal(isPuppy: Bool) -> some Animal {
        if isPuppy {
            return Dog(name: "Little Puppy")
        } else {
            return Dog(name: "Grown-Up Dog")
        }
    }
    
    func demonstrate() {
        print("\n--- 2. Opaque Return Type Demonstration ---")
        let animal = makeAnimal()
        print("Created animal: \(animal.name), sound: \(animal.makeSound())")
        
        // ❌ The caller CANNOT call Dog-specific methods through the opaque interface:
        // animal.fetchBall() // Compile Error: Value of type 'some Animal' has no member 'fetchBall'
        
        let conditionalPet = validConditionalAnimal(isPuppy: true)
        print("Conditional pet: \(conditionalPet.name), sound: \(conditionalPet.makeSound())")
    }
}


// =============================================================================
// MARK: - 3. Using `some` as a Function Parameter (Swift 5.7+ / SE-0341)
// =============================================================================

class OpaqueParameterTypeDemo {
    
    // MARK: - `some` in Parameter Position
    /// Since Swift 5.7, `some` can be used in parameter positions.
    /// It serves as concise shorthand for an unnamed generic parameter.
    func describeAnimal(_ animal: some Animal) {
        print("[\(type(of: animal))] \(animal.name) says: \(animal.makeSound())")
    }
    
    // MARK: - Equivalent Named Generic Function
    /// The function above is functionally equivalent to this generic declaration:
    func describeAnimalGeneric<T: Animal>(_ animal: T) {
        print("[\(type(of: animal))] \(animal.name) says: \(animal.makeSound())")
    }
    
    // MARK: - Key Difference: Multiple Parameters
    
    /// Case A: Independent opaque parameters.
    /// Each occurrence of `some` introduces its OWN independent unnamed generic type parameter!
    /// Under the hood: `func compareIndependent<T: Animal, U: Animal>(_ first: T, _ second: U)`
    /// This allows passing two DIFFERENT concrete types (e.g. Dog and Cat).
    func compareIndependent(_ first: some Animal, _ second: some Animal) {
        print("Comparing independent types: \(type(of: first)) (\(first.name)) vs \(type(of: second)) (\(second.name))")
    }
    
    /// Case B: Shared named generic parameter.
    /// Uses a single generic type `T`. Both arguments MUST have the EXACT SAME concrete type!
    func compareIdentical<T: Animal>(_ first: T, _ second: T) {
        print("Comparing identical types: Both are \(T.self) -> '\(first.name)' and '\(second.name)'")
    }
    
    func demonstrate() {
        print("\n--- 3. Opaque Parameter Type Demonstration ---")
        let dog = Dog(name: "Rex")
        let cat = Cat(name: "Milo")
        
        // Parameter `some` accepts different types across different calls:
        describeAnimal(dog)
        describeAnimal(cat)
        
        // Passing different concrete types to independent `some` parameters:
        compareIndependent(dog, cat) // ✅ Allowed: first is Dog, second is Cat
        
        // Passing matching types to shared generic parameter:
        compareIdentical(Dog(name: "Rex"), Dog(name: "Buddy")) // ✅ Allowed
        
        // ❌ Not allowed:
        // compareIdentical(dog, cat) // Compile Error: Conflicting arguments to generic parameter 'T' ('Dog' vs. 'Cat')
    }
}


// =============================================================================
// MARK: - 4. `some` in SwiftUI (`var body: some View`)
// =============================================================================

/// Why does SwiftUI use `some View`?
///
/// SwiftUI views are constructed through deep generic composition and view modifiers.
/// Without `some View`, you would have to write out the full, nested, monstrous return type:
///
/// Example:
/// ModifiedContent<VStack<TupleView<(Text, ModifiedContent<Image, _PaddingLayout>)>>, _BackgroundModifier<Color>>
///
/// `some View` solves this by:
/// 1. Promising that the return value conforms to `View`.
/// 2. Hiding the complex, verbose, and internal composite type hierarchy from the API.
/// 3. Preserving the exact concrete type for SwiftUI's internal diffing and state management.
struct SimpleSwiftUIDemoView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Hello, SwiftUI!")
                .font(.headline)
            Text("Powered by 'some View'")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}


// =============================================================================
// MARK: - 5. The SwiftUI Conditional Mystery: Why Does `if/else` Work in `body`?
// =============================================================================

/// The Question:
/// If `some` strictly requires a single concrete return type, why does this compile in SwiftUI?
///
/// ```swift
/// if isText {
///     Text("I am a text")
/// } else {
///     Image(systemName: "star")
/// }
/// ```
///
/// The Answer:
/// SwiftUI uses Result Builders—specifically `@ViewBuilder`.
///
/// The `@ViewBuilder` attribute transforms the `if / else` statement into a SINGLE composite type:
/// `_ConditionalContent<Text, Image>`
///
/// Under the hood, SwiftUI generates calls to:
/// - `ViewBuilder.buildEither(first:)`  -> returns `_ConditionalContent<TrueContent, FalseContent>`
/// - `ViewBuilder.buildEither(second:)` -> returns `_ConditionalContent<TrueContent, FalseContent>`
///
/// Therefore, the function STILL returns ONE single concrete type at compile time!
/// The underlying type is `_ConditionalContent<Text, Image>`, which itself conforms to `View`.
/// The rule of `some View` is NEVER violated!

class ConditionalViewBuilderExplanation {
    
    // ❌ Ordinary Swift function without @ViewBuilder will NOT compile with if/else:
    /*
    func makeViewOrdinary(isText: Bool) -> some View {
        if isText {
            return Text("I am a text")
        } else {
            return Image(systemName: "star") // ❌ Error: Return statements have mismatching underlying types!
        }
    }
    */
    
    // ✅ With @ViewBuilder, it compiles perfectly!
    // Notice that explicit `return` statements are removed because the result builder transforms the statements.
    @ViewBuilder
    static func makeConditionalView(isText: Bool) -> some View {
        if isText {
            Text("I am a text")
                .foregroundColor(.blue)
        } else {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        }
    }
}

/// Interactive SwiftUI View demonstrating conditional views and `@ViewBuilder`.
struct ContentView_SomeKeywordDemo: View {
    @State private var isText: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            Text("SwiftUI Conditional & @ViewBuilder")
                .font(.title2)
                .bold()
            
            Button(action: {
                withAnimation {
                    isText.toggle()
                }
            }) {
                Text("Toggle Condition (Current: \(isText ? "Text" : "Image"))")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Divider()
            
            // 1. Direct if/else inside ViewBuilder closure:
            // Under the hood, this compiles to: _ConditionalContent<Text, Image>
            if isText {
                Text("I am a text")
                    .font(.headline)
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            Divider()
            
            // 2. Calling a helper function annotated with @ViewBuilder:
            ConditionalViewBuilderExplanation.makeConditionalView(isText: isText)
        }
        .padding()
    }
}


// =============================================================================
// MARK: - 6. Behind the Scenes: Custom Result Builder Analogy (`AnimalBuilder`)
// =============================================================================

/// To understand how SwiftUI's `@ViewBuilder` creates a single concrete type from `if / else`,
/// let's build the exact same pattern ourselves for `Animal`!

/// A composite type that holds either the first animal or the second animal.
/// This mirrors SwiftUI's internal `_ConditionalContent<First, Second>`.
enum EitherAnimal<First: Animal, Second: Animal>: Animal {
    case first(First)
    case second(Second)
    
    var name: String {
        switch self {
        case .first(let animal): return animal.name
        case .second(let animal): return animal.name
        }
    }
    
    func makeSound() -> String {
        switch self {
        case .first(let animal): return animal.makeSound()
        case .second(let animal): return animal.makeSound()
        }
    }
}

/// A custom `@resultBuilder` that enables `if/else` branching for `some Animal`.
@resultBuilder
struct AnimalBuilder {
    /// Handles a single statement
    static func buildBlock<T: Animal>(_ component: T) -> T {
        return component
    }
    
    /// Handles the 'true' branch of an if/else
    static func buildEither<First: Animal, Second: Animal>(first component: First) -> EitherAnimal<First, Second> {
        return .first(component)
    }
    
    /// Handles the 'false' branch of an if/else
    static func buildEither<First: Animal, Second: Animal>(second component: Second) -> EitherAnimal<First, Second> {
        return .second(component)
    }
}

class CustomResultBuilderDemo {
    
    /// Using `@AnimalBuilder`, this function returns `some Animal` even with `if / else`!
    /// The underlying concrete return type is `EitherAnimal<Dog, Cat>`.
    @AnimalBuilder
    static func makeBuilderAnimal(isDog: Bool) -> some Animal {
        if isDog {
            Dog(name: "Builder Pup")
        } else {
            Cat(name: "Builder Kitty")
        }
    }
    
    static func demonstrate() {
        print("\n--- 6. Custom Result Builder Analogy ---")
        let animal1 = makeBuilderAnimal(isDog: true)
        print("Result builder (true branch):  \(animal1.name) says \(animal1.makeSound())")
        
        let animal2 = makeBuilderAnimal(isDog: false)
        print("Result builder (false branch): \(animal2.name) says \(animal2.makeSound())")
        print("Underlying concrete type is: \(type(of: animal1))")
    }
}


// =============================================================================
// MARK: - 7. `some` vs `any` (Opaque Types vs Existential Boxed Types)
// =============================================================================

class SomeVsAnyDemo {
    
    func makeDog() -> some Animal {
        Dog(name: "Max")
    }
    
    func makeAnotherDog() -> some Animal {
        // Returns the same underlying Dog type as makeDog:
        // But in Swift, each function with an opaque return type defines its OWN distinct opaque type identity!
        Dog(name: "Rocky")
    }
    
    func makeCat() -> some Animal {
        Cat(name: "Luna")
    }
    
    func demonstrate() {
        print("\n--- 7. 'some' vs 'any' Comparison ---")
        
        // -------------------------------------------------------------
        // 1. `some Animal` (Opaque Type)
        // -------------------------------------------------------------
        // - A specific, fixed underlying concrete type known to the compiler.
        // - The type identity is preserved and strictly enforced.
        // - Can be reassigned to another value from the SAME opaque source:
        var opaqueAnimal = makeDog()
        print("some Animal initial: \(opaqueAnimal.name) -> \(opaqueAnimal.makeSound())")
        
        opaqueAnimal = makeDog() // ✅ Allowed: exactly identical opaque type identity
        
        // ❌ We CANNOT reassign it to makeCat() (even though Cat conforms to Animal):
        // opaqueAnimal = makeCat() // Compile Error: type mismatch!
        
        // ❌ We CANNOT reassign an opaque variable to an arbitrary concrete Cat:
        // let fixedOpaque: some Animal = Dog(name: "Spot")
        // fixedOpaque = Cat(name: "Whiskers") // Compile Error: Cannot reassign to different type
        
        // -------------------------------------------------------------
        // 2. `any Animal` (Existential Boxed Type)
        // -------------------------------------------------------------
        // - An existential container box capable of holding ANY type conforming to Animal.
        // - The specific concrete type is erased at compile time and inspected via dynamic dispatch.
        // - CAN be dynamically reassigned to different concrete types at runtime!
        var existentialAnimal: any Animal = Dog(name: "Buddy")
        print("any Animal (holding Dog): \(existentialAnimal.name) -> \(existentialAnimal.makeSound())")
        
        // Dynamically reassigning to Cat:
        existentialAnimal = Cat(name: "Luna") // ✅ Allowed!
        print("any Animal (now holding Cat): \(existentialAnimal.name) -> \(existentialAnimal.makeSound())")
        
        // Dynamically reassigning to Bird:
        existentialAnimal = Bird(name: "Robin") // ✅ Allowed!
        print("any Animal (now holding Bird): \(existentialAnimal.name) -> \(existentialAnimal.makeSound())")
        
        // -------------------------------------------------------------
        // 3. Heterogeneous Collections
        // -------------------------------------------------------------
        // You cannot create an array of varying types using `[some Animal]`.
        // But `[any Animal]` is specifically designed for heterogeneous collections!
        let petCollection: [any Animal] = [
            Dog(name: "Charlie"),
            Cat(name: "Oliver"),
            Bird(name: "Tweety")
        ]
        
        print("\nHeterogeneous Array of [any Animal]:")
        for pet in petCollection {
            print(" - \(pet.name) (type: \(type(of: pet))) says: \(pet.makeSound())")
        }
        
        // -------------------------------------------------------------
        // 4. Returning `any Animal` conditionally
        // -------------------------------------------------------------
        let dynamicPet1 = makeExistentialAnimal(isDog: true)
        let dynamicPet2 = makeExistentialAnimal(isDog: false)
        print("\nFunction returning 'any Animal':")
        print(" - Is Dog: \(dynamicPet1.name) says \(dynamicPet1.makeSound())")
        print(" - Is Cat: \(dynamicPet2.name) says \(dynamicPet2.makeSound())")
    }
    
    /// With `any Animal`, an ordinary function CAN return different concrete types
    /// in different branches without needing result builders.
    func makeExistentialAnimal(isDog: Bool) -> any Animal {
        if isDog {
            return Dog(name: "Existential Dog")
        } else {
            return Cat(name: "Existential Cat")
        }
    }
}


// =============================================================================
// MARK: - 8. Practical Decision Framework & Comparison Matrix
// =============================================================================

/*
 ┌─────────────────────────┬───────────────────────────────────┬──────────────────────────────────┐
 │ Feature                 │ `some Protocol` (Opaque)          │ `any Protocol` (Existential)     │
 ├─────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
 │ Type Identity           │ Preserved at compile-time         │ Erased into existential box      │
 │ Concrete Type           │ Single, fixed underlying type     │ Can vary dynamically at runtime  │
 │ Dispatch Mechanism      │ Static dispatch (inlinable)       │ Dynamic dispatch via witness tbl │
 │ Memory Allocation       │ Inline on stack (zero overhead)   │ Boxed container (potential heap) │
 │ Reassign to other type? │ ❌ No                             │ ✅ Yes                           │
 │ Heterogeneous Arrays    │ ❌ No (homogeneous only)         │ ✅ Yes: `[any Protocol]`         │
 │ SwiftUI `body` return   │ ✅ Standard (`some View`)         │ ❌ Avoid (causes unnecessary     │
 │                         │                                   │    re-renders & loses identity)  │
 │ Associated Types / Self │ ✅ Fully supported                │ ⚠️ Supported since Swift 5.7    │
 │                         │                                   │    with primary associated types │
 └─────────────────────────┴───────────────────────────────────┴──────────────────────────────────┘

 WHEN TO USE WHAT:
 1. Use `some Protocol`:
    - For return types when the function implementation always produces ONE consistent concrete type.
    - In SwiftUI `var body: some View` to preserve structural identity for layout & diffing.
    - In function parameters as clean syntax sugar for generics when you don't need named type parameters.
    - When you want maximum performance (static dispatch, memory layout optimization, devirtualization).

 2. Use `any Protocol`:
    - When you need a variable or property to hold DIFFERENT concrete types over time.
    - When you need heterogeneous collections like `[any Animal]`.
    - When a function must return different concrete types across different runtime branches without a result builder.

 3. Use Named Generics `<T: Protocol>`:
    - When multiple parameters or the return type must share the EXACT SAME concrete type (`(T, T) -> T`).
    - When you need complex type constraints via `where` clauses.
    - When storing or referencing the generic type parameter across multiple methods in a class or struct.
*/


// =============================================================================
// MARK: - 9. Knowledge Check & Quiz (From the Chat)
// =============================================================================

enum KnowledgeCheck {
    static func printQuiz() {
        print("\n=======================================================")
        print("             KNOWLEDGE CHECK & QUIZ ANSWERS            ")
        print("=======================================================")
        
        print("""
        Q1: What does `func make() -> some Animal` promise?
        Answer: It promises to return a SPECIFIC underlying concrete type
                that conforms to Animal. The exact type is fixed at compile time.
        
        Q2: Can `func play(_ animal: some Animal)` accept both Dog and Cat?
        Answer: YES! In separate calls. Each call site can pass a different
                concrete type because `some` in parameters is generic syntax sugar.
        
        Q3: Which is best when a variable must hold a Dog now and a Cat later?
        Answer: `any Animal`. Only existential types support storing different
                concrete types in the same variable across runtime assignments.
        
        Q4: Why does SwiftUI's `var body: some View` allow `if/else` branches
            returning Text and Image?
        Answer: Because of `@ViewBuilder`! The result builder wraps the branches
                into a single composite type: `_ConditionalContent<Text, Image>`.
                The function still returns a single concrete type at compile time.
        """)
        print("=======================================================\n")
    }
}


// =============================================================================
// MARK: - 10. Comprehensive Demo Runner
// =============================================================================

public class SomeKeywordDemoRunner {
    public static func runAllDemos() {
        print("=======================================================")
        print("       SWIFT 'some' KEYWORD & OPAQUE TYPES DEMO        ")
        print("=======================================================")
        
        // 1. Opaque Return Types
        let returnDemo = OpaqueReturnTypeDemo()
        returnDemo.demonstrate()
        
        // 2. Opaque Parameter Types
        let paramDemo = OpaqueParameterTypeDemo()
        paramDemo.demonstrate()
        
        // 3. Custom Result Builder Analogy
        CustomResultBuilderDemo.demonstrate()
        
        // 4. some vs any
        let someVsAnyDemo = SomeVsAnyDemo()
        someVsAnyDemo.demonstrate()
        
        // 5. Knowledge Check
        KnowledgeCheck.printQuiz()
    }
}

// Preview provider for Xcode SwiftUI canvas
#Preview {
    ContentView_SomeKeywordDemo()
}
