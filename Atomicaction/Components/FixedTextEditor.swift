//
//  FixedTextEditor.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//
import SwiftUI

struct FixedTextEditor: View {
    @Binding var text: String
    let limit: Int
    let placeholder: String
    let frameHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: limitedBinding)
                .scrollContentBackground(.hidden)
                .frame(height: frameHeight) // Fixed height
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .allowsHitTesting(false) // Prevents placeholder from blocking input
            }
        }
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                .background(.white)
//        )
        .foregroundStyle(.white)
        .colorScheme(.dark)          // forces white text inside the editor
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "12121F"))  // darker than 1C1C2E
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                )
        )
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
