//
//  CommandInterface.swift
//
//
//  Created by 0x41c on 2024-02-16.
//

import Foundation

protocol CommandInterface {
  /// The command we want to interface with.
  var executableBinaryName: String { get }
  /// The directory containing the binary
  var executableDirectory: String { get }
}

extension CommandInterface {
  // Available for overwrite by implementation
  var executableDirectory: String { "/usr/bin" }
  var executablePath: String { "\(executableDirectory)/\(executableBinaryName)" }

  private func parseOutput(_ handle: FileHandle) -> String? {
    guard let line = String(data: handle.availableData, encoding: .utf8) else {
      fatalError("Failed to parse command output.")
    }
    guard !line.isEmpty else { return nil }
    return line.replacingOccurrences(of: "\n", with: "")
  }

  internal func exec(
    _ arguments: [String],
    didOutput: @escaping (String) -> Void,
    didError: @escaping (String) -> Void
  ) throws -> CommandOutput {
    let process = Process()
    let stdout = Pipe()
    let stderr = Pipe()
    var outLines = [String]()
    var errLines = [String]()

    stdout.fileHandleForReading.readabilityHandler = { handle in
      guard let parsed = parseOutput(handle) else { return }
      outLines.append(parsed)
      didOutput(parsed)
    }
    stderr.fileHandleForReading.readabilityHandler = { handle in
      guard let parsed = parseOutput(handle) else { return }
      errLines.append(parsed)
      didError(parsed)
    }

    process.executableURL = URL(fileURLWithPath: executablePath)
    process.standardOutput = stdout
    process.arguments = arguments

    try process.run()
    process.waitUntilExit()

    stdout.fileHandleForReading.readabilityHandler = nil
    stderr.fileHandleForReading.readabilityHandler = nil

    return (outLines, errLines)
  }
}

/// A simple tuple representing the possible output given by a command
public typealias CommandOutput = (out: [String], error: [String])
