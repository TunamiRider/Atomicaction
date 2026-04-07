//
//  Category.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//

enum Category: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case home = "Home"
    case other = "Other"
    
    var sortIndex: Int {
        switch self {
        case .work: return 0
        case .personal: return 1
        case .home: return 2
        case .other: return 3
        }
    }
}
