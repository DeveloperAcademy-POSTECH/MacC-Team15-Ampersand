//
//  Color+Extension.swift
//  gridy
//
//  Created by 제나 on 2023/09/26.
//

import Foundation
import SwiftUI
import AppKit

extension Color {
    init(
        hex: UInt,
        alpha: Double = 1.0
    ) {
        let red = Double((hex >> 16) & 0xff) / 255.0
        let green = Double((hex >> 8) & 0xff) / 255.0
        let blue = Double(hex & 0xff) / 255.0
        self.init(
            red: red,
            green: green,
            blue: blue,
            opacity: alpha
        )
    }
    
    func getUIntCode() -> UInt {
        let nsColor = NSColor(self)
        let cgColor = nsColor.cgColor
        let colorSpace = cgColor.colorSpace
        guard let components = cgColor.components else { return 0x000000 }
        
        if let colorSpaceModel = colorSpace?.model {
            switch colorSpaceModel {
            case .rgb:
                let red = UInt(components[0] * 255)
                let green = UInt(components[1] * 255)
                let blue = UInt(components[2] * 255)
                return (red << 16) + (green << 8) + blue
            default:
                return 0x000000
            }
        }
        return 0x000000
    }
    
    
    static let blackWhite = Color("blackWhite")
    static let border = Color("border")
    static let textField = Color("textField")
    static let SideBar = Color("SideBar")
    static let textInactive = Color("textInactive")
    static let subtitle = Color("subtitle")
    static let title = Color("title")
    static let button = Color("button")
    static let buttonHovered = Color("buttonHovered")
    static let buttonText = Color("buttonText")
    static let tabBar = Color("tabBar")
    static let tab = Color("tab")
    static let tabHovered = Color("tabHovered")
    static let tabLabel = Color("tabLabel")
    static let itemBackground = Color("itemBackground")
    static let itemHovered = Color("itemHovered")
    static let itemSelected = Color("itemSelected")
    static let itemSelectedBorder = Color("itemSelectedBorder")
    static let gridyBW = Color("gridyBW")


}
