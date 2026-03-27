//
//  EditTaskView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/24/26.
//
import SwiftUI
import SwiftData
struct EditTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let task: Task

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date?
    @State private var selectedCategory: Category

    init(task: Task) {
        self.task = task
        _title           = State(initialValue: task.title)
        _description     = State(initialValue: task.task_description)
        _dueDate         = State(initialValue: task.dueDate)
        _selectedCategory = State(initialValue: task.category)
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
                        .foregroundStyle(.white)
                        .colorScheme(.dark)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "12121F"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                                )
                        )
                    } header: { sectionHeader("Title") }

                    // MARK: - Description
                    Section {
                        FixedTextEditor(
                            text: $description,
                            limit: 280,
                            placeholder: "Description (optional)",
                            frameHeight: 200
                        )
                        .foregroundStyle(.white)
                        .colorScheme(.dark)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "12121F"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                                )
                        )
                    } header: { sectionHeader("Description") }

                    // MARK: - Due Date
                    Section {
                        OptionalDatePicker(date: $dueDate, title: "Due date")
                            .foregroundStyle(.white)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "1C1C2E"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                                    )
                            )
                    } header: { sectionHeader("Due Date") }

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
                .colorScheme(.dark)
                .scrollContentBackground(.hidden)
                .background(Color(hex: "141428"))
                .navigationTitle("Edit Task")
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
                                task.title            = title
                                task.task_description = description
                                task.category         = selectedCategory
                                task.dueDate          = dueDate
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Save")
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

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.35))
            .textCase(nil)
    }
}
