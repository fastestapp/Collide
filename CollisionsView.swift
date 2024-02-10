//
//  CollisionsView
//  Collisions
// 
//  David@Fastest.App 7:49 PM 10/23/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation
import SwiftUI

struct CollisionsView: View {
    var particleSystem: ParticleSystem
    
    var body: some View {
        ZStack {
            Color(.blue)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    particleSystem.update(date: timeline.date)
                    let baseTransform = context.transform
                    for particle in particleSystem.particles {
                        context.translateBy(x: particle.xCoord, y: particle.yCoord)
                        context.draw(particleSystem.image, at: .zero)
                        context.transform = baseTransform
                    }
                }
                .background(Color.purple)
            }
//            TimerView()
            PriorityQueueCount()
        }
    }
}

struct TimerView: View {
    @State var isTimerRunning = false
    @State private var startTime =  Date()
    @State private var timerString = "0.00"
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        Text(self.timerString)
            .font(Font.system(.largeTitle, design: .monospaced))
            .onReceive(timer) { _ in
                if self.isTimerRunning {
                    timerString = String(format: "%.2f", (Date().timeIntervalSince( self.startTime)))
                }
            }
            .onAppear {
                if !isTimerRunning {
                    timerString = "0.00"
                    startTime = Date()
                }
                isTimerRunning.toggle()
            }
    }
}
