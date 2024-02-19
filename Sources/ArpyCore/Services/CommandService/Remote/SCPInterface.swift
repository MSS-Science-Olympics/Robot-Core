//
//  SCPInterface.swift
//
//
//  Created by 0x41c on 2024-02-18.
//

import Foundation

public struct SCPInterface: RemoteCommandProvider {
  let executableBinaryName: String = "scp"
  let username: String
  let hostname: String

  public init(username: String, hostName: String) {
    self.username = username
    self.hostname = hostName
  }

  public func scp(sourcePath: URL, destinationPath: URL) async throws {
    let fullPath = sourcePath.absoluteString
  }

  public func copy(directory: URL, to: URL) {}
  public func copy(file: URL, to: URL) {}
}
