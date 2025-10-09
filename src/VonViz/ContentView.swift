//
//  ContentView.swift
//  VonViz
//
//  Created by Kayla Quinlan on 9/14/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model: AppModel = AppModel()
    
    /// toolBar view with all main buttons of our app
    var toolBarContent: some View {
        HStack {
            LoadButton(model: model)
            // Axis menus only if model has headers
            if !model.headers.isEmpty {
                // X axis selector
                AxisButton(model: model, axis: .x)
                AxisButton(model: model, axis: .y)
                AxisButton(model: model, axis: .z)
            }
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
