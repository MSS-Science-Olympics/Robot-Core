//
//  Core.swift
//
//
//  Created by 0x41c on 2024-02-11.
//

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
        var home = fm.homeDirectoryForCurrentUser
        home.append(path: defaultConfig.homeFolderName)
        
        for didFail in 0...1 {
            do {
                // Attempting to determine if the directory exists outside of this function doesn't work – likely because
                // of the nature of the final path component. (It treats it as a file because of the "."). Therefore,
                // to circumvent this, we use the error thrown from here as an indicator.
                try fm.createDirectory(at: home, withIntermediateDirectories: false)
                logger.debug("Created home directory")
                // If we're here, there's no need to try again.
                break
            } catch {
                #if DEBUG
                let rp = (command as? Arpy)
                if rp != nil && rp!.cleanHomeDir {
                    logger.debug("Removing existing home directory")
                    try fm.removeItem(at: home)
                }
                
                #else
                guard didFail != 1 else { throw error }
                break // It exists so we can get out of the loop
                #endif
            }
        }
    }
    
}

extension Core {
    enum InitializationError: Error {
        case homeDirConflict
    }
}
