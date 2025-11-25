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

///Chart that has the visualization of the data
struct Chart : View {
    ///Model with backend data
    @ObservedObject var model: DataChartModel
    
    /// Create a new Axis button
    /// - Parameters:
    ///   - model: Model for button to update
    init(model: DataChartModel) {
        self.model = model
    }
    
    var body: some View {
        // attempt to get the string for each axis if not able use placeholder
        let xLabel: String = "X: \(model.getAxisHeader(axisToGet: .x) ?? "X Axis")"
        let yLabel: String = "Y: \(model.getAxisHeader(axisToGet: .y) ?? "Y Axis")"
        let zLabel: String = "Z: \(model.getAxisHeader(axisToGet: .z) ?? "Z Axis")"

        // Pull AxisInfo (min/max/steps). If it throws or is invalid, use defaults.
        let xInfo = try? model.getAxisInfo(axis: .x)
        let yInfo = try? model.getAxisInfo(axis: .y)
        let zInfo = try? model.getAxisInfo(axis: .z)

        // Domains from AxisInfo (fallback to -50...50)
        let xDom: ClosedRange<Double> = (try? model.getAxisRange(axis: .x)) ?? (-50...50)
        let yDom: ClosedRange<Double> = (try? model.getAxisRange(axis: .y)) ?? (-50...50)
        let zDom: ClosedRange<Double> = (try? model.getAxisRange(axis: .z)) ?? (-50...50)
        
        // Tick values from steps (if <= 0, let Charts auto-pick ticks by giving an empty list)
        //chatgpt generated ticks for chart 
        let xTicks: [Double] = {
            guard let info = xInfo, info.steps > 0 else { return [] }
            return Array(stride(from: info.min, through: info.max, by: info.steps))
        }()
        let yTicks: [Double] = {
            guard let info = yInfo, info.steps > 0 else { return [] }
            return Array(stride(from: info.min, through: info.max, by: info.steps))
        }()
        let zTicks: [Double] = {
            guard let info = zInfo, info.steps > 0 else { return [] }
            return Array(stride(from: info.min, through: info.max, by: info.steps))
        }()

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
        // Use steps to control tick marks when provided
        .chartXAxis {
            // If xTicks is empty, Charts will auto-generate marks
            AxisMarks(values: xTicks)
        }
        .chartYAxis {
            AxisMarks(values: yTicks)
        }
        .chartZAxis {
            AxisMarks(values: zTicks)
        }
        
    }
}
