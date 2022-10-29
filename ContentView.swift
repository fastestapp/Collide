//
//  ContentView
//  Collide
// 
//  David@Fastest.App 9:17 PM 10/28/22
//  Datascream Corporation
//  Copyright © 2022 Datascream, Inc. All rights reserved
//
//  Swift 5.0
//

import SwiftUI

struct ContentView: View {
    @StateObject var particleSystem = ParticleSystem()
    
    var body: some View {
        CollisionsView(particleSystem: particleSystem)
            .ignoresSafeArea()
            .background(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
