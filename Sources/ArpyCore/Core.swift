//
//  Core.swift
//
//
//  Created by 0x41c on 2024-02-11.
//

import Logging
import Foundation

/// Central robot controller
public class Core {

  private static var _core: Core?
  static var core: Core {
    guard _core == nil else { return _core! }
    fatalError("Core accessed before call to softInit")
  }
  static var defaultConfig: CoreConfigurationSchema = CoreConfiguration.default

  static private(set) var logger: Logger = {
    LoggingSystem.bootstrap(GlobalLogHandler.init)
    return Logger(label: defaultConfig.programID)
  }()

  /// Initializes the core and performs required checks for pre-requisites without
  /// instantiating any non-essental services. This is the only initialization stage
  /// called when the command is not `arpy boot`
  static func softInit(_ command: ArpyCommand? = nil) async throws {
    if let main = command as? MainArpyCommand {
      logger.logLevel = main.logLevel
    }

    logger.debug("Initializing Core")

    let defaultManager = FileManager.default
    var home = defaultManager.homeDirectoryForCurrentUser
    #if os(macOS)
    home.append(path: defaultConfig.homeFolderName)
    #else
    home = home.appendingPathComponent(defaultConfig.homeFolderName, isDirectory: true)
    #endif

    for didFail in 0...1 {
      do {
        // Attempting to determine if the directory exists outside of this function doesn't work – likely because
        // of the nature of the final path component. (It treats it as a file because of the "."). Therefore,
        // to circumvent this, we use the error thrown from here as an indicator.
        try defaultManager.createDirectory(at: home, withIntermediateDirectories: false)
        logger.debug("Created home directory")
        // If we're here, there's no need to try again.
        break
      } catch {
        if logger.logLevel == .debug {
          let main = (command as? MainArpyCommand)
          if main != nil && main!.cleanHomeDir {
            logger.debug("Removing existing home directory")
            try defaultManager.removeItem(at: home)
          }
        }

        guard didFail != 1 else { throw error }
        break // It exists so we can get out of the loop
      }
    }
  }

}

extension Core {
  enum InitializationError: Error {
    case homeDirConflict
  }
}
