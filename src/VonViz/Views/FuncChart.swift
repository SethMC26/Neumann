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

import SwiftUI
import Charts

///Function Chart view aka Surface Plot
struct FuncChart : View {
    ///Internal Model for view
    @ObservedObject var model: FuncChartModel
    ///String representing current function in math lang
    @State private var function: String
    @State private var showKeyboard: Bool = false
    
    init(model: FuncChartModel, initFunc: String) {
        self.function = initFunc
        self.model = model
    }
    
    var chart : some View {
        Chart3D() {
            let ast = model.ast
                
            SurfacePlot(x: "x", y: "z", z: "y", ) { x, y in
                do {
                    return try ast.eval(x, y)
                }
                catch {
                    Log.Model.error("Surface plot cannot eval correctly")
                    return 0.0
                }
            }
            .foregroundStyle(.heightBased)
        }
        ///since x/y/yAxis is a publish var we will rerender everytime it is updated
        .chartXAxisLabel("x")
        .chartXScale(domain: model.xAxis.getDomain())
        .chartXAxis {
            AxisMarks(values: .stride(by: model.xAxis.steps))
        }
        //y and z is purposefully switch to match example math graphs
        .chartYAxisLabel("z")
        .chartYScale(domain: model.zAxis.getDomain())
        .chartYAxis {
            AxisMarks(values: .stride(by: model.zAxis.steps))
        }
        .chartZAxisLabel("y")
        .chartZScale(domain: model.yAxis.getDomain())
        .chartZAxis {
            AxisMarks(values: .stride(by: model.yAxis.steps))
        }
    }
    
    //COMPLETELY VIBE CODED WITH CHATGPT LIKELY NEEDS TO BE FIXED
    //yolo it looks good and works we gonna ship
    ///All vars are for vibe coded picker button
    @State private var axis: Axis = .x
    @State private var minVal = -4.0
    @State private var maxVal = 4.0
    @State private var steps = 1.5
    
    // Pull the current values for whichever axis is selected
    private func loadFields(from axis: Axis) {
        let info: AxisInfo
        switch axis {
        case .x: info = model.xAxis
        case .y: info = model.yAxis
        case .z: info = model.zAxis
        }
        minVal = info.min
        maxVal = info.max
        steps  = info.steps
    }
    ///toolbar vibed coded with ChatGPT looks good and function wells
    // if the hackathon taught me one thing its vibe coding UI works
    var toolbar: some View {
        VStack(alignment: .leading, spacing: 10) {
            LabeledContent("Function: ") {
                HStack {
                    // Tappable display for current function; opens popover
                    Text(function.isEmpty ? "Tap to enter function" : function)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture { showKeyboard.toggle() }
                        .popover(isPresented: $showKeyboard, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                            // Fully visible keyboard, no scrolling, explicit size to avoid clipping
                            MathKeyboardView(text: $function)
                                .padding(12)
                                // Ensure the popover has a concrete size that fits the keyboard
                                // Tune these numbers if you change the keyboard layout later.
                                .frame(width: 720, height: 360)   // wide and tall enough for all rows
                                // Optional: scale keys a touch larger for comfort
                                .scaleEffect(1.05)
                                // Keep the “closer” depth if desired
                                .offset(z: 1000)
                                // Move the popover down relative to the anchor (positive is down)
                                .offset(y: 100)
                        }
                        .layoutPriority(1) // keep this from collapsing
                    
                    Button("Evaluate") {
                        do {
                            try model.setInput(function)
                            showKeyboard = false
                        } catch {
                            Log.UserView.error("Error updating surfaceplot \(error)")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(minWidth: 150)
                    
                    Button("Clear") {
                        function = ""
                    }
                    .buttonStyle(.bordered)
                    .frame(minWidth: 90)
                }
            }
            // Initial load + update when axis changes
            .onAppear { loadFields(from: axis) }
            .onChange(of: axis) {
                loadFields(from: axis)
            }
            
            // Axis controls below
            // Wrap in horizontal scroll to avoid squeezing on compact widths
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Picker("Axis", selection: $axis) {
                        Text("X").tag(Axis.x)
                        Text("Y").tag(Axis.y)
                        Text("Z").tag(Axis.z)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    
                    HStack(spacing: 5) {
                        Text("Min:")
                        TextField("", value: $minVal, format: .number)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack(spacing: 5) {
                        Text("Max:")
                        TextField("", value: $maxVal, format: .number)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack(spacing: 5) {
                        Text("Steps:")
                        TextField("", value: $steps, format: .number)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Button("Apply") {
                        try? model.setAxis(axis: axis, max: maxVal, min: minVal, steps: steps)
                        //todo add error handing if min < max right now the model will throw and we silently fail
                        // we need to let the user know what they did wrong
                        
                        // Optional: reload from model in case it clamps/normalizes
                        loadFields(from: axis)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minWidth: 90)
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    var body : some View {
        VStack {
            self.chart
            self.toolbar
        }
        .padding()
    }
}
