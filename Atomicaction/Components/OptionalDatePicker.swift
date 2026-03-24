//
//  OptionalDatePicker.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//
import SwiftUI
internal import Combine
import Foundation



struct OptionalDatePicker: View {
    @Binding var date: Date?          // nil = None selected
    let title: String

    // Fallback date when user first turns it on
    private var defaultDate: Date { Date() }

    // Non‑optional binding for DatePicker
    private var dateBinding: Binding<Date> {
        Binding(
            get: { date ?? defaultDate },
            set: { date = $0 }
        )
    }

    var body: some View {
        HStack {
            Button(action: {
                date = date == nil ? defaultDate : nil
            }){
                HStack{
                    Image(systemName: date != nil ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(date != nil ? .blue : .white)
                    Text(title)
                }
            }
            .buttonStyle(.plain)

            if date != nil {
                DatePicker(
                    "",
                    selection: dateBinding,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .accentColor(.white)           // White selection
                .tint(.white)                  // White accents
                .preferredColorScheme(.dark)
                .id(date)
            } else {
                Text("None")
                    .foregroundColor(.white)
            }
        }
    }
}
