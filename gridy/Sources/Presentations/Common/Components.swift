//
//  Components.swift
//  gridy
//
//  Created by 최민규 on 11/4/23.
//

import SwiftUI

func systemBorder(_ direction: Edge.Set, _ lineWidth: CGFloat = 1) -> some View {
    Rectangle()
        .foregroundStyle(Color.border)
        .frame(width: direction == .vertical ? lineWidth : nil)
        .frame(height: direction == .horizontal ? lineWidth : nil)
}
func planBoardBorder(_ direction: Edge.Set, _ lineWidth: CGFloat = 1) -> some View {
    Rectangle()
        .foregroundStyle(Color.planBoardBorder)
        .frame(width: direction == .vertical ? lineWidth : nil)
        .frame(height: direction == .horizontal ? lineWidth : nil)
}
