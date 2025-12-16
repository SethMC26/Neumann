import SwiftUI
import UniformTypeIdentifiers
import QuickLook
import SafariServices

struct UserManual: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quickLookItem: QLPreviewItemWrapper?
    @State private var showingHelper = false
    @State private var showingManualWeb = false
    @State private var showingFuncChartHelp = false  // NEW: For FuncChart explanation/help
    private static let defaultFunc = "sin(2 * x) * cos(y)"
    @StateObject private var funcChartModel = try! FuncChartModel(input: defaultFunc)
    
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
                        Text("Setting Sheet")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the Settings icon in the navigation bar to open the display limit. Adjust the limit to control how many data points are displayed in the chart.")
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
                    
                    // --- FuncChart Section ---
                    Group {
                        Text("FuncChart (Surface Plot)")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("The FuncChart lets you visualize a mathematical function of two variables as a 3D surface plot. Tap below for an explanation.")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button(action: { showingFuncChartHelp = true }) {
                            Label("FuncChart Explanation", systemImage: "info.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 6)
                        .sheet(isPresented: $showingFuncChartHelp) {
                            FuncChartExplanationSheet(
                                onShowChart: {
                                    // Show the surface plot interactively (optional)
                                    showingFuncChartHelp = false
                                    // Optionally, you could add a second state var to show the chart after help
                                },
                                onClose: { showingFuncChartHelp = false }
                            )
                            .presentationDetents([.medium, .large])
                        }
                        
                        // Inline explanation/guide for surface plot is now in the sheet
                    }
                }
            }
            .navigationTitle("User Manual")
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
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                            .accessibilityLabel("Surface Plot Guide")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Exit") { dismiss() }
                }
            }
            .popover(isPresented: $showingHelper, arrowEdge: .top) {
                Helper.HelperGuideView(
                    onOpenManual: { showingManualWeb = true },
                    onClose: { showingHelper = false }
                )
                .frame(width: 500, height: 700)
            }
            .sheet(isPresented: $showingManualWeb) {
                SafariView(url: manualURL)
            }
        }
    }

    // MARK: - FuncChart Explanation Sheet
    private struct FuncChartExplanationSheet: View {
        var onShowChart: () -> Void
        var onClose: () -> Void
        
        var body: some View {
            NavigationStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text("FuncChart (Surface Plot) Explanation")
                        .font(.title2)
                        .bold()
                    Text("• Enter a function of x and y (e.g., 'sin(2 * x) * cos(y)') in the Function field.")
                        .font(.title2)
                        .bold()
                    Text("• Adjust X, Y, and Z axis ranges and steps with the axis controls.")
                        .font(.title2)
                        .bold()
                    Text("• The plot updates live as you make changes.")
                        .font(.title2)
                        .bold()
                    Text("• For supported operations (e.g., +, -, *, /, sin, cos, tan, **, //) see the user manual.")
                        .font(.title2)
                        .bold()
                    Text("• You can view and interact with the surface plot by tapping the button below.")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: onShowChart) {
                        Label("Show Interactive FuncChart", systemImage: "cube.transparent")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                    
                    Button("Close", action: onClose)
                        .buttonStyle(.bordered)
                        .padding(.vertical)
                }
                .padding()
            }
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

    // MARK: - SafariView (SwiftUI wrapper for SFSafariViewController)
    struct SafariView: UIViewControllerRepresentable {
        let url: URL

        func makeUIViewController(context: Context) -> SFSafariViewController {
            SFSafariViewController(url: url)
        }

        func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    }
}
