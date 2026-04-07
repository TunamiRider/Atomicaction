//
//  Task.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//
import SwiftData
import Foundation
@Model
class Task {
    var order: Int = 0
    var categoryOrder: Int
    //common
    var timestamp: Date
    var title: String
    var task_description: String
    var isRoutine: Bool = false
    var isCompleted: Bool = false
    var category: Category
    
    // task
    var dueDate: Date?
    // routine
    var scheduledAt: Date?
    var durationMinutes: Int?
    // sort order
    var completionRank: Int = 0
    var dueDateRank: Int = 0
    
    init(timestamp: Date,
         title: String,
         task_description: String,
         isRoutine: Bool? = false,
         category: Category = .other,
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         scheduledAt: Date? = nil,
         durationMinutes: Int? = 0) {
        
        //default
        self.timestamp = timestamp
        self.title = title
        self.task_description = task_description
        self.isRoutine = isRoutine ?? false
        self.category = category
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        // routine
        self.scheduledAt = scheduledAt
        self.durationMinutes = durationMinutes
        
        self.categoryOrder = category.sortIndex
        self.completionRank = isCompleted ? 1 : 0
        self.dueDateRank = (dueDate == nil) ? 1 : 0
    }
    
    func updateCompletionRank(){
        self.completionRank = isCompleted ? 1 : 0
    }
    func updateDueDateRank(){
        self.dueDateRank = (dueDate == nil) ? 1 : 0
    }
}
