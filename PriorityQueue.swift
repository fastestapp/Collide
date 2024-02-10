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
    let maxPQSize = 20
    
    // Add a new value to the Priority Queue and delete the maximum value if the size of the Priority Queue exceeds the max:
    public func insert<T: Comparable>(x: T) where T: ParticleUpdateEvent {
        if PQ.count == 0 {
            // Make a placeholder update event for index zero; something we must do because Priority Queues start at index 1:
            let p1 = Particle.init(angle: 0, speed: 0, xCoord: 0, yCoord: 0)
            let p2 = Particle.init(angle: 0, speed: 0, xCoord: 0, yCoord: 0)
            PQ.append(ParticleUpdateEvent.init(P1: p1, P2: p2, updateTime: Date()))
        }
        
        if !checkPreexisting(x: x) {
            PQ.append(x)
            PQ = swim(PQ, PQ.count - 1)
            if PQ.count > maxPQSize {
                PQ = deleteMaximum(PQ)
            }
        }
        insertionCount += 1
    }
    
    // If there's already an event in the queue containing the particle in question, and the existing event will occur sooner, then it's a preexisting event, and return true
    private func checkPreexisting(x: ParticleUpdateEvent) -> Bool {
        for (index, event) in PQ.enumerated() {
            if x.p2 != nil && (event.p1 == x.p2 || event.p2 == x.p2 ) {
                if event.updateTime <= x.updateTime {
                    return true
                } else {
                    PQ.remove(at: index)
                    return false
                }
            } else if event.p1 == x.p1 {
                if event.updateTime < x.updateTime {
//                    print("times: \(event.updateTime.timeIntervalSinceReferenceDate) and \(x.updateTime.timeIntervalSinceReferenceDate)")
                    return true
                } else {
                    PQ.remove(at: index)
                    return false
                }
            } else if event.p2 == x.p1 {
                if event.updateTime < x.updateTime {
                    return true
                } else {
                    PQ.remove(at: index)
                    return false
                }
            }
        }
        return false
    }
    
    private func swim(_ arr: [ParticleUpdateEvent], _ i: Int) -> [ParticleUpdateEvent] {
        var k = i
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
        while 2*k < n {
            var j = 2*k
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
    
    var startingDate: Date?
    
    public func runPriorityQueue() {
        var done: Bool = false
        
        if startingDate == nil {
            startingDate = Date()
        }
        
        while !done && PQ.count > 1 {
            let updateEvent = PQ[PQ.count - 1]
            
//            print("date: \(Date().timeIntervalSince1970)")
            // We are checking this priority queue for events that are scheduled to occur on or before the current time;
            // And we are checking it about 50 times a second 
            // The Priority Queue is never very long, so we CHECK this many times a second, but we ENTER the code much less often. 
            if updateEvent.updateTime <= Date() && updateEvent.p2 == nil {
                // This is a wall event, so we will hit the wall and then reverse angle while keeping the velocity the same
                if (updateEvent.p1.yCoord > (UIScreen.main.bounds.height - 10) ) ||
                    (updateEvent.p1.yCoord < 10) {
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
    
    public func evaluateNextWallCollision(_ particle: Particle) {
        // First, check to see if it's already past the boundary and then reverse angle and calculate:
        let xCoor = particle.xCoord
        
        if xCoor >  UIScreen.main.bounds.width {
            particle.xCoord = UIScreen.main.bounds.width
        }
        else if xCoor < 0 {
            particle.xCoord = 0.003
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


