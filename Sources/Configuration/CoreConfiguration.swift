//
//  CoreConfiguration.swift
//
//
//  Created by 0x41c on 2024-02-13.
//

import System

/// Arpy's main configuration.
protocol CoreConfigurationSchema: ConfigurationData {
    var homeFolderName: FilePath { get }
    var programID: String { get }
}

fileprivate struct Default: CoreConfigurationSchema {
    var homeFolderName = ".arpycore" as FilePath
    var programID = "ca.bc.sd57.student.arpycore"
}

struct CoreConfiguration: CoreConfigurationSchema {
    var homeFolderName: FilePath
    var programID: String
}

extension CoreConfiguration {
    static var `default`: CoreConfigurationSchema { Default() as CoreConfigurationSchema }
}
