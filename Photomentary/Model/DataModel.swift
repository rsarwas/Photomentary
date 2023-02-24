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
    private var insertPointer = 1 // After the default (splash) photo
    private let cacheSize = 40 // Max count in photos
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
            //print("loading \(cacheSize/2) photos")
            //Preload half the images the cache can hold
            // the current photo should always be halfway between the oldest viewed image, and the newest unviewed image
            for _ in 0..<(cacheSize/2) {
                if let photo = await self.loader.load() {
                    // Use main thread to synchronize updates to photos array
                    DispatchQueue.main.async { self.add(photo: photo) }
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
        // insertPointer the count of array before it is full,
        // then it is the location of the oldest (already viewed photo
        // currentPointer whould always be less (with wrapping) than insertPointer
        if (currentPointer + 1) % photos.count == insertPointer {
            print("Waiting for new photos to load. currentPointer: \(currentPointer), insertPointer: \(insertPointer), photos.count: \(photos.count), cacheSize: \(cacheSize)")
            //TODO: Display message on screen
            return
        }
        currentPointer += 1
        currentPointer %= photos.count
        //print("Next - Show \(currentPointer)/\(photos.count); oldest photo at \(insertPointer)")
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
        if currentPointer == insertPointer || (photos.count < cacheSize && currentPointer == 0) {
            print("Can't back up any further. currentPointer: \(currentPointer), insertPointer: \(insertPointer), photos.count: \(photos.count), cacheSize: \(cacheSize)")
            //TODO: write message to screen
            return
        }
        currentPointer -= 1
        if currentPointer < 0 {
            currentPointer = photos.count - 1
        }
        currentPhoto = photos[currentPointer]
        //print("Previous - Show \(currentPointer)/\(photos.count); oldest photo at \(insertPointer)")
        doNotDownloadCounter += 1
    }
    
    func add(photo: Photo) {
        if photos.count < cacheSize {
            //print("Adding \"\(photo.caption)\" after \(photos.count) of \(cacheSize)")
            photos.append(photo)
            insertPointer = photos.count
            insertPointer %= cacheSize
        } else {
            //print("Adding \"\(photo.caption)\" at \(insertPointer) out of \(photos.count)")
            photos[insertPointer] = photo
            insertPointer += 1
            insertPointer %= cacheSize
        }
        // When we get the first real photo, start the automatic paging
        if self.photos.count == 2 {
            self.status = .ready
            self.next()
            self.start()
        }
    }
}
