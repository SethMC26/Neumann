//
//  ContentView.swift
//  VonViz
//
//  Created by Kayla Quinlan on 9/14/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State var enlarge = false

    var body: some View {
        VStack {
            Text("VonViz App")
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding()
            Button {
                enlarge.toggle()
            } label: {
                Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
            }
            .animation(.none, value: 0)
            .fontWeight(.semibold)
        }
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
            // Update the RealityKit content when SwiftUI state changes
            if let scene = content.entities.first {
                let uniformScale: Float = enlarge ? 3.0 : 1.0
                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            enlarge.toggle()
        })
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
