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
    @State private var selectedFile: URL?
    @State private var isImporterPresented = false
    
    var body: some View {
        
        VStack {
            Text("VonViz App")
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding()
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
                        }
                        catch{
                            print("Error ingesting file \(error)")
                        }
                    }
                case .failure(let error):
                    print("Failed to pick file: \(error)")
                }
            }
            if #available(visionOS 26.0, *) {
                if !model.rows.isEmpty {
                    let xLabel: String = model.getAxisHeader(axisToGet: .x) ?? ""
                    let yLabel: String = model.getAxisHeader(axisToGet: .y) ?? ""
                    let zLabel: String = model.getAxisHeader(axisToGet: .z) ?? ""

                    
                    // 2) Build the chart in a small, explicit closure
                    let chart = Chart3D(model.rows) { (row: Row) in
                        PointMark(
                            x: .value(xLabel, row.x),
                            y: .value(yLabel, row.y),
                            z: .value(zLabel, row.z)
                        )
                    }
                    .chartXAxisLabel(xLabel)
                    .chartYAxisLabel(yLabel)
                    .chartZAxisLabel(zLabel)
                    .chartXScale(domain: -50...150)
                    .chartYScale(domain: -50...150)
                    .chartZScale(domain: -50...150)
                    
                    chart.frame(width: 1500, height: 1500, alignment: .center)
                }
            }
        }
        //chart does not render properly if this is removed
        //DO NOT REMOVE IS LOAD BEARING 
        RealityView { content in
//            // Add the initial RealityKit content
//            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
//                content.add(scene)
//            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
