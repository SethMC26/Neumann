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
        VStack(alignment: .leading, spacing: 25) {
            Text(function.isEmpty ? "Tap to enter function" : function)
                .frame(maxWidth: 1000, alignment: .leading)
                .background(Color.gray.opacity(0.2))
                .padding()
                .cornerRadius(8)
                .onTapGesture { showKeyboard.toggle() }
                .popover(isPresented: $showKeyboard/*, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom */) {
                    // Larger, fully visible keyboard; shifted left to avoid right-edge clipping
                    MathKeyboardView(text: $function, onEvaluate: {
                        do {
                            try model.setInput(function)
                            showKeyboard = false
                        } catch {
                            // Keep the keyboard open so the user can fix the input
                            Log.UserView.error("Error updating surfaceplot \(error)")
                            showKeyboard = false
                        }
                    })
                    .padding(12)
                    .background(Color.gray.opacity(0.9))
                    .frame(width: 900, height: 560)  // wider & taller to ensure full visibility
                    //.offset(x: -220)                 // shift left so right side isn't clipped
                    .offset(z: 600)                 // keep it closer to the user
                    .offset(y: 50)                   // move down a bit
                    }
                .layoutPriority(1) // keep this from collapsing
                // Initial load + update when axis changes
                .onAppear { loadFields(from: axis) }
                .onChange(of: axis) {
                    loadFields(from: axis)
                }
            
            // Axis controls below
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
        }
    }
    
    var body : some View {
        VStack {
            self.chart
                .offset(z: -200)
            self.toolbar
                .offset(z: 600)
        }
        .padding()
    }
}
