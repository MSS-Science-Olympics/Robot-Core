//
//  RemoteCommandProvider.swift
//
//
//  Created by 0x41c on 2024-02-18.
//

import Foundation

protocol RemoteCommandProvider: CommandInterface {
  /// The username to login to in the remote machine
  var username: String { get }
  /// The hostname of the remote machine to establish a connection over
  var hostname: String { get }
  /// The port facilitating a remote connection through
  var port: UInt16 { get }
}

extension RemoteCommandProvider {
  var port: UInt16 { 22 }
}
