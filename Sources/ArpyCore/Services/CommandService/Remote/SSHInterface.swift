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
  public func remote(
    command: String,
    arguments: [String],
    livePrint: Bool = false
  ) async throws -> CommandOutput {
    let sshArguments = [
      "\(username)@\(hostname)", "-p", "\(port)", command
    ] + arguments

    var out = [String]()
    var error = [String]()

    try exec(sshArguments) { outLine in
      if livePrint { print(outLine) }
      out.append(outLine)
    } didError: { errorLine in
      if livePrint { print(errorLine) }
      error.append(errorLine)
    }

    return (out, error)
  }
}

extension SSHInterface {
  /// An incomplete list of errors thrown by the ssh cli output
  enum SSHError: Error {
    case hostnameNotFound
    case noSustainedConnectionSupported
  }
}
