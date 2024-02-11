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
    var priorityQueue = PriorityQueue.shared
    var particles = Array<Particle>()
    
    var particleCount = 20
    let image = Image("ball")
    var lastContextUpdate = Date()
    var particleCreationDate = Date()
    var didInitialCheck = false
    
    func update(date: Date) {
        let timeBetweenContextUpdates = date.timeIntervalSince1970 - lastContextUpdate.timeIntervalSince1970
        lastContextUpdate = date
        
        // Create the particles.
        while particles.count < particleCount {
            particles.append(createParticle())
            particleCreationDate = date
        }
        
        // Here's where we add a small amount of x and y distance to the position of each particle
        for particle in particles {
            // Here we figure the first collision of each particle after the initial particle creation:
            if !didInitialCheck {
                // Here we first calculate the time until the next vertical wall collision, where
                // a vertical wall is the left or right side:
                let hTime = particle.timeUntilVertWallCollision()
                let vTime = particle.timeUntilHorizWallCollision()
                let timeToHit = (hTime < vTime) ? hTime : vTime
                if timeToHit > 0 {
                    let updateDate = Date() + timeToHit
                    let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
                    priorityQueue.insert(x: particleUpdateEvent)
                }
            }
            particle.x += cos(particle.angle) * particle.speed  * timeBetweenContextUpdates
            particle.y += sin(particle.angle) * particle.speed  * timeBetweenContextUpdates
        }
        
        didInitialCheck = true
        
        // Call this on a regular interval
        priorityQueue.runPriorityQueue()
    }
    
    // Create particles with angles and positions randomized to a small range of values
    private func createParticle() -> Particle {
        let angleDegrees = Double.random(in: 0...90)
        let angleRadians = angleDegrees * .pi / 180
        
        return Particle (
            angle: angleRadians,
            speed: 300,
            xCoord: Double.random(in: 0...100),
            yCoord: Double.random(in: 0...80)
        )
    }
    
}

