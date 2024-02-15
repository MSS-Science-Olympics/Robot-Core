//
//  Arpy.swift
//
//
//  Created by 0x41c on 2024-02-10.
//

import ArgumentParser

/// Command interceptor allowing core soft initialization before command handling
protocol ArpyCommand : AsyncParsableCommand {
    /// Redirected command entrypoint
    func runCmd() async throws
}

extension ArpyCommand {
    func run() async throws {
        do {
            try await Core.softInit(self)
        }
        if (Self.self == Arpy.self) { // We need to softInit regardless of the context to establish logging/configuration
            #if DEBUG
            guard !(self as! Arpy).suppressHelp else { return }
            #endif
            print(Self.helpMessage())
            return
        }
        try await runCmd()
    }
    
    func runCmd() {}
}

@main
struct Arpy: ArpyCommand {
#if DEBUG
    @Flag(help: "Suppresses help dialog")
    var suppressHelp = false
    @Flag(help: "Removes the default home directory if it exists for intialization development")
    var cleanHomeDir = false
#endif
    static var configuration = CommandConfiguration(
        abstract: "An \"Autonomous Robotic Produce Yielder\" for the 2024 Mackenzie Science Olympics Team Challenge",
        subcommands: [Boot.self]
    )
}
