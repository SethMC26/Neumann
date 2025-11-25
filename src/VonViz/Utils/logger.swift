/*
 *   Copyright (C) 2025  Seth Holtzman
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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
