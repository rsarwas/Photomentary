//
//  PhotoLoader.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/7/23.
//

import Foundation

class PhotoLoader {
    let resource_name = "photos.txt"
    let paths: [String]
    init() {
        if let fileURL = Bundle.main.url(forResource: "photos", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileURL) {
                paths = fileContents.split(separator:"\n").map { String($0) }
            } else {
                paths = []
            }
        } else {
            paths = []
        }
    }
    
    func url(path: String) -> String {
        return "smb://192.168.0.10/Photos/" + path
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
            return path.dropFirst(2)[..<lastSlash].replacingOccurrences(of: "/", with: " - ")
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
    
    var photo: Photo {
        let path = paths.randomElement()
        let image = ["image1", "image2", "image3", "image4"].randomElement()
        return Photo(path: image ?? "No Path", caption: name(path: path) ?? "No Name")
    }
}
