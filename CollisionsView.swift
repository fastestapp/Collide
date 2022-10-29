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
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                particleSystem.update(date: timeline.date)
                let baseTransform = context.transform
                
                for particle in particleSystem.particles {
                    let xPos = particle.x * size.width
                    let yPos = particle.y * size.height
                    
                    context.translateBy(x: xPos, y: yPos)
                    context.draw(particleSystem.image, at: .zero)
                    context.transform = baseTransform
                }
            }
        }
    }
}
