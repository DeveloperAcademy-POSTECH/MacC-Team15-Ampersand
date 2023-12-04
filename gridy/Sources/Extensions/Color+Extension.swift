//
//  Color+Extension.swift
//  gridy
//
//  Created by 제나 on 2023/09/26.
//

import Foundation
import SwiftUI

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
    
    static let gridyBW = Color("gridyBW")
    static let blackWhite = Color("blackWhite")
    static let border = Color("border")
    static let sideBar = Color("sideBar")
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
    static let tabLabelInactive = Color("tabLabelInactive")
    static let project = Color("project")
    static let folder = Color("folder")
    static let board = Color("board")
    static let boardHoveredBorder = Color("boardHoveredBorder")
    static let boardSelectedBorder = Color("boardSelectedBorder")
    static let item = Color("item")
    static let itemHovered = Color("itemHovered")
    
    static let topToolBar = Color("topToolBar")
    static let topToolItem = Color("topToolItem")
    static let listArea = Color("listArea")
    static let listItem = Color("listItem")
    static let listHovered = Color("listHovered")
    static let index = Color("index")
    static let indexHovered = Color("indexHovered")
    static let verticalLine = Color("verticalLine")
    static let verticalLineWeek = Color("verticalLineWeek")
    static let horizontalLine = Color("horizontalLine")
    static let horizontalSection = Color("horizontalSection")
    static let lineArea = Color("lineArea")
    static let weekend = Color("weekend")
    static let planBoardBorder = Color("planBoardBorder")
    static let rightToolBar = Color("rightToolBar")
    static let hoveredCell = Color("hoveredCell")
    static let rightToolBarTask = Color("rightToolBarTask")
    static let rightToolBarText = Color("rightToolBarText")
    static let rightToolBarArea = Color("rightToolBarArea")
    static let rightToolBarBackground = Color("rightToolBarBackground")
    
    // TODO: - Demo용 컬러셋, 추후 삭제
    static let planColors = [
        [Color(hex: 0xF9D864)],
        [Color(hex: 0xF9B464)],
        [Color(hex: 0xFF5C00)],
        [Color(hex: 0xB0D06D)],
        [Color(hex: 0x7BD06D)],
        [Color(hex: 0x50C03E)],
        [Color(hex: 0xFF8E8E)],
        [Color(hex: 0xE63C3C)],
        [Color(hex: 0xA00000)],
        [Color(hex: 0xE8A4FF)],
        [Color(hex: 0xBF00FF)],
        [Color(hex: 0x8C0AB8)],
        [Color(hex: 0x83BCFF)],
        [Color(hex: 0x146CD2)],
        [Color(hex: 0x004798)]
    ]
}
