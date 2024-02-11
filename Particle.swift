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
    // Direction, in radians. With 0 rad pointing to the right when in landscape mode:
    var angle: Double
    // Velocity
    var speed: Double
    
    init(angle: Double, speed: Double, xCoord: Double, yCoord: Double) {
        self.x = xCoord
        self.y = yCoord
        self.angle = angle
        self.speed = speed
    }
    
    static func ==(lhs: Particle, rhs: Particle) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // find the time for the particle to collide with the left or right.
    func timeUntilVertWallCollision() -> Double {
        let width = UIScreen.main.bounds.width
        let distanceToRight = width - x
        let distanceToLeft = x

        var hypotenuse = 0.0
        let actualVelocity = self.speed
        // going right:
        if ( self.angle >= (1.5 * .pi) && self.angle <= (2 * .pi) ) {
            // going right and up:
            hypotenuse = distanceToRight / cos((2 * .pi) - self.angle)
        } else if ( self.angle >= 0 && self.angle < (0.5 * .pi) ) {
            // going right and down:
            hypotenuse = distanceToRight / cos(self.angle)
        } else if ( self.angle >= (0.5 * .pi) && self.angle <= (.pi) ) {
            // going left and down:
            hypotenuse = distanceToLeft / cos(.pi - self.angle)
        } else if ( self.angle >= (.pi) && self.angle <= (1.5 * .pi) ) {
            // going left and up:
            hypotenuse = distanceToLeft / cos(self.angle - .pi)
        }
        
        let trueTime = abs(hypotenuse) / actualVelocity
        return trueTime
    }
    
    // find the time for the particle to collide with the bottom or top.
    func timeUntilHorizWallCollision() -> Double {
        let height = UIScreen.main.bounds.height
        let distanceToBottom = height - y
        let distanceToTop = y
        
        if self.angle == 0 || self.angle == .pi || self.angle == (2 * .pi) {
            return Double.greatestFiniteMagnitude
        }

        var hypotenuse = 0.0
        let actualVelocity = self.speed
        // going down:
        if ( self.angle >= (1.5 * .pi) && self.angle <= (2 * .pi) ) {
            // going right and up:
            hypotenuse = distanceToTop / cos((.pi / 2) - (2 * .pi - self.angle))
        } else if ( self.angle >= 0 && self.angle < (0.5 * .pi) ) {
            // going right and down:
            hypotenuse = distanceToBottom / cos((.pi/2) - self.angle)
        } else if ( self.angle >= (0.5 * .pi) && self.angle <= (.pi) ) {
            // going left and down:
            hypotenuse = distanceToBottom / cos(self.angle - (.pi / 2))
        } else if ( self.angle >= (.pi) && self.angle <= (1.5 * .pi) ) {
            // going left and up:
            hypotenuse = distanceToTop / cos( (.pi / 2) - (self.angle - .pi) )
        }
        let trueTime = abs(hypotenuse) / actualVelocity

        return trueTime
    }
    
}
