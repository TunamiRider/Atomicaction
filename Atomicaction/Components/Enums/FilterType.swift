//
//  FilterType.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 4/3/26.
//

enum FilterType: String, CaseIterable, Codable {
    case all = "all"
    case showOnlyCompleted = "show_only_completed"
    case showOnlyRoutine = "show_only_routine"
    
}
