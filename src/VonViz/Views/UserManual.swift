import SwiftUI
import UniformTypeIdentifiers
import QuickLook
import SafariServices

struct UserManual: View {
    @Environment(\.dismiss) private var dismiss
    // State for large file attach/preview
    @State private var quickLookItem: QLPreviewItemWrapper?
    @State private var showingHelper = false
    @State private var showingManualWeb = false // <-- new state

    private let manualURL = URL(string: "https://docs.google.com/document/d/1ao8-fAkPDrW8zezHz3fVqypJ6h8nPMJtJ3KifFBYjvQ/edit?tab=t.0")!

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Data Graph User Guide")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()

                    Group {
                        Text("Choose CSV File Button")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the Choose CSV File button in the toolbar to select and import a CSV file. Once loaded, your data will appear in the chart area.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Group {
                        Text("User Manual")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the document icon in the navigation bar to open the full user manual and documentation for the app.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Group {
                        Text("Helper Button")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the question mark icon in the navigation bar to learn how the syntax grammars work")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Group {
                        Text("X")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the X axis button to make changes to the graph's X axis")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Group {
                        Text("Y")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the Y axis button to make changes to the graph's Y axis")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Group {
                        Text("Z")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the Z axis button to make changes to the graph's Z axis")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
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

            // Present a popover with detailed instructions when showingHelper is true
            .popover(isPresented: $showingHelper, arrowEdge: .top) {
                Spacer()
                Button("Close") {
                    showingHelper = false
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
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

