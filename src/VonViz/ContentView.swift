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
    @State private var enlarge: Bool = false // <-- Fix: add enlarge state
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    // If model loaded add buttons for each axis
                    if !model.headers.isEmpty {
                        // X axis selector
                        Menu {
                            ForEach(model.headers, id: \.self) { header in
                                Button(header) {
                                    do {
                                        try model.setAxis(axisToSet: .x, header: header)
                                    }
                                    catch {
                                        print("Error setting axis : \(error)")
                                    }
                                }
                            }
                        } label: {
                            Label("Set X Axis", systemImage: "x.circle")
                                .labelStyle(.titleAndIcon)
                        }
                        // Y Axis selector
                        Menu {
                            ForEach(model.headers, id: \.self) { header in
                                Button(header) {
                                    do {
                                        try model.setAxis(axisToSet: .y, header: header)
                                    }
                                    catch {
                                        print("Error setting axis : \(error)")
                                    }
                                }
                            }
                        } label: {
                            Label("Set Y Axis", systemImage: "y.circle")
                                .labelStyle(.titleAndIcon)
                        }
                        // Z Axis Selector
                        Menu {
                            ForEach(model.headers, id: \.self) { header in
                                Button(header) {
                                    do {
                                        try model.setAxis(axisToSet: .z, header: header)
                                    }
                                    catch {
                                        print("Error setting axis : \(error)")
                                    }
                                }
                            }
                        } label: {
                            Label("Set Z Axis", systemImage: "z.circle")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
                if #available(visionOS 26.0, *) {
                    if !model.rows.isEmpty {
                        // attempt to get the string for each axis if not able use placeholder
                        let xLabel: String = model.getAxisHeader(axisToGet: .x) ?? "X Axis"
                        let yLabel: String = model.getAxisHeader(axisToGet: .y) ?? "Y Axis"
                        let zLabel: String = model.getAxisHeader(axisToGet: .z) ?? "Z Axis"
                        
                        //attempt to get axis range but fall back to a default range
                        let xDom = (try? model.getAxisRange(axis: .x)) ?? (-50...50)
                        let yDom = (try? model.getAxisRange(axis: .y)) ?? (-50...50)
                        let zDom = (try? model.getAxisRange(axis: .z)) ?? (-50...50)
                        
                        //add chart with rows, labels and scale
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
                            .chartXScale(domain: xDom, range: .plotDimension(padding: 100))
                            .chartYScale(domain: yDom, range: .plotDimension(padding: 100))
                            .chartZScale(domain: zDom, range: .plotDimension(padding: 100))
                        
                        chart.frame(width: 1500, height: 1500, alignment: .center)
                    }
                }
            }
            //chart does not render properly if this is removed
            //DO NOT REMOVE IS LOAD BEARING
            RealityView { content in
                /// A glowing, vibrant button ideal for primary actions.
                struct PrimaryButtonStyle: ButtonStyle {
                    func makeBody(configuration: Configuration) -> some View {
                        configuration.label
                            .font(.callout.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule().stroke(Color.white.opacity(configuration.isPressed ? 0.7 : 0.2), lineWidth: 2)
                            )
                            .shadow(
                                color: Color.blue.opacity(configuration.isPressed ? 0.15 : 0.36),
                                radius: configuration.isPressed ? 4 : 16,
                                y: configuration.isPressed ? 1 : 8
                            )
                            .opacity(configuration.isPressed ? 0.85 : 1)
                            .scaleEffect(configuration.isPressed ? 0.97 : 1)
                            .animation(.easeOut(duration: 0.17), value: configuration.isPressed)
                    }
                }
                
                /// A secondary, frosted "ghost" button.
                struct SecondaryButtonStyle: ButtonStyle {
                    func makeBody(configuration: Configuration) -> some View {
                        configuration.label
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                            .background(
                                .ultraThinMaterial,
                                in: Capsule()
                            )
                            .overlay(
                                Capsule().stroke(Color.white.opacity(configuration.isPressed ? 0.5 : 0.28), lineWidth: 1.5)
                            )
                            .shadow(
                                color: Color.black.opacity(configuration.isPressed ? 0.12 : 0.20),
                                radius: configuration.isPressed ? 2 : 7,
                                y: 2
                            )
                            .opacity(configuration.isPressed ? 0.90 : 1)
                            .scaleEffect(configuration.isPressed ? 0.98 : 1)
                            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
                    }
                }

                }
                
                // Floating "Choose CSV File" button, always front/top
                Button {
                    isImporterPresented = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.fill.badge.plus")
                            .font(.title.weight(.bold))
                        Text("Choose CSV File")
                            .font(.title2.weight(.bold))
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .accessibilityLabel("Choose CSV File")
                }
                .fileImporter(
                    isPresented: $isImporterPresented,
                    allowedContentTypes: [.commaSeparatedText],
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
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
                .zIndex(1)
            }
        }
    }

