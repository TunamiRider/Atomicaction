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

}

struct AppGlobals {
    static func labelColor(isEditing: Bool, isCompleted: Bool) -> Color {
        isCompleted ? AppConsts.limeGreen.opacity(0.5) : isEditing ?  AppConsts.navyPurple : AppConsts.navyBlack
    }
    static func backgroundColor(isEditing: Bool) -> Color {
        isEditing ?  AppConsts.navyPurple : AppConsts.spaceblack
    }
    
}
