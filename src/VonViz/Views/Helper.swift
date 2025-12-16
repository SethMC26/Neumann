//
//  Helper.swift
//  VonViz
//
//  Created by Michael Plescia on 2025-12-01.
//

import SwiftUI

struct Helper: View {
    @State private var showingHelper = true
    @State private var showingManualWeb = false

    // Reuse the same manual URL used elsewhere
    private let manualURL = URL(string: "https://docs.google.com/document/d/1ao8-fAkPDrW8zezHz3fVqypJ6h8nPMJtJ3KifFBYjvQ/edit?tab=t.0")!

    var body: some View {
        // Present the guide content directly. You can embed this in a popover/sheet where Helper is used.
        Group {
            if showingHelper {
                HelperGuideView(
                    onOpenManual: { showingManualWeb = true },
                    onClose: { showingHelper = false }
                )
                .frame(width: 500, height: 700)
            } else {
                EmptyView()
            }
        }
        .sheet(isPresented: $showingManualWeb) {
            SafariView(url: manualURL)
        }
    }

    // MARK: - HelperGuideView: The guide content as a reusable view with close/manual actions
    struct HelperGuideView: View {
        var onOpenManual: () -> Void
        var onClose: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        // Header
                        Text("Functional Graph & Grammar Guide")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .bold()
                            .padding(.top)
                            .fixedSize(horizontal: true, vertical: true)

                        GroupBox(label: Label("What is the Functional Graph?", systemImage: "function")) {
                            Text("""
                            The Functional Graph lets you visualize mathematical functions of two variables (x, y) as interactive 3D surface plots.
                            You can enter your own function, adjust the plotting range for each axis, and instantly view the result.
                            """)
                            .font(.body)
                            .padding(.top, 4)
                        }

                        GroupBox(label: Label("Allowed Grammar", systemImage: "keyboard")) {
                            VStack(alignment: .center, spacing: 16) {
                                Text("Enter mathematical expressions with:")
                                    .font(.headline)
                                Text(
                                    """
                                    • Numbers: `1, 2.5, -3`, etc.

                                    • Operators:
                                      - Addition: `+`
                                      - Subtraction: `-`
                                      - Multiplication: `*`
                                      - Division: `/`
                                      - Power: `**` (for exponents, e.g., `x**2`)
                                      - nth: `8/2 is the square root of 8`

                                    • Parentheses: for grouping, e.g., `(x + y) * 2`

                                    • Functions: `sin(expr)`, `cos(expr)`, `tan(expr)`

                                    • Variables: `x`, `y` (e.g., `sin(2 * x) * cos(y)`)
                                    """
                                )
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.primary)
                                .padding(.bottom, 8)

                                Text("Example:").font(.headline)
                                Text("sin(2 * x) * cos(y)")
                                    .font(.system(.title3, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 4)

                                Text("Tap the function field to open the math keyboard, which only contains valid inputs for this grammar.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        GroupBox(label: Label("Entering and Editing Functions", systemImage: "square.and.pencil")) {
                            VStack(alignment: .center, spacing: 16) {
                                Text("1. Tap the large function field above the graph (shows your current formula).")
                                Text("2. Use the math keyboard to type or edit your function.")
                                Text("3. Tap Evaluate to update the plot, or Clear to start over.")
                                Text("4. Use the Delete button to erase symbols one at a time.")
                                Text("If the input is invalid, you'll see an error and can fix your formula.")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        GroupBox(label: Label("Setting Axis Scale", systemImage: "ruler")) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("To adjust the plotting range for X, Y, or Z axes:")
                                    .font(.headline)
                                Text(
                                    """
                                    1. Use the Axis picker (“X”, “Y”, “Z”) beneath the function field to select an axis.
                                    2. Edit Min, Max, and Steps fields to set the axis range and step size.
                                    3. Tap Apply to update the graph.

                                    - The plot will instantly refresh using your new axis settings.
                                    - Make sure Min < Max for each axis.
                                    """
                                )
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.primary)
                            }
                        }

                        HStack(spacing: 12) {
                            Button("FuncChart") { onOpenManual() }
                                .buttonStyle(.borderedProminent)
                            Button("Close", action: onClose)
                                .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    .padding()
                    .frame(maxWidth: 500)
                }
            }
        }
    }
}
