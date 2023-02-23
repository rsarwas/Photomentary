//
//  Photo.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/4/23.
//

import Foundation // for Data
import SwiftUI    // for Image
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct Photo {
    let path: String
    let caption: String
    let data: Data
}

extension Photo {
    static var defaultPhoto: Photo {
        Photo(
            path: "Splash",
            caption: "Regan and Jenny's Photo Album",
            data: Data()
        )
    }
}

extension Photo {
#if os(macOS)
    var image: Image {
        // TODO: This This method should not be called on the main thread as it may lead to UI unresponsiveness.
        if let image = NSImage(data: data) {
            return Image(nsImage: image)
        }
        return Image(Photo.defaultPhoto.path)
    }
    #else
    var image: Image {
        if let image = UIImage(data: data) {
            return Image(uiImage: image)
        }
        return Image(Photo.defaultPhoto.path)
    }
    #endif
}
