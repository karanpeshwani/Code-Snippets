//
//  ObservedObject-Bug.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 20/07/25.
//

import SwiftUI

class StateObjectClass: ObservableObject {
    @Published var count = 0
    let id = UUID()
    
    init() {
        print("StateObjectClass created with id: \(id)")
    }
    
    deinit {
        print("StateObjectClass destroyed with id: \(id)")
    }
}

// Parent view that can trigger redraws
struct ParentView: View {
    @State var randomNumber = 0
    
    init(){
        print("init => ContentView")
    }
    
    var body: some View {
        VStack {
            Text("Random number is: \(randomNumber)")
            Button("Randomize number") {
                randomNumber = (0..<1000).randomElement()!
            }
            .padding(.bottom)
            
            // This will cause issues!
            CounterViewWithObservedObject()
        }
    }
}

// Problematic view using @ObservedObject for initialization
struct CounterViewWithObservedObject: View {
    @ObservedObject var viewModel = StateObjectClass() // BUG: Should use @StateObject
    
    init() {
        print("init => CounterViewWithObservedObject")
    }
    
    var body: some View {
        VStack {
            Text("@ObservedObject's count: \(viewModel.count)")
            Button("Add 1") {
                viewModel.count += 1
            }
        }
    }
}
