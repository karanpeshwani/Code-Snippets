//
//  Property-Wrapper.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 21/07/25.
//

import Foundation

// MARK: - 1. Implementation of the Custom Property Wrapper

@propertyWrapper
struct Capitalized {
    
    // This is the private storage for our value.
    private var value: String
    
    // 'wrappedValue' is a required property for any property wrapper.
    // This is the computed property that the compiler synthesizes for us.
    // When you access the property decorated with @Capitalized, you are actually
    // accessing this 'wrappedValue'.
    var wrappedValue: String {
        get {
            // When the property is read, we return the stored value.
            return value
        }
        set {
            // When a new value is assigned to the property,
            // we capitalize it before storing it in our private 'value'.
            value = newValue.capitalized
        }
    }
    
    // The initializer for the property wrapper.
    // It takes the initial value that the property is set to.
    init(wrappedValue: String) {
        // We capitalize the initial value right away.
        self.value = wrappedValue.capitalized
    }
}


// MARK: - 2. Usage Example

// Let's create a struct that uses our new property wrapper.
struct User {
    // By applying @Capitalized here, any string assigned to 'name'
    // will automatically be capitalized by the wrapper's logic.
    @Capitalized var name: String
    
    // We can use it on multiple properties.
    @Capitalized var city: String
}


// MARK: - 3. Demonstration

func propertyWrapperExample() {
    
    // --- Create an instance of the User struct ---
    // Notice we are providing lowercase strings during initialization.
    var user = User(name: "john doe", city: "new york")

    // --- Accessing the properties ---
    // The property wrapper's 'init' has already capitalized the initial values.
    print("Initial User Name: \(user.name)") // Output: Initial User Name: John Doe
    print("Initial User City: \(user.city)")   // Output: Initial User City: New York

    print("---")

    // --- Modifying the properties ---
    // Let's assign new, non-capitalized values.
    print("Assigning 'jane smith' to user.name...")
    user.name = "jane smith"

    print("Assigning 'san francisco' to user.city...")
    user.city = "san francisco"

    // --- Accessing the properties again ---
    // The 'set' block of our wrappedValue automatically capitalized the new values.
    print("Updated User Name: \(user.name)") // Output: Updated User Name: Jane Smith
    print("Updated User City: ʻ\(user.city)")   // Output: Updated User City: San Francisco

    // --- Another example with mixed casing ---
    print("---")
    print("Assigning 'chicago' to user.city...")
    user.city = "chicago"
    print("Updated User City: \(user.city)") // Output: Updated User City: Chicago
    
}


