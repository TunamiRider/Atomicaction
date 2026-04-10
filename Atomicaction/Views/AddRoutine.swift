//
//  AddRoutine.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//
import SwiftUI
import SwiftData

struct AddRoutine: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    let scheduledAt: Date
    let durationMinutes: Int
    @State private var selectedCategory: Category = .work

    var categoryConfig: (color: Color, label: String) {
        switch selectedCategory {
        case .work:     return (Color(hex: "4A90E2"), "Work")
        case .personal: return (Color(hex: "F5A623"), "Personal")
        case .home:     return (Color(hex: "7ED321"), "Home")
        case .other:    return (Color(hex: "E24A4A"), "Other")
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "0F0F1A").ignoresSafeArea()

            NavigationView {
                Form {
                    // MARK: - Title
                    Section {
                        FixedTextEditor(
                            text: $title,
                            limit: 30,
                            placeholder: "Mission title",
                            frameHeight: 40
                        )
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "1C1C2E"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                                )
                        )
                    } header: {
                        sectionHeader("Title")
                    }

                    // MARK: - Description
                    Section {
                        FixedTextEditor(
                            text: $description,
                            limit: 280,
                            placeholder: "Description (optional)",
                            frameHeight: 200
                        )
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "1C1C2E"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                                )
                        )
                    } header: {
                        sectionHeader("Description")
                    }
                    
                    // MARK: - Duration
                    Section {
                        HStack(spacing: 16) {
                            // Scheduled time
                            VStack(spacing: 2) {
                                Text("Scheduled")
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .kerning(0.2)
                                    .foregroundStyle(.white)
                                Text(scheduledAt.formatted(date: .omitted, time: .shortened).lowercased())
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(.white)
                            }
                            
                            // Divider dot
                            Circle()
                                .fill(.white)
                                .frame(width: 3, height: 3)
                            
                            // Remaining time
                            VStack(spacing: 2) {
                                Text("Duration")
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .kerning(0.2)
                                    .foregroundStyle(.white)
                                Text("\(durationMinutes) min")
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        //                        .listRowBackground(
                        //                            RoundedRectangle(cornerRadius: 12)
                        //                                .fill(Color.secondary.opacity(0.3))
                        //                        )
                    }
                    header: {
                        sectionHeader("Schedule Date and Duration")
                    }


                    // MARK: - Category
                    Section {
                        HStack(spacing: 8) {
                            ForEach(Category.allCases, id: \.self) { category in
                                let config = CategoryConfig.from(category)
                                let isSelected = selectedCategory == category
                                Button { selectedCategory = category } label: {
                                    Text(category.rawValue.capitalized)
                                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                        .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? config.color.opacity(0.3) : config.color.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(
                                                    isSelected ? config.color.opacity(0.8) : config.color.opacity(0.2),
                                                    lineWidth: isSelected ? 1 : 0.5
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "0F0F1A"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                                )
                        )
                    } header: { sectionHeader("Category") }
                }
                .scrollContentBackground(.hidden)
                .preferredColorScheme(.dark)
                .background(Color(hex: "0F0F1A"))
                .navigationTitle("New Task")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(hex: "0F0F1A"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "1C1C2E"))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                            )
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            withAnimation {
                                let newTask = Task(
                                    timestamp: Date(),
                                    title: title,
                                    task_description: description,
                                    isRoutine: true,
                                    category: selectedCategory,
                                    isCompleted: false,
                                    // dueDate: nil,
                                    scheduledAt: scheduledAt,
                                    durationMinutes: durationMinutes
                                    
                                )
                                modelContext.insert(newTask)
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Add")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(title.isEmpty ? Color(hex: "1C1C2E") : Color(hex: "4A90E2"))
                            .clipShape(Capsule())
                        }
                        .disabled(title.isEmpty)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }

    // MARK: - Helpers
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.35))
            .textCase(nil)
    }
}

#Preview {
//    @Preview var scheduledAt = Date().now
//    @Preview var durationMinutes = 10
    
    AddRoutine(scheduledAt: .now, durationMinutes: 10)
        .modelContainer(for: Task.self, inMemory: true)
    
}
