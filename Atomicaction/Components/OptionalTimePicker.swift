//
//  OptionalTimePicker.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//
import SwiftUI
internal import Combine
import Foundation

struct OptionalTimePicker: View {
    @Binding var date: Date?  // nil = None selected
    let title: String

    private var defaultDate: Date { Date() }

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
            }) {
                HStack {
                    Image(systemName: date != nil ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(date != nil ? .blue : .gray)
                    Text(title)
                }
            }
            .buttonStyle(.plain)

            if date != nil {
                DatePicker(
                    "",
                    selection: dateBinding,
                    displayedComponents: .hourAndMinute  // ← CHANGED: Time only
                )
                .labelsHidden()
                .datePickerStyle(.compact)  // ← CHANGED: Compact time picker
                .id(date)
            } else {
                Text("None")
                    .foregroundColor(.secondary)
            }
        }
    }
}
