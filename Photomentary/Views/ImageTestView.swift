//
//  ImageTestView.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/2/23.
//

import SwiftUI

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
    @ObservedObject private var model = DataModel()
    @State private var playing = true
    
    var body: some View {
        ZStack {
            Image(model.currentPhoto.path)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 40)
                .opacity(0.4)
            ZStack(alignment:.bottom) {
                Image(model.currentPhoto.path)
                    .resizable()
                    .scaledToFit()
                ImageCaption(text: model.currentPhoto.caption)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .focusable()
        .onAppear() { model.start() }
        .onPlayPauseCommand() { playOrPause() }
        .onMoveCommand() { direction in
            print("move \(direction)")
            switch direction {
            case .left:  model.previous()
            case .right: model.next()
            default: break // do nothing
        }
        }
        .onExitCommand() {
            print("menu")
            model.stop()
            // Show command menu
        }
    }
    
    func playOrPause() {
        print("play/pause")
        if playing {
            model.stop()
            // Show command menu
        } else {
            model.start()
        }
        playing.toggle()
    }
}

struct ImageTestView_Previews: PreviewProvider {
    static var previews: some View {
        ImageTestView()
    }
}