//
//  TaskListView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/25/26.
//

import SwiftUI
import SwiftData
struct TaskListView: View {
    @State private var selectedSortType: SortType = .order

    var body: some View {

        TaskListContentView(sortType: selectedSortType, selectedSortType: $selectedSortType)



    }
}
struct TaskListContentView: View {
    let sortType: SortType
    @Binding var selectedSortType: SortType
    @State var selectedFilterType: FilterType = .all
    var selectedSortTypeStr: String {
        sortType.rawValue
    }
    @Query(sort: \Task.order) private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    //@Environment(\.editMode) private var editMode
    @State private var isEditing = false
    @State private var editMode: EditMode = .inactive
    @State private var showingAddSheet = false
    private var visibleTasks: [Task] {
        if selectedFilterType == .all { return tasks }
        
        if selectedFilterType == .showOnlyCompleted { return tasks.filter{ $0.isCompleted } }
        
        if selectedFilterType == .showOnlyRoutine { return tasks.filter{ $0.isRoutine } }
        
        return tasks.filter{ !$0.isCompleted }
    }

    init(sortType: SortType, selectedSortType: Binding<SortType>) {
        self.sortType = sortType
        self._selectedSortType = selectedSortType
        switch sortType {
        case .order:
            _tasks = Query(sort: [
                SortDescriptor(\.completionRank),
                SortDescriptor(\.order)
                
            ])
        case .category:
            _tasks = Query(sort: [
                SortDescriptor(\.completionRank),
                SortDescriptor(\.categoryOrder)
            ])
        case .dueDate:
            _tasks = Query(sort: [
                SortDescriptor(\.completionRank),
                SortDescriptor(\.dueDateRank),
                SortDescriptor(\.dueDate, order: .forward)
                
            ])
        }
    }
    // move all the list body, toolbar, etc. here
    
    var body: some View {
        VStack {
            
            NavigationStack {
                List {
                    ForEach(visibleTasks) { task in
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
                                    task: task,
                                    isEditing: isEditing
                                )
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.25))
                                    .padding(.trailing, 16)
                                
                            }
                            .background( AppGlobals.labelColor(isEditing: isEditing, isCompleted: task.isCompleted) )
                            //.animation(.easeInOut, value: isEditing)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
                            )
                        }
                        .moveDisabled(task.isCompleted)
                        .listRowBackground( AppGlobals.backgroundColor(isEditing: isEditing))
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
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { showingAddSheet = true }) {
                            createButtons(systenName: "plus", text: "Add Task")
                        }
                        
                        Button {
                            withAnimation {
                                let newValue: EditMode = (editMode == .active) ? .inactive : .active
                                editMode = newValue
                                isEditing = newValue == .active
                            }
                        } label: {
                            createButtons(systenName: "arrow.up.arrow.down", text: editMode == .active ? "Done" : "Order")
                        }
                        .opacity(selectedSortType != .order ? 0.4 : 1.0)
                        .disabled(selectedSortType != .order)
                        

                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        
                        Menu {
                            Menu {
                                Picker("Sort By", selection: $selectedSortType) {
                                    ForEach(SortType.allCases, id: \.self) { sortType in
                                        Text(sortType.rawValue).tag(sortType)  // use .tag(sortType) not .tag(sortType.rawValue)
                                    }
                                }
                            } label: {
                                createButtons(systenName: "arrow.2.squarepath", text: "Sort by")
                            }
                            
                            Menu {
                                Picker("Filter By", selection: $selectedFilterType) {
                                    ForEach(FilterType.allCases, id: \.self) { filterType in
                                        Text(filterType.rawValue).tag(filterType)
                                    }
                                }
                            } label: {
                                createButtons(systenName: "square.3.layers.3d", text: "Filter By")
                            }

                        } label: {
                            // This is the single button / “three‑dots” icon shown in toolbar
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    AddTaskView()
                        .presentationDetents([.large])
                }
                .scrollContentBackground(.hidden)
                .background(AppConsts.spaceblack)
                //.deleteDisabled(isEditing)
                .environment(\.editMode, $editMode)
            }
        }
        .onChange(of: selectedSortType) { _, _ in
            let orderedTasks = tasks
            for (index, task) in orderedTasks.enumerated() {
                task.order = index
            }
            
            try? modelContext.save()
        }
        .onAppear{
            
            let orderedTasks = tasks
            for (index, task) in orderedTasks.enumerated() {
                task.order = index
            }
            fixTaskCompletionRanks(in: modelContext)
            try? modelContext.save()
        }
//        .onChange(of: selectedFilterType){_, newSelectedFilterType in
//            if FilterType.none == newSelectedFilterType {
//                print(newSelectedFilterType)
//            }
//            if FilterType.showOnlyCompleted == newSelectedFilterType {
//                print(newSelectedFilterType)
//            }
//        }

    }
    @ViewBuilder
    func createButtons(systenName: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systenName)
                .font(.system(size: 12, weight: .bold))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppConsts.navyBlack)
        .clipShape(Capsule())
    }
    func fixTaskCompletionRanks(in modelContext: ModelContext) {
        let allTasks = (try? modelContext.fetch(FetchDescriptor<Task>())) ?? []
        for task in allTasks {
            task.updateCompletionRank()
        }
        try? modelContext.save()
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

// Helper to create a preview container with sample data
@MainActor
func makePreviewContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
    let now = Date.now
    let date2 = now.addingTimeInterval(60 * 2)
    let sampleTasks = [
        Task(timestamp: .now, title: "Morning Run", task_description: "5km around the park", isRoutine: true, category: .personal, dueDate: nil, scheduledAt: now, durationMinutes: 2),
        Task(timestamp: .now, title: "Team Meeting", task_description: "Weekly sync with the dev team", isRoutine: true, category: .work, dueDate: nil, scheduledAt: date2, durationMinutes: 2),
        
        
        Task(timestamp: .now, title: "Buy Groceries", task_description: "Milk, eggs, bread, and fruits", category: .home, isCompleted: true, dueDate: tomorrow),
        

        
        Task(timestamp: .now, title: "Read Book", task_description: "Finish chapter 4 of Swift Programming", category: .work),
        Task(timestamp: .now, title: "Evening Meditation", task_description: "15 minutes mindfulness session", category: .other, isCompleted: true, scheduledAt: Calendar.current.date(byAdding: .hour, value: 8, to: .now)),
        
        Task(timestamp: .now, title: "Evening Meditation2", task_description: "15 minutes mindfulness session2", category: .other, isCompleted: false, dueDate: Calendar.current.date(byAdding: .day, value: -8, to: .now)!, scheduledAt: Calendar.current.date(byAdding: .day, value: -8, to: .now)!),
        
//        Task(timestamp: .now, title: "Run 15 mins", task_description: "Weekly sync with the dev team", isRoutine: true, category: .work, scheduledAt: Date(), durationMinutes: 15),
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
