//
//  ContentView.swift
//  VonViz
//
//  Created by Kayla Quinlan on 9/14/25.
//

import SwiftUI
import Charts
import RealityKit
import RealityKitContent

struct Penguin: Identifiable {
    let id: Int
    let flipperLength: Double
    let weight: Double
    let beakLength: Double
}


let penguins: [Penguin] = [
    Penguin(id: 0, flipperLength: 197, weight: 4.2, beakLength: 59),
    Penguin(id: 1, flipperLength: 220, weight: 100.7, beakLength: 48),
    Penguin(id: 2, flipperLength: 235, weight: 5.8, beakLength: 200),
    ]

struct ContentView: View {
    @StateObject private var model: AppModel = AppModel()
    @State var enlarge = false
    @State private var selectedFile: URL?
    @State private var isImporterPresented = false
    
    var body: some View {
        
        VStack {
            Text("VonViz App")
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding()
            Group {
                if #available(visionOS 26.0, *) {
                    if !model.rows.isEmpty {
                        Chart3D(model.rows) {
                            PointMark(
                                x: .value(model.getAxisHeader(axisToGet: <#T##Axis#>.x), $0.x),
                                y: .value(model.getAxisHeader(axisToGet: <#T##Axis#>.y), $0.y),
                                z: .value(model.getAxisHeader(axisToGet: <#T##Axis#>.z), $0.z)
                            )
                        }
                    }
                }
            }
            Button {
                enlarge.toggle()
            } label: {
                Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
            }
            .animation(.none, value: 0)
            .fontWeight(.semibold)
            
            // THIS BUTTON WAS CHATGPT GENERERATED AND ONLY FOR TESTING!!!
            // WILL NEED TO UPDATED AND REMOVED
            Button("Choose CSV File") {
                isImporterPresented = true
            }
            // example file importer
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) {
                //Logic is simply for testing NEEDS TO BE CLEANED UP
                result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedFile = url
                        print("Picked file: \(url)")
                        do {
                            try self.model.ingestFile(file: url)
                            print("Headers \(self.model.getHeaders())")
                        }
                        catch{
                            print("Error ingesting file \(error)")
                        }
                    }
                case .failure(let error):
                    print("Failed to pick file: \(error)")
                }
            }
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
