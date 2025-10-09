import SwiftUI

///Load button to load in a CSV file
struct LoadButton : View {
    ///Model for data updates
    @ObservedObject var model: AppModel
    ///flag to show if we should present the data view
    @State private var isImporterPresented = false

    /// Create a new Axis button
    /// - Parameters:
    ///   - model: Model for button to update
    init(model: AppModel) {
        self.model = model
    }
    
    var body : some View {
        // TEMP button for testing
        Button("Choose CSV File") {
            isImporterPresented = true
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    Log.UserView.debug("Picked file: \(url)")
                    do {
                        try model.ingestFile(file: url)
                    } catch {
                        Log.UserView.error("Error loading file: \(error.localizedDescription)")
                    }
                } else {
                    Log.UserView.error("File picker returned empty URL list")
                }
            case .failure(let error):
                Log.UserView.error("Failed to pick file: \(error.localizedDescription)")
            }
        }
    }
}
