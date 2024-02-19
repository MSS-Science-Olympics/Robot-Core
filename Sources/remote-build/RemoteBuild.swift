//
//  RemoteBuild.swift
//
//
//  Created by 0x41c on 2024-02-15.
//

import Foundation
import ArgumentParser
import Logging
import ArpyCore

var logger: Logger = Logger(label: DefaultConfiguration.logging.identifier)

enum RemoteBuildError: Error {
  case unableToConnect
}

@main
struct RemoteBuild: AsyncParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "remote-build",
    abstract: "Connects and builds arpy on a remote raspberry-pi target"
  )

  @Flag
  var debug = false

  func run() async throws {
    logger.logLevel = debug ? .debug : .info
    let ssh = SSHInterface(
      username: DefaultConfiguration.sshData.username,
      hostName: DefaultConfiguration.sshData.hostname
    )
    // Foolproof
    let ack = try await ssh.remote(command: "echo", arguments: ["ack"], livePrint: debug)
    guard ack.error.isEmpty else {
      logger.error("Unable to establish connection with Raspberry Pi:")
      for line in ack.error {
        print("\(line)")
      }
      throw RemoteBuildError.unableToConnect
    }
  }
}

/// Default values/paths that are used to connect to the raspberry pi during development.
struct DefaultConfiguration {
  static let logging = (identifier: "ca.bc.sd57.student.arpy.remote-build", level: Logger.Level.debug)
  /// - Note: The host machine executing this command needs to be preconfigured to connect
  /// to the pi without a requied password through `ssh-keygen` in tandem with `ssh-copy-id`.
  static let sshData = (hostname: "rp.local", username: "rp")
}
