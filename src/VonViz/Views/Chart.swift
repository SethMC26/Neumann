import SwiftUI
import Charts

///Chart that has the visualization of the data
struct Chart : View {
    ///Model with backend data
    @ObservedObject var model: AppModel
    
    /// Create a new Axis button
    /// - Parameters:
    ///   - model: Model for button to update
    init(model: AppModel) {
        self.model = model
    }
    
    var body : some View {
        // attempt to get the string for each axis if not able use placeholder
        let xLabel: String = "X: \(model.getAxisHeader(axisToGet: .x) ?? "X Axis")"
        let yLabel: String = "Y: \(model.getAxisHeader(axisToGet: .y) ?? "Y Axis")"
        let zLabel: String = "Z: \(model.getAxisHeader(axisToGet: .z) ?? "Z Axis")"
        
        //attempt to get axis range but fall back to a default range
        let xDom = (try? model.getAxisRange(axis: .x)) ?? (-50...50)
        let yDom = (try? model.getAxisRange(axis: .y)) ?? (-50...50)
        let zDom = (try? model.getAxisRange(axis: .z)) ?? (-50...50)
        
        if #available(visionOS 26.0, *) {
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
        //not avaiable show placeholder; User error they must update AVP
        else {
            ContentUnavailableView("Only VisionOS 26 or newer is supported", systemImage: "tray")
        }
    }
}
