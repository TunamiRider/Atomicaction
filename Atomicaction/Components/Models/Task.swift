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
    var startTime: Date?
    
    init(timestamp: Date,
         title: String,
         task_description: String,
         category: Category = .other,
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         startTime: Date? = nil) {
        
        self.timestamp = timestamp
        self.title = title
        self.task_description = task_description
        self.category = category
        self.isCompleted = isCompleted
        // task
        self.dueDate = dueDate
        // routine
        self.startTime = startTime
    }
}
