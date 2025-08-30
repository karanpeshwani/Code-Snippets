//
//  Parking-Lot.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 30/08/25.
//

//Question:
/*
 Design a parking lot system that can handle different types of vehicles (Car, Motorcycle, Truck), 
 different parking spot sizes (Compact, Regular, Large), and supports features like:
 - Vehicle entry and exit
 - Spot allocation based on vehicle type
 - Payment processing with different rates
 - Real-time availability tracking
 - Multiple floors support
*/

import Foundation
import Combine

// MARK: - 1. Core Protocols (Abstractions)

/// Defines the contract for a vehicle that can be parked
protocol Vehicle {
    var licensePlate: String { get }
    var vehicleType: VehicleType { get }
    var size: VehicleSize { get }
}

/// Defines the contract for a parking spot
protocol ParkingSpot {
    var id: String { get }
    var spotType: SpotType { get }
    var floor: Int { get }
    var isOccupied: Bool { get set }
    var occupiedBy: Vehicle? { get set }
    
    /// Checks if the spot can accommodate the given vehicle
    func canFit(_ vehicle: Vehicle) -> Bool
    
    /// Parks a vehicle in this spot
    mutating func parkVehicle(_ vehicle: Vehicle) -> Bool
    
    /// Removes the vehicle from this spot
    mutating func removeVehicle() -> Vehicle?
}

/// Defines the contract for payment processing
protocol PaymentProcessor {
    func calculateFee(for ticket: ParkingTicket, exitTime: Date) -> Decimal
    func processPayment(amount: Decimal, method: PaymentMethod) async throws -> PaymentResult
}

/// Defines the contract for spot allocation strategy
protocol SpotAllocationStrategy {
    func findAvailableSpot(for vehicle: Vehicle, in spots: [ParkingSpot]) -> ParkingSpot?
}

/// Defines the contract for parking lot operations
protocol ParkingLotService {
    func parkVehicle(_ vehicle: Vehicle) async throws -> ParkingTicket
    func exitVehicle(ticket: ParkingTicket, paymentMethod: PaymentMethod) async throws -> ExitResult
    func getAvailableSpots(for vehicleType: VehicleType) -> Int
    func getOccupancyRate(for floor: Int?) -> Double
}

// MARK: - 2. Supporting Enums and Structs

enum VehicleType: String, CaseIterable, Codable {
    case motorcycle = "Motorcycle"
    case car = "Car"
    case truck = "Truck"
}

enum VehicleSize: Int, Comparable {
    case small = 1    // Motorcycle
    case medium = 2   // Car
    case large = 3    // Truck
    
    static func < (lhs: VehicleSize, rhs: VehicleSize) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum SpotType: String, CaseIterable, Codable {
    case compact = "Compact"
    case regular = "Regular"
    case large = "Large"
    
    var maxVehicleSize: VehicleSize {
        switch self {
        case .compact: return .small
        case .regular: return .medium
        case .large: return .large
        }
    }
    
    var hourlyRate: Decimal {
        switch self {
        case .compact: return 2.0
        case .regular: return 3.0
        case .large: return 5.0
        }
    }
}

enum PaymentMethod: String, CaseIterable {
    case cash = "Cash"
    case creditCard = "Credit Card"
    case digitalWallet = "Digital Wallet"
}

enum ParkingError: Error, LocalizedError {
    case noAvailableSpots
    case vehicleAlreadyParked
    case invalidTicket
    case paymentFailed(String)
    case spotNotFound
    case vehicleNotFound
    
    var errorDescription: String? {
        switch self {
        case .noAvailableSpots:
            return "No available parking spots for this vehicle type."
        case .vehicleAlreadyParked:
            return "Vehicle is already parked in the lot."
        case .invalidTicket:
            return "The provided parking ticket is invalid."
        case .paymentFailed(let reason):
            return "Payment failed: \(reason)"
        case .spotNotFound:
            return "The specified parking spot was not found."
        case .vehicleNotFound:
            return "Vehicle not found in the parking lot."
        }
    }
}

// MARK: - 3. Data Models

struct ParkingTicket: Identifiable, Codable {
    let id: String
    let vehicleLicensePlate: String
    let spotId: String
    let entryTime: Date
    let vehicleType: VehicleType
    let spotType: SpotType
    
    init(vehicle: Vehicle, spot: ParkingSpot) {
        self.id = UUID().uuidString
        self.vehicleLicensePlate = vehicle.licensePlate
        self.spotId = spot.id
        self.entryTime = Date()
        self.vehicleType = vehicle.vehicleType
        self.spotType = spot.spotType
    }
}

struct PaymentResult {
    let transactionId: String
    let amount: Decimal
    let method: PaymentMethod
    let timestamp: Date
    let success: Bool
}

struct ExitResult {
    let ticket: ParkingTicket
    let exitTime: Date
    let totalFee: Decimal
    let paymentResult: PaymentResult
    let duration: TimeInterval
}

// MARK: - 4. Concrete Vehicle Implementations

struct Motorcycle: Vehicle {
    let licensePlate: String
    let vehicleType: VehicleType = .motorcycle
    let size: VehicleSize = .small
}

struct Car: Vehicle {
    let licensePlate: String
    let vehicleType: VehicleType = .car
    let size: VehicleSize = .medium
}

struct Truck: Vehicle {
    let licensePlate: String
    let vehicleType: VehicleType = .truck
    let size: VehicleSize = .large
}

// MARK: - 5. Concrete Parking Spot Implementation

struct ConcreteParkingSpot: ParkingSpot {
    let id: String
    let spotType: SpotType
    let floor: Int
    var isOccupied: Bool = false
    var occupiedBy: Vehicle?
    
    func canFit(_ vehicle: Vehicle) -> Bool {
        return !isOccupied && vehicle.size <= spotType.maxVehicleSize
    }
    
    mutating func parkVehicle(_ vehicle: Vehicle) -> Bool {
        guard canFit(vehicle) else { return false }
        
        isOccupied = true
        occupiedBy = vehicle
        return true
    }
    
    mutating func removeVehicle() -> Vehicle? {
        guard let vehicle = occupiedBy else { return nil }
        
        isOccupied = false
        occupiedBy = nil
        return vehicle
    }
}

// MARK: - 6. Payment Processor Implementation

final class StandardPaymentProcessor: PaymentProcessor {
    
    func calculateFee(for ticket: ParkingTicket, exitTime: Date) -> Decimal {
        let duration = exitTime.timeIntervalSince(ticket.entryTime)
        let hours = max(1, ceil(duration / 3600)) // Minimum 1 hour, round up
        let hourlyRate = ticket.spotType.hourlyRate
        
        return Decimal(hours) * hourlyRate
    }
    
    func processPayment(amount: Decimal, method: PaymentMethod) async throws -> PaymentResult {
        // Simulate payment processing delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Simulate payment success/failure (95% success rate)
        let success = Int.random(in: 1...100) <= 95
        
        if !success {
            throw ParkingError.paymentFailed("Payment gateway error")
        }
        
        return PaymentResult(
            transactionId: UUID().uuidString,
            amount: amount,
            method: method,
            timestamp: Date(),
            success: success
        )
    }
}

// MARK: - 7. Spot Allocation Strategies

/// Finds the closest available spot to the entrance (lowest floor, lowest spot number)
final class ClosestToEntranceStrategy: SpotAllocationStrategy {
    func findAvailableSpot(for vehicle: Vehicle, in spots: [ParkingSpot]) -> ParkingSpot? {
        return spots
            .filter { $0.canFit(vehicle) }
            .sorted { spot1, spot2 in
                if spot1.floor != spot2.floor {
                    return spot1.floor < spot2.floor
                }
                return spot1.id < spot2.id
            }
            .first
    }
}

/// Finds the smallest available spot that can fit the vehicle (space optimization)
final class SmallestFitStrategy: SpotAllocationStrategy {
    func findAvailableSpot(for vehicle: Vehicle, in spots: [ParkingSpot]) -> ParkingSpot? {
        return spots
            .filter { $0.canFit(vehicle) }
            .sorted { $0.spotType.maxVehicleSize.rawValue < $1.spotType.maxVehicleSize.rawValue }
            .first
    }
}

// MARK: - 8. Main Parking Lot Implementation

final class ParkingLot: ParkingLotService, ObservableObject {
    @Published private(set) var spots: [ParkingSpot]
    @Published private(set) var activeTickets: [String: ParkingTicket] = [:]
    
    private let paymentProcessor: PaymentProcessor
    private let allocationStrategy: SpotAllocationStrategy
    private let maxFloors: Int
    
    init(
        floors: Int = 3,
        spotsPerFloor: Int = 100,
        paymentProcessor: PaymentProcessor = StandardPaymentProcessor(),
        allocationStrategy: SpotAllocationStrategy = SmallestFitStrategy()
    ) {
        self.maxFloors = floors
        self.paymentProcessor = paymentProcessor
        self.allocationStrategy = allocationStrategy
        self.spots = Self.generateSpots(floors: floors, spotsPerFloor: spotsPerFloor)
    }
    
    private static func generateSpots(floors: Int, spotsPerFloor: Int) -> [ParkingSpot] {
        var spots: [ParkingSpot] = []
        
        for floor in 1...floors {
            for spotNumber in 1...spotsPerFloor {
                let spotType: SpotType
                
                // Distribution: 40% compact, 50% regular, 10% large
                switch spotNumber % 10 {
                case 1...4: spotType = .compact
                case 5...9: spotType = .regular
                default: spotType = .large
                }
                
                let spot = ConcreteParkingSpot(
                    id: "\(floor)-\(String(format: "%03d", spotNumber))",
                    spotType: spotType,
                    floor: floor
                )
                spots.append(spot)
            }
        }
        
        return spots
    }
    
    func parkVehicle(_ vehicle: Vehicle) async throws -> ParkingTicket {
        // Check if vehicle is already parked
        if activeTickets.values.contains(where: { $0.vehicleLicensePlate == vehicle.licensePlate }) {
            throw ParkingError.vehicleAlreadyParked
        }
        
        // Find available spot
        guard let availableSpotIndex = spots.firstIndex(where: { spot in
            allocationStrategy.findAvailableSpot(for: vehicle, in: [spot]) != nil
        }) else {
            throw ParkingError.noAvailableSpots
        }
        
        // Park the vehicle
        let success = spots[availableSpotIndex].parkVehicle(vehicle)
        guard success else {
            throw ParkingError.noAvailableSpots
        }
        
        // Create ticket
        let ticket = ParkingTicket(vehicle: vehicle, spot: spots[availableSpotIndex])
        activeTickets[ticket.id] = ticket
        
        return ticket
    }
    
    func exitVehicle(ticket: ParkingTicket, paymentMethod: PaymentMethod) async throws -> ExitResult {
        // Validate ticket
        guard let activeTicket = activeTickets[ticket.id] else {
            throw ParkingError.invalidTicket
        }
        
        // Find the spot
        guard let spotIndex = spots.firstIndex(where: { $0.id == activeTicket.spotId }) else {
            throw ParkingError.spotNotFound
        }
        
        let exitTime = Date()
        
        // Calculate fee
        let totalFee = paymentProcessor.calculateFee(for: activeTicket, exitTime: exitTime)
        
        // Process payment
        let paymentResult = try await paymentProcessor.processPayment(
            amount: totalFee,
            method: paymentMethod
        )
        
        // Remove vehicle from spot
        let removedVehicle = spots[spotIndex].removeVehicle()
        guard removedVehicle != nil else {
            throw ParkingError.vehicleNotFound
        }
        
        // Remove ticket from active tickets
        activeTickets.removeValue(forKey: ticket.id)
        
        let duration = exitTime.timeIntervalSince(activeTicket.entryTime)
        
        return ExitResult(
            ticket: activeTicket,
            exitTime: exitTime,
            totalFee: totalFee,
            paymentResult: paymentResult,
            duration: duration
        )
    }
    
    func getAvailableSpots(for vehicleType: VehicleType) -> Int {
        let vehicleSize: VehicleSize
        switch vehicleType {
        case .motorcycle: vehicleSize = .small
        case .car: vehicleSize = .medium
        case .truck: vehicleSize = .large
        }
        
        return spots.count { spot in
            !spot.isOccupied && spot.spotType.maxVehicleSize >= vehicleSize
        }
    }
    
    func getOccupancyRate(for floor: Int? = nil) -> Double {
        let relevantSpots = floor != nil ? spots.filter { $0.floor == floor } : spots
        let occupiedSpots = relevantSpots.count { $0.isOccupied }
        
        guard !relevantSpots.isEmpty else { return 0.0 }
        return Double(occupiedSpots) / Double(relevantSpots.count)
    }
    
    // Additional utility methods
    func getFloorOccupancy() -> [Int: (occupied: Int, total: Int)] {
        var floorData: [Int: (occupied: Int, total: Int)] = [:]
        
        for floor in 1...maxFloors {
            let floorSpots = spots.filter { $0.floor == floor }
            let occupiedCount = floorSpots.count { $0.isOccupied }
            floorData[floor] = (occupied: occupiedCount, total: floorSpots.count)
        }
        
        return floorData
    }
    
    func getSpotsByType() -> [SpotType: (available: Int, total: Int)] {
        var spotData: [SpotType: (available: Int, total: Int)] = [:]
        
        for spotType in SpotType.allCases {
            let spotsOfType = spots.filter { $0.spotType == spotType }
            let availableCount = spotsOfType.count { !$0.isOccupied }
            spotData[spotType] = (available: availableCount, total: spotsOfType.count)
        }
        
        return spotData
    }
}

// MARK: - 9. Example Usage

// Example of how a parking lot management system would use the ParkingLot
@MainActor
class ParkingLotManager: ObservableObject {
    @Published var parkingLot: ParkingLot
    @Published var recentTransactions: [ExitResult] = []
    @Published var errorMessage: String?
    
    init(parkingLot: ParkingLot = ParkingLot()) {
        self.parkingLot = parkingLot
    }
    
    func parkVehicle(_ vehicle: Vehicle) async {
        do {
            let ticket = try await parkingLot.parkVehicle(vehicle)
            print("✅ Vehicle \(vehicle.licensePlate) parked successfully. Ticket ID: \(ticket.id)")
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to park vehicle: \(error)")
        }
    }
    
    func exitVehicle(ticket: ParkingTicket, paymentMethod: PaymentMethod) async {
        do {
            let exitResult = try await parkingLot.exitVehicle(ticket: ticket, paymentMethod: paymentMethod)
            recentTransactions.append(exitResult)
            
            let hours = exitResult.duration / 3600
            print("✅ Vehicle \(ticket.vehicleLicensePlate) exited successfully.")
            print("   Duration: \(String(format: "%.1f", hours)) hours")
            print("   Total Fee: $\(exitResult.totalFee)")
            
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to process vehicle exit: \(error)")
        }
    }
    
    func displayParkingStatus() {
        print("\n🅿️ Parking Lot Status:")
        print("Overall Occupancy: \(String(format: "%.1f", parkingLot.getOccupancyRate() * 100))%")
        
        let floorOccupancy = parkingLot.getFloorOccupancy()
        for floor in floorOccupancy.keys.sorted() {
            let data = floorOccupancy[floor]!
            let rate = Double(data.occupied) / Double(data.total) * 100
            print("Floor \(floor): \(data.occupied)/\(data.total) (\(String(format: "%.1f", rate))%)")
        }
        
        let spotsByType = parkingLot.getSpotsByType()
        print("\nSpots by Type:")
        for spotType in SpotType.allCases {
            let data = spotsByType[spotType]!
            print("\(spotType.rawValue): \(data.available) available / \(data.total) total")
        }
    }
}

// MARK: - 10. Demo Usage

func demonstrateParkingLotSystem() async {
    let manager = await ParkingLotManager()
    
    // Create some vehicles
    let motorcycle = Motorcycle(licensePlate: "BIKE123")
    let car1 = Car(licensePlate: "CAR456")
    let car2 = Car(licensePlate: "CAR789")
    let truck = Truck(licensePlate: "TRUCK001")
    
    print("🚗 Parking Lot System Demo")
    print(String(repeating: "=", count: 40))
    
    // Park vehicles
    await manager.parkVehicle(motorcycle)
    await manager.parkVehicle(car1)
    await manager.parkVehicle(car2)
    await manager.parkVehicle(truck)
    
    // Display status
    await manager.displayParkingStatus()
    
    // Simulate some time passing and then exit a vehicle
    let activeTickets = await manager.parkingLot.activeTickets
    if let ticket = activeTickets.values.first {
        // Wait a bit to simulate parking duration
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        await manager.exitVehicle(ticket: ticket, paymentMethod: .creditCard)
    }
    
    print("\n" + String(repeating: "=", count: 40))
    await manager.displayParkingStatus()
}

/*
 ================================================================================
 Interview Questions & Answers
 ================================================================================

 Q1: How does this design handle different vehicle sizes and parking spot compatibility?
 A1: The system uses a VehicleSize enum with comparable values (small=1, medium=2, large=3) and each SpotType has a maxVehicleSize property. The canFit() method in ParkingSpot checks if vehicle.size <= spotType.maxVehicleSize, ensuring that smaller vehicles can park in larger spots but not vice versa. This provides flexibility while maintaining logical constraints.

 Q2: Explain the different spot allocation strategies and when you would use each.
 A2: 
    - ClosestToEntranceStrategy: Prioritizes convenience by assigning spots closest to the entrance (lowest floor, lowest spot number). Best for customer satisfaction and reducing walking distance.
    - SmallestFitStrategy: Optimizes space utilization by assigning the smallest possible spot that can fit the vehicle. This maximizes overall capacity and is ideal for high-traffic scenarios.
    The strategy pattern allows easy switching between allocation methods based on business requirements or time of day.

 Q3: How does the payment system handle different pricing models?
 A3: The PaymentProcessor protocol abstracts payment logic, allowing different implementations. The current StandardPaymentProcessor calculates fees based on:
    - Duration (minimum 1 hour, rounded up)
    - Spot type hourly rates (Compact: $2, Regular: $3, Large: $5)
    This can be extended to support flat rates, peak/off-peak pricing, membership discounts, or dynamic pricing based on demand.

 Q4: How would you add support for reserved parking spots?
 A4: I would extend the ParkingSpot protocol to include:
    - var isReserved: Bool { get }
    - var reservedFor: String? { get } // License plate or user ID
    - var reservationExpiry: Date? { get }
    
    The canFit() method would check reservation status, and the allocation strategy would respect reservations. A ReservationManager could handle booking and expiry of reserved spots.

 Q5: How would you implement real-time notifications for spot availability?
 A5: I would add a NotificationService protocol and use Combine publishers:
    - @Published properties in ParkingLot for spot availability changes
    - Observer pattern for real-time updates to mobile apps or digital displays
    - Push notifications when preferred spot types become available
    - WebSocket connections for live dashboard updates

 Q6: How does this design support multiple parking lot locations?
 A6: The current design focuses on a single lot. For multiple locations, I would:
    - Create a ParkingLotNetwork class managing multiple ParkingLot instances
    - Add location identifiers and GPS coordinates
    - Implement a LocationService for finding nearby lots
    - Create a unified booking system across locations
    - Add inter-lot transfer capabilities for large vehicle fleets

 Q7: How would you handle peak hours and dynamic pricing?
 A7: I would create a DynamicPaymentProcessor that considers:
    - Time-based multipliers (peak hours: 1.5x, off-peak: 0.8x)
    - Occupancy-based pricing (higher rates when >80% full)
    - Event-based pricing (concerts, sports events)
    - Demand prediction using historical data
    The pricing strategy could be injected as a dependency, following the Open/Closed principle.

 Q8: What security measures would you implement?
 A8: Security considerations include:
    - Encrypted ticket QR codes with expiration timestamps
    - License plate recognition (LPR) integration for validation
    - Secure payment processing with PCI compliance
    - Access control for management functions
    - Audit trails for all transactions
    - Rate limiting for API endpoints to prevent abuse

 Q9: How would you optimize the system for high concurrency?
 A9: For high-traffic scenarios:
    - Use actor-based concurrency for thread-safe spot allocation
    - Implement optimistic locking for spot reservations
    - Cache frequently accessed data (availability counts)
    - Use database transactions for atomic operations
    - Implement circuit breakers for payment processing
    - Add request queuing during peak times

 Q10: How would you add support for electric vehicle charging stations?
 A10: I would extend the system with:
    - ChargingSpot protocol extending ParkingSpot
    - ChargingType enum (Level 1, Level 2, DC Fast)
    - ElectricVehicle protocol with battery capacity and charging requirements
    - ChargingService for managing power allocation and billing
    - Integration with smart charging algorithms to optimize grid usage
    - Separate pricing for parking vs. charging time

 Q11: How does this design follow SOLID principles?
 A11:
    - Single Responsibility: Each class has one job (ParkingLot manages spots, PaymentProcessor handles payments)
    - Open/Closed: New vehicle types, spot types, or payment methods can be added without modifying existing code
    - Liskov Substitution: Any PaymentProcessor or SpotAllocationStrategy implementation can be substituted
    - Interface Segregation: Protocols are focused and don't force unnecessary dependencies
    - Dependency Inversion: High-level ParkingLot depends on abstractions (protocols), not concrete implementations

 Q12: How would you implement a mobile app integration?
 A12: For mobile integration:
    - RESTful API layer wrapping the ParkingLotService
    - Real-time updates using WebSockets or Server-Sent Events
    - QR code generation for tickets
    - GPS integration for navigation to assigned spots
    - Push notifications for reservation reminders and payment due
    - Offline capability for viewing active tickets
    - Integration with mobile payment systems (Apple Pay, Google Pay)

 ================================================================================
*/

