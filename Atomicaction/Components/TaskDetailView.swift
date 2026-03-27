//
//  Untitled.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/23/26.
//
import SwiftUI
struct TaskDetailView: View {
    let task: Task
    let categoryConfig: CategoryConfig
    
    init(task: Task){
        self.task = task
        self.categoryConfig = CategoryConfig.from(task.category)
    }

//    var categoryConfig: (icon: String, color: Color, label: String) {
//        switch task.category {
//        case .work:     return ("briefcase.fill",         Color(hex: "4A90E2"), "Work")
//        case .personal: return ("person.crop.circle.fill", Color(hex: "F5A623"), "Personal")
//        case .home:     return ("house.fill",             Color(hex: "7ED321"), "Home")
//        case .other:    return ("tag.fill",               Color(hex: "E24A4A"), "Other")
//        }
//    }

    var body: some View {
        ZStack {
            Color(hex: "0F0F1A").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // MARK: - Header card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            // Category pill
                            HStack(spacing: 6) {
                                Image(systemName: categoryConfig.icon)
                                    .font(.system(size: 11, weight: .medium))
                                Text(categoryConfig.label)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(categoryConfig.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(categoryConfig.color.opacity(0.15))
                            .clipShape(Capsule())

                            Spacer()

                            // Timestamp
                            Text(task.timestamp.formatted(.dateTime.month(.abbreviated).day().year()))
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.35))
                        }

                        // Title
                        Text(task.title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)

                        // Accent divider
                        Rectangle()
                            .fill(categoryConfig.color.opacity(0.4))
                            .frame(height: 1)
                            .clipShape(Capsule())
                    }
                    .padding(16)
                    .background(Color(hex: "1C1C2E"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                    )

                    // MARK: - Description card
                    if !task.task_description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Description")
                            Text(task.task_description)
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.75))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "1C1C2E"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                        )
                    }

                    // MARK: - Meta card
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Details")

                        metaRow(
                            icon: "calendar",
                            label: "Created",
                            value: task.timestamp.formatted(.dateTime.month(.abbreviated).day().year())
                        )

                        if let due = task.dueDate {
                            Divider().overlay(.white.opacity(0.06))
                            metaRow(
                                icon: "clock",
                                label: "Due",
                                value: due.formatted(.dateTime.month(.abbreviated).day().year()),
                                valueColor: due < Date() ? Color(hex: "E24A4A") : .white.opacity(0.75)
                            )
                        }

                        Divider().overlay(.white.opacity(0.06))

                        metaRow(
                            icon: "checkmark.circle",
                            label: "Status",
                            value: task.isCompleted ? "Completed" : "Pending",
                            valueColor: task.isCompleted ? Color(hex: "7ED321") : .white.opacity(0.75)
                        )
                    }
                    .padding(16)
                    .background(Color(hex: "1C1C2E"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                    )
                }
                .padding(16)
            }
        }
        .navigationTitle(task.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        //.toolbarBackground(Color(hex: "0F0F1A"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
    }

    // MARK: - Helpers
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.35))
            .textCase(nil)
    }

    private func metaRow(
        icon: String,
        label: String,
        value: String,
        valueColor: Color = .white.opacity(0.75)
    ) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.35))
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.35))
            }
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(valueColor)
        }
    }
}

#Preview {
    let task = Task(timestamp: .now, title: "Morning Run", task_description: "5km around the park", category: .personal, startTime: .now)
    TaskDetailView(task: task)
}
