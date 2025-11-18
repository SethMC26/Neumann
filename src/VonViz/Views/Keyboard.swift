import SwiftUI

/// Custom keyboard view for MathLang grammar
/// Only allows valid inputs: numbers, operators (+, -, *, /, **, //), functions (sin, cos, tan), variables (x, z), and parentheses
struct MathKeyboardView: View {
    @Binding var text: String
    
    var body: some View {
        VStack(spacing: 10) {
            // Function row
            HStack(spacing: 8) {
                KeyButton("sin(", text: $text)
                KeyButton("cos(", text: $text)
                KeyButton("tan(", text: $text)
                KeyButton("(", text: $text)
                KeyButton(")", text: $text)
            }
            
            // Number row 1
            HStack(spacing: 8) {
                ForEach(["7", "8", "9"], id: \.self) { num in
                    KeyButton(num, text: $text)
                }
                KeyButton("+", text: $text)
                KeyButton("-", text: $text)
            }
            
            // Number row 2
            HStack(spacing: 8) {
                ForEach(["4", "5", "6"], id: \.self) { num in
                    KeyButton(num, text: $text)
                }
                KeyButton("*", text: $text)
                KeyButton("/", text: $text)
            }
            
            // Number row 3
            HStack(spacing: 8) {
                ForEach(["1", "2", "3"], id: \.self) { num in
                    KeyButton(num, text: $text)
                }
                KeyButton("**", text: $text)
                KeyButton("//", text: $text)
            }
            
            // Bottom row
            HStack(spacing: 8) {
                KeyButton("0", text: $text)
                KeyButton(".", text: $text)
                KeyButton("x", text: $text)
                KeyButton("z", text: $text)
                Button(action: {
                    if !text.isEmpty {
                        text.removeLast()
                    }
                }) {
                    Image(systemName: "delete.left.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

/// Individual key button for the keyboard
private struct KeyButton: View {
    let label: String
    @Binding var text: String
    
    init(_ label: String, text: Binding<String>) {
        self.label = label
        self._text = text
    }
    
    var body: some View {
        Button(action: {
            text += label
        }) {
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}
