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
    
    let minGridSize = CGFloat(20)
    let maxGridSize = CGFloat(70)
    @Published var gridWidth = CGFloat(45)
    @Published var scheduleAreaGridHeight = CGFloat(45)
    @Published var lineAreaGridHeight = CGFloat(45)
    @Published var horizontalMagnification = CGFloat(1.0)
    @Published var verticalMagnification = CGFloat(1.0)
    
    @Published var hoverLocation: CGPoint = .zero
    @Published var hoveringCellRow = 0
    @Published var hoveringCellCol = 0
    @Published var isHovering = false

    @Published var selectedGridRanges: [SelectedGridRange] = []
    @Published var selectedDateRanges: [SelectedDateRange] = []
    
    @Published var maxLineAreaRow = 0
    @Published var maxCol = 0
    @Published var exceededRow = 0
    @Published var exceededCol = 0
    
    @Published var isShiftKeyPressed = false
    @Published var isCommandKeyPressed = false
    
    @Published var columnStroke = CGFloat(0.1)
    @Published var rowStroke = CGFloat(0.5)
}

