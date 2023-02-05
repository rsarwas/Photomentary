//
//  Photo.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/4/23.
//

struct Photo {
    let path: String
    let caption: String
}

extension Photo {
    static var defaultPhoto: Photo {
        Photo(
            path: "image1",
            caption: "Regan and Jenny's Photo Album"
        )
    }
}
