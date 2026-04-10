//
//  AddTask.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/20/26.
//
import SwiftUI
import SwiftData

//struct AddItemView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var title = ""
//    @State private var description = ""
//    @State private var dueDate: Date?
//    @State private var selectedCategory: Category = .work
//    
//    var body: some View {
//        ZStack {
//            
//            // Background layer - same color for both
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.white
////                    LinearGradient(
////                        colors: [
////                            AppConsts.spaceblack.opacity(0.4),
////                            AppConsts.spaceblack.opacity(0.2),
////                            AppConsts.spaceblack.opacity(0.1),
////                            AppConsts.spaceblack.opacity(0.05)
////                        ],
////                        startPoint: .topLeading,
////                        endPoint: .bottomTrailing
////                    )
////                )
////                .background(.black)
////                .blur(radius: 12)
////                .overlay(
////                    RoundedRectangle(cornerRadius: 16)
////                        .stroke(AppConsts.spaceblack.opacity(0.6), lineWidth: 1)
//                )
//            
//    
//            NavigationView {
//                Form {
//                    // TextField("Mission title", text: $title)
//                    FixedTextEditor(
//                        text: $title,
//                        limit: 30,
//                        placeholder: "Mission title",
//                        frameHeight: CGFloat(40.0)
//                    )
//                    //.listRowBackground(Color.clear)
//                    
//                    FixedTextEditor(
//                        text: $description,
//                        limit: 280,
//                        placeholder: "Description (optional)",
//                        frameHeight: CGFloat(280.0)
//                    )
//                    //.listRowBackground(Color.clear)
//                    
//                    OptionalDatePicker(date: $dueDate, title: "Due date")
//                    
//                    Picker("Category", selection: $selectedCategory) {
//                        ForEach(Category.allCases, id: \.self) { category in
//                            Text(category.rawValue.capitalized)
//                                .foregroundStyle(Color.red)
//                                .tag(category)
//                                
//                        }
//                    }
//                    //.listRowBackground(Color.clear)
//                    .pickerStyle(.palette)
//                    
//                    
//                }
//                .scrollContentBackground(.hidden)
//                //.background(AppConsts.spaceblack)
//                .toolbar {
//                    ToolbarItem(placement: .cancellationAction) {
//                        Button("Cancel") { dismiss() }
//                    }
//                    ToolbarItem(placement: .confirmationAction) {
//                        Button("Add") {
//                            withAnimation{
//                                let newTask = Task(timestamp: Date(), title: self.title,task_description: self.description,category: self.selectedCategory, isCompleted: false, dueDate: self.dueDate)
//                                modelContext.insert(newTask)
//                                dismiss()
//                            }
//
//                        }
//                        .disabled(title.isEmpty)
//                    }
//                    
//                }
//                
//                .border(Color.red)
//                
//            }
//            .scrollContentBackground(.hidden)
//            .background(Color.clear)
//            .padding()
//            
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//            .stroke(Color.brown, lineWidth: 2)
//        )
//        
//        //.ignoresSafeArea()
//    }
//}

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate: Date?
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
                    } header: {
                        sectionHeader("Due Date")
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
                                    category: selectedCategory,
                                    isCompleted: false,
                                    dueDate: dueDate
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
    AddTaskView()
        .modelContainer(for: Task.self, inMemory: true)
    
}
