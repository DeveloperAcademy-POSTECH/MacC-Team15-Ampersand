//
//  TimelineLayoutViewModel.swift
//  gridy
//
//  Created by 최민규 on 10/17/23.
//

import SwiftUI

class TimelineLayoutViewModel: ObservableObject {
    @Published var numOfScheduleAreaRow = 5
    @Published var numOfCol = 30
    
    let minGridSize: CGFloat = 20
    let maxGridSize: CGFloat = 70
    @Published var gridWidth: CGFloat = 45
    @Published var scheduleAreaGridHeight: CGFloat = 45
    @Published var lineAreaGridHeight: CGFloat = 45
    @Published var horizontalMagnification: CGFloat = 1.0
    @Published var verticalMagnification: CGFloat = 1.0
    
    @Published var hoverLocation: CGPoint = .zero
    @Published var hoveringCellRow: Int = 0
    @Published var hoveringCellCol: Int = 0
    @Published var isHovering = false

    @Published var selectedRanges: [SelectedRange] = []
    
    @Published var maxLineAreaRow: Int = 0
    @Published var maxCol: Int = 0
    @Published var exceededRow: Int = 0
    @Published var exceededCol: Int = 0
    
    @Published var isShiftKeyPressed = false
    @Published var isCommandKeyPressed = false
}

