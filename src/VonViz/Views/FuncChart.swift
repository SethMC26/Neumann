import SwiftUI
import Charts

@available(visionOS 26.0, *)
struct FuncChart : View {
    @ObservedObject var model: FuncChartModel
    @State private var function: String
    
    init(model: FuncChartModel, initFunc: String) {
        self.function = initFunc
        self.model = model
    }
    
    var body : some View {
        VStack {
            Chart3D() {
                let ast = model.ast
                    
                SurfacePlot(x: "x", y: "y", z: "z", ) { x, z in
                    do {
                        return try ast.eval(x, z)
                    }
                    catch {
                        Log.Model.error("Surface plot cannot eval correctly")
                        return 0.0
                    }
                }
                .foregroundStyle(.heightBased)
            }
            .chartXScale(domain: -1...1)   // widen X
            .chartYScale(domain: -1...1)   // widen Y
            .chartZScale(domain: -1...1)
            .offset(z: -100)
                
            LabeledContent("Function: ") {
                TextField("Enter function", text: $function)
                    .multilineTextAlignment(.leading)
                    //add box to help let user know they can tap it
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit() {
                        do {
                            try model.setInput(function)
                        } catch {
                            Log.UserView.error("Error updating surfaceplot \(error)")
                        }
                    }
            }.frame(width: 1000).offset(z: 200)
        }
    }
}
