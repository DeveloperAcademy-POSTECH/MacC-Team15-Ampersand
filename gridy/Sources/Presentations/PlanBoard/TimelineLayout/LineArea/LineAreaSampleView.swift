//
//  LineAreaSampleView.swift
//  gridy
//
//  Created by 최민규 on 10/12/23.
//

import SwiftUI

struct LineAreaSampleView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    @State private var columnStroke = CGFloat(0.1)
    @State private var rowStroke = CGFloat(0.5)
    @State private var temporarySelectedGridRange: SelectedGridRange?
    @State private var isExceededLeft = false
    @State private var isExceededRight = false
    @State private var isExceededTop = false
    @State private var isExceededBottom = false
    @State private var timer: Timer?
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Button(action: {
                        if !viewModel.selectedGridRanges.isEmpty {
                            let today = Date()
                            let startDate = min(Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.start.col, to: today)!, Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.end.col, to: today)!)
                            let endDate = max(Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.start.col, to: today)!, Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.end.col, to: today)!)
                            viewModel.selectedDateRanges = [SelectedDateRange(start: startDate, end: endDate)]
                        }
                    }) {
                        Text("create Plan")
                    }
                    .keyboardShortcut(.return, modifiers: [])
                    Button(action: {
                        viewModel.exceededCol = 0
                        viewModel.exceededRow = 0
                    }) {
                        Text("today")
                    }
                    .keyboardShortcut(.return, modifiers: [.command])
                    Button(action: {
                        moveSelectedCell(rowOffset: -1, colOffset: 0)
                    }) {
                        Text("Up")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [])
                    
                    Button(action: {
                        moveSelectedCell(rowOffset: 1, colOffset: 0)}) {
                            Text("Down")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                    
                    Button(action: {
                        moveSelectedCell(rowOffset: 0, colOffset: -1)}) {
                            Text("Left")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                    
                    Button(action: {
                        moveSelectedCell(rowOffset: 0, colOffset: 1)}) {
                            Text("Right")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                    Button(action: {
                        moveSelectedCellToEnd(rowOffset: -1, colOffset: 0)
                    }) {
                        Text("Top")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [.command])
                    
                    Button(action: {
                        moveSelectedCellToEnd(rowOffset: 1, colOffset: 0)}) {
                            Text("Bottom")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [.command])
                    
                    Button(action: {
                        moveSelectedCellToEnd(rowOffset: 0, colOffset: -1)}) {
                            Text("Lead")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [.command])
                    
                    Button(action: {
                        moveSelectedCellToEnd(rowOffset: 0, colOffset: 1)}) {
                            Text("Trail")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [.command])
                    Button(action: {
                        temporarySelectedGridRange = nil
                        viewModel.selectedGridRanges = []
                    }) {
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                }
                
                Color.white
                
                Path { path in
                    for rowIndex in 0..<viewModel.maxLineAreaRow {
                        let yLocation = CGFloat(rowIndex) * viewModel.lineAreaGridHeight - rowStroke
                        path.move(to: CGPoint(x: 0, y: yLocation))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                    }
                }
                .stroke(Color.gray, lineWidth: rowStroke)
                Path { path in
                    for columnIndex in 0..<viewModel.maxCol {
                        let xLocation = CGFloat(columnIndex) * viewModel.gridWidth - columnStroke
                        path.move(to: CGPoint(x: xLocation, y: 0))
                        path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                    }
                }
                .stroke(Color.gray, lineWidth: columnStroke)
                
                ZStack {
                    if !viewModel.selectedGridRanges.isEmpty {
                        ForEach(viewModel.selectedGridRanges, id: \.self) { selectedRange in
                            let height = CGFloat((selectedRange.end.row - selectedRange.start.row).magnitude + 1) * viewModel.lineAreaGridHeight
                            let width = CGFloat((selectedRange.end.col - selectedRange.start.col).magnitude + 1) * viewModel.gridWidth
                            let isStartRowSmaller = selectedRange.start.row <= selectedRange.end.row
                            let isStartColSmaller = selectedRange.start.col <= selectedRange.end.col
                            Rectangle()
                                .fill(Color.gray.opacity(0.05))
                                .overlay(Rectangle().stroke(Color.blue, lineWidth: 1))
                                .frame(width: width, height: height)
                                .position(x: isStartColSmaller ? CGFloat(selectedRange.start.col - viewModel.exceededCol) * viewModel.gridWidth + width / 2 : CGFloat(selectedRange.end.col - viewModel.exceededCol) * viewModel.gridWidth + width / 2, y: isStartRowSmaller ? CGFloat(selectedRange.start.row) * viewModel.lineAreaGridHeight + height / 2 : CGFloat(selectedRange.end.row) * viewModel.lineAreaGridHeight + height / 2)
                        }
                    }
                    if let temporaryRange = temporarySelectedGridRange {
                        let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewModel.lineAreaGridHeight
                        let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewModel.gridWidth
                        let isStartRowSmaller: Bool = temporaryRange.start.row <= temporaryRange.end.row
                        let isStartColSmaller: Bool = temporaryRange.start.col <= temporaryRange.end.col
                        Rectangle()
                            .fill(Color.red.opacity(0.05))
                            .frame(width: width, height: height)
                            .position(x: 
                                        isStartColSmaller ? CGFloat(temporaryRange.start.col - viewModel.exceededCol) * viewModel.gridWidth + width / 2 :
                                        CGFloat(temporaryRange.end.col - viewModel.exceededCol) * viewModel.gridWidth + width / 2,
                                      y: 
                                        isStartRowSmaller ? CGFloat(temporaryRange.start.row) * viewModel.lineAreaGridHeight + height / 2 :
                                        CGFloat(temporaryRange.end.row) * viewModel.lineAreaGridHeight + height / 2)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onChange(of: geometry.size) { newSize in
                viewModel.maxLineAreaRow = Int(newSize.height / viewModel.lineAreaGridHeight) + 1
                viewModel.maxCol = Int(newSize.width / viewModel.gridWidth) + 1
            }
            .onChange(of: [viewModel.gridWidth, viewModel.lineAreaGridHeight]) { newSize in
                viewModel.maxLineAreaRow = Int(geometry.size.height / newSize[1]) + 1
                viewModel.maxCol = Int(geometry.size.width / newSize[0]) + 1
            }
            .onChange(of: [isExceededLeft, isExceededRight, isExceededTop, isExceededBottom]) { exceeded in
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                    viewModel.exceededCol += (exceeded[0] ? -1 : 0) + (exceeded[1] ? 1 : 0)
                    viewModel.exceededRow += (exceeded[2] ? -1 : 0) + (exceeded[3] ? 1 : 0)
                }
            }
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    viewModel.hoverLocation = location
                    viewModel.hoveringCellRow = Int(viewModel.hoverLocation.y / viewModel.lineAreaGridHeight)
                    viewModel.hoveringCellCol = Int(viewModel.hoverLocation.x / viewModel.gridWidth)
                    viewModel.isHovering = true
                case .ended:
                    viewModel.isHovering = false
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { gesture in
                        let dragEnd = gesture.location
                        let dragStart = gesture.startLocation
                        
                        let startRow = Int(dragStart.y / viewModel.lineAreaGridHeight)
                        let endRow = Int(dragEnd.y / viewModel.lineAreaGridHeight)
                        let startCol = Int(dragStart.x / viewModel.gridWidth)
                        let endCol = Int(dragEnd.x / viewModel.gridWidth)
                        self.isExceededLeft = dragEnd.x < 0
                        self.isExceededRight = dragEnd.x > geometry.size.width
                        self.isExceededTop = dragEnd.y < 0
                        self.isExceededBottom = dragEnd.y > geometry.size.height
                        if !viewModel.isCommandKeyPressed {
                            if !viewModel.isShiftKeyPressed {
                                viewModel.selectedGridRanges = []
                                self.temporarySelectedGridRange = SelectedGridRange(start: (startRow, startCol), 
                                                                                    end: (endRow, isExceededRight ? endCol + viewModel.exceededCol : endCol))
                            } else {
                                if let lastIndex = viewModel.selectedGridRanges.indices.last {
                                    var updatedRange = viewModel.selectedGridRanges[lastIndex]
                                    updatedRange.end.row = endRow
                                    updatedRange.end.col = endCol
                                    viewModel.selectedGridRanges[lastIndex] = updatedRange
                                }
                            }
                        } else {
                            if !viewModel.isShiftKeyPressed {
                                self.temporarySelectedGridRange = SelectedGridRange(start: (startRow, startCol),
                                                                                    end: (endRow, endCol))
                            } else {
                                if let lastIndex = viewModel.selectedGridRanges.indices.last {
                                    var updatedRange = viewModel.selectedGridRanges[lastIndex]
                                    updatedRange.end.row = endRow
                                    updatedRange.end.col = endCol
                                    viewModel.selectedGridRanges[lastIndex] = updatedRange
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        if let newRange = temporarySelectedGridRange {
                            viewModel.selectedGridRanges.append(newRange)
                            temporarySelectedGridRange = nil
                        }
                        self.isExceededLeft = false
                        self.isExceededRight = false
                        self.isExceededTop = false
                        self.isExceededBottom = false
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        viewModel.gridWidth = min(max(viewModel.gridWidth * min(max(value, 0.5), 2.0), viewModel.minGridSize),
                                                  viewModel.maxGridSize)
                        viewModel.lineAreaGridHeight = min(max(viewModel.lineAreaGridHeight * min(max(value, 0.5), 2.0), viewModel.minGridSize),
                                                           viewModel.maxGridSize)
                        viewModel.maxLineAreaRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) + 1
                        viewModel.maxCol = Int(geometry.size.width / viewModel.gridWidth) + 1
                    }
            )
            
        }
    }
    func moveSelectedCell(rowOffset: Int, colOffset: Int) {
        if !viewModel.selectedGridRanges.isEmpty {
            if Int(viewModel.selectedGridRanges.last!.end.col) + colOffset < 0 {
                viewModel.exceededCol -= 1
            } else if Int(viewModel.selectedGridRanges.last!.end.col) + colOffset > viewModel.maxCol - 2 {
                viewModel.exceededCol += 1
            }
            if !viewModel.isShiftKeyPressed {
                let movedRow = min(max(Int(viewModel.selectedGridRanges.last!.start.row) + rowOffset, 0), 
                                   viewModel.maxLineAreaRow - 2)
                let movedCol = min(max(Int(viewModel.selectedGridRanges.last!.start.col) + colOffset, 0), viewModel.maxCol - 2)
                viewModel.selectedGridRanges = [SelectedGridRange(start: (movedRow, movedCol), end: (movedRow, movedCol))]
            } else {
                let startRow = Int(viewModel.selectedGridRanges.last!.start.row)
                let movedEndRow = Int(viewModel.selectedGridRanges.last!.end.row) + rowOffset
                let startCol = Int(viewModel.selectedGridRanges.last!.start.col)
                let movedEndCol = Int(viewModel.selectedGridRanges.last!.end.col) + colOffset
                viewModel.selectedGridRanges = [SelectedGridRange(start: (startRow, startCol), end: (movedEndRow, movedEndCol))]
            }
        }
    }
    
    func moveSelectedCellToEnd(rowOffset: Int, colOffset: Int) {
        if !viewModel.selectedGridRanges.isEmpty {
            if Int(viewModel.selectedGridRanges.last!.end.col) + colOffset < 0 {
                viewModel.exceededCol -= 7
            } else if Int(viewModel.selectedGridRanges.last!.end.col) + colOffset > viewModel.maxCol - 2 {
                viewModel.exceededCol += 7
            }
            if !viewModel.isShiftKeyPressed {
                var movedRow: Int = 0
                var movedCol: Int = 0
                if rowOffset < 0 {
                    movedRow = 0
                    movedCol = min(max(Int(viewModel.selectedGridRanges.last!.start.col) + colOffset, 0), viewModel.maxCol - 2)
                } else if rowOffset > 0 {
                    movedRow = viewModel.maxLineAreaRow - 2
                    movedCol = min(max(Int(viewModel.selectedGridRanges.last!.start.col) + colOffset, 0), viewModel.maxCol - 2)
                }
                if colOffset < 0 {
                    movedRow = min(Int(viewModel.selectedGridRanges.last!.start.row) + rowOffset, viewModel.maxLineAreaRow - 2)
                    movedCol = 0
                } else if colOffset > 0 {
                    movedRow = min(max(Int(viewModel.selectedGridRanges.last!.start.row) + rowOffset, 0), viewModel.maxLineAreaRow - 2)
                    movedCol = viewModel.maxCol - 2
                }
                viewModel.selectedGridRanges = [SelectedGridRange(start: (movedRow, movedCol), end: (movedRow, movedCol))]
            } else {
                var movedEndRow: Int = 0
                var movedEndCol: Int = 0
                if rowOffset < 0 {
                    movedEndRow = 0
                    movedEndCol = min(max(Int(viewModel.selectedGridRanges.last!.end.col) + colOffset, 0), viewModel.maxCol - 2)
                } else if rowOffset > 0 {
                    movedEndRow = viewModel.maxLineAreaRow - 2
                    movedEndCol = min(max(Int(viewModel.selectedGridRanges.last!.end.col) + colOffset, 0), viewModel.maxCol - 2)
                }
                if colOffset < 0 {
                    movedEndRow = min(max(Int(viewModel.selectedGridRanges.last!.end.row) + rowOffset, 0), viewModel.maxLineAreaRow - 2)
                    movedEndCol = 0
                } else if colOffset > 0 {
                    movedEndRow = min(max(Int(viewModel.selectedGridRanges.last!.end.row) + rowOffset, 0), viewModel.maxLineAreaRow - 2)
                    movedEndCol = viewModel.maxCol - 2
                }
                let startRow = Int(viewModel.selectedGridRanges.last!.start.row)
                let startCol = Int(viewModel.selectedGridRanges.last!.start.col)
                viewModel.selectedGridRanges = [SelectedGridRange(start: (startRow, startCol), end: (movedEndRow, movedEndCol))]
            }
        }
    }
}
