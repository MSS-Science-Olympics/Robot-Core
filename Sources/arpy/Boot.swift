//
//  Boot.swift
//
//
//  Created by 0x41c on 2024-02-11.
//

import ArgumentParser
import ArpyCore

extension Arpy {
  /// Triggers full core initialization.
  struct Boot: ArpyCommand {
    static var configuration = CommandConfiguration(
      abstract: "Starts Arpy's core services"
    )

    func runCmd() async throws {
      // Platform detection, configuration loading and service detection has been done
      // Check loaded-services
    }
  }
}
