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
    @Published var displayInterval: TimeInterval = 6 {
        didSet {
            stop()
            start()
        }
    }
    private var currentPointer: Int = 0
    private var photos: [Photo] = [Photo.defaultPhoto]
    private var displayTimer: Cancellable?
    private let loader = PhotoLoader()
    private var insertPointer = 1
    private let cacheSize = 50 //max count in photos
    private var doNotDownloadCounter = 0 // a count of next() calls to wait before resuming downloads
    
    init() {
        loader.load(10) { [weak self] photo in
            self?.photos.append(photo)
        }
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
        if doNotDownloadCounter == 0 {
            loader.load(1) { [weak self] photo in
                self?.add(photo: photo)
            }
        } else {
            doNotDownloadCounter -= 1
        }
    }
    
    func previous() {
        currentPointer -= 1
        if currentPointer < 0 {
            currentPointer = photos.count - 1
        }
        currentPhoto = photos[currentPointer]
        doNotDownloadCounter += 1
    }
    
    func add(photo: Photo) {
        if photos.count < cacheSize {
            photos.append(photo)
            insertPointer += 1
        } else {
            insertPointer %= cacheSize
            photos[insertPointer] = photo
            insertPointer += 1
        }
    }
}
