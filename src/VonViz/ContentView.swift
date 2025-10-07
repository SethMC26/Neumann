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

struct ContentView: View {
    @StateObject private var model: AppModel = AppModel()
    @State private var selectedFile: URL?
    @State private var isImporterPresented = false
    
    /// toolBar view with all main buttons of our app
    var toolBarContent: some View {
        HStack {
            // TEMP button for testing
            Button("Choose CSV File") {
                isImporterPresented = true
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedFile = url
                        Log.UserView.debug("Picked file: \(url)")
                        do {
                            try model.ingestFile(file: url)
                        } catch {
                            Log.UserView.error("Error loading file: \(error.localizedDescription)")
                        }
                    } else {
                        Log.UserView.error("File picker returned empty URL list")
                    }
                case .failure(let error):
                    Log.UserView.error("Failed to pick file: \(error.localizedDescription)")
                }
            }
            
            // Axis menus only if model has headers
            if !model.headers.isEmpty {
                // X axis selector
                Menu {
                    ForEach(model.headers, id: \.self) { header in
                        Button(header) {
                            do {
                                try model.setAxis(axisToSet: .x, header: header)
                                Log.UserView.info("Set X axis to '\(header)'")
                            } catch {
                                Log.UserView.error("Error setting X axis: \(error.localizedDescription)")
                            }
                        }
                    }
                } label: {
                    Label("Set X Axis", systemImage: "chart.xyaxis.line") // safe symbol
                        .labelStyle(.titleAndIcon)
                }
                
                // Y axis selector
                Menu {
                    ForEach(model.headers, id: \.self) { header in
                        Button(header) {
                            do {
                                try model.setAxis(axisToSet: .y, header: header)
                                Log.UserView.info("Set Y axis to '\(header)'")
                            } catch {
                                Log.UserView.error("Error setting Y axis: \(error.localizedDescription)")
                            }
                        }
                    }
                } label: {
                    Label("Set Y Axis", systemImage: "chart.xyaxis.line")
                        .labelStyle(.titleAndIcon)
                }
                
                // Z axis selector
                Menu {
                    ForEach(model.headers, id: \.self) { header in
                        Button(header) {
                            do {
                                try model.setAxis(axisToSet: .z, header: header)
                                Log.UserView.info("Set Z axis to '\(header)'")
                            } catch {
                                Log.UserView.error("Error setting Z axis: \(error.localizedDescription)")
                            }
                        }
                    }
                } label: {
                    Label("Set Z Axis", systemImage: "chart.xyaxis.line")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
    }
    
    ///Chart View of our app with the main charts of the app
    @ViewBuilder
    var chart: some View {
        if #available(visionOS 26.0, *) {
            if !model.rows.isEmpty {
                // attempt to get the string for each axis if not able use placeholder
                let xLabel: String = "X: \(model.getAxisHeader(axisToGet: .x) ?? "X Axis")"
                let yLabel: String = "Y: \(model.getAxisHeader(axisToGet: .y) ?? "Y Axis")"
                let zLabel: String = "Z: \(model.getAxisHeader(axisToGet: .z) ?? "Z Axis")"
                
                //attempt to get axis range but fall back to a default range
                let xDom = (try? model.getAxisRange(axis: .x)) ?? (-50...50)
                let yDom = (try? model.getAxisRange(axis: .y)) ?? (-50...50)
                let zDom = (try? model.getAxisRange(axis: .z)) ?? (-50...50)
                
                //add chart with rows, labels and scale
                Chart3D(model.rows) { (row: Row) in
                    PointMark(
                        x: .value(xLabel, row.x),
                        y: .value(yLabel, row.y),
                        z: .value(zLabel, row.z)
                    )
                }
                .chartXAxisLabel(xLabel)
                .chartYAxisLabel(yLabel)
                .chartZAxisLabel(zLabel)
                .chartXScale(domain: xDom, range: .plotDimension(padding: 750))
                .chartYScale(domain: yDom, range: .plotDimension(padding: 750))
                .chartZScale(domain: zDom, range: .plotDimension(padding: 750))
            }
        }
    }
    
    var body: some View {
        
        VStack {
            if #available(visionOS 26.0, *), !model.rows.isEmpty {
                chart
                    .offset(z: 100)
                    .zIndex(0)
                    .frame(width: 1000, height: 1000, alignment: .center)
                    .frame(depth: 1000, alignment: .back)
                    .scaleEffect(2)
                    .scaledToFit3D()
                    .padding(100)
                    .layoutPriority(10.0)
            }
            else {
                ContentUnavailableView("No data yet", systemImage: "tray")
                    .offset(z: 300)
                    .zIndex(1)
            }
            toolBarContent
                .offset(z: 500)
                .zIndex(1)
                
        }
    }
}
