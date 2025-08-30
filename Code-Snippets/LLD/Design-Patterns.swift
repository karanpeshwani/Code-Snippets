//
//  Design-Patterns.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 30/08/25.
//

import Foundation
import UIKit

// MARK: - ===================================
// MARK: - CREATIONAL PATTERNS (Most to Least Frequently Used)
// MARK: - ===================================

// MARK: - 1. Singleton Pattern
// Most frequently used - ensures only one instance exists
class NetworkManager {
    // Static instance - only one will ever exist
    static let shared = NetworkManager()
    
    // Private initializer prevents external instantiation
    private init() {
        print("NetworkManager initialized")
    }
    
    func fetchData() -> String {
        return "Data from network"
    }
}

// Usage example
let networkManager1 = NetworkManager.shared
let networkManager2 = NetworkManager.shared
// Both variables point to the same instance

// MARK: - 2. Factory Method Pattern
// Very common - creates objects without specifying exact classes
protocol Vehicle {
    func start()
    func stop()
}

class Car: Vehicle {
    func start() { print("Car engine started") }
    func stop() { print("Car engine stopped") }
}

class Motorcycle: Vehicle {
    func start() { print("Motorcycle engine started") }
    func stop() { print("Motorcycle engine stopped") }
}

// Factory that creates vehicles
class VehicleFactory {
    enum VehicleType {
        case car, motorcycle
    }
    
    static func createVehicle(type: VehicleType) -> Vehicle {
        switch type {
        case .car:
            return Car()
        case .motorcycle:
            return Motorcycle()
        }
    }
}

// Usage
let car = VehicleFactory.createVehicle(type: .car)
let motorcycle = VehicleFactory.createVehicle(type: .motorcycle)

// MARK: - 3. Builder Pattern
// Common for complex object construction
class Pizza {
    private var size: String = ""
    private var crust: String = ""
    private var toppings: [String] = []
    
    // Builder class for step-by-step construction
    class Builder {
        private var pizza = Pizza()
        
        func setSize(_ size: String) -> Builder {
            pizza.size = size
            return self
        }
        
        func setCrust(_ crust: String) -> Builder {
            pizza.crust = crust
            return self
        }
        
        func addTopping(_ topping: String) -> Builder {
            pizza.toppings.append(topping)
            return self
        }
        
        func build() -> Pizza {
            return pizza
        }
    }
    
    func description() -> String {
        return "\(size) pizza with \(crust) crust and toppings: \(toppings.joined(separator: ", "))"
    }
}

// Usage - fluent interface for easy construction
let pizza = Pizza.Builder()
    .setSize("Large")
    .setCrust("Thin")
    .addTopping("Pepperoni")
    .addTopping("Mushrooms")
    .build()

// MARK: - 4. Abstract Factory Pattern
// Less common - creates families of related objects
protocol UIComponentFactory {
    func createButton() -> Button
    func createTextField() -> TextField
}

protocol Button {
    func render()
}

protocol TextField {
    func render()
}

// iOS implementations
class iOSButton: Button {
    func render() { print("Rendering iOS style button") }
}

class iOSTextField: TextField {
    func render() { print("Rendering iOS style text field") }
}

// Android implementations
class AndroidButton: Button {
    func render() { print("Rendering Android style button") }
}

class AndroidTextField: TextField {
    func render() { print("Rendering Android style text field") }
}

// Concrete factories
class iOSUIFactory: UIComponentFactory {
    func createButton() -> Button { return iOSButton() }
    func createTextField() -> TextField { return iOSTextField() }
}

class AndroidUIFactory: UIComponentFactory {
    func createButton() -> Button { return AndroidButton() }
    func createTextField() -> TextField { return AndroidTextField() }
}

// MARK: - 5. Prototype Pattern
// Least common - creates objects by cloning existing instances
protocol Cloneable {
    func clone() -> Self
}

class Document: Cloneable {
    var title: String
    var content: String
    var metadata: [String: Any]
    
    init(title: String, content: String, metadata: [String: Any] = [:]) {
        self.title = title
        self.content = content
        self.metadata = metadata
    }
    
    // Deep copy implementation
    func clone() -> Document {
        let clonedMetadata = metadata // For simplicity, shallow copy of metadata
        return Document(title: title, content: content, metadata: clonedMetadata)
    }
}

// Usage
let originalDoc = Document(title: "Original", content: "Some content")
let clonedDoc = originalDoc.clone()
clonedDoc.title = "Cloned Document"

// MARK: - ===================================
// MARK: - STRUCTURAL PATTERNS (Most to Least Frequently Used)
// MARK: - ===================================

// MARK: - 1. Adapter Pattern
// Most common - allows incompatible interfaces to work together
// Legacy printer with old interface
class LegacyPrinter {
    func printOldFormat(text: String) {
        print("Legacy printer: \(text)")
    }
}

// Modern printer interface expected by client
protocol ModernPrinter {
    func print(document: String)
}

// Adapter that makes legacy printer work with modern interface
class PrinterAdapter: ModernPrinter {
    private let legacyPrinter: LegacyPrinter
    
    init(legacyPrinter: LegacyPrinter) {
        self.legacyPrinter = legacyPrinter
    }
    
    func print(document: String) {
        // Adapt the interface - convert new format to old format
        legacyPrinter.printOldFormat(text: document)
    }
}

// Usage
let legacyPrinter = LegacyPrinter()
let adapter = PrinterAdapter(legacyPrinter: legacyPrinter)
adapter.print(document: "Modern document")

// MARK: - 2. Decorator Pattern
// Very common - adds behavior to objects dynamically
protocol Coffee {
    func cost() -> Double
    func description() -> String
}

// Base coffee implementation
class SimpleCoffee: Coffee {
    func cost() -> Double { return 2.0 }
    func description() -> String { return "Simple coffee" }
}

// Base decorator
class CoffeeDecorator: Coffee {
    private let coffee: Coffee
    
    init(coffee: Coffee) {
        self.coffee = coffee
    }
    
    func cost() -> Double { return coffee.cost() }
    func description() -> String { return coffee.description() }
}

// Concrete decorators
class MilkDecorator: CoffeeDecorator {
    override func cost() -> Double {
        return super.cost() + 0.5
    }
    
    override func description() -> String {
        return super.description() + ", milk"
    }
}

class SugarDecorator: CoffeeDecorator {
    override func cost() -> Double {
        return super.cost() + 0.2
    }
    
    override func description() -> String {
        return super.description() + ", sugar"
    }
}

// Usage - can stack multiple decorators
let coffee = SimpleCoffee()
let coffeeWithMilk = MilkDecorator(coffee: coffee)
let coffeeWithMilkAndSugar = SugarDecorator(coffee: coffeeWithMilk)

// MARK: - 3. Facade Pattern
// Common - provides simplified interface to complex subsystem
// Complex subsystem classes
class CPU {
    func freeze() { print("CPU frozen") }
    func jump(position: Int) { print("CPU jumping to position \(position)") }
    func execute() { print("CPU executing") }
}

class Memory {
    func load(position: Int, data: String) {
        print("Loading data '\(data)' at position \(position)")
    }
}

class HardDrive {
    func read(lba: Int, size: Int) -> String {
        return "Data from sector \(lba)"
    }
}

// Facade that simplifies the complex subsystem
class ComputerFacade {
    private let cpu = CPU()
    private let memory = Memory()
    private let hardDrive = HardDrive()
    
    func startComputer() {
        print("Starting computer...")
        cpu.freeze()
        let bootData = hardDrive.read(lba: 0, size: 1024)
        memory.load(position: 0, data: bootData)
        cpu.jump(position: 0)
        cpu.execute()
        print("Computer started successfully!")
    }
}

// Usage - simple interface hides complexity
let computer = ComputerFacade()
computer.startComputer()

// MARK: - 4. Composite Pattern
// Moderately common - treats individual and composite objects uniformly
protocol FileSystemComponent {
    func getSize() -> Int
    func getName() -> String
}

// Leaf - individual file
class File: FileSystemComponent {
    private let name: String
    private let size: Int
    
    init(name: String, size: Int) {
        self.name = name
        self.size = size
    }
    
    func getSize() -> Int { return size }
    func getName() -> String { return name }
}

// Composite - directory containing files and other directories
class Directory: FileSystemComponent {
    private let name: String
    private var components: [FileSystemComponent] = []
    
    init(name: String) {
        self.name = name
    }
    
    func add(component: FileSystemComponent) {
        components.append(component)
    }
    
    func getSize() -> Int {
        return components.reduce(0) { $0 + $1.getSize() }
    }
    
    func getName() -> String { return name }
}

// Usage
let file1 = File(name: "document.txt", size: 100)
let file2 = File(name: "image.jpg", size: 500)
let directory = Directory(name: "MyFolder")
directory.add(component: file1)
directory.add(component: file2)

// MARK: - 5. Proxy Pattern
// Less common - provides placeholder/surrogate for another object
protocol Image {
    func display()
}

// Real subject - expensive to create
class RealImage: Image {
    private let filename: String
    
    init(filename: String) {
        self.filename = filename
        loadFromDisk()
    }
    
    private func loadFromDisk() {
        print("Loading image: \(filename)")
        // Simulate expensive loading operation
        Thread.sleep(forTimeInterval: 1)
    }
    
    func display() {
        print("Displaying image: \(filename)")
    }
}

// Proxy - controls access to real subject
class ImageProxy: Image {
    private let filename: String
    private var realImage: RealImage?
    
    init(filename: String) {
        self.filename = filename
    }
    
    func display() {
        // Lazy loading - create real image only when needed
        if realImage == nil {
            realImage = RealImage(filename: filename)
        }
        realImage?.display()
    }
}

// Usage - proxy delays expensive operation until needed
let imageProxy = ImageProxy(filename: "large_image.jpg")
// Image not loaded yet
imageProxy.display() // Now image is loaded and displayed

// MARK: - 6. Bridge Pattern
// Least common - separates abstraction from implementation
// Abstraction
class RemoteControl {
    private let device: Device
    
    init(device: Device) {
        self.device = device
    }
    
    func togglePower() {
        if device.isEnabled() {
            device.disable()
        } else {
            device.enable()
        }
    }
    
    func volumeUp() {
        device.setVolume(device.getVolume() + 10)
    }
    
    func volumeDown() {
        device.setVolume(device.getVolume() - 10)
    }
}

// Implementation interface
protocol Device {
    func isEnabled() -> Bool
    func enable()
    func disable()
    func getVolume() -> Int
    func setVolume(_ volume: Int)
}

// Concrete implementations
class TV: Device {
    private var enabled = false
    private var volume = 30
    
    func isEnabled() -> Bool { return enabled }
    func enable() { enabled = true; print("TV turned on") }
    func disable() { enabled = false; print("TV turned off") }
    func getVolume() -> Int { return volume }
    func setVolume(_ volume: Int) { self.volume = volume; print("TV volume: \(volume)") }
}

class Radio: Device {
    private var enabled = false
    private var volume = 20
    
    func isEnabled() -> Bool { return enabled }
    func enable() { enabled = true; print("Radio turned on") }
    func disable() { enabled = false; print("Radio turned off") }
    func getVolume() -> Int { return volume }
    func setVolume(_ volume: Int) { self.volume = volume; print("Radio volume: \(volume)") }
}

// Usage
let tv = TV()
let remote = RemoteControl(device: tv)
remote.togglePower()
remote.volumeUp()

// MARK: - ===================================
// MARK: - BEHAVIORAL PATTERNS (Most to Least Frequently Used)
// MARK: - ===================================

// MARK: - 1. Observer Pattern
// Most common - defines one-to-many dependency between objects
protocol Observer: AnyObject {
    func update(temperature: Double)
}

protocol Subject {
    func attach(observer: Observer)
    func detach(observer: Observer)
    func notify()
}

// Concrete subject
class WeatherStation: Subject {
    private var observers: [Observer] = []
    private var temperature: Double = 0.0 {
        didSet {
            notify()
        }
    }
    
    func attach(observer: Observer) {
        observers.append(observer)
    }
    
    func detach(observer: Observer) {
        observers.removeAll { $0 === observer }
    }
    
    func notify() {
        observers.forEach { $0.update(temperature: temperature) }
    }
    
    func setTemperature(_ temp: Double) {
        temperature = temp
    }
}

// Concrete observers
class PhoneDisplay: Observer {
    func update(temperature: Double) {
        print("Phone display: Temperature is \(temperature)°C")
    }
}

class WebDisplay: Observer {
    func update(temperature: Double) {
        print("Web display: Current temperature: \(temperature)°C")
    }
}

// Usage
let weatherStation = WeatherStation()
let phoneDisplay = PhoneDisplay()
let webDisplay = WebDisplay()

weatherStation.attach(observer: phoneDisplay)
weatherStation.attach(observer: webDisplay)
weatherStation.setTemperature(25.5)

// MARK: - 2. Strategy Pattern
// Very common - defines family of algorithms and makes them interchangeable
protocol PaymentStrategy {
    func pay(amount: Double)
}

// Concrete strategies
class CreditCardPayment: PaymentStrategy {
    private let cardNumber: String
    
    init(cardNumber: String) {
        self.cardNumber = cardNumber
    }
    
    func pay(amount: Double) {
        print("Paid $\(amount) using Credit Card ending in \(String(cardNumber.suffix(4)))")
    }
}

class PayPalPayment: PaymentStrategy {
    private let email: String
    
    init(email: String) {
        self.email = email
    }
    
    func pay(amount: Double) {
        print("Paid $\(amount) using PayPal account: \(email)")
    }
}

class ApplePayPayment: PaymentStrategy {
    func pay(amount: Double) {
        print("Paid $\(amount) using Apple Pay")
    }
}

// Context that uses strategy
class ShoppingCart {
    private var paymentStrategy: PaymentStrategy?
    
    func setPaymentStrategy(_ strategy: PaymentStrategy) {
        self.paymentStrategy = strategy
    }
    
    func checkout(amount: Double) {
        guard let strategy = paymentStrategy else {
            print("Please select a payment method")
            return
        }
        strategy.pay(amount: amount)
    }
}

// Usage
let cart = ShoppingCart()
cart.setPaymentStrategy(CreditCardPayment(cardNumber: "1234567890123456"))
cart.checkout(amount: 99.99)

cart.setPaymentStrategy(ApplePayPayment())
cart.checkout(amount: 149.99)

// MARK: - 3. Command Pattern
// Common - encapsulates requests as objects
protocol Command {
    func execute()
    func undo()
}

// Receiver - knows how to perform operations
class TextEditor {
    private var content: String = ""
    
    func write(_ text: String) {
        content += text
        print("Content: '\(content)'")
    }
    
    func delete(_ length: Int) {
        let endIndex = content.index(content.endIndex, offsetBy: -min(length, content.count))
        content = String(content[..<endIndex])
        print("Content: '\(content)'")
    }
    
    func getContent() -> String {
        return content
    }
}

// Concrete commands
class WriteCommand: Command {
    private let editor: TextEditor
    private let text: String
    
    init(editor: TextEditor, text: String) {
        self.editor = editor
        self.text = text
    }
    
    func execute() {
        editor.write(text)
    }
    
    func undo() {
        editor.delete(text.count)
    }
}

class DeleteCommand: Command {
    private let editor: TextEditor
    private let length: Int
    private var deletedText: String = ""
    
    init(editor: TextEditor, length: Int) {
        self.editor = editor
        self.length = length
    }
    
    func execute() {
        let content = editor.getContent()
        let startIndex = content.index(content.endIndex, offsetBy: -min(length, content.count))
        deletedText = String(content[startIndex...])
        editor.delete(length)
    }
    
    func undo() {
        editor.write(deletedText)
    }
}

// Invoker
class EditorInvoker {
    private var history: [Command] = []
    private var currentPosition = -1
    
    func executeCommand(_ command: Command) {
        // Remove any commands after current position
        history = Array(history[0...currentPosition])
        
        command.execute()
        history.append(command)
        currentPosition += 1
    }
    
    func undo() {
        guard currentPosition >= 0 else { return }
        history[currentPosition].undo()
        currentPosition -= 1
    }
    
    func redo() {
        guard currentPosition < history.count - 1 else { return }
        currentPosition += 1
        history[currentPosition].execute()
    }
}

// Usage
let editor = TextEditor()
let invoker = EditorInvoker()

let writeHello = WriteCommand(editor: editor, text: "Hello ")
let writeWorld = WriteCommand(editor: editor, text: "World!")

invoker.executeCommand(writeHello)
invoker.executeCommand(writeWorld)
invoker.undo() // Removes "World!"
invoker.redo() // Adds "World!" back

// MARK: - 4. State Pattern
// Moderately common - allows object to change behavior when internal state changes
protocol State {
    func insertCoin(_ context: VendingMachine)
    func selectProduct(_ context: VendingMachine)
    func dispenseProduct(_ context: VendingMachine)
}

// Context
class VendingMachine {
    private var state: State
    private var hasProduct: Bool = true
    
    // States
    lazy var noCoinState = NoCoinState()
    lazy var hasCoinState = HasCoinState()
    lazy var dispensingState = DispensingState()
    lazy var outOfStockState = OutOfStockState()
    
    init() {
        state = noCoinState
    }
    
    func setState(_ state: State) {
        self.state = state
    }
    
    func insertCoin() { state.insertCoin(self) }
    func selectProduct() { state.selectProduct(self) }
    func dispenseProduct() { state.dispenseProduct(self) }
    
    func hasProduct() -> Bool { return hasProduct }
    func setHasProduct(_ hasProduct: Bool) { self.hasProduct = hasProduct }
}

// Concrete states
class NoCoinState: State {
    func insertCoin(_ context: VendingMachine) {
        print("Coin inserted")
        context.setState(context.hasCoinState)
    }
    
    func selectProduct(_ context: VendingMachine) {
        print("Please insert coin first")
    }
    
    func dispenseProduct(_ context: VendingMachine) {
        print("Please insert coin first")
    }
}

class HasCoinState: State {
    func insertCoin(_ context: VendingMachine) {
        print("Coin already inserted")
    }
    
    func selectProduct(_ context: VendingMachine) {
        print("Product selected")
        if context.hasProduct() {
            context.setState(context.dispensingState)
        } else {
            context.setState(context.outOfStockState)
        }
    }
    
    func dispenseProduct(_ context: VendingMachine) {
        print("Please select product first")
    }
}

class DispensingState: State {
    func insertCoin(_ context: VendingMachine) {
        print("Please wait, dispensing product")
    }
    
    func selectProduct(_ context: VendingMachine) {
        print("Please wait, dispensing product")
    }
    
    func dispenseProduct(_ context: VendingMachine) {
        print("Product dispensed")
        context.setState(context.noCoinState)
    }
}

class OutOfStockState: State {
    func insertCoin(_ context: VendingMachine) {
        print("Out of stock, coin returned")
    }
    
    func selectProduct(_ context: VendingMachine) {
        print("Out of stock")
    }
    
    func dispenseProduct(_ context: VendingMachine) {
        print("Out of stock")
    }
}

// Usage
let vendingMachine = VendingMachine()
vendingMachine.insertCoin()
vendingMachine.selectProduct()
vendingMachine.dispenseProduct()

// MARK: - 5. Template Method Pattern
// Less common - defines skeleton of algorithm, subclasses fill in details
abstract class DataProcessor {
    // Template method - defines the algorithm skeleton
    final func processData() {
        readData()
        processDataImpl()
        saveData()
    }
    
    // Common implementation
    private func readData() {
        print("Reading data from source")
    }
    
    private func saveData() {
        print("Saving processed data")
    }
    
    // Abstract method - subclasses must implement
    func processDataImpl() {
        fatalError("Subclasses must implement processDataImpl()")
    }
}

// Concrete implementations
class CSVProcessor: DataProcessor {
    override func processDataImpl() {
        print("Processing CSV data - parsing columns and rows")
    }
}

class JSONProcessor: DataProcessor {
    override func processDataImpl() {
        print("Processing JSON data - parsing objects and arrays")
    }
}

class XMLProcessor: DataProcessor {
    override func processDataImpl() {
        print("Processing XML data - parsing tags and attributes")
    }
}

// Usage
let csvProcessor = CSVProcessor()
csvProcessor.processData()

let jsonProcessor = JSONProcessor()
jsonProcessor.processData()

// MARK: - 6. Chain of Responsibility Pattern
// Less common - passes requests along chain of handlers
protocol SupportHandler: AnyObject {
    var nextHandler: SupportHandler? { get set }
    func handleRequest(_ request: SupportRequest)
}

struct SupportRequest {
    let type: RequestType
    let description: String
    
    enum RequestType {
        case basic, technical, billing
    }
}

// Base handler
class BaseSupportHandler: SupportHandler {
    var nextHandler: SupportHandler?
    
    func handleRequest(_ request: SupportRequest) {
        if canHandle(request) {
            process(request)
        } else if let nextHandler = nextHandler {
            nextHandler.handleRequest(request)
        } else {
            print("No handler available for request: \(request.description)")
        }
    }
    
    func canHandle(_ request: SupportRequest) -> Bool {
        return false // Override in subclasses
    }
    
    func process(_ request: SupportRequest) {
        // Override in subclasses
    }
}

// Concrete handlers
class BasicSupportHandler: BaseSupportHandler {
    override func canHandle(_ request: SupportRequest) -> Bool {
        return request.type == .basic
    }
    
    override func process(_ request: SupportRequest) {
        print("Basic Support: Handling '\(request.description)'")
    }
}

class TechnicalSupportHandler: BaseSupportHandler {
    override func canHandle(_ request: SupportRequest) -> Bool {
        return request.type == .technical
    }
    
    override func process(_ request: SupportRequest) {
        print("Technical Support: Handling '\(request.description)'")
    }
}

class BillingSupportHandler: BaseSupportHandler {
    override func canHandle(_ request: SupportRequest) -> Bool {
        return request.type == .billing
    }
    
    override func process(_ request: SupportRequest) {
        print("Billing Support: Handling '\(request.description)'")
    }
}

// Setup chain
let basicHandler = BasicSupportHandler()
let technicalHandler = TechnicalSupportHandler()
let billingHandler = BillingSupportHandler()

basicHandler.nextHandler = technicalHandler
technicalHandler.nextHandler = billingHandler

// Usage
let basicRequest = SupportRequest(type: .basic, description: "How to reset password?")
let technicalRequest = SupportRequest(type: .technical, description: "Server is down")
let billingRequest = SupportRequest(type: .billing, description: "Refund request")

basicHandler.handleRequest(basicRequest)
basicHandler.handleRequest(technicalRequest)
basicHandler.handleRequest(billingRequest)

// MARK: - 7. Mediator Pattern
// Less common - defines how objects interact with each other
protocol Mediator {
    func notify(sender: Component, event: String)
}

// Base component
class Component {
    protected var mediator: Mediator?
    
    init(mediator: Mediator? = nil) {
        self.mediator = mediator
    }
    
    func setMediator(_ mediator: Mediator) {
        self.mediator = mediator
    }
}

// Concrete components
class Button: Component {
    func click() {
        print("Button clicked")
        mediator?.notify(sender: self, event: "click")
    }
}

class Checkbox: Component {
    private var checked = false
    
    func check() {
        checked.toggle()
        print("Checkbox \(checked ? "checked" : "unchecked")")
        mediator?.notify(sender: self, event: checked ? "check" : "uncheck")
    }
    
    func isChecked() -> Bool { return checked }
}

class TextField: Component {
    private var text = ""
    
    func setText(_ text: String) {
        self.text = text
        print("TextField text changed to: '\(text)'")
        mediator?.notify(sender: self, event: "textChanged")
    }
    
    func getText() -> String { return text }
}

// Concrete mediator
class DialogMediator: Mediator {
    private var button: Button!
    private var checkbox: Checkbox!
    private var textField: TextField!
    
    init() {
        button = Button(mediator: self)
        checkbox = Checkbox(mediator: self)
        textField = TextField(mediator: self)
    }
    
    func notify(sender: Component, event: String) {
        switch (sender, event) {
        case (button, "click"):
            print("Mediator: Button clicked - submitting form")
            
        case (checkbox, "check"):
            print("Mediator: Checkbox checked - enabling text field")
            
        case (checkbox, "uncheck"):
            print("Mediator: Checkbox unchecked - clearing text field")
            textField.setText("")
            
        case (textField, "textChanged"):
            print("Mediator: Text changed - validating input")
            
        default:
            break
        }
    }
    
    // Public interface for external interaction
    func clickButton() { button.click() }
    func toggleCheckbox() { checkbox.check() }
    func updateText(_ text: String) { textField.setText(text) }
}

// Usage
let dialog = DialogMediator()
dialog.toggleCheckbox()
dialog.updateText("Hello World")
dialog.clickButton()

// MARK: - 8. Iterator Pattern
// Moderately common - provides way to access elements sequentially
// Swift has built-in support through Sequence and IteratorProtocol
struct BookCollection: Sequence {
    private var books: [String] = []
    
    mutating func addBook(_ book: String) {
        books.append(book)
    }
    
    // Implement Sequence protocol
    func makeIterator() -> BookIterator {
        return BookIterator(books: books)
    }
}

struct BookIterator: IteratorProtocol {
    private let books: [String]
    private var currentIndex = 0
    
    init(books: [String]) {
        self.books = books
    }
    
    mutating func next() -> String? {
        guard currentIndex < books.count else { return nil }
        let book = books[currentIndex]
        currentIndex += 1
        return book
    }
}

// Usage
var collection = BookCollection()
collection.addBook("Swift Programming")
collection.addBook("iOS Development")
collection.addBook("Design Patterns")

// Can use for-in loop thanks to Sequence protocol
for book in collection {
    print("Book: \(book)")
}

// MARK: - 9. Visitor Pattern
// Least common - separates algorithm from object structure
protocol ShapeVisitor {
    func visit(_ circle: Circle)
    func visit(_ rectangle: Rectangle)
    func visit(_ triangle: Triangle)
}

protocol Shape {
    func accept(_ visitor: ShapeVisitor)
}

// Concrete shapes
class Circle: Shape {
    let radius: Double
    
    init(radius: Double) {
        self.radius = radius
    }
    
    func accept(_ visitor: ShapeVisitor) {
        visitor.visit(self)
    }
}

class Rectangle: Shape {
    let width: Double
    let height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    func accept(_ visitor: ShapeVisitor) {
        visitor.visit(self)
    }
}

class Triangle: Shape {
    let base: Double
    let height: Double
    
    init(base: Double, height: Double) {
        self.base = base
        self.height = height
    }
    
    func accept(_ visitor: ShapeVisitor) {
        visitor.visit(self)
    }
}

// Concrete visitors
class AreaCalculator: ShapeVisitor {
    func visit(_ circle: Circle) {
        let area = Double.pi * circle.radius * circle.radius
        print("Circle area: \(area)")
    }
    
    func visit(_ rectangle: Rectangle) {
        let area = rectangle.width * rectangle.height
        print("Rectangle area: \(area)")
    }
    
    func visit(_ triangle: Triangle) {
        let area = 0.5 * triangle.base * triangle.height
        print("Triangle area: \(area)")
    }
}

class PerimeterCalculator: ShapeVisitor {
    func visit(_ circle: Circle) {
        let perimeter = 2 * Double.pi * circle.radius
        print("Circle perimeter: \(perimeter)")
    }
    
    func visit(_ rectangle: Rectangle) {
        let perimeter = 2 * (rectangle.width + rectangle.height)
        print("Rectangle perimeter: \(perimeter)")
    }
    
    func visit(_ triangle: Triangle) {
        // Simplified - assuming equilateral triangle
        let perimeter = 3 * triangle.base
        print("Triangle perimeter: \(perimeter)")
    }
}

// Usage
let shapes: [Shape] = [
    Circle(radius: 5),
    Rectangle(width: 4, height: 6),
    Triangle(base: 3, height: 4)
]

let areaCalculator = AreaCalculator()
let perimeterCalculator = PerimeterCalculator()

print("Calculating areas:")
shapes.forEach { $0.accept(areaCalculator) }

print("\nCalculating perimeters:")
shapes.forEach { $0.accept(perimeterCalculator) }

// MARK: - 10. Memento Pattern
// Least common - captures and restores object state
// Memento - stores state
struct EditorMemento {
    let content: String
    let cursorPosition: Int
    let timestamp: Date
    
    init(content: String, cursorPosition: Int) {
        self.content = content
        self.cursorPosition = cursorPosition
        self.timestamp = Date()
    }
}

// Originator - creates and restores from mementos
class TextEditorOriginator {
    private var content: String = ""
    private var cursorPosition: Int = 0
    
    func write(_ text: String) {
        content += text
        cursorPosition = content.count
        print("Content: '\(content)', Cursor: \(cursorPosition)")
    }
    
    func setCursorPosition(_ position: Int) {
        cursorPosition = min(max(0, position), content.count)
        print("Cursor moved to position: \(cursorPosition)")
    }
    
    // Create memento
    func createMemento() -> EditorMemento {
        return EditorMemento(content: content, cursorPosition: cursorPosition)
    }
    
    // Restore from memento
    func restore(from memento: EditorMemento) {
        content = memento.content
        cursorPosition = memento.cursorPosition
        print("Restored - Content: '\(content)', Cursor: \(cursorPosition)")
    }
}

// Caretaker - manages mementos
class EditorHistory {
    private var mementos: [EditorMemento] = []
    private let editor: TextEditorOriginator
    
    init(editor: TextEditorOriginator) {
        self.editor = editor
    }
    
    func save() {
        let memento = editor.createMemento()
        mementos.append(memento)
        print("State saved at \(memento.timestamp)")
    }
    
    func undo() {
        guard mementos.count > 1 else {
            print("No more states to undo")
            return
        }
        
        // Remove current state and restore previous
        mementos.removeLast()
        let previousMemento = mementos.last!
        editor.restore(from: previousMemento)
    }
}

// Usage
let textEditor = TextEditorOriginator()
let history = EditorHistory(editor: textEditor)

// Save initial state
history.save()

textEditor.write("Hello")
history.save()

textEditor.write(" World")
history.save()

textEditor.write("!")
print("\nUndoing changes:")
history.undo() // Back to "Hello World"
history.undo() // Back to "Hello"




/*
 ===================================
 DESIGN PATTERNS Q&A - 20 MOST IMPORTANT QUESTIONS
 ===================================
 
 1. Q: What are design patterns and why are they important?
    A: Design patterns are reusable solutions to common problems in software design. They provide a template for how to solve problems that can be used in many different situations. They're important because they promote code reusability, maintainability, and help developers communicate using a common vocabulary.
 
 2. Q: What's the difference between Creational, Structural, and Behavioral patterns?
    A: Creational patterns deal with object creation mechanisms, Structural patterns deal with object composition and relationships, and Behavioral patterns focus on communication between objects and the assignment of responsibilities.
 
 3. Q: When should you use the Singleton pattern and what are its drawbacks?
    A: Use Singleton when you need exactly one instance of a class (like UserDefaults, FileManager). Drawbacks include difficulty in unit testing, potential memory leaks, thread safety issues, and violation of Single Responsibility Principle.
 
 4. Q: What's the difference between Factory Method and Abstract Factory patterns?
    A: Factory Method creates objects of a single type through inheritance, while Abstract Factory creates families of related objects through composition. Abstract Factory is more complex but provides better flexibility for creating multiple related products.
 
 5. Q: How does the Observer pattern work and what are its alternatives in iOS?
    A: Observer pattern defines a one-to-many dependency between objects. When one object changes state, all dependents are notified. In iOS, alternatives include NotificationCenter, KVO, Combine framework, and delegation pattern.
 
 6. Q: What's the difference between Adapter and Facade patterns?
    A: Adapter converts the interface of a class into another interface clients expect, allowing incompatible classes to work together. Facade provides a simplified interface to a complex subsystem. Adapter focuses on interface compatibility, Facade on simplification.
 
 7. Q: When would you use the Strategy pattern over simple inheritance?
    A: Use Strategy when you have multiple algorithms for a task and want to switch between them at runtime. It's better than inheritance when you want to avoid a large hierarchy of classes and when algorithms change independently of clients.
 
 8. Q: How does the Decorator pattern differ from inheritance?
    A: Decorator adds behavior to objects dynamically without altering their structure, while inheritance adds behavior statically at compile time. Decorator is more flexible as you can combine multiple decorators and add/remove behavior at runtime.
 
 9. Q: What problems does the Command pattern solve?
    A: Command pattern encapsulates requests as objects, allowing you to parameterize clients with different requests, queue operations, log requests, and support undo operations. It decouples the invoker from the receiver.
 
 10. Q: How is the Builder pattern different from a constructor with many parameters?
     A: Builder pattern constructs complex objects step by step and allows creating different representations using the same construction process. It's more readable than constructors with many parameters and allows optional parameters without method overloading.
 
 11. Q: What's the Template Method pattern and when is it useful?
     A: Template Method defines the skeleton of an algorithm in a base class, letting subclasses override specific steps without changing the algorithm's structure. It's useful when you have common algorithm steps but different implementations.
 
 12. Q: How does the Proxy pattern work and what are its types?
     A: Proxy provides a placeholder/surrogate for another object to control access to it. Types include: Virtual Proxy (lazy loading), Protection Proxy (access control), Remote Proxy (network objects), and Smart Proxy (additional functionality).
 
 13. Q: What's the difference between State and Strategy patterns?
     A: Both use composition and delegation, but State pattern allows an object to change behavior when internal state changes (appears as if object changed class), while Strategy pattern allows selecting algorithm at runtime. State focuses on state transitions, Strategy on algorithm selection.
 
 14. Q: When should you use the Chain of Responsibility pattern?
     A: Use it when you want to give multiple objects a chance to handle a request without coupling sender to receivers. Common in UI event handling, middleware processing, and validation chains where multiple handlers might process the same request.
 
 15. Q: How does the Mediator pattern promote loose coupling?
     A: Mediator defines how objects interact with each other, preventing direct references between communicating objects. Objects communicate through the mediator, reducing dependencies and making the system easier to maintain and extend.
 
 16. Q: What's the Memento pattern and how does it support undo functionality?
     A: Memento captures and stores an object's internal state without violating encapsulation, allowing the object to be restored to this state later. It's essential for implementing undo/redo functionality and checkpoints.
 
 17. Q: How does the Composite pattern simplify client code?
     A: Composite lets clients treat individual objects and compositions uniformly. Clients don't need to distinguish between leaf and composite objects, simplifying code that works with tree structures like UI hierarchies or file systems.
 
 18. Q: What's the Iterator pattern and how does Swift implement it?
     A: Iterator provides a way to access elements of a collection sequentially without exposing underlying representation. Swift implements this through the Sequence and IteratorProtocol, enabling for-in loops and functional operations.
 
 19. Q: When is the Bridge pattern preferred over inheritance?
     A: Use Bridge when you want to separate abstraction from implementation, allowing both to vary independently. It's preferred when you have multiple implementations and don't want to create a class explosion through inheritance combinations.
 
 20. Q: How do you choose the right design pattern for a problem?
     A: Identify the core problem: object creation (Creational), object structure/composition (Structural), or object behavior/interaction (Behavioral). Consider factors like flexibility needs, performance requirements, complexity, and future extensibility. Start simple and refactor to patterns when complexity justifies it.
 */
