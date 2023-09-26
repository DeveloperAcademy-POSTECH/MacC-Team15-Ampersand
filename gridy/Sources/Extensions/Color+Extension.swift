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
}
