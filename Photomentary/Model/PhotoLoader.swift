//
//  PhotoLoader.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/7/23.
//

import Foundation
import AMSMB2

class PhotoLoader {
    // Adjust the next five constants as needed for your Network Storage
    let server = URL(string: "smb://XXX")!
    let share = "XXX"
    let user = "XXX"
    let password = "XXX"
    let encrypted = false
    
    let resource_name = "photos.txt"
    let paths: [String]
    var photos: [Photo] = []
    
    init() {
        print("Start PhotoLoader Init: \(Date())")
        if let fileURL = Bundle.main.url(forResource: "photos", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileURL) {
                paths = fileContents.split(separator:"\n").map { String($0) }
            } else {
                paths = []
            }
        } else {
            paths = []
        }
        print("Paths loaded: \(Date())")
    }
    
    func load(_ n: Int, completion: @escaping (Photo) -> Void) {
        for _ in 0..<n {
            if let path = paths.randomElement() {
                load(path: path, completion: completion)
            }
        }
    }
    
    func fullPath(_ path: String) -> String {
        //return "smb://192.168.0.10/Photos/" + path
        return "Photos/" + path
    }
    
    func name(path: String?) -> String? {
        
        guard let path = path else { return nil }
        guard let lastDot = path.lastIndex(of: ".") else { return path }
        guard let lastSlash = path.lastIndex(of: "/") else { return path }

        if path.contains("Traci's Web Page") {
            return path.dropFirst(5)[..<lastSlash].replacingOccurrences(of: "/", with: " - ")
        }
        if path.hasPrefix("2002/Spring Mexico Trip/") {
            return path.dropFirst(2)[..<lastDot].replacingOccurrences(of: "/", with: " - ")
        }
        if path.hasPrefix("Good Old Pictures/") {
            return path.dropFirst(18)[..<lastDot].replacingOccurrences(of: "/", with: " - ")
        }

        if path.hasPrefix("FIrst Day of School/") ||
            path.hasPrefix("Mom and Dad Slides") ||
            path.hasPrefix("2002/") {
            return path[..<lastSlash].replacingOccurrences(of: "/", with: " - ")
        }
        if path.hasPrefix("19") ||
            path.hasPrefix("20") {
            let path2 = path[..<lastSlash]
            guard let start = path2.lastIndex(of: "/") else { return String(path2) }
            let start1 = path2.index(after: start)
            return String(path2[start1..<path2.endIndex])
        }
        // default
        return path[..<lastDot].replacingOccurrences(of: "/", with: " - ")
    }
    
    func load(path: String, completion: @escaping (Photo) -> Void) -> Void {
        print("load: Start: \(Date())")
        let caption = name(path: path) ?? path
        let fullPath = fullPath(path)
        let credential = URLCredential(user: user, password: password, persistence: .forSession)
        let smb = AMSMB2(url: server, credential: credential)!
        print("load: Connect: \(Date())")
        smb.connectShare(name: share, encrypted: encrypted) { (error) in
            if let error = error {
                print("Connect failed: \(error)")
                return
            }
            print("load: Connected: \(Date())")
            smb.contents(atPath: fullPath, progress: { (progress, total) -> Bool in
                //print("downloaded: \(progress) of \(total)")
                return true
            }, completionHandler: { result in
                switch result {
                case .success(let rdata):
                    let photo = Photo(path: path, caption: caption, data: rdata)
                    print("load: Loaded: \(Date())")
                    completion(photo)
                case .failure(let error):
                    print("Download of \(fullPath) failed: \(error.localizedDescription)")
                }
            })
            smb.disconnectShare(gracefully: true)
        }
    }
}
