import SwiftUI
import UniformTypeIdentifiers
import QuickLook
import SafariServices

struct UserManual: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quickLookItem: QLPreviewItemWrapper?
    @State private var showingHelper = false
    @State private var showingManualWeb = false

    private let manualURL = URL(string: "https://docs.google.com/document/d/1ao8-fAkPDrW8zezHz3fVqypJ6h8nPMJtJ3KifFBYjvQ/edit?tab=t.0")!

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .center, spacing: 16) {
                    Group {
                        Text("Choose CSV File Button")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the Choose CSV File button in the toolbar to select and import a CSV file. Once loaded, your data will appear in the chart area.")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Group {
                        Text("User Manual")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the document icon in the navigation bar to open the full user manual and documentation for the app.")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Group {
                        Text("Helper Button")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the question mark icon in the navigation bar to learn how the syntax grammars work")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Group {
                        Text("X")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the X axis button to make changes to the graph's X axis")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Group {
                        Text("Y")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the Y axis button to make changes to the graph's Y axis")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Group {
                        Text("Z")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the Z axis button to make changes to the graph's Z axis")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("User Manual")
            Button("Exit") { dismiss() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingManualWeb = true
                    } label: {
                        Image(systemName: "doc.text")
                            .imageScale(.large)
                            .accessibilityLabel("User Manual")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingHelper = true
                    } label: {
                        Image(systemName: "questionmark")
                            .imageScale(.large)
                            .accessibilityLabel("Surface Plot Guide")
                    }
                }
            }
            // SHOW THE NEW GUIDE IN THE POPOVER
            .popover(isPresented: $showingHelper, arrowEdge: .top) {
                HelperGuideView(
                    onOpenManual: { showingManualWeb = true },
                    onClose: { showingHelper = false }
                )
                .frame(width: 500, height: 700) // Or adjust as needed for your UI
            }
            .sheet(isPresented: $showingManualWeb) {
                SafariView(url: manualURL)
            }
            .padding()
            .frame(width: 340)
        }
    }

    // MARK: - Quick Look helpers

    private struct QLPreviewItemWrapper: Identifiable {
        let id = UUID()
        let url: URL
    }

    private struct QuickLookPreview: UIViewControllerRepresentable {
        let item: QLPreviewItemWrapper

        func makeUIViewController(context: Context) -> QLPreviewController {
            let controller = QLPreviewController()
            controller.dataSource = context.coordinator
            return controller
        }

        func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(item: item)
        }

        final class Coordinator: NSObject, QLPreviewControllerDataSource {
            let item: QLPreviewItemWrapper
            init(item: QLPreviewItemWrapper) { self.item = item }

            func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
            func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
                item.url as NSURL
            }
        }
    }
}

// MARK: - SafariView (SwiftUI wrapper for SFSafariViewController)
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
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
                                  - Integer Division: `//`
                                
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
                            Text("3. Tap **Evaluate** to update the plot, or **Clear** to start over.")
                            Text("4. Use the **Delete** button to erase symbols one at a time.")
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
                                2. Edit **Min**, **Max**, and **Steps** fields to set the axis range and step size.
                                3. Tap **Apply** to update the graph.
                                
                                - The plot will instantly refresh using your new axis settings.
                                - Make sure Min < Max for each axis.
                                """
                            )
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.primary)
                        }
                    }
                }
                Button("Close", action: onClose)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: 500, maxHeight: 700)
        }
    }
}
