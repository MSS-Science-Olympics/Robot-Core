//
//  URL+filePath.swift
//
//
//  Created by 0x41c on 2024-02-19.
//

import Foundation

public extension URL {
  /// Returns the url in the form of a relative file path only if the url is a file.
  /// 
  /// If the url isn't relative to begin with, this will output `absoluteFilePath`
  var relativeFilePath: String {
    guard isFileURL else { return "" }
    return relativeString.replacingOccurrences(of: "file://", with: "")
  }

  /// Returns the url in the form of an absolute file path
  var absoluteFilePath: String {
    guard isFileURL else { return "" }
    return absoluteString.replacingOccurrences(of: "file://", with: "")
  }

  /// Removes the last `k` components from the url path.
  ///
  /// This function may either remove a path component, or append `/..`.
  ///
  /// If the URL has an empty path (e.g: `http://www.example.com`) it'll
  /// do nothing.
  mutating func deleteLastPathComponents(_ count: Int) {
    let componentCount = pathComponents.count
    let removing = if componentCount < count { componentCount } else { count }
    for _ in 1...removing { deleteLastPathComponent() }
  }

  /// Creates a new instance and removes the last `k` components from the
  /// url path of that instance.
  ///
  /// This function may either remove a path component, or append `/..`.
  ///
  /// If the URL has an empty path (e.g: `http://www.example.com`) it'll
  /// do nothing.
  func deletingLastPathComponents(_ count: Int) -> URL {
    /// Instead of interfacing with CoreFoundation, we could just copy ourselves
    /// into another region and mutate there... right?
    let copyAddr = UnsafeMutablePointer<URL>.allocate(capacity: 1)
    withUnsafePointer(to: self) { pointer in
      copyAddr.initialize(from: pointer, count: 1)
    }
    var copy = copyAddr.move()
    copy.deleteLastPathComponents(count)
    return copy
  }
}
