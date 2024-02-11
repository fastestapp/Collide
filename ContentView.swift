//
//  ContentView
//  Collide
//
//  David@Fastest.App 9:17 PM 10/28/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import SwiftUI

struct ContentView: View {
    @StateObject var particleSystem = ParticleSystem()
    
    var body: some View {
        ZStack {
            Color(.blue)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let globalQueue = DispatchQueue.global(qos: .userInitiated)
                    globalQueue.async {
                        particleSystem.update(date: timeline.date)
                    }
                
                    let baseTransform = context.transform
                    for particle in particleSystem.particles {
                        context.translateBy(x: particle.x, y: particle.y)
                        context.draw(particleSystem.image, at: .zero)
                        context.transform = baseTransform
                    }
                }
            }
            PriorityQueueCount()
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
