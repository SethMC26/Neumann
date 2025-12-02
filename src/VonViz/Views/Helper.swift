//
//  Helper.swift
//  VonViz
//
//  Created by Michael Plescia on 2025-12-01.
//

import SwiftUI

struct Helper: View {
    var body: some View {
        toolBarContent
    }
    
    var toolBarContent: some View {
        HStack {
            // User Manual button moved to the far left
            Button {
                // showingUserManual = true // <-- You must provide this state from outside if needed
            } label: {
                Image(systemName: "?")
                    .imageScale(.large)
                    .accessibilityLabel("Help Guide")
            }
            .padding(.trailing, 8)
        }
    }
}
