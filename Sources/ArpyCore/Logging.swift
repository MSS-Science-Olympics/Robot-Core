//
//  Logging.swift
//
//
//  Created by 0x41c on 2024-02-14.
//

import Foundation
import Logging

protocol LogFormatter {
  typealias LogData = (
    level: Logger.Level,
    identifier: String,
    message: Logger.Message,
    metadata: Logger.Metadata?,
    source: String,
    file: String,
    function: String,
    line: UInt,
    time: Date
  )

  static func processLog(data: LogData) -> String
  static var dateFormatter: DateFormatter { get }
}

enum LogComponent {
  case level
  case identifier
  case message
  case metadata
  case source
  case file
  case function
  case line
  case timestamp
  case string(String)
  case group([LogComponent])
}

extension Logger.Level {
  var displayString: String {
    switch self {
    case .critical:
      "CRITICAL"
    case .debug:
      "Debug"
    case .error:
      "ERROR"
    case .info:
      "Info"
    case .notice:
      "Notice"
    case .trace:
      "TRACE"
    case .warning:
      "WARNING"
    }
  }
}

extension LogFormatter {
  static var dateFormatter: DateFormatter {
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return format
  }

  // swiftlint:disable:next cyclomatic_complexity
  static func processComponent(_ componentType: LogComponent, data: LogData) -> String {
    switch componentType {
    case .level:
      data.level.displayString
    case .identifier:
      data.identifier
    case .message:
      "\(data.message)"
    case .metadata:
      // TODO: Dynamically configurable data formatting
      data.metadata == nil ? "" :
        (data.metadata?.map({ (key, value) in "\(key): \(value)"}).joined(separator: ",") ?? "")
        .wrappingWith(prefix: "[", suffix: "]")
    case .source:
      "\(data.source)"
    case .file:
      "\(data.file)"
    case .function:
      "\(data.function)"
    case .line:
      "\(data.line)"
    case .timestamp:
      dateFormatter.string(from: data.time)
    case .string(let value):
      value
    case .group(let components):
      components.map { component in processComponent(component, data: data)}.joined()
    }
  }
}

extension Core {
  struct GlobalLogHandler: LogHandler {
    subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
      get {
        return metadata[key]
      }
      set(newValue) {
        metadata[key] = newValue
      }
    }

    var metadata = Logger.Metadata()
    var logLevel: Logger.Level = .info
    var formatType: LogFormatter.Type = DefaultFormat.self
    var identifier: String {
      guard self[metadataKey: "identifier"] != nil else {
        fatalError("Identifier lost to the grim reaper")
      }
      return self[metadataKey: "identifier"]!.description
    }

    init(_ identifier: String) {
      self.metadata = .init()
      self.logLevel = .notice
      self[metadataKey: "identifier"] = .string(identifier)
    }

    // swiftlint:disable:next function_parameter_count
    func log(
      level: Logger.Level,
      message: Logger.Message,
      metadata: Logger.Metadata?,
      source: String,
      file: String,
      function: String,
      line: UInt
    ) {
      let args = (level, identifier, message, metadata, source, file, function, line, .now) as LogFormatter.LogData
      let formatted = formatType.processLog(data: args)
      // TODO: Integrate custom backend with Vapor and websocket transport
      print(formatted)
    }
  }
}

extension Core.GlobalLogHandler {
  struct DefaultFormat: LogFormatter {
    static func processLog(data: LogData) -> String {
      ([
        .timestamp,
        .identifier,
        .group([
          .level,
          .string(":")
        ]),
        .message,
        .metadata
      ] as [LogComponent]).map { component in
        processComponent(component, data: data)
      }.joined(separator: " ")
    }
  }
}

extension String {
  /// Wraps the current string instance with a given prefix and suffix
  func wrappingWith(prefix: String = "", suffix: String = "") -> String {
    "\(prefix)\(self)\(suffix)"
  }
}
