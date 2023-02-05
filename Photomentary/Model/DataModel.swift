//
//  DataModel.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/4/23.
//

import Foundation
import Combine


final class DataModel: ObservableObject {
    @Published var currentPhoto = Photo.defaultPhoto
    @Published var displayInterval: TimeInterval = 2 {
        didSet {
            stop()
            start()
        }
    }
    private var currentPointer: Int = 0
    private var photos: [Photo] = [Photo.defaultPhoto]
    private var displayTimer: Cancellable?
    
    init() {
        photos = [
            Photo(path:"image1", caption:"2023-01-09 Wes in a Bucket"),
            Photo(path:"image2", caption:"2023-01-13 Kayaking Around the North Side of Caye Caulker"),
            Photo(path:"image3", caption:"2022-02-05 Hiking to Imperial Sand Dunes"),
            Photo(path:"image4", caption:"2022-02-05 Hiking to Imperial Sand Dunes"),
        ]
    }
    
    func start() {
        displayTimer = Timer.TimerPublisher(interval: displayInterval, tolerance: 0.5, runLoop: .main, mode: .common)
            .autoconnect()
            .sink() { [weak self] _ in self?.next() }
    }

    func stop() {
        displayTimer?.cancel()
    }

    func next() {
        currentPointer += 1
        currentPointer %= photos.count
        currentPhoto = photos[currentPointer]
    }
    
    func previous() {
        currentPointer -= 1
        if currentPointer < 0 {
            currentPointer = photos.count - 1
        }
        currentPhoto = photos[currentPointer]
    }

}
