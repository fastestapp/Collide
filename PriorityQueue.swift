//
//  David@Fastest.App 7:58 PM 9/3/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation
import UIKit
import Combine

class PriorityQueue: ObservableObject {
    static let shared = PriorityQueue()
    var PQ = [ParticleUpdateEvent]()
    var insertionCount = 0
    let maxPQSize = 400
    var startingDate: Date?
    
    public func runPriorityQueue() {
        var done: Bool = false
        
        if startingDate == nil {
            startingDate = Date()
        }
        
        while !done && PQ.count > 1 {
            let updateEvent = PQ[PQ.count - 1]
            
            if updateEvent.updateTime <= Date() && updateEvent.p2 == nil {
                // This is a wall event, so we will hit the wall and then reverse angle while keeping the velocity the same
                if (updateEvent.p1.y > (UIScreen.main.bounds.height - 10) ) ||
                    (updateEvent.p1.y < 10) {
                    updateEvent.p1.angle = reverseAngleHWall(updateEvent.p1.angle)
                } else {
                    updateEvent.p1.angle = reverseAngleVWall(updateEvent.p1.angle)
                }
                PQ = deleteMinimum(PQ)
                
                evaluateNextWallCollision(updateEvent.p1)
            } else if updateEvent.updateTime <= Date() && updateEvent.p2 != nil{
                // This is a two particle collision event
                updateEvent.p1.angle = reverseAngleVWall(updateEvent.p1.angle)
                if let p2 = updateEvent.p2 {
                    p2.angle = reverseAngleVWall(p2.angle)
                }
                PQ = deleteMinimum(PQ)
            } else {
                done = true
            }
        }
    }
    
    // Add a new value to the Priority Queue and delete the maximum value if the size of the Priority Queue exceeds the max:
    public func insert<T: Comparable>(x: T) where T: ParticleUpdateEvent {
        // Insert new events at position 1, and sink them as far as needed. But this won't be too far, because they are almost in order.
        // Previously we appended new events to the same end of the array that we were reading from, and thus they had to swim much further every time.
        PQ.insert(x, at: 0)
        PQ = sink(PQ, 0)

        insertionCount += 1
    }
    
    // The oldest events -- and the ones that must execute next -- are at the low index numbers.
    // The newest events that were just added, are appended to the highest index number, and must swim to the lowest until they are in order to execute next
    private func swim(_ arr: [ParticleUpdateEvent]) -> [ParticleUpdateEvent] {
        var k = arr.count - 1
        var a = arr
        while k > 1 && (a[k - 1] < a[k]) {
            a = exchange(a, i: k, j: k - 1)
            k = k - 1
        }
        return a
    }
    
    private func sink<T: Comparable>(_ arr: [T], _ i: Int) -> [T] {
        var a = arr
        var k = i
        let n = a.count - 1
        while k + 1 < n {
            var j = k + 1
            if j < n && a[j] < a[j+1] {
                j += 1
            }
            if a[k] >= a[j] {
                break
            }
            a = exchange(a, i: k, j: j)
            k = j
        }
        return a
    }
    
    public func deleteMaximum<T: Comparable>(_ arr: [T]) -> [T] {
        var a = arr
        let n = a.count - 1
        a = sink(a, 1)
        a.remove(at: n)
        return a
    }
    

    public func removeOld(_ arr: [ParticleUpdateEvent]) -> [ParticleUpdateEvent] {
        var a = arr
        let n = a.count - 1
        
        while a[n].updateTime >= Date() {
            a.removeLast()
        }
        
        return a
    }
    
    public func deleteMinimum<T: Comparable>(_ arr: [T]) -> [T] {
        var a = arr
        let n = a.count - 1
        a.remove(at: n)
        return a
    }
    
    public func exchange<T: Comparable>(_ arr: [T], i: Int, j: Int) -> [T] {
        var a = arr
        let temp = a[i]
        a[i] = a[j]
        a[j] = temp
        return a
    }
    
    public func reverseAngleHWall(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        if angle >= 1.5 * .pi {
            revAngle = (2 * .pi)  - angle
        } else if angle >= .pi {
            // going up and left
            revAngle = ((1.5 * .pi) - angle) + (0.5 * .pi)
        } else if angle >= 0.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (0.5 * .pi))
        } else if angle >= 0 {
            revAngle = (2 * .pi) - angle
        }
        return revAngle
    }
    
    public func reverseAngleVWall(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        if angle >= 1.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (1.5 * .pi))
        } else if angle >= .pi {
            revAngle = (1.5 * .pi) + ((1.5 * .pi) - angle)
        } else if angle >= 0.5 * .pi {
            revAngle = (0.5 * .pi) - (angle - (0.5 * .pi))
        } else if angle >= 0 {
            revAngle = (0.5 * .pi) + ((0.5 * .pi) - angle)
        }
        return revAngle
    }

    public func evaluateNextWallCollision(_ particle: Particle) {
        // First, check to see if it's already past the boundary and then reverse angle and calculate:
        let xCoor = particle.x
        
        if xCoor >  UIScreen.main.bounds.width {
            particle.x = UIScreen.main.bounds.width
        }
        else if xCoor < 0 {
            particle.x = 0.003
        }
        let hTime = particle.timeUntilVertWallCollision()
        let vTime = particle.timeUntilHorizWallCollision()

        let timeToHit = (hTime < vTime) ? hTime : vTime
        if timeToHit > 0 {
            let updateDate = Date() + timeToHit
            let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
            self.insert(x: particleUpdateEvent)
        }
    }
}


