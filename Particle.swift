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
    var x: Double
    var y: Double
    // Direction, in radians. With 0/2.pi pointing to the right.
    var angle: Double
    // Velocity
    var speed: Double
    // Radius
    var radius: Double = 0.005
    
    init(x: Double, y: Double, angle: Double, speed: Double) {
        self.x = x
        self.y = y
        self.angle = angle
        self.speed = speed
    }
    
    static func ==(lhs: Particle, rhs: Particle) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // find the time the self particle will collide with the wall.
    func timeUntilVertWallCollision() -> Double {
        let width = UIScreen.main.bounds.width
        let xPosition = self.x
        let pixelsFromLeft = xPosition * width
        let distanceFromRight = width - (xPosition * width)
        let xVelocity = abs(xVelocity(self.speed, self.angle))
        
        // going right:
        if ( self.angle > (1.5 * .pi) && self.angle <= (2 * .pi) ) ||
            ( self.angle >= 0 && self.angle < (0.5 * .pi) ) {
            return distanceFromRight / (xVelocity * 8.4)
        } else {
            // going left:
            return -(1 - pixelsFromLeft) / (xVelocity * 8.4)
        }
    }
    
    // find the time the self self will collide with the wall.
    func timeUntilHorizWallCollision() -> Double {
        let height = UIScreen.main.bounds.height
        let yPosition = self.y
        let distanceFromTop = yPosition * height
        let distanceFromBottom = height - (yPosition * height)
        let yVelocity = abs(yVelocity(self.speed, self.angle))
        
        // going down:
        if (self.angle > 0 && self.angle < .pi) {
            return (distanceFromBottom) / (yVelocity * 12)
        } else {
            // going up:
            return distanceFromTop / (yVelocity * 12)
        }
    }
    
    func yVelocity(_ speed: Double, _ radians: Double) -> Double {
        var yVelocity: Double = 0
        
        if ( (radians > 0)  && (radians < .pi) ) {
            yVelocity = sin(radians) * speed
        } else {
            yVelocity = -1 * sin(radians) * speed
        }
        
        return yVelocity
    }
    
    func xVelocity(_ speed: Double, _ radians: Double) -> Double {
        var xVelocity: Double = 0
        
        if ( (radians > (1.5 * .pi))  && (radians <= (2.0 * .pi)) ) ||
            ( (radians >= 0) && (radians < (0.5 * .pi)) ) {
            xVelocity = cos(radians) * speed
        } else if ( radians > (0.5 * .pi)  && (radians < (2.0 * .pi)) ) {
            xVelocity = -1 * cos(radians) * speed
        }
        return xVelocity
    }
}
