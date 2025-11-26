import SwiftUI

/// Custom keyboard view for MathLang grammar
/// Only allows valid inputs: numbers, operators (+, -, *, /, **, //), functions (sin, cos, tan), variables (x, y), and parentheses
struct MathKeyboardView: View {
    @Binding var text: String
    /// Called when the user taps Evaluate. Caller is responsible for parsing/applying and dismissal decisions.
    var onEvaluate: (() -> Void)? = nil

    // Layout constants for a predictable, centered grid
    private let keyWidth: CGFloat = 60
    private let columnsPerRow: Int = 6
    private let rowSpacing: CGFloat = 10
    private let verticalBlockSpacing: CGFloat = 12

    // Computed total content width for each row so everything aligns and centers
    private var rowContentWidth: CGFloat {
        CGFloat(columnsPerRow) * keyWidth + CGFloat(columnsPerRow - 1) * rowSpacing
    }

    // Estimated desired keyboard size (used for adaptive scaling)
    // Rows: 1 preview + 1 actions + 5 key rows = 7 rows
    private var desiredSize: CGSize {
        let rows = 7
        let estimatedRowHeight: CGFloat = 44 // conservative button/textfield height
        let contentHeight = CGFloat(rows) * estimatedRowHeight + CGFloat(rows - 1) * verticalBlockSpacing
        // Add padding that we apply to the container below
        let horizontalPadding: CGFloat = 24
        let verticalPadding: CGFloat = 28
        return CGSize(width: rowContentWidth + horizontalPadding, height: contentHeight + verticalPadding)
    }

    var body: some View {
        AdaptiveScaleBox(desiredSize: desiredSize) {
            VStack(spacing: verticalBlockSpacing) {

                // Preview row: live function string (editable) — at the very top
                HStack(spacing: 8) {
                    TextField("Enter function", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
                .frame(width: rowContentWidth)

                // Top action row: Evaluate / Clear
                HStack(spacing: 16) {
                    Button("Evaluate") {
                        onEvaluate?()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Clear", role: .destructive) {
                        text = ""
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .frame(width: rowContentWidth)

                // Function row (5 keys + 1 filler) → centered
                row {
                    KeyButton("sin(", text: $text, width: keyWidth)
                    KeyButton("cos(", text: $text, width: keyWidth)
                    KeyButton("tan(", text: $text, width: keyWidth)
                    KeyButton("(", text: $text, width: keyWidth)
                    KeyButton(")", text: $text, width: keyWidth)
                    filler
                }

                // Number row 1 (5 keys + 1 filler)
                row {
                    KeyButton("7", text: $text, width: keyWidth)
                    KeyButton("8", text: $text, width: keyWidth)
                    KeyButton("9", text: $text, width: keyWidth)
                    KeyButton("+", text: $text, width: keyWidth)
                    KeyButton("-", text: $text, width: keyWidth)
                    filler
                }

                // Number row 2 (5 keys + 1 filler)
                row {
                    KeyButton("4", text: $text, width: keyWidth)
                    KeyButton("5", text: $text, width: keyWidth)
                    KeyButton("6", text: $text, width: keyWidth)
                    KeyButton("*", text: $text, width: keyWidth)
                    KeyButton("/", text: $text, width: keyWidth)
                    filler
                }

                // Number row 3 (5 keys + 1 filler)
                row {
                    KeyButton("1", text: $text, width: keyWidth)
                    KeyButton("2", text: $text, width: keyWidth)
                    KeyButton("3", text: $text, width: keyWidth)
                    KeyButton("**", text: $text, width: keyWidth)
                    KeyButton("//", text: $text, width: keyWidth)
                    filler
                }

                // Bottom input row (4 keys + delete + 1 filler) → centered like others
                row {
                    KeyButton("0", text: $text, width: keyWidth)
                    KeyButton(".", text: $text, width: keyWidth)
                    KeyButton("x", text: $text, width: keyWidth)
                    KeyButton("y", text: $text, width: keyWidth)

                    Button(role: .destructive) {
                        if !text.isEmpty { text.removeLast() }
                    } label: {
                        Label("Delete", systemImage: "delete.left")
                            .labelStyle(.iconOnly)
                            .frame(width: keyWidth)
                    }
                    .buttonStyle(.bordered)

                    filler
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            // Native background with subtle border and shadow
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
    }

    // Helper to build a uniformly sized, centered row with consistent spacing
    @ViewBuilder
    private func row<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: rowSpacing) { content() }
            .frame(width: rowContentWidth, alignment: .center)
    }

    // Invisible filler to make every row use the same number of columns
    private var filler: some View {
        Color.clear.frame(width: keyWidth, height: 0)
    }
}

/// A container that scales its content down to fit within the available size,
/// preserving aspect ratio. If there is enough space, scale is 1 (no scaling).
private struct AdaptiveScaleBox<Content: View>: View {
    let desiredSize: CGSize
    @ViewBuilder var content: Content

    var body: some View {
        GeometryReader { proxy in
            let available = proxy.size
            let scale = min(1.0, min(available.width / max(desiredSize.width, 1),
                                     available.height / max(desiredSize.height, 1)))
            ZStack {
                // Center the content and apply scale
                content
                    .frame(width: desiredSize.width, height: desiredSize.height)
                    .scaleEffect(scale, anchor: .center)
            }
            .frame(width: available.width, height: available.height, alignment: .center)
            .clipped() // ensure no overflow beyond the popover bounds
        }
    }
}

/// Individual key button for the keyboard
private struct KeyButton: View {
    let label: String
    @Binding var text: String
    let width: CGFloat

    init(_ label: String, text: Binding<String>, width: CGFloat) {
        self.label = label
        self._text = text
        self.width = width
    }

    var body: some View {
        Button {
            text += label
        } label: {
            Text(label)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .frame(width: width)
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }
}
