//
//  ContentView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/20/26.
//

import SwiftUI
import SwiftData

struct TaskLabel: View {
    let timestamp: Date
    let title: String
    let category: Category
    let task_description: String
    let dueDate: Date?

    var categoryConfig: (icon: String, color: Color, label: String) {
        switch category {
        case .work:     return ("briefcase.fill",        Color(hex: "4A90E2"), "Work")
        case .personal: return ("person.crop.circle.fill", Color(hex: "F5A623"), "Personal")
        case .home:     return ("house.fill",            Color(hex: "7ED321"), "Home")
        case .other:    return ("tag.fill",              Color(hex: "E24A4A"), "Other")
        }
    }

    var clippedDescription: String {
        let trimmed = task_description.trimmingCharacters(in: .whitespacesAndNewlines)
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
                    Text(title)
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
                        timestamp.formatted(.dateTime.month(.abbreviated).day()),
                        systemImage: "calendar"
                    )
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))

                    if let due = dueDate {
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
        .background(Color(hex: "1C1C2E"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
        )
    }
}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @State private var showingAddSheet = false
    


    var body: some View {
        NavigationSplitView {
            List {
                ForEach(tasks) { task in
                    ZStack {
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            EmptyView()  // hide the default label entirely
                        }
                        .opacity(0)      // makes the default arrow invisible

                        // Your fully custom row
                        HStack(spacing: 0) {
                            TaskLabel(
                                timestamp: task.timestamp,
                                title: task.title,
                                category: task.category,
                                task_description: task.task_description,
                                dueDate: task.dueDate
                            )

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.25))
                                .padding(.trailing, 16)
                        }
                        .background(Color(hex: "1C1C2E"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(1))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "1C1C2E"))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                        )
                }
#endif
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingAddSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("Add Task")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "1C1C2E"))
                        .clipShape(Capsule())
                    }
                    .sheet(isPresented: $showingAddSheet) {
                        AddItemView()
                            .presentationDetents([.large])
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppConsts.spaceblack)
            
        } detail: {
            Text("Select an item")
        }
        
    }

//    private func addItem() {
//        withAnimation {
//            let newTask = Task(timestamp: Date(), title: "test", isCompleted: false, dueDate: Date())
//            modelContext.insert(newTask)
//        }
//    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Task.self, inMemory: false)
    //ModelConfiguration(isStoredInMemoryOnly: false)
    
//    TaskLabel(timestamp: Date(),title: "Misson 1",category: Category.home, task_description: "test decription test decription test decription ", dueDate: Date())
//    
//    TaskLabel(timestamp: Date(),title: "Misson 1",category: Category.personal, task_description: "test decription test decription test decription ", dueDate: Date())
}
