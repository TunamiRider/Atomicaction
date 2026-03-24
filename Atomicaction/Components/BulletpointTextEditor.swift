//
//  BulletpointTextEditor.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//
import SwiftUI
import Foundation
struct BulletpointTextEditor: View {
    @Binding var text: String
    let limit: Int
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: limitedBinding)
                .scrollContentBackground(.hidden)
                .frame(height: 100)
                .onChange(of: text) { oldValue, newValue in
                    // Only format when pressing Enter (new line added)
                    if newValue.count > oldValue.count &&
                        newValue.hasSuffix("\n") &&
                        !oldValue.hasSuffix("\n") {
                        text = formatNewLine(newValue)
                    }
                }
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .allowsHitTesting(false)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(.white)
        )
    }

    private func formatNewLine(_ input: String) -> String {
        let lines = input.components(separatedBy: .newlines)
        guard let lastLine = lines.last,
              lastLine.trimmingCharacters(in: .whitespaces).isEmpty else {
            return input
        }
        
        // Count non-empty lines for numbering
        let nonEmptyLineCount = lines.dropLast().filter {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }.count
        
        let newLastLine = "\(nonEmptyLineCount + 1). "
        return (lines.dropLast() + [newLastLine]).joined(separator: "\n")
    }

    private var limitedBinding: Binding<String> {
        Binding(
            get: { text },
            set: { newValue in
                if newValue.count <= limit {
                    text = newValue
                }
            }
        )
    }
}
