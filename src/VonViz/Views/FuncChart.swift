import SwiftUI
import Charts

struct FuncChart : View {
    @ObservedObject var model: FuncChartModel
    @State private var function: String = ""
    
    init(model: FuncChartModel) {
       self.model = model
    }
    
    var body : some View {
        VStack {
            if #available(visionOS 26.0, *) {
                Chart3D() {
                    SurfacePlot(x: "x", y: "y", z: "z") { x, z in
                            sin(2 * x) * cos(z)
                        }
                    .foregroundStyle(.heightBased)
                }
                .offset(z: -100)
            }
                
            LabeledContent("Function: ") {
                TextField("Enter function", text: $function)
                    .multilineTextAlignment(.leading)
                    //add box to help let user know they can tap it
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
            }.frame(width: 1000).offset(z: 200)
        }
    }
}
