//
//  RSyncInterface.swift
//
//
//  Created by 0x41c on 2024-02-19.
//

import Foundation

public struct RSyncInterface: RemoteCommandProvider {
  let executableBinaryName: String = "rsync"
  let username: String
  let hostname: String

  public init(username: String, hostname: String) {
    self.username = username
    self.hostname = hostname
  }

  /// Syncs a local directory with a remote directory.
  ///
  /// - Note: Equivilent to:
  /// `$ rsync -a --delete [... --exclude=<excluding>] <localBaseDir> <username>@<hostname>:<remoteBaseDir>`
  @discardableResult
  public func sync(
    localBaseDir: URL,
    remoteBaseDir: URL,
    excluding: [String],
    livePrint: Bool = false
  ) throws -> CommandOutput {
    guard !localBaseDir.pathComponents.isEmpty else {
      throw RSError.emptyLocal
    }
    guard !remoteBaseDir.pathComponents.isEmpty else {
      throw RSError.emptyRemote
    }

    var arguments = ["-a", "--delete"] + excluding.map({ pattern in
      "--exclude=\(pattern)"
    })

    arguments.append(localBaseDir.absoluteFilePath)
    arguments.append("\(username)@\(hostname):\(remoteBaseDir.absoluteFilePath)")
    
    let cond: (String) -> Void  = { line in
      if livePrint { print(line) }
    }
    return try exec(arguments, didOutput: cond, didError: cond)
  }

}

extension RSyncInterface {
  public enum RSError: Error {
    case emptyLocal
    case emptyRemote
  }
}
