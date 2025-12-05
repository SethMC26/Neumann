import SwiftUI
import UniformTypeIdentifiers
import QuickLook

struct UserManual: View {
    @Environment(\.dismiss) private var dismiss
    // State for large file attach/preview
    @State private var quickLookItem: QLPreviewItemWrapper?
    @State private var showingHelper = false
    
    var body: some View {
        NavigationStack {
            Form {
                Text("This user manual provides guidance for loading CSV data, configuring axes, adjusting display limits, and working with function-based surface plots.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .navigationTitle("User Manual")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showingHelper = true
                    } label: {
                        Image(systemName: "questionmark")
                            .imageScale(.large)
                            .accessibilityLabel("Surface Plot Guide")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Exit") { dismiss() }
                }
            }
            // Present a popover with detailed instructions when showingHelper is true
            .popover(isPresented: $showingHelper, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Data Graph User Guide")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 4)
                    
                    Group {
                        Text("**Importing a File**")
                            .font(.headline)
                        Text("Tap the document icon in the toolbar to select and import a CSV file. Once loaded, your data will appear in the chart area.")
                    }
                    
                    Group {
                        Text("**Setting Axis Scale & Header**")
                            .font(.headline)
                        Text("After importing, use the X, Y, and Z axis buttons to select which data column is mapped to each axis. In the popups, you can also set the minimum, maximum, and step size for each axis to adjust the chart's scale.")
                    }
                    
                    Group {
                        Text("**Changing Settings**")
                            .font(.headline)
                        Text("Tap the gear icon in the toolbar to open settings. Here you can adjust general display preferences and fine-tune how your data is visualized.")
                    }
                    
                    Spacer()
                    
                    Button("Close") {
                        showingHelper = false
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(width: 340)
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
}
