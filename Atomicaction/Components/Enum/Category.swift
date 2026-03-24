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
}
