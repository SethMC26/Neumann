        //
        //  ContentView.swift
        //  VonViz
        //
        //  Created by Kayla Quinlan on 9/14/25.
        //

        import SwiftUI
        import RealityKit
        import RealityKitContent

        // MARK: - Button Styles

        /// A glowing, vibrant button ideal for primary actions.
        struct PrimaryButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .overlay(
                        Capsule().stroke(Color.white.opacity(configuration.isPressed ? 0.7 : 0.2), lineWidth: 2)
                    )
                    .shadow(
                        color: Color.blue.opacity(configuration.isPressed ? 0.15 : 0.36),
                        radius: configuration.isPressed ? 4 : 16,
                        y: configuration.isPressed ? 1 : 8
                    )
                    .opacity(configuration.isPressed ? 0.85 : 1)
                    .scaleEffect(configuration.isPressed ? 0.97 : 1)
                    .animation(.easeOut(duration: 0.17), value: configuration.isPressed)
            }
        }

        /// A secondary, frosted "ghost" button.
        struct SecondaryButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(
                        .ultraThinMaterial,
                        in: Capsule()
                    )
                    .overlay(
                        Capsule().stroke(Color.white.opacity(configuration.isPressed ? 0.5 : 0.28), lineWidth: 1.5)
                    )
                    .shadow(
                        color: Color.black.opacity(configuration.isPressed ? 0.12 : 0.20),
                        radius: configuration.isPressed ? 2 : 7,
                        y: 2
                    )
                    .opacity(configuration.isPressed ? 0.90 : 1)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
                    .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            }
        }

        struct ContentView: View {
            @State var enlarge = false
            @State private var selectedFile: URL?
            @State private var isImporterPresented = false

            var body: some View {
                ZStack {
                    // Background gradient for depth, now with rounded corners!
                    LinearGradient(
                        colors: [Color(.black), Color(.systemIndigo)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                    .shadow(color: .black.opacity(0.18), radius: 24, y: 8)
                    .padding(20)

                    VStack(spacing: 28) {
                        Text("VonViz App")
                            .font(.largeTitle.bold())
                            .foregroundColor(.blue)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                            .shadow(color: .black.opacity(0.25), radius: 15, y: 9)

                        Button {
                            enlarge.toggle()
                        } label: {
                            Label(
                                enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content",
                                systemImage: enlarge ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right"
                            )
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.horizontal, 40)
                        .animation(.smooth(duration: 0.25), value: enlarge)

                        Button {
                            isImporterPresented = true
                        } label: {
                            Label("Choose CSV File", systemImage: "doc.fill.badge.plus")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 40)
                        .fileImporter(
                            isPresented: $isImporterPresented,
                            allowedContentTypes: [.commaSeparatedText, .plainText],
                            allowsMultipleSelection: false
                        ) { result in
                            switch result {
                            case .success(let urls):
                                if let url = urls.first {
                                    selectedFile = url
                                    print("Picked file: \(url)")
                                }
                            case .failure(let error):
                                print("Failed to pick file: \(error)")
                            }
                        }

                        if let file = selectedFile {
                            VStack(spacing: 8) {
                                RealityView { content in
                                    if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                                        content.add(scene)
                                    }
                                } update: { content in
                                    if let scene = content.entities.first {
                                        let uniformScale: Float = enlarge ? 3.0 : 1.0
                                        scene.transform.scale = [uniformScale, uniformScale, uniformScale]
                                    }
                                }
                                .frame(width: 250, height: 250)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
                                .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
                                    enlarge.toggle()
                                })

                                Text(file.lastPathComponent)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.30), radius: 12, y: 6)
                            .frame(width: 320, height: 420)
                            .transition(.scale)
                        }
                    }
                    .padding(.vertical, 40)
                }
                .navigationTitle("VonViz")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isImporterPresented = true
                        }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
