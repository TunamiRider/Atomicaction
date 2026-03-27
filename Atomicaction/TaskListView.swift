//
//  TaskListView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/25/26.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Query(sort: \Task.order) private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    //@Environment(\.editMode) private var editMode
    @State private var isEditing = false
    @State private var editMode: EditMode = .inactive
    @State private var showingAddSheet = false
    @State private var taskToEdit: Task? = nil

    var backgroundColor: Color {
        isEditing ?  Color(hex: "252540") : Color(hex: "1C1C2E")
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    ZStack {
                        NavigationLink {
                            if isEditing {
                                
                            } else {
                                
                            }
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
                                dueDate: task.dueDate,
                                isEditing: isEditing
                            )

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.25))
                                .padding(.trailing, 16)
                            
                        }
                        .background( backgroundColor )
                        //.animation(.easeInOut, value: isEditing)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                        )
                    }
                    .listRowBackground( Color(hex: "252540") )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    // .border(Color.red)
                }
                .onMove(perform: moveTask)
                .onDelete(perform: deleteItems)
                //.animation(.easeInOut(duration: 0.25), value: isEditing)
                .deleteDisabled(isEditing)
            }
            .navigationTitle("Tasks")
            .toolbar {
                Button {
                    withAnimation {
                        let newValue: EditMode = (editMode == .active) ? .inactive : .active
                        editMode = newValue
                        isEditing = newValue == .active
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text(editMode == .active ? "Done" : "Order")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "1C1C2E"))
                    .clipShape(Capsule())
                }
                .buttonStyle(.bordered)
                .tint(backgroundColor)
                .foregroundColor(.blue.opacity(0.8))
                
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
            .scrollContentBackground(.hidden)
            .background(AppConsts.spaceblack)
            //.deleteDisabled(isEditing)
            .onAppear {
                let unordered = tasks.enumerated().filter { $0.element.order == 0 }
                guard unordered.count > 1 else { return }
                for (index, task) in tasks.enumerated() {
                    task.order = index
                }
                try? modelContext.save()
            }
            .environment(\.editMode, $editMode)
            .scrollContentBackground(.hidden)
            .background(AppConsts.spaceblack)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }

    private func moveTask(from source: IndexSet, to destination: Int) {
        // Build a mutable copy of the current order
        var reordered = tasks

        // Apply the move
        reordered.move(fromOffsets: source, toOffset: destination)

        // Update the `order` property on each task
        for (index, task) in reordered.enumerated() {
            task.order = index
        }

        // SwiftData auto-saves on context change, but you can save explicitly:
        try? modelContext.save()
    }
}
struct TaskRowView: View {
    let task: Task

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.headline)
                .strikethrough(task.isCompleted)
            if !task.task_description.isEmpty {
                Text(task.task_description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Helper to create a preview container with sample data
@MainActor
func makePreviewContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    
    let sampleTasks = [
        Task(timestamp: .now, title: "Morning Run", task_description: "5km around the park", category: .personal, startTime: .now),
        Task(timestamp: .now, title: "Buy Groceries", task_description: "Milk, eggs, bread, and fruits", category: .home, dueDate: Calendar.current.date(byAdding: .hour, value: 3, to: .now)),
        Task(timestamp: .now, title: "Team Meeting", task_description: "Weekly sync with the dev team", category: .work, dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: .now)),
        Task(timestamp: .now, title: "Read Book", task_description: "Finish chapter 4 of Swift Programming", category: .personal),
        Task(timestamp: .now, title: "Evening Meditation", task_description: "15 minutes mindfulness session", category: .other, startTime: Calendar.current.date(byAdding: .hour, value: 8, to: .now))
    ]
    
    for (index, task) in sampleTasks.enumerated() {
        task.order = index
        container.mainContext.insert(task)
    }
    
    return container
}

#Preview {
    TaskListView()
        .modelContainer(makePreviewContainer())
}
