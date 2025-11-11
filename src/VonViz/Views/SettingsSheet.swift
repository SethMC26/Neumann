import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var model: DataChartModel
    @Environment(\.dismiss) private var dismiss

    @State private var displayLimitText: String

    init(model: DataChartModel) {
        self.model = model
        _displayLimitText = State(initialValue: "\(model.displayLimit)")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Display Limit")) {
                    TextField("Row display limit", text: $displayLimitText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let newLimit = Int(displayLimitText), newLimit > 0 {
                            model.displayLimit = newLimit
                        }
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            self.displayLimitText = "\(model.displayLimit)"
        }
    }
}
