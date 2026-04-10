//
//  Tab.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/28/26.
//

enum Tab: Int, CaseIterable, Identifiable {
    case home = 0
    case list = 1
    case slot = 2
    
    var image: String {
        switch self {
        case .home: return "house"
        case .list: return "list.bullet.rectangle"
        case .slot: return "calendar.day.timeline.left"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .list: return "Tasks"
        case .slot: return "Routines"
        }
    }
    
    var id: Int { rawValue }
}
