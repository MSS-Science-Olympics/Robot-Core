//
//  CoreConfiguration.swift
//
//
//  Created by 0x41c on 2024-02-13.
//

/// Arpy's main configuration.
protocol CoreConfigurationSchema: ConfigurationData {
    var homeFolderName: String { get }
    var programID: String { get }
}

fileprivate struct Default: CoreConfigurationSchema {
    var homeFolderName = ".arpycore"
    var programID = "ca.bc.sd57.student.arpycore"
}

struct CoreConfiguration: CoreConfigurationSchema {
    var homeFolderName: String
    var programID: String
}

extension CoreConfiguration {
    static var `default`: CoreConfigurationSchema { Default() as CoreConfigurationSchema }
}
