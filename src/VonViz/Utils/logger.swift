
import os

//
//  Log.swift
//  YourApp
//
//  Created by [Your Name or Team] on YYYY-MM-DD
//  Author: ChatGPT (OpenAI) – contributed logging utility wrapper
//

/// Application-wide logging utility.
///
/// Provides singleton-like access to categorized loggers so you can
/// write structured logs with simple calls like:
///
/// ```swift
/// Log.View.info("MainView appeared")
/// Log.Model.debug("Loaded \(rows.count) rows")
/// Log.Model.error("❌ Failed to parse API response")
/// Log.Model.fault("🔥 Unrecoverable state: database corrupted")
/// ```
struct Log {
    
    /// Logger for **view/UI layer** events.
    ///
    /// - Category: `"view"`
    /// - Usage:
    ///   ```swift
    ///   Log.View.info("User tapped chart point at x=\(x)")
    ///   ```
    struct UserView {
        private static let logger = Logger(subsystem: "edu.Neumann.VonViz", category: "view")
        
        static func debug(_ message: String) { logger.debug("\(message, privacy: .public)") }
        static func info(_ message: String) { logger.info("\(message, privacy: .public)") }
        static func error(_ message: String) { logger.error("\(message, privacy: .public)") }
        static func fault(_ message: String) { logger.fault("\(message, privacy: .public)") }
    }
    
    /// Logger for **model/data layer** events.
    ///
    /// - Category: `"model"`
    /// - Usage:
    ///   ```swift
    ///   Log.Model.error("Database connection lost")
    ///   ```
    struct Model {
        private static let logger = Logger(subsystem: "edu.Neumann.VonViz", category: "model")
        
        static func debug(_ message: String) { logger.debug("\(message, privacy: .public)") }
        static func info(_ message: String) { logger.info("\(message, privacy: .public)") }
        static func error(_ message: String) { logger.error("\(message, privacy: .public)") }
        static func fault(_ message: String) { logger.fault("\(message, privacy: .public)") }
    }
    
    /// Logger for **Lang layer** events.
    ///
    /// - Category: `"Lang"`
    /// - Usage:
    ///   ```swift
    ///   Log.Lang.error("Could not parse input")
    ///   ```
    struct Lang {
        private static let logger = Logger(subsystem: "edu.Neumann.VonViz", category: "Lang")
        
        static func debug(_ message: String) { logger.debug("\(message, privacy: .public)") }
        static func info(_ message: String) { logger.info("\(message, privacy: .public)") }
        static func error(_ message: String) { logger.error("\(message, privacy: .public)") }
        static func fault(_ message: String) { logger.fault("\(message, privacy: .public)") }
    }
}
