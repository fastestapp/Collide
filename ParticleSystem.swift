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
    var didInitialCheck = false
    
    var xPosition = 50.0
    var yPosition = 0.0
    
    var angle = 80.0
    var angleRange = 180.0
    
    var speed = 200.0
    
    func update(date: Date) {
        let elapsedTime = date.timeIntervalSince1970 - lastUpdate.timeIntervalSince1970
        lastUpdate = date
        
        // Create the particles.
        while particles.count < particleCount {
            particles.append(createParticle())
            lastCreationDate = date
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
//                    print("updateDate: \(updateDate.timeIntervalSince1970)")
                    let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
                    priorityQueue.insert(x: particleUpdateEvent)
                }
            }
            particle.xCoord += cos(particle.angle) * particle.speed  * elapsedTime
            particle.yCoord += sin(particle.angle) * particle.speed  * elapsedTime
        }
        
        didInitialCheck = true
        
        // Call this on a regular interval
        priorityQueue.runPriorityQueue()
    }
    
    private func createParticle() -> Particle {
        let angleDegrees = Double.random(in: 0...90) //+ Double.random(in: -angleRange / 2...angleRange / 2)
        let angleRadians = angleDegrees * .pi / 180
        
        return Particle (
            angle: angleRadians,
//            angle: 0.3,
            speed: 300,
            xCoord: Double.random(in: 0...100),
            yCoord: Double.random(in: 0...80)
            //            xCoord: 20,
            //            yCoord: 0
        )
    }
    
}

