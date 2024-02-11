//
//  PriorityQueueCount
//  Collide
// 
//  David Strehlow 3:56 PM 2/10/24
//  Datascream Corporation
//  Copyright © 2024 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import SwiftUI

struct PriorityQueueCount: View {
    @ObservedObject var queue = PriorityQueue.shared
    
    var body: some View {
        TimelineView(.animation) { timeline in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Priority Queue Count: \(queue.PQ.count)")
                        .frame(width: 200, height: 50)
                        Text("Insertion Count: \(queue.insertionCount)")
                        .frame(width: 300, height: 50)
                    }
                    .foregroundColor(.yellow)
                }
            }
            
        
    }
}

//#Preview {
//    PriorityQueueCount()
//}
