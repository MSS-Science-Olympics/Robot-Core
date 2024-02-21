//
//  SSHInterface.swift
//
//
//  Created by 0x41c on 2024-02-16.
//

import Foundation

public struct SSHInterface: RemoteCommandProvider {
  let executableBinaryName: String = "ssh"
  let username: String
  let hostname: String

  public init(username: String, hostName: String) {
    self.username = username
    self.hostname = hostName
  }

  /// Executes a remote command through ssh.
  ///
  ///
  /// - Note: Equivilent to ```ssh <username>@<hostname> -p <port> <command> ...<arguments>```
  @discardableResult
  public func remote(
    command: String,
    arguments: [String],
    livePrint: Bool = false
  ) throws -> CommandOutput {
    let sshArguments = [
      "\(username)@\(hostname)", "-p", "\(port)", command
    ] + arguments

    let cond: (String) -> () = { line in
      if livePrint { print(line) }
    }

    return try exec(sshArguments, didOutput: cond, didError: cond)
  }
}

extension SSHInterface {
  /// An incomplete list of errors thrown by the ssh cli output
  enum SSHError: Error {
    case hostnameNotFound
    case noSustainedConnectionSupported
  }
}
