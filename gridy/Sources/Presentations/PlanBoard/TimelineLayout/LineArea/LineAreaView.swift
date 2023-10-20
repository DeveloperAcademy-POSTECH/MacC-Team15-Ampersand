//
//  LineAreaView.swift
//  gridy
//
//  Created by 최민규 on 10/12/23.
//

import SwiftUI

struct LineAreaView: View {
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
                        viewModel.moveSelectedCell(rowOffset: -1, colOffset: 0)
                    }) {
                        Text("Up")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [])
                    
                    Button(action: {
                        viewModel.moveSelectedCell(rowOffset: 1, colOffset: 0)}) {
                            Text("Down")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                    
                    Button(action: {
                        viewModel.moveSelectedCell(rowOffset: 0, colOffset: -1)}) {
                            Text("Left")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                    
                    Button(action: {
                        viewModel.moveSelectedCell(rowOffset: 0, colOffset: 1)}) {
                            Text("Right")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                    Button(action: {
                        viewModel.moveSelectedCell(rowOffset: -7, colOffset: 0)
                    }) {
                        Text("Top")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [.command])
                    
                    Button(action: {
                        viewModel.moveSelectedCell(rowOffset: 7, colOffset: 0)}) {
                            Text("Bottom")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [.command])
                    
                    Button(action: {
                        viewModel.moveSelectedCell(rowOffset: 0, colOffset: -7)}) {
                            Text("Lead")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [.command])
                    
                    Button(action: {
                        viewModel.moveSelectedCell(rowOffset: 0, colOffset: 7)}) {
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
                                self.temporarySelectedGridRange = SelectedGridRange(start: (startRow + viewModel.exceededRow, startCol + viewModel.exceededCol), end: (endRow + viewModel.exceededRow, endCol + viewModel.exceededCol))
                            } else {
                                if let lastIndex = viewModel.selectedGridRanges.indices.last {
                                    var updatedRange = viewModel.selectedGridRanges[lastIndex]
                                    updatedRange.end.row = endRow + viewModel.exceededRow
                                    updatedRange.end.col = endCol + viewModel.exceededCol
                                    viewModel.selectedGridRanges[lastIndex] = updatedRange
                                }
                            }
                        } else {
                            if !viewModel.isShiftKeyPressed {
                                self.temporarySelectedGridRange = SelectedGridRange(start: (startRow + viewModel.exceededRow, startCol + viewModel.exceededCol),
                                                                                    end: (endRow + viewModel.exceededRow, endCol + viewModel.exceededCol))
                            } else {
                                if let lastIndex = viewModel.selectedGridRanges.indices.last {
                                    var updatedRange = viewModel.selectedGridRanges[lastIndex]
                                    updatedRange.end.row = endRow + viewModel.exceededRow
                                    updatedRange.end.col = endCol + viewModel.exceededCol
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
}
