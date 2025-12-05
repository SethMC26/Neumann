/*
 *   Copyright (C) 2025  Seth Holtzman
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

//
//  ContentView.swift
//  VonViz
//
//  Created by Kayla Quinlan on 9/14/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    ///Model to hold the data of our data chart
    @StateObject private var dcModel: DataChartModel = DataChartModel()
    //initial string for surface plot
    private static let initFunc: String = "sin(2 * x) * cos(y)"
    //Model to hold the data of surfaceplot
    //crash if first input doesnt work something is very wrong our default should ALWAYS work
    @StateObject var fModel: FuncChartModel = try! FuncChartModel(input: ContentView.initFunc)
    /// Show user message
    @State private var alertMessage: String?
    /// Show settings sheet
    @State private var showingSettings = false
    /// Show user manual sheet
    @State private var showingUserManual = false
    
    /// toolBar view with all main buttons of our app
    var toolBarContent: some View {
        HStack {
            // User Manual button moved to the far left
            Button {
                showingUserManual = true
            } label: {
                Image(systemName: "doc.text")
                    .imageScale(.large)
                    .accessibilityLabel("User Manual")
            }
            .padding(.trailing, 8)

            // Choose CSV File button (LoadButton) now comes after User Manual
            LoadButton(model: dcModel) { message in
                alertMessage = message
            }

            // Axis menus only if model has headers
            if !dcModel.headers.isEmpty {
                // X axis selector
                AxisButton(model: dcModel, axis: .x)
                AxisButton(model: dcModel, axis: .y)
                AxisButton(model: dcModel, axis: .z)
            }
            // Settings button
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
    
    ///data chart and toolbar for data visualization
    var dataChart : some View {
        VStack {
            if !dcModel.rows.isEmpty {
                    Chart(model: dcModel)
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
                .alert(alertMessage ?? "", isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                )) {
                    Button("OK", role: .cancel) { alertMessage = nil }
                }
                // Present Settings
                .sheet(isPresented: $showingSettings) {
                    SettingsSheet(model: dcModel)
                        .presentationDetents([.medium, .large])
                }
                // Present User Manual
                .sheet(isPresented: $showingUserManual) {
                    UserManual()
                        .presentationDetents([.medium, .large])
                }
        }
    }
           
    var funcChart : some View {
        FuncChart(model: fModel, initFunc: ContentView.initFunc)
            .tabItem{
                Text("Surface Plot")
            }
    }
            
    var body: some View {
        //tab view to switch between data visualization and function visualization
        TabView {
            dataChart
                //added the following framing to avoid clipping
                .offset(z: -350)
                .frame(width: 1500, height: 1500, alignment: .center)
                .frame(depth: 1500, alignment: .back)
                .tabItem {
                    Text("Data Chart")
                }
            funcChart
        }
    }
}
