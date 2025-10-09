import SwiftUI

struct LoadButton : View {
    @ObservedObject var model: AppModel
    @State private var isImporterPresented = false

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
