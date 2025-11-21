//
//  UserManual.swift
//  VonViz
//
//  Created by Michael Plescia on 2025-11-20.
//

import SwiftUI

struct UserManual: View {
    typealias Body =
    
    var body : some View {
        // TEMP button for testing
        Button("User Manual") {
            isImporterPresented = true
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
                            } catch let error as AppError {
                        }
                    }
                }
            }
        }
    }
}
