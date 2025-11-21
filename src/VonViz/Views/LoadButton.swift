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

    /// Create a new Axis button
    /// - Parameters:
    ///   - model: Model for button to update
    init(model: DataChartModel) {
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
                        Log.UserView.error("Error loading file: \(error)")
                    }
                } else {
                    Log.UserView.error("File picker returned empty URL list")
                }
            case .failure(let error):
                Log.UserView.error("Failed to pick file: \(error)")
            }
        }
    }
}
