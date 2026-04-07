////
////  ContentView.swift
////  Atomicaction
////
////  Created by Yuki Suzuki on 3/20/26.
////
//
//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    // @Query private var tasks: [Task]
//    @Query(sort: \Task.order) private var tasks: [Task]
//    @State private var showingAddSheet = false
//    @State private var taskToEdit: Task? = nil
//    @State private var isEditing = false
//    // @Environment(\.editMode) private var editMode
//    
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(tasks) { task in
//                    ZStack {
//                        NavigationLink {
//                            TaskDetailView(task: task)
//                        } label: {
//                            EmptyView()  // hide the default label entirely
//                        }
//                        .opacity(0)      // makes the default arrow invisible
//
//                        // Your fully custom row
//                        HStack(spacing: 0) {
//                            TaskLabel(
//                                task: task,
////                                timestamp: task.timestamp,
////                                title: task.title,
////                                category: task.category,
////                                task_description: task.task_description,
////                                dueDate: task.dueDate,
////                                isCompleted: task.isCompleted,
//                                isEditing: isEditing
//                            )
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 11, weight: .semibold))
//                                .foregroundStyle(.white.opacity(0.25))
//                                .padding(.trailing, 16)
//                        }
//                        .background(isEditing ? Color(hex: "252540") : Color(hex: "1C1C2E"))
//                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 14)
//                                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
//                        )
//                        // Only attach the gesture in edit mode — otherwise NavigationLink handles the tap
//                        .onTapGesture {
//                            if isEditing {
//                                taskToEdit = task
//                            }
//                        }
//                        .allowsHitTesting(isEditing)
//                    }
//                    .listRowBackground(Color.clear)
//                    .listRowSeparator(.hidden)
//                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
//                }
//                .onMove(perform: moveTasks)
//                .onDelete(perform: deleteItems)
//            }
//            
//            .sheet(item: $taskToEdit) { task in
//                EditTaskView(task: task)
//                    .presentationDetents([.large])
//            }
//#if os(macOS)
//            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
//#endif
//            .toolbar {
//#if os(iOS)
//ToolbarItem(placement: .navigationBarLeading) {
//    Button {
//        // edit mode — tap a task row to edit
//        isEditing.toggle()
//        //editMode?.wrappedValue = isEditing ? .active : .inactive
//    } label: {
//        HStack(spacing: 6) {
//            Image(systemName: isEditing ? "checkmark" : "pencil")
//                .font(.system(size: 12, weight: .bold))
//            Text(isEditing ? "Done" : "Edit")
//                .font(.system(size: 13, weight: .medium))
//        }
//        .foregroundStyle(.white.opacity(0.7))
//        .padding(.horizontal, 12)
//        .padding(.vertical, 6)
//        .background(isEditing ? Color(hex: "252540") : Color(hex: "1C1C2E"))
//        .clipShape(Capsule())
//        .overlay(
//            Capsule()
//                .strokeBorder(.white.opacity(0.07), lineWidth: 0.5)
//        )
//    }
//}
//#endif
//                ToolbarItem(placement: .automatic) {
//                    Button(action: { showingAddSheet = true }) {
//                        HStack(spacing: 6) {
//                            Image(systemName: "plus")
//                                .font(.system(size: 12, weight: .bold))
//                            Text("Add Task")
//                                .font(.system(size: 13, weight: .medium))
//                        }
//                        .foregroundStyle(.white)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(Color(hex: "1C1C2E"))
//                        .clipShape(Capsule())
//                    }
//                    .sheet(isPresented: $showingAddSheet) {
//                        AddItemView()
//                            .presentationDetents([.large])
//                    }
//                }
//            }
//            .scrollContentBackground(.hidden)
//            .background(AppConsts.spaceblack)
//            
//        } detail: {
//            Text("Select an item")
//        }
//        
//    }
//
////    private func addItem() {
////        withAnimation {
////            let newTask = Task(timestamp: Date(), title: "test", isCompleted: false, dueDate: Date())
////            modelContext.insert(newTask)
////        }
////    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(tasks[index])
//            }
//        }
//    }
//    private func moveTasks(_ fromOffsets: IndexSet, toOffset: Int) {
//        print("🔄 onMove CALLED! fromOffsets: \(fromOffsets), toOffset: \(toOffset)")
//        withAnimation {
//            print("test")
//            var sortedTasks = tasks.sorted(by: { $0.order < $1.order })
//            sortedTasks.move(fromOffsets: fromOffsets, toOffset: toOffset)
//            for (index, task) in sortedTasks.enumerated() {
//                task.order = index
//            }
//            try? modelContext.save()
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .modelContainer(for: Task.self, inMemory: false)
//    //ModelConfiguration(isStoredInMemoryOnly: false)
//    
////    TaskLabel(timestamp: Date(),title: "Misson 1",category: Category.home, task_description: "test decription test decription test decription ", dueDate: Date())
////    
////    TaskLabel(timestamp: Date(),title: "Misson 1",category: Category.personal, task_description: "test decription test decription test decription ", dueDate: Date())
//}
