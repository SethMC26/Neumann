//
//  VonVizApp.swift
//  VonViz
//
//  Created by Kayla Quinlan on 9/14/25.
//

import SwiftUI

@main
struct VonVizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxDepth: .infinity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .windowStyle(.volumetric)
    }
}
