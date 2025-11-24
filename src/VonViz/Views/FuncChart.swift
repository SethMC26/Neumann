import SwiftUI
import Charts

@available(visionOS 26.0, *)
struct FuncChart : View {
    @ObservedObject var model: FuncChartModel
    @State private var function: String
    @State private var showKeyboard: Bool = false
    
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
                
            VStack(spacing: 15) {
                LabeledContent("Function: ") {
                    HStack {
                        Text(function.isEmpty ? "Tap to enter function" : function)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .onTapGesture {
                                showKeyboard.toggle()
                            }
                        
                        Button("Evaluate") {
                            do {
                                try model.setInput(function)
                                showKeyboard = false
                            } catch {
                                Log.UserView.error("Error updating surfaceplot \(error)")
                            }
                        }
<<<<<<< Updated upstream
                        .buttonStyle(.borderedProminent)
                        
                        Button("Clear") {
                            function = ""
                        }
=======
>>>>>>> Stashed changes
                        .buttonStyle(.bordered)
                    }
                }
                .frame(width: 1000)
                
                if showKeyboard {
                    MathKeyboardView(text: $function)
                        .frame(width: 1000)
                }
            }
            .offset(z: 200)
        }
    }
}
