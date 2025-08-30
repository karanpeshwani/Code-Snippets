//
//  Test-1.swift
//  DSA_Playground
//
//  Created by Karan Peshwani on 26/08/25.
//

import Foundation

/*
 Design a logging system.
 should handle logging via:
 - API
 - console
 - File
 */


/*
 Modelling:
 
 LoggingService:
 - add logger
 - remove logger
 - log
 - Facade:
     - log Console
     - log remote
     - log file
     - log critical
     - log warning
 
 
 enum logLevel -> debug, info, warning, critical
 
 LoggerProtocol
 - id
 - minLogLevel
 - log
 */

enum LogLevel: Int {
    case debug = 1, info, warning, critical
}

protocol LogProtocol {
    
    typealias Payload = [String: Any]
    
    var message: String { get }
    var level: LogLevel { get }
    var timeStamp: Date { get }
    var payload: Payload { get }
}

struct LogV1: LogProtocol {
    
}

protocol LoggingDestinationProtocol {
    
    var id: Int { get }
    
    var minLogLevel: LogLevel { get }
    
    func log()
    
}


final class LoggingService {
    
    func addLogger() {
        
    }
    
    func removeLogger() {
        
    }
    
}
