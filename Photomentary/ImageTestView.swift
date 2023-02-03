//
//  ImageTestView.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/2/23.
//

import SwiftUI

struct Photo {
    let path: String
    let caption: String
}

let defaultPhoto: Photo = Model().photo
let defaultInterval: TimeInterval = 5

class Model: ObservableObject {
    private var currentPointer: Int = 0
    @Published
    var pauseInterval: TimeInterval = 5
    private var photos = [
        Photo(path:"image1", caption:"2023-01-09 Wes in a Bucket"),
        Photo(path:"image2", caption:"2023-01-13 Kayaking Around the North Side of Caye Caulker"),
        Photo(path:"image3", caption:"2022-02-05 Hiking to Imperial Sand Dunes"),
        Photo(path:"image4", caption:"2022-02-05 Hiking to Imperial Sand Dunes"),
    ]
    var photo: Photo { photos[currentPointer] }
    
    func next() -> Photo {
        currentPointer += 1
        currentPointer %= photos.count
        return photos[currentPointer]
    }
    
    func prev() -> Photo {
        currentPointer += 1
        currentPointer %= photos.count
        return photos[currentPointer]
    }
}

struct ImageCaption: View {
    let text: String
    var body: some View {
        ZStack {
            Text(text)
                .font(.largeTitle)
                .padding([.horizontal], 25)
                .padding([.vertical], 5)
                .foregroundColor(.white)
        }.background(Color.black)
        .opacity(0.8)
        .cornerRadius(30.0)
        .padding(10)
    }
}

struct ImageTestView: View {
    @State private var model = Model()
    @State private var photo = defaultPhoto
    let timer = Timer.publish(every: defaultInterval, tolerance: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Image(photo.path)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 40)
                .opacity(0.4)
            ZStack(alignment:.bottom) {
                Image(photo.path)
                    .resizable()
                    .scaledToFit()
                //ImageCaption(text: "Place A Really Really Really Long Caption Here")
                ImageCaption(text: photo.caption)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onReceive(timer) { _ in
            photo = model.next()
        }
    }
}

struct ImageTestView_Previews: PreviewProvider {
    static var previews: some View {
        ImageTestView()
    }
}
