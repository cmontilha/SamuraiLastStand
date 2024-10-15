//
//  ContentView.swift
//  Samurai Last Stand
//
//  Created by Caio Montilha on 10/14/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: OpeningScene(size: UIScreen.main.bounds.size))
            .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    ContentView()
}
