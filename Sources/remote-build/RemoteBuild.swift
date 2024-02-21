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
  case unableToSync
  case buildFail
}

@main
struct RemoteBuild: AsyncParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "remote-build",
    abstract: "Connects, syncs, and builds arpy on a preconfigured remote raspberry-pi target"
  )

  @Flag
  var debug = false

  func run() async throws {
    logger.logLevel = debug ? .debug : .info
    let data = DefaultConfiguration.sshData
    let ssh = SSHInterface(username: data.username, hostName: data.hostname)
    // Foolproof
    let ack = try ssh.remote(command: "echo", arguments: ["ack"], livePrint: debug)
    guard ack.error.isEmpty else {
      logger.error("Unable to establish connection with Raspberry Pi:")
      for line in ack.error {
        print("\(line)")
      }
      throw RemoteBuildError.unableToConnect
    }
    let excludedIdentifiers = [".git", ".swiftpm", ".build", "Package.resolved"]
    let rsync = RSyncInterface(username: data.username, hostname: data.hostname)

    // Remove source path components: Sources/target/file
    let projectDir = URL(filePath: #filePath).deletingLastPathComponents(3)
    let remoteProjectDir = URL(filePath: DefaultConfiguration.remoteProjectFilePath)
    logger.info("Syncing directory \"\(projectDir.absoluteFilePath)\" with \"\(remoteProjectDir)\"")
    let syncResults = try rsync.sync(
      localBaseDir: projectDir,
      remoteBaseDir: remoteProjectDir,
      excluding: excludedIdentifiers,
      livePrint: debug
    )
    guard syncResults.error.count == 0 else {
      throw RemoteBuildError.unableToSync
    }

    logger.info("Building on Raspberry Pi...")
    let buildResult = try ssh.remote(
      command: "swift",
      arguments: [
        "build",
        "--package-path", "\(DefaultConfiguration.remoteProjectFilePath)",
        "--target", "ArpyCore" // TODO: Configurable targets
      ],
      livePrint: debug
    )
    guard buildResult.error.count == 0 else {
      throw RemoteBuildError.buildFail
    }
    logger.info("Finished remote-build")
  }
}

/// Default values/paths that are used to connect to the raspberry pi during development.
struct DefaultConfiguration {
  /// - Note: The host machine executing this command needs to be preconfigured to connect
  /// to the pi without a requied password through `ssh-keygen` in tandem with `ssh-copy-id`.
  static let sshData = (hostname: "rp.local", username: "rp")
  static let logging = (identifier: "ca.bc.sd57.student.arpy.remote-build", level: Logger.Level.debug)
  static let remoteProjectFilePath = "/home/rp/core/"
}
