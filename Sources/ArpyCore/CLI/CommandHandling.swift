//
//  CommandHandling.swift
//
//
//  Created by 0x41c on 2024-02-15.
//

import Foundation
import ArgumentParser
import Logging

/// Command interceptor providing core soft initialization before command handling
public protocol ArpyCommand: AsyncParsableCommand {
  /// Redirected command entrypoint
  func runCmd() async throws
}

extension ArpyCommand {
  /// Redirects to ``Core.softInit``
  public func run() async throws {
    try await Core.softInit(self as ArpyCommand)
    // We need to softInit regardless of the context to establish logging/configuration
    if Self.self == MainArpyCommand.self {
      guard let main = self as? MainArpyCommand else {
        fatalError("unreachable")
      }
      guard !main.suppressHelp else { return }
      print(Self.helpMessage())
      return
    }
    try await runCmd()
  }

  public func runCmd() {}
}

public protocol MainArpyCommand: ArpyCommand {
  var suppressHelp: Bool { get set }
  var cleanHomeDir: Bool { get set }
  var logLevel: Logger.Level { get set }
}

extension Logger.Level: EnumerableFlag {}
