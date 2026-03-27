//
//  categoryConfig.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/23/26.
//
import SwiftUI

struct CategoryConfig {
    let icon: String
    let color: Color
    let label: String

    static func from(_ category: Category) -> CategoryConfig {
        switch category {
        case .work:     return CategoryConfig(icon: "briefcase.fill",         color: Color(hex: "4A90E2"), label: "Work")
        case .personal: return CategoryConfig(icon: "person.crop.circle.fill", color: Color(hex: "F5A623"), label: "Personal")
        case .home:     return CategoryConfig(icon: "house.fill",             color: Color(hex: "7ED321"), label: "Home")
        case .other:    return CategoryConfig(icon: "tag.fill",               color: Color(hex: "E24A4A"), label: "Other")
        }
    }
}
