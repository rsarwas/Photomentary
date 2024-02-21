//
//  PhotoLoader.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/7/23.
//

import AMSMB2
import Foundation

class PhotoLoader {
  // Adjust the next five constants as needed for your Network Storage
  let server = URL(string: "smb://XXX")!
  let share = "XXX"
  let user = "XXX"
  let password = "XXX"
  let encrypted = false

  let resource_name = "photos.txt"
  private var paths: [String] = []
  private var photos: [Photo] = []

  private var smb: AMSMB2?

  deinit {
    smb?.disconnectShare(gracefully: true)
  }

  func connect() async -> Bool {
    let credential = URLCredential(user: user, password: password, persistence: .forSession)
    smb = AMSMB2(url: server, credential: credential)
    guard let smb = smb else { return false }
    return await withCheckedContinuation { continuation in
      smb.connectShare(name: share, encrypted: encrypted) { error in
        continuation.resume(returning: error == nil)
      }
    }
  }

  func loadPathsFromBundle() async -> Bool {
    await self.paths =
      Task {
        if let fileURL = Bundle.main.url(forResource: "photos", withExtension: "txt") {
          if let fileContents = try? String(contentsOf: fileURL) {
            return fileContents.split(separator: "\n").map { String($0) }
          }
        }
        return []
      }.value
    return !self.paths.isEmpty
  }

  func fullPath(_ path: String) -> String {
    return "Photos/" + path
  }

  func name(path: String?) -> String? {

    guard let path = path else { return nil }
    guard let lastDot = path.lastIndex(of: ".") else { return path }
    guard let firstSlash = path.firstIndex(of: "/") else { return path }
    guard let lastSlash = path.lastIndex(of: "/") else { return path }

    func startsWithYear(_ path: String) -> Bool {
      guard path.hasPrefix("19") || path.hasPrefix("20") else { return false }
      guard path.dropFirst(4).hasPrefix("/") else { return false }
      return true
    }

    func isTypical(_ path: String) -> Bool {
      return path.dropFirst(5).starts(with: path[..<firstSlash])
    }

    func named_photo(in path: String) -> Bool {
      let filename = URL(fileURLWithPath: path).lastPathComponent
      return !filename.starts(with: "IMG") && !filename.starts(with: "P000")
        && !filename.starts(with: "p_v1")
    }

    if startsWithYear(path) {
      if isTypical(path) {
        // year/year-mon-day description{/subfolder}/file.ext -> year-mon-day description{ - subfolder}
        let start = path.index(after: firstSlash)
        return path[start..<lastSlash].replacingOccurrences(of: "/", with: " - ")
      } else {
        // Exceptions to typical year folder
        // 2002/activity/subactivity/../filename.ext -> 2002 - activity - subactivity - ..
        if named_photo(in: path) {
          return path[..<lastDot].replacingOccurrences(of: "/", with: " - ")
        } else {
          return path[..<lastSlash].replacingOccurrences(of: "/", with: " - ")
        }
      }
    }

    // default
    // blah/blab/blah.ext -> blah - blah - blah
    if named_photo(in: path) {
      return path[..<lastDot].replacingOccurrences(of: "/", with: " - ")
    } else {
      return path[..<lastSlash].replacingOccurrences(of: "/", with: " - ")
    }
  }

  func load() async -> Photo? {
    guard let path = paths.randomElement() else { return nil }
    return await load(path: path)
  }

  func load(path: String) async -> Photo? {
    //print("load: \(path)")
    let caption = name(path: path) ?? path
    let fullPath = fullPath(path)
    guard let smb = smb else { return nil }
    return await withCheckedContinuation { continuation in
      smb.contents(
        atPath: fullPath,
        progress: { (progress, total) -> Bool in
          //print("load: downloaded: \(progress) of \(total)")
          return true
        },
        completionHandler: { result in
          switch result {
          case .success(let rdata):
            let photo = Photo(path: path, caption: caption, data: rdata)
            //print("load: Loaded: \(Date())")
            continuation.resume(returning: photo)
          case .failure(let error):
            print("ERROR: Download of \(fullPath) failed: \(error.localizedDescription)")
            continuation.resume(returning: nil)
          }
        })
    }
  }
}
