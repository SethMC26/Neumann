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
    private var model: AppModel = AppModel()
    @State var enlarge = false
    @State private var selectedFile: URL?
    @State private var isImporterPresented = false
    
    
    var body: some View {
        VStack {
            Text("VonViz App")
                .font(.title2)
                .foregroundColor(.white)
                .padding(6)
                .background(.black)
                .cornerRadius(6)
            
            Button {
                enlarge.toggle()
            } label: {
                Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(.black)
                    .cornerRadius(10)
            }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)
            
            // THIS BUTTON WAS CHATGPT GENERERATED AND ONLY FOR TESTING!!!
            // WILL NEED TO UPDATED AND REMOVED
            Button("Choose CSV File") {
                isImporterPresented = true
            }
            .font(.title2)
            .foregroundColor(.white)
            .padding(6)
            .background(.black)
            .cornerRadius(6)
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
                            // print("Headers \(self.model.getHeaders())")
                        }
                        catch{
                            print("Error ingesting file \(error)")
                        }
                    }
                case .failure(let error):
                    print("Failed to pick file: \(error)")
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
            .frame(width: 250, height: 250)
            .cornerRadius(12)
            .shadow(radius: 8)
            .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
                enlarge.toggle()
            })
        }
        .frame(width: 300, height: 400)  // <-- fixed size for the background box
        .padding()
        .background(
            Color.blue
                .cornerRadius(20)
        )
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
