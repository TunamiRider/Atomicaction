//
//  TaskLabel.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/24/26.
//
import SwiftUI
import SwiftData
struct TaskLabel: View {
//    let timestamp: Date
//    let title: String
//    let category: Category
//    let task_description: String
//    let dueDate: Date?
//    let isCompleted: Bool
    let task: Task
    var isEditing: Bool = false

    var categoryConfig: (icon: String, color: Color, label: String) {
        switch task.category {
        case .work:     return ("briefcase.fill",        Color(hex: "4A90E2"), "Work")
        case .personal: return ("person.crop.circle.fill", Color(hex: "F5A623"), "Personal")
        case .home:     return ("house.fill",            Color(hex: "7ED321"), "Home")
        case .other:    return ("tag.fill",              Color(hex: "E24A4A"), "Other")
        }
    }
    
//    var categoryConfig2: CategoryConfig {
//        CategoryConfig.from(category)
//    }

    var clippedDescription: String {
        let trimmed = task.task_description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 40 else { return trimmed }
        return String(trimmed.prefix(40)) + "…"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Category accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(categoryConfig.color)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                                
                // Title row
                HStack(spacing: 6) {
                    // Routine indicator (only if routine)
                    if task.isRoutine {
                        Image(systemName: "repeat.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.yellow.opacity(0.8))  // Or categoryConfig.color
                    }
                    
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()

                    // Category pill
                    HStack(spacing: 4) {
                        Image(systemName: categoryConfig.icon)
                            .font(.system(size: 10, weight: .medium))
                        Text(categoryConfig.label)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(categoryConfig.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(categoryConfig.color.opacity(0.15))
                    .clipShape(Capsule())
                }

                // Description
                if !clippedDescription.isEmpty {
                    Text(clippedDescription)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }

                // Footer: date + optional due date
                HStack(spacing: 8) {
                    Label(
                        task.timestamp.formatted(.dateTime.month(.abbreviated).day()),
                        systemImage: "calendar"
                    )
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                    if let due = task.dueDate {
                        Label(
                            due.formatted(.dateTime.month(.abbreviated).day()),
                            systemImage: "clock"
                        )
                        .font(.system(size: 11))
                        .foregroundStyle(due < Date() ? Color(hex: "E24A4A") : .white.opacity(0.4))
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.trailing, 14)
        .padding(.leading, 10)
        .background(AppGlobals.labelColor(isEditing: isEditing, isCompleted: task.isCompleted))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
        )
    }
}
