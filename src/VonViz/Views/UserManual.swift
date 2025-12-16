import SwiftUI
import UniformTypeIdentifiers
import QuickLook
import SafariServices

struct UserManual: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quickLookItem: QLPreviewItemWrapper?
    @State private var showingHelper = false
    @State private var showingManualWeb = false
    @State private var showingDataChartHelp = false
    @State private var showingFuncChartHelp = false
    @State private var showingFuncChart = false
    // Provide a default example function for FuncChart
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
                    Group {
                        Text("FuncChart")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Tap the FuncChart button to view the graph")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .center)
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
                    
//                    Button("FuncChart") { showingFuncChart = true }
//                        .padding()
//                        .frame(width: 340)
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingFuncChart = true
                        } label: {
                            Image(systemName: "star.fill")
                                .imageScale(.large)
                                .accessibilityLabel("Func Chart")
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
                .sheet(isPresented: $showingFuncChart) {
                    FuncChart(model: funcChartModel, initFunc: Self.defaultFunc)
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }
        // MARK: - Data Chart Help Guide View
        struct DataChartGuideView: View {
            var onClose: () -> Void
            var body: some View {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .center, spacing: 16) {
                            Text("Data Chart Guide")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .bold()
                                .padding(.top)
                                .fixedSize(horizontal: true, vertical: true)
                            
                            GroupBox(label: Label("What is the Data Chart?", systemImage: "chart.bar.doc.horizontal")) {
                                Text("""
                            The Data Chart visualizes your imported CSV data in 3D. You can select which columns map to the X, Y, and Z axes, adjust axis ranges, and filter your dataset.
                            """)
                                .font(.body)
                                .padding(.top, 4)
                            }
                            
                            GroupBox(label: Label("Importing Data", systemImage: "tray.and.arrow.down")) {
                                Text("""
                            Tap the 'Choose CSV File' button in the toolbar to import your data. The first three numeric columns are mapped to X, Y, and Z axes by default.
                            """)
                                .font(.body)
                                .padding(.top, 4)
                            }
                            
                            GroupBox(label: Label("Setting Axes", systemImage: "chart.xyaxis.line")) {
                                Text("""
                            Use the X, Y, and Z buttons in the toolbar to select which data columns appear on each axis, and to edit the scale and step size for that axis.
                            """)
                                .font(.body)
                                .padding(.top, 4)
                            }
                            
                            GroupBox(label: Label("Adjusting Display", systemImage: "gearshape")) {
                                Text("""
                            Tap the settings icon to adjust the display limit (max # of points shown).
                            """)
                                .font(.body)
                                .padding(.top, 4)
                            }
                            
                            Button("Close", action: onClose)
                                .buttonStyle(.bordered)
                                .padding(.vertical)
                        }
                        .padding()
                        .frame(maxWidth: 500)
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
            
        // MARK: - SafariView (SwiftUI wrapper for SFSafariViewController)
              struct SafariView: UIViewControllerRepresentable {
                  let url: URL
                  
                  func makeUIViewController(context: Context) -> SFSafariViewController {
                      SFSafariViewController(url: url)
                  }
                  
                  func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
              }
        }

      
    
