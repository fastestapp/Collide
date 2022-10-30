//
//  ParticleSystem
// 
//  David@Fastest.App 1:18 PM 10/22/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import SwiftUI

class ParticleSystem: ObservableObject {
    var particleCount = 20
    let image = Image("disk")
    var particles = Array<Particle>()
    var lastUpdate = Date()
    var lastCreationDate = Date()
    var priorityQueue = PriorityQueue.shared
    var didInitialQuadratic = false
    var didInitialBounceCheck = false
    
    var xPosition = 50.0
    var yPosition = 0.0
    var xPositionRange = 100.0
    var yPositionRange = 0.0
    
    var angle = 80.0
    var angleRange = 180.0
    
    var speed = 20.0
    var speedRange = 2.0
    
    func update(date: Date) {
        let elapsedTime = date.timeIntervalSince1970 - lastUpdate.timeIntervalSince1970
        lastUpdate = date
        
        // Create the particles or add them to maintain. However, if it's working, none should get lost:
        while particles.count < particleCount {
            particles.append(createParticle())
            lastCreationDate = date
        }
        
        if particles.count == particleCount {
            for particle in particles {
                if !didInitialBounceCheck {
                    let hTime = particle.timeUntilVertWallCollision()
                    let vTime = particle.timeUntilHorizWallCollision()
                    
                    let timeToHit = (hTime < vTime ? hTime : vTime)
                    if timeToHit > 0 {
                        let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
                        let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
                        let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
                        priorityQueue.insert(x: particleUpdateEvent)
                    }
                }
                particle.x += cos(particle.angle) * particle.speed / 100 * elapsedTime
                particle.y += sin(particle.angle) * particle.speed / 100 * elapsedTime
            }
            
            didInitialBounceCheck = true
        }
        
        // Update events from the PriorityQueue.
        priorityQueue.runPriorityQueue()
    }
    
    private func createParticle() -> Particle {
        let angleDegrees = Double.random(in: 0...360) + Double.random(in: -angleRange / 2...angleRange / 2)
        let angleRadians = angleDegrees * .pi / 180
        
        return Particle (
            x: Double.random(in: 0...1),
            y: Double.random(in: 0...1),
            angle: angleRadians,
            speed: 20 //speed + Double.random(in: -speedRange / 2...speedRange / 2),
        )
    }
    
}

