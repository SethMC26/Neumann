import SwiftUI

///Button to control the axis of our model
///Author - ChatGPT
struct AxisButton: View {
    //BELOW CODE IS 100% CHATGPT GENERATED
    //I Vibe coded this because I am not a UI dev or care to be one - seth
    //Someone should probably fix it
    @ObservedObject var model: AppModel
    let axis: Axis

    // Sheet state
    @State private var showingSheet = false

    // Current (baseline) values loaded from the model
    @State private var currentHeader: String?
    @State private var currentMin: Double?
    @State private var currentMax: Double?
    @State private var currentSteps: Double?

    // Editable text fields
    @State private var minText: String = ""
    @State private var maxText: String = ""
    @State private var stepsText: String = ""

    /// Create a new Axis button
    /// - Parameters:
    ///   - model: Model for button to update
    ///   - axis: Axis that this button will control(Axis.x, Axis.y, Axis,z)
    init(model: AppModel, axis: Axis) {
        self.model = model
        self.axis = axis
    }

    var body: some View {
        Button {
            do {
                // Preload values before showing the sheet
                let info = try model.getAxisInfo(axis: self.axis)
                currentHeader = info.header
                currentMin = info.min
                currentMax = info.max
                currentSteps = info.steps
                minText = String(info.min)
                maxText = String(info.max)
                stepsText = String(info.steps)
                showingSheet = true
            } catch {
                Log.UserView.error("Failed to get axis info for \(axis): \(error)")
            }
        } label: {
            // set label based on axis
            switch axis {
            case .x:
                Label("Set X Axis", systemImage: "chart.xyaxis.line").labelStyle(.titleAndIcon)
            case .y:
                Label("Set y Axis", systemImage: "chart.xyaxis.line").labelStyle(.titleAndIcon)
            case .z:
                Label("Set z Axis", systemImage: "chart.xyaxis.line").labelStyle(.titleAndIcon)
            }
        }
        .sheet(isPresented: $showingSheet) {
            NavigationStack {
                Form {
                    // Header dropdown
                    Section {
                        Menu {
                            ForEach(model.headers, id: \.self) { header in
                                Button(header) {
                                    currentHeader = header
                                    try? model.setAxis(axisToSet: axis, header: header)
                                }
                            }
                        } label: {
                            HStack {
                                Text("Header")
                                Spacer()
                                Text(currentHeader ?? "Select header")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Inline editors for Min / Max / Steps
                    Section("Edit Values") {
                        TextField("Min", text: $minText)
                            .keyboardType(.decimalPad)
                        TextField("Max", text: $maxText)
                            .keyboardType(.decimalPad)
                        TextField("Steps", text: $stepsText)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("\(axisLabel) Options")
                // Done button automatically applies changes before closing
                .navigationBarItems(trailing: Button("Done") {
                    // Parse input
                    let newMin = Double(minText)
                    let newMax = Double(maxText)
                    let newSteps = Double(stepsText)

                    // Compare to previous values
                    let minToSend = changedOrNil(newValue: newMin, current: currentMin)
                    let maxToSend = changedOrNil(newValue: newMax, current: currentMax)
                    let stepsToSend = changedOrNil(newValue: newSteps, current: currentSteps)

                    // Apply updates
                    try? model.setAxisDomain(axis: axis,
                                             min: minToSend,
                                             max: maxToSend,
                                             steps: stepsToSend)

                    // Update local baselines
                    if let v = minToSend { currentMin = v }
                    if let v = maxToSend { currentMax = v }
                    if let v = stepsToSend { currentSteps = v }

                    showingSheet = false
                })
            }
        }
    }

    // Helper: returns newValue only if it differs significantly from current
    private func changedOrNil(newValue: Double?, current: Double?) -> Double? {
        guard let new = newValue, let cur = current else { return newValue }
        let eps = 1e-12
        return abs(new - cur) <= eps ? nil : new
    }

    private var axisLabel: String {
        switch axis {
        case .x: return "X"
        case .y: return "Y"
        case .z: return "Z"
        }
    }
}

