//
//  Core.swift
//
//
//  Created by 0x41c on 2024-02-11.
//

import System
import Logging
import Foundation

/// Central robot controller
class Core {
    
    private static var _core: Core?
    static var core: Core {
        guard _core == nil else { return _core! }
        fatalError("Core accessed before call to softInit")
    }
    static var defaultConfig: CoreConfigurationSchema = CoreConfiguration.default
    
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    /// Initializes the core and performs required checks for pre-requisites without
    /// instantiating any non-essental services. This is the only initialization stage
    /// called when the command is not `arpy boot`
    static func softInit(_ command: ArpyCommand? = nil) async throws {
        LoggingSystem.bootstrap(GlobalLogHandler.init)
        var logger = Logger(label: defaultConfig.programID)
        
        #if DEBUG
        logger.logLevel = .debug
        #endif
        
        logger.debug("Initializing Core")
        
        let fm = FileManager.default
        let userHome = fm.homeDirectoryForCurrentUser
        let arpyHome = userHome.appending(path: defaultConfig.homeFolderName.string)
        let homeString = arpyHome.absoluteString
        
        var homeDirectoryExists: ObjCBool = false
        let homeTaken = fm.fileExists(atPath: homeString, isDirectory: &homeDirectoryExists)
        
        guard !(homeTaken && !homeDirectoryExists.boolValue) else {
            throw Core.InitializationError.homeDirConflict
        }
        
        var exists = homeDirectoryExists.boolValue
        
        logger.debug("\(homeString): \(homeTaken),\(homeDirectoryExists.boolValue)")
        
        #if DEBUG
        let rp = (command as? Arpy)
        if rp != nil && exists && rp!.cleanHomeDir {
            logger.debug("Removing existing home directory")
            try fm.removeItem(at: arpyHome)
        }
        exists = false
        #endif
        
        if !exists {
            logger.debug("Creating home directory")
            // Creating a directory using the homeString results in it forcing the file scheme
            try fm.createDirectory(at: arpyHome, withIntermediateDirectories: false)
        }
        
        
    }
    
}

extension Core {
    enum InitializationError: Error {
        case homeDirConflict
    }
}
