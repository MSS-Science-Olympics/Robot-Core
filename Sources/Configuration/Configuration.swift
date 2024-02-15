//
//  Configuration.swift
//
//
//  Created by 0x41c on 2024-02-11.
//


import Foundation

/// Data used for configuration and preferences, stored and read as JSON.
protocol ConfigurationData: Codable {}

enum ConfigurationError: Error {
    case noReadPermission
    case noWritePermission
}

extension ConfigurationData {
    /// Reads configuration data from a given JSON file path.
    static func read(_ type: ConfigurationData.Type, fromFile jsonFile: URL) throws -> ConfigurationData {
        let data = try Data(contentsOf: jsonFile)
        return try JSONDecoder().decode(type, from: data)
    }
    
    /// Writes configuration data to a given JSON file path.
    static func write(_ config: ConfigurationData, toFile jsonFile: URL) async throws {
        let data = try JSONEncoder().encode(config)
        if FileManager.default.fileExists(atPath: jsonFile.absoluteString) {
            try String(data: data, encoding: .utf8)?.write(to: jsonFile, atomically: true, encoding: .utf8)
        }
    }
}
