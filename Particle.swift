//
//  Particle
// 
//  David@Fastest.App 1:11 PM 10/22/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation
import UIKit

class Particle: Hashable, Equatable {
    let id = UUID()
    
    // Position
    var xCoord: Double
    var yCoord: Double
    // Direction, in radians. With 0/2.pi pointing to the right.
    var angle: Double
    // Velocity
    var speed: Double
    // Radius
    var radius: Double = 0.001
    
    
    init(angle: Double, speed: Double, xCoord: Double, yCoord: Double) {
        self.xCoord = xCoord
        self.yCoord = yCoord
        self.angle = angle
        self.speed = speed
    }
    
    static func ==(lhs: Particle, rhs: Particle) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var counter = 0
    // find the time the self particle will collide with the wall.
    func timeUntilVertWallCollision() -> Double {
        let width = UIScreen.main.bounds.width
        let distanceToRight = width - xCoord
        let distanceToLeft = xCoord

        var actualDistance = 0.0
        let actualVelocity = self.speed
        // going right:
        if ( self.angle >= (1.5 * .pi) && self.angle <= (2 * .pi) ) {
            // going right and up:
            actualDistance = distanceToRight / cos((2 * .pi) - self.angle)
        } else if ( self.angle >= 0 && self.angle < (0.5 * .pi) ) {
            // going right and down:
            // cosine of the angle = adjacent / hypotenuse. hyp = adj / cos(angle)
            actualDistance = distanceToRight / cos(self.angle)
        } else if ( self.angle >= (0.5 * .pi) && self.angle <= (.pi) ) {
            // going left and down:
            actualDistance = distanceToLeft / cos(.pi - self.angle)
        } else if ( self.angle >= (.pi) && self.angle <= (1.5 * .pi) ) {
            // going left and up:
            actualDistance = distanceToLeft / cos(self.angle - .pi)
        }
        
        let trueTime = abs(actualDistance) / actualVelocity
        print("truetime v: \(trueTime)")
        return trueTime
    }
    
    // find the time the self self will collide with the wall.
    func timeUntilHorizWallCollision() -> Double {
        let height = UIScreen.main.bounds.height
        let distanceToBottom = height - yCoord
        let distanceToTop = yCoord
        
        if self.angle == 0 || self.angle == .pi || self.angle == (2 * .pi) {
            return Double.greatestFiniteMagnitude
        }

        var actualDistance = 0.0
        let actualVelocity = self.speed
        // going down:
        if ( self.angle >= (1.5 * .pi) && self.angle <= (2 * .pi) ) {
            // going right and up:
            actualDistance = distanceToTop / cos((.pi / 2) - (2 * .pi - self.angle))
        } else if ( self.angle >= 0 && self.angle < (0.5 * .pi) ) {
            // going right and down:
            actualDistance = distanceToBottom / cos((.pi/2) - self.angle)
        } else if ( self.angle >= (0.5 * .pi) && self.angle <= (.pi) ) {
            // going left and down:
            actualDistance = distanceToBottom / cos(self.angle - (.pi / 2))
        } else if ( self.angle >= (.pi) && self.angle <= (1.5 * .pi) ) {
            // going left and up:
            actualDistance = distanceToTop / cos( (.pi / 2) - (self.angle - .pi) )
        }
        let trueTime = abs(actualDistance) / actualVelocity

        print("truetime h: \(trueTime)")
        return trueTime
    }
    
}
