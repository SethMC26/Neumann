//
//  ContentView.swift
//  VonViz
//
//  Created by Kayla Quinlan on 9/14/25.
//

import SwiftUI

struct ContentView: View {
    ///Model to hold the data of our data chart
    @StateObject private var dcModel: DataChartModel = DataChartModel()
    //initial string for surface plot
    private static let initFunc: String = "sin(2 * x) * cos(z)"
    //Model to hold the data of surfaceplot
    //crash if first input doesnt work something is very wrong our default should ALWAYS work
    @StateObject var fModel: FuncChartModel = try! FuncChartModel(input: ContentView.initFunc)
    
    /// toolBar view with all main buttons of our app
    var toolBarContent: some View {
        HStack {
            LoadButton(model: dcModel)
            // Axis menus only if model has headers
            if !dcModel.headers.isEmpty {
                // X axis selector
                AxisButton(model: dcModel, axis: .x)
                AxisButton(model: dcModel, axis: .y)
                AxisButton(model: dcModel, axis: .z)
            }
        }
    }
    
    ///data chart and toolbar for data visualization
    var dataChart : some View {
        VStack {
            if #available(visionOS 26.0, *), !dcModel.rows.isEmpty {
                Chart(model: dcModel)
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
   
    @available(visionOS 26.0, *)
    var funcChart : some View {
        FuncChart(model: fModel, initFunc: ContentView.initFunc)
            .tabItem{
                Text("Surface Plot")
            }
        
    }
    
    var body: some View {
        //tab view to switch between data visualization and function visualization
        TabView {
            if #available(visionOS 26.0, *){
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
}
