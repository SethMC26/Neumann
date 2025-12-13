/*
 *   Copyright (C) 2025  Seth Holtzman
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import SwiftUI

///Load button to load in a CSV file
struct LoadButton : View {
    ///Model for data updates
    @ObservedObject var model: DataChartModel
    ///flag to show if we should present the data view
    @State private var isImporterPresented = false
    /// Closure to notify caller of an error (e.g. show alert)
    var onError: ((String) -> Void)?
    
    /// Create a new Load button
    /// - Parameters:
    ///   - model: Model for button to update
    ///   - onError: Closure called with error message for user if loading fails (optional)
    init(model: DataChartModel, onError: ((String) -> Void)? = nil) {
        self.model = model
        self.onError = onError
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
                    // Some File Provider locations require security-scoped access even when returned by the picker.
                    let needsAccess = url.startAccessingSecurityScopedResource()
                    defer {
                        if needsAccess {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                    do {
                        try model.ingestFile(file: url)
                    } catch let error as AppError {
                        Log.UserView.error("Error loading file: \(error)")
                        // Show user-friendly message for known errors
                        let message: String
                        switch error {
                        case .noLoadedDataset:
                            message = "No dataset could be loaded from the selected file. Please check the file and try again."
                        case .notEnoughColumns:
                            message = "This dataset does not have enough numeric columns to visualize. Please select a CSV file with at least three number columns."
                        case .headerNotRecongized:
                            message = "One or more selected columns could not be recognized in the file. Please reselect your axes."
                        case .internalStateError:
                            message = "An internal error occurred while loading the dataset. Please try again or contact support if the issue persists."
                        case .minGreaterThanMax:
                            message = "The minimum axis value is greater than the maximum. Please check your axis settings and try again."
                        }
                        onError?(message)
                    } catch {
                        Log.UserView.error("Error loading file: \(error)")
                        onError?("An unexpected error occurred: \(error.localizedDescription)")
                    }
                } else {
                    Log.UserView.error("File picker returned empty URL list")
                    onError?("No file was selected.")
                }
            case .failure(let error):
                Log.UserView.error("Failed to pick file: \(error)")
                onError?("Failed to pick a file: \(error.localizedDescription)")
            }
        }
    }
}
