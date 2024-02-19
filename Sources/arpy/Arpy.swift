//
//  Arpy.swift
//
//
//  Created by 0x41c on 2024-02-10.
//

import ArpyCore
import ArgumentParser
import Logging

@main
struct Arpy: MainArpyCommand {
  @Flag(help: "Suppresses help dialog")
  var suppressHelp = false
  @Flag(help: "Removes the default home directory if it exists for intialization development")
  var cleanHomeDir = false
  @Flag(help: "Sets the core log level")
  var logLevel: Logger.Level = .info

  static var configuration = CommandConfiguration(
    abstract: "An \"Autonomous Robotic Produce Yielder\" for the 2024 Mackenzie Science Olympics Team Challenge",
    subcommands: [Boot.self]
  )
}
