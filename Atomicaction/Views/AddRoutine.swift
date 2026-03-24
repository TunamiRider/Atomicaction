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
    @State private var dueDate: Date?
    @State private var startDate: Date?
    @State private var startTime: Date?
    @State private var selectedCategory: Category = .work
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Routine title", text: $title)
                
                BulletpointTextEditor(
                    text: $description,
                    limit: 280,
                    placeholder: "Description (optional)"
                )
                //OptionalDatePicker(date: $startDate, title: "Start date")
                //OptionalTimePicker(date: $startTime, title: "Start time")
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue.capitalized).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        withAnimation{
                            let newTask = Task(timestamp: Date(), title: "test",task_description: "task description", isCompleted: false, dueDate: Date())
                            modelContext.insert(newTask)
                            dismiss()
                        }

                    }
                    .disabled(title.isEmpty)
                }
                
            }
            .navigationTitle("New Routine")
            .border(Color.red)
            
        }
        .padding()
        .border(Color.blue)
//        .background(Color(red: 18/255, green: 18/255, blue: 22/255))  // Space Black
//        .ignoresSafeArea()
        

    }
}

#Preview {
    AddRoutine()
        .modelContainer(for: Task.self, inMemory: true)
    
}
