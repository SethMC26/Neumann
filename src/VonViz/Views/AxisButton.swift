import SwiftUI

struct AxisButton : View {
    @ObservedObject var model: AppModel
    let axis: Axis

    init(model: AppModel, axis: Axis) {
        self.model = model
        self.axis = axis
    }
    
    var body : some View {
        Menu {
            ForEach(model.headers, id: \.self) { header in
                Button(header) {
                    do {
                        try model.setAxis(axisToSet: axis, header: header)
                        Log.UserView.info("Set \(axis) axis to '\(header)'")
                    } catch {
                        //todo add better error handling 
                        Log.UserView.error("Error setting X axis: \(error.localizedDescription)")
                    }
                }
            }
        } label: {
            switch axis {
            case .x:
                Label("Set X Axis", systemImage: "chart.xyaxis.line") // safe symbol
                    .labelStyle(.titleAndIcon)
            case .y:
                Label("Set y Axis", systemImage: "chart.xyaxis.line") // safe symbol
                    .labelStyle(.titleAndIcon)
            case .z:
                Label("Set z Axis", systemImage: "chart.xyaxis.line") // safe symbol
                    .labelStyle(.titleAndIcon)
            }
            
        }
    }
}
