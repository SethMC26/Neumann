import SwiftUI
import UniformTypeIdentifiers
import QuickLook

struct UserManual: View {
    @Environment(\.dismiss) private var dismiss
    
    // State for large file attach/preview
    @State private var isImporterPresented = false
    @State private var attachedFileURL: URL?
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
                            showingHelper = true // <-- You must provide this state from outside if needed
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

