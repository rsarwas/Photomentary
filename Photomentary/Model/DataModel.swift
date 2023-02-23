//
//  DataModel.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/4/23.
//

import Foundation
import Combine

enum Status {
    case unitialized
    case connecting
    case loading
    case ready
    case failed(String)
}

final class DataModel: ObservableObject {
    @Published var status: Status = .unitialized
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
    
    func load() async {
        DispatchQueue.main.async { self.status = .connecting }
        //

        async let connected = loader.connect()
        async let loaded = loader.loadPathsFromBundle()
        //let loaded = true

        let ops = await [connected, loaded]
        let ready = ops.allSatisfy { x in x }
        if !ready {
            //if !connected { status = .failed("Unable to connect")}
            DispatchQueue.main.async { self.status = .failed("Unable to load photo list") }
        }
        if ready {
            DispatchQueue.main.async { self.status = .loading }
            print("loading 10 photos")
            for _ in 0..<10 {
                if let photo = await self.loader.load() {
                    // Us main thread to synchronize updates to photos array
                    DispatchQueue.main.async {
                        self.photos.append(photo)
                        if self.photos.count == 2 {
                            self.status = .ready
                            self.next()
                            self.start()
                        }
                    }
                }
            }
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
        print("Call next, with \(photos.count) photos")
        currentPointer += 1
        currentPointer %= photos.count
        currentPhoto = photos[currentPointer]
        if doNotDownloadCounter == 0 {
            Task {
                if let photo = await loader.load() {
                    // Us main thread to synchronize updates to photos array
                    DispatchQueue.main.async { self.add(photo: photo) }
                }
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
