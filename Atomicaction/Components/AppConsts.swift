//
//  AppConst.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 3/22/26.
//
import SwiftUI

struct AppConsts {
    static let appName: String = "Atomicaction"
    
    static let spaceblack = Color.black.opacity(1)
    
    static let fontColot = Color.white
    
    static let navyBlack = Color(hex: "1C1C2E")
    static let limeGreen = Color(hex: "7ED321")
    static let navyPurple = Color(hex: "252540")

    static let appFont12 = Font.system(size: 12, weight: .semibold, design: .monospaced)
    static let appFont16 = Font.system(size: 16, weight: .semibold, design: .monospaced)
    static let appFont14 = Font.system(size: 14, weight: .semibold, design: .monospaced)
}

struct AppGlobals {
    static func labelColor(isEditing: Bool, isCompleted: Bool) -> Color {
        isCompleted ? AppConsts.limeGreen.opacity(0.5) : isEditing ?  AppConsts.navyPurple : AppConsts.navyBlack
    }
    static func backgroundColor(isEditing: Bool) -> Color {
        isEditing ?  AppConsts.navyPurple : AppConsts.spaceblack
    }
    
}

struct Gradients {
    static let spaceBlack = RadialGradient(
        colors: [
            Color(red: 0.04, green: 0.02, blue: 0.12),  // #0a051f
            Color(red: 0.01, green: 0.01, blue: 0.06),  // #03030f
            Color.black  // #000000
        ],
        center: .center,
        startRadius: 0,
        endRadius: 520 * 1  // Pass s or make it computed
    )
}

//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let r = Double((int >> 16) & 0xFF) / 255
//        let g = Double((int >> 8)  & 0xFF) / 255
//        let b = Double( int        & 0xFF) / 255
//        self.init(red: r, green: g, blue: b)
//    }
//}
