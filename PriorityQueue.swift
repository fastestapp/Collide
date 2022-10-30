//
//  David@Fastest.App 7:58 PM 9/3/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import Foundation

class PriorityQueue {
    
    static let shared = PriorityQueue()
    var PQ = [ParticleUpdateEvent]()
    let maxPQSize = 20
    
    // Add a new value to the Priority Queue and delete the maximum value if the size of the Priority Queue exceeds the max.
    // This amounts to deleting the updateEvent that is the furthest away from now to occur:
    public func insert<T: Comparable>(x: T) where T: ParticleUpdateEvent {
        if PQ.count == 0 {
            // Make a placeholder update event for index zero; something we must do because Priority Queues start at index 1:
            let p1 = Particle.init(x: -1, y: -1, angle: 0, speed: 0)
            let p2 = Particle.init(x: -1, y: -1, angle: 0, speed: 0)
            PQ.append(ParticleUpdateEvent.init(P1: p1, P2: p2, updateTime: Date()))
        }
        
        if !checkPreexisting(x: x) {
            PQ.append(x)
            PQ = swim(PQ, PQ.count - 1)
            if PQ.count > maxPQSize {
                PQ = deleteMaximum(PQ)
            }
        }
    }
    
    // If there's already an event in the queue with the particle in question, and the existing event will occur sooner, then it's a preexisting event, and return true
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
                    print("times: \(event.updateTime.timeIntervalSinceReferenceDate) and \(x.updateTime.timeIntervalSinceReferenceDate)")
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
    
    public func exchangeWithEnd(a1: [ParticleUpdateEvent], s1: Int) -> [ParticleUpdateEvent] {
        var a = a1
        let temp = a[s1]
        a[s1] = a[a.count - 1]
        a[a.count - 1] = temp
        return a
    }
    
    var counter = 0
    
    func reverseAngleHWall(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        if angle >= 1.5 * .pi {
            revAngle = (2 * .pi)  - angle
            counter += 1
        } else if angle >= .pi {
            // going up and left
            revAngle = ((1.5 * .pi) - angle) + (0.5 * .pi)
            counter += 1
        } else if angle >= 0.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (0.5 * .pi))
            counter += 1
        } else if angle >= 0 {
            revAngle = (2 * .pi) - angle
            counter += 1
        }
        return revAngle
    }
    
    func reverseAngleVWall(_ angle: Double) -> Double {
        var revAngle: Double = 0.0
        if angle >= 1.5 * .pi {
            revAngle = (1.5 * .pi) - (angle - (1.5 * .pi))
            counter += 1
        } else if angle >= .pi {
            revAngle = (1.5 * .pi) + ((1.5 * .pi) - angle)
            counter += 1
        } else if angle >= 0.5 * .pi {
            revAngle = (0.5 * .pi) - (angle - (0.5 * .pi))
            counter += 1
        } else if angle >= 0 {
            revAngle = (0.5 * .pi) + ((0.5 * .pi) - angle)
            counter += 1
        }
        return revAngle
    }
    
    public func runPriorityQueue() {
        var done: Bool = false
        while !done && PQ.count > 1 {
            let updateEvent = PQ[PQ.count - 1]
            if updateEvent.updateTime <= Date() && updateEvent.p2 == nil {
                // This is a wall event
                if updateEvent.p1.y > 0.95 || updateEvent.p1.y < 0.05 {
                    updateEvent.p1.angle = reverseAngleHWall(updateEvent.p1.angle)
                } else {
                    updateEvent.p1.angle = reverseAngleVWall(updateEvent.p1.angle)
                }
                PQ = deleteMinimum(PQ)
                
                evaluateNextWallCollision(updateEvent.p1)
            } else if updateEvent.updateTime <= Date() && updateEvent.p2 != nil{
                // This is a two particle collision event
                updateEvent.p1.angle = reverseAngleVWall(updateEvent.p1.angle)
                if var p2 = updateEvent.p2 {
                    p2.angle = reverseAngleVWall(p2.angle)
                }
                PQ = deleteMinimum(PQ)
            } else {
                done = true
            }
        }
    }
    
    public func evaluateNextWallCollision(_ particle: Particle) -> Double {
        
        // First, check to see if it's already past the boundary and then reverse angle and calculate:
        var xPosition = particle.x
        if xPosition > 0.99 {
            particle.x = 0.99
            particle.angle = reverseAngleVWall(particle.angle)
        }
        if xPosition < 0.003 {
            particle.x = 0.003
            particle.angle = reverseAngleVWall(particle.angle)
        }
        
        let hTime = particle.timeUntilVertWallCollision()
        let vTime = particle.timeUntilHorizWallCollision()

        let timeToHit = (hTime < vTime ? hTime : vTime)
        if timeToHit > 0 {
            let updateSecondsFromNow = Date.timeIntervalSinceReferenceDate + timeToHit
            let updateDate = Date(timeIntervalSinceReferenceDate: updateSecondsFromNow)
            let particleUpdateEvent = ParticleUpdateEvent(P1: particle, P2: nil, updateTime: updateDate)
            self.insert(x: particleUpdateEvent)
        }
        return timeToHit
    }
}


