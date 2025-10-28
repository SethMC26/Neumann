//
//  ContentView.swift
//  VonViz
//
//  Created by Kayla Quinlan on 9/14/25.
//

import SwiftUI

struct ContentView: View {
    /// Model to hold the data of our app between the different views
    @StateObject private var model: AppModel = AppModel()
    
    /// Show user message
    @State private var alertMessage: String?
    /// Show settings sheet
    @State private var showingSettings = false

    /// toolBar view with all main buttons of our app
    var toolBarContent: some View {
        HStack {
            LoadButton(model: model) { message in
                alertMessage = message
            }
            if !model.headers.isEmpty {
                AxisButton(model: model, axis: .x)
                AxisButton(model: model, axis: .y)
                AxisButton(model: model, axis: .z)
            }
            // Add settings button at end
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .accessibilityLabel("Settings")
            }
            .padding(.leading, 8)
        }
    }
    
    var body: some View {
        VStack {
            if #available(visionOS 26.0, *), !model.rows.isEmpty {
                Chart(model: model)
                    .offset(z: 100)
                    .zIndex(0)
                    .frame(width: 1000, height: 1000, alignment: .center)
                    .frame(depth: 1000, alignment: .back)
                    .scaleEffect(2)
                    .scaledToFit3D()
                    .padding(100)
                    .layoutPriority(10.0)
            } else {
                ContentUnavailableView("No data yet", systemImage: "tray")
                    .offset(z: 300)
                    .zIndex(1)
            }
            toolBarContent
                .offset(z: 500)
                .zIndex(1)
        }
        .alert(alertMessage ?? "", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheet(model: model)
                .presentationDetents([.medium, .large])
        }
    }
}

