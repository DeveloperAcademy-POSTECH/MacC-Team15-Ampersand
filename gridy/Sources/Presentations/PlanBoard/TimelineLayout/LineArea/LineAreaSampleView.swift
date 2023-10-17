//
//  LineAreaSampleView.swift
//  grirowOffset
//
//  Created by 최민규 on 10/12/23.
//

import SwiftUI

struct LineAreaSampleView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    @State private var columnStroke: CGFloat = 0.1
    @State private var rowStroke: CGFloat = 0.5
    @State private var temporarySelectedRange: SelectedRange?
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Button(action: {
                        moveSelectedCell(rowOffset: -1, colOffset: 0)
                    }) {
                        Text("UP")
                        }
                        .keyboardShortcut(.upArrow, modifiers: [])
                    
                    Button(action: {
                        moveSelectedCell(rowOffset: 1, colOffset: 0)}) {
                            Text("DOWN")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                    
                    Button(action: {
                        moveSelectedCell(rowOffset: 0, colOffset: -1)}) {
                            Text("LEFT")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                    
                    Button(action: {
                        moveSelectedCell(rowOffset: 0, colOffset: 1)}) {
                            Text("RIGHT")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                    Button(action: {
                       temporarySelectedRange = nil
                        viewModel.selectedRanges = []
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
                        if !viewModel.selectedRanges.isEmpty {
                            ForEach(viewModel.selectedRanges, id: \.self) { selectedRange in
                                let height = CGFloat((selectedRange.end.row - selectedRange.start.row).magnitude + 1) * viewModel.lineAreaGridHeight
                                let width = CGFloat((selectedRange.end.col - selectedRange.start.col).magnitude + 1) * viewModel.gridWidth
                                let isStartRowSmaller: Bool = selectedRange.start.row <= selectedRange.end.row
                                let isStartColSmaller: Bool = selectedRange.start.col <= selectedRange.end.col
                                Rectangle()
                                    .fill(Color.gray.opacity(0.05))
                                    .overlay(Rectangle().stroke(Color.blue, lineWidth: 1))
                                    .frame(width: width, height: height)
                                    .position(x: isStartColSmaller ? CGFloat(selectedRange.start.col) * viewModel.gridWidth + width / 2 : CGFloat(selectedRange.end.col) * viewModel.gridWidth + width / 2, y: isStartRowSmaller ? CGFloat(selectedRange.start.row) * viewModel.lineAreaGridHeight + height / 2 : CGFloat(selectedRange.end.row) * viewModel.lineAreaGridHeight + height / 2)
                            }
                        }
                        if let temporaryRange = temporarySelectedRange {
                            let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewModel.lineAreaGridHeight
                            let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewModel.gridWidth
                            let isStartRowSmaller: Bool = temporaryRange.start.row <= temporaryRange.end.row
                            let isStartColSmaller: Bool = temporaryRange.start.col <= temporaryRange.end.col
                            Rectangle()
                                .fill(Color.gray.opacity(0.05))
                                .frame(width: width, height: height)
                                .position(x: isStartColSmaller ? CGFloat(temporaryRange.start.col) * viewModel.gridWidth + width / 2 : CGFloat(temporaryRange.end.col) * viewModel.gridWidth + width / 2, y: isStartRowSmaller ? CGFloat(temporaryRange.start.row) * viewModel.lineAreaGridHeight + height / 2 : CGFloat(temporaryRange.end.row) * viewModel.lineAreaGridHeight + height / 2)
                        }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onChange(of: geometry.size) { newSize in
                viewModel.maxLineAreaRow = Int(newSize.height / viewModel.lineAreaGridHeight) + 1
                viewModel.maxCol = Int(newSize.width / viewModel.gridWidth) + 1
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
                        if !viewModel.isCommandKeyPressed {
                            if !viewModel.isShiftKeyPressed {
                                viewModel.selectedRanges = []
                                self.temporarySelectedRange = SelectedRange(start: (row: startRow, col: startCol), end: (row: endRow, col: endCol))
                            } else {
                                if let lastIndex = viewModel.selectedRanges.indices.last {
                                    var updatedRange = viewModel.selectedRanges[lastIndex]
                                    updatedRange.end.row = endRow
                                    updatedRange.end.col = endCol
                                    viewModel.selectedRanges[lastIndex] = updatedRange
                                }
                            }
                        } else {
                            if !viewModel.isShiftKeyPressed {
                                self.temporarySelectedRange = SelectedRange(start: (row: startRow, col: startCol), end: (row: endRow, col: endCol))
                            } else {
                                if let lastIndex = viewModel.selectedRanges.indices.last {
                                    var updatedRange = viewModel.selectedRanges[lastIndex]
                                    updatedRange.end.row = endRow
                                    updatedRange.end.col = endCol
                                    viewModel.selectedRanges[lastIndex] = updatedRange
                                }
                            }
                        }
                        
//                        if dragEnd.x > geometry.size.width {
//                            let offset = Int((dragEnd.x - geometry.size.width) / viewModel.gridWidth)
//                            if let temporaryRange = temporarySelectedRange {
//                                self.temporarySelectedRange = SelectedRange(start: (row: startRow, col: startCol - offset), end: (row: endRow, col: endCol))
//                                print(Int((dragEnd.x - geometry.size.width) / viewModel.gridWidth))
//                                print(temporarySelectedRange!.start.col)
//                            }
//                        }
                    }
                    .onEnded { _ in
                        if let newRange = temporarySelectedRange {
                            viewModel.selectedRanges.append(newRange)
                            temporarySelectedRange = nil
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                            viewModel.gridWidth = min(max(viewModel.gridWidth * min(max(value, 0.5), 2.0), viewModel.minGridSize), viewModel.maxGridSize)
                            viewModel.lineAreaGridHeight = min(max(viewModel.lineAreaGridHeight * min(max(value, 0.5), 2.0), viewModel.minGridSize), viewModel.maxGridSize)
                        viewModel.maxLineAreaRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) + 1
                        viewModel.maxCol = Int(geometry.size.width / viewModel.gridWidth) + 1
                    }
            )
        }
    }
    
    func moveSelectedCell(rowOffset: Int, colOffset: Int) {
        if !viewModel.selectedRanges.isEmpty {
            if !viewModel.isShiftKeyPressed {
                let startRow = min(max(Int(viewModel.selectedRanges.last!.start.row) + rowOffset, 0), viewModel.maxLineAreaRow - 2)
                let startCol = min(max(Int(viewModel.selectedRanges.last!.start.col) + colOffset, 0), viewModel.maxCol - 2)
                viewModel.selectedRanges = [SelectedRange(start: (row: startRow, col: startCol), end: (row: startRow, col: startCol))]
            } else {
                let startRow = Int(viewModel.selectedRanges.last!.start.row)
                let endRow = Int(viewModel.selectedRanges.last!.end.row) + rowOffset
                let startCol = Int(viewModel.selectedRanges.last!.start.col)
                let endCol = Int(viewModel.selectedRanges.last!.end.col) + colOffset
                viewModel.selectedRanges = [SelectedRange(start: (row: startRow, col: startCol), end: (row: endRow, col: endCol))]
            }
        }
    }
}
