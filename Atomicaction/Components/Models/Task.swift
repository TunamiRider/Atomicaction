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
    var lastCompletedDate: Date? = nil
    
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
    func markCompleted(){
        self.isCompleted = true
        self.lastCompletedDate = Date.now
        self.updateCompletionRank()
    }
    // Call this to check and reset if past reset time today
    func resetIfNeeded(resetHour: Int = 21) {  // 21 = 9pm
        guard isRoutine, isCompleted, let completedDate = lastCompletedDate else { return }
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Get today's reset time (9pm)
        var resetComponents = calendar.dateComponents([.year, .month, .day], from: now)
        resetComponents.hour = resetHour
        resetComponents.minute = 18
        resetComponents.second = 0
        guard let todayResetTime = calendar.date(from: resetComponents) else { return }

        // Was it completed BEFORE today's reset time, and we're now past it?
        let completedBeforeReset = completedDate < todayResetTime
        let nowPastReset = now >= todayResetTime
        
        // Or was it completed yesterday or earlier?
        let completedYesterday = !calendar.isDateInToday(completedDate)

        if (completedBeforeReset && nowPastReset) || completedYesterday {
            isCompleted = false
            lastCompletedDate = nil
        }
    }
}
