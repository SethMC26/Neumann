import SwiftUI
import UniformTypeIdentifiers
import QuickLook

struct UserManual: View {
    @Environment(\.dismiss) private var dismiss

    // State for large file attach/preview
    @State private var isImporterPresented = false
    @State private var attachedFileURL: URL?
    @State private var quickLookItem: QLPreviewItemWrapper?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("User Manual")) {
                    Text("This user manual provides guidance for loading CSV data, configuring axes, adjusting display limits, and working with function-based surface plots.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Section(header: Text("Large File or Sheet")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attach a large reference file (e.g., PDF, CSV, or documentation) to view or keep handy while using the app.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        HStack {
                            Button {
                                isImporterPresented = true
                            } label: {
                                Label("Attach File", systemImage: "paperclip")
                            }

                            if attachedFileURL != nil {
                                Button {
                                    if let url = attachedFileURL {
                                        quickLookItem = QLPreviewItemWrapper(url: url)
                                    }
                                } label: {
                                    Label("Preview", systemImage: "doc.richtext")
                                }
                            }
                        }

                        if let url = attachedFileURL {
                            Divider().padding(.vertical, 4)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(url.lastPathComponent)
                                    .font(.subheadline)
                                    .bold()
                                    .lineLimit(2)
                                if let size = fileSizeString(for: url) {
                                    Text("Size: \(size)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(url.path(percentEncoded: false))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        } else {
                            Text("No file attached yet.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("User Manual")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Exit") { dismiss() }
                }
            }
            // File importer for attaching a large file
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [
                    .item,                // allow any file
                    .pdf,                 // common doc
                    .plainText,
                    .commaSeparatedText,  // CSV
                    .data
                ],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let first = urls.first {
                        attachedFileURL = first
                        quickLookItem = QLPreviewItemWrapper(url: first)
                        Log.UserView.info("Attached file: \(first)")
                    }
                case .failure(let error):
                    Log.UserView.error("Failed to attach file: \(error)")
                }
            }
            // Quick Look preview sheet
            .sheet(item: $quickLookItem) { item in
                QuickLookPreview(item: item)
                    .ignoresSafeArea()
            }
        }
    }

    private func fileSizeString(for url: URL) -> String? {
        do {
            let res = try url.resourceValues(forKeys: [.fileSizeKey])
            if let bytes = res.fileSize {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                return formatter.string(fromByteCount: Int64(bytes))
            }
        } catch {
            Log.UserView.error("Could not read file size: \(error)")
        }
        return nil
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
