//
//  TimerTestView.swift
//  Photomentary
//
//  Created by Regan Sarwas on 2/2/23.
//

import SwiftUI

struct TimerTestView: View {
    let minDelay: TimeInterval = 1
    let maxDelay: TimeInterval = 10
    @State var delay: TimeInterval
    @State var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State private var counter = 0

    var body: some View {
        VStack {
            Text("Hello \(counter) World!")
                .onReceive(timer) { _ in
                    counter += 1
                }
            Text("Delay: \(Int(delay)) second")
            Text("Pause between Images (\(Int(minDelay)) to \(Int(maxDelay)) seconds):")
            HStack {
                Button(action: {
                    delay -= 1
                    restartTimer(interval:delay)
                }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(delay == minDelay)
                Text("\(Int(delay))")
                Button(action: {
                    delay += 1
                    restartTimer(interval:delay)
                }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(delay == maxDelay)
            }
            HStack {
                Button("Stop") {
                    timer.upstream.connect().cancel()
                }
                Button("Reset") {
                    counter = 0
                    restartTimer(interval:delay)
                }
            }
        }
        .onAppear(){
            timer.upstream.connect().cancel()
            timer = Timer.publish(every: delay, tolerance: 0.5, on: .main, in: .common).autoconnect()
        }
    }
    func restartTimer(interval: TimeInterval) {
        timer.upstream.connect().cancel()
        timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }
}

struct TimerTestView_Previews: PreviewProvider {
    static var previews: some View {
        TimerTestView(delay:5)
    }
}
