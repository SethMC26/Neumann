import SwiftUI
import Charts

@available(visionOS 26.0, *)
///Function Chart view aka Surface Plot
struct FuncChart : View {
    ///Internal Model for view
    @ObservedObject var model: FuncChartModel
    ///String representing current function in math lang
    @State private var function: String
    
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
    
    ///Toolbar for UI
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
            // Function input on top
            TextField("Enter function", text: $function)
                .multilineTextAlignment(.leading)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .frame(width: 400)
                .onSubmit {
                    do { try model.setInput(function) }
                    catch { Log.UserView.error("Error updating surfaceplot \(error)") }
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
                        .frame(width: 60)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack(spacing: 5) {
                    Text("Max:")
                    TextField("", value: $maxVal, format: .number)
                        .frame(width: 60)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack(spacing: 5) {
                    Text("Steps:")
                    TextField("", value: $steps, format: .number)
                        .frame(width: 60)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button("Apply") {
                    try? model.setAxis(axis: axis, max: maxVal, min: minVal, steps: steps)
                    // Optional: reload from model in case it clamps/normalizes
                    loadFields(from: axis)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        // Initial load + update when axis changes
        .onAppear { loadFields(from: axis) }
            .onChange(of: axis) {
                loadFields(from: axis)
            }
    }
    
    var body : some View {
        VStack {
            self.chart
                .offset(z: -100)
            self.toolbar
                .offset(z: 200)
        }
    }
}
