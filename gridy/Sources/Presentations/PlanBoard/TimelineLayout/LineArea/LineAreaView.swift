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
    @State private var exceededDirection = [false, false, false, false]
    @State private var timer: Timer?
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Button(action: {
                        if !viewModel.selectedGridRanges.isEmpty {
                            let today = Date()
                            let startDate = min(Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.start.col, to: today)!,
                                                Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.end.col, to: today)!)
                            let endDate = max(Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.start.col, to: today)!,
                                              Calendar.current.date(byAdding: .day, value: viewModel.selectedGridRanges.last!.end.col, to: today)!)
                            viewModel.selectedDateRanges.append(SelectedDateRange(start: startDate, end: endDate))
                            print(viewModel.selectedDateRanges)
                            if let dateRange = viewModel.selectedDateRanges.last {
                                let dateDiff = Calendar.current.dateComponents([.day], from: dateRange.start, to: dateRange.end)
                                print(dateDiff)
                            }
                        }
                    }) {
                        Text("create Plan")
                    }
                    .keyboardShortcut(.return, modifiers: [])
                    Button(action: {
                        viewModel.shiftToToday()
                    }) {
                        Text("shift to today")
                    }
                    .keyboardShortcut(.return, modifiers: [.command])
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: -1, colOffset: 0)
                    }) {
                        Text("shift 1 UP")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [])
                    
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: 1, colOffset: 0)}) {
                            Text("shift 1 Down")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                    
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: 0, colOffset: -1)}) {
                            Text("shift 1 Left")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                    
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: 0, colOffset: 1)}) {
                            Text("shift 1 Right")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: -7, colOffset: 0)
                    }) {
                        Text("shift 7 Top")
                    }
                    .keyboardShortcut(.upArrow, modifiers: [.command])
                    
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: 7, colOffset: 0)}) {
                            Text("shift 7 Bottom")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [.command])
                    
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: 0, colOffset: -7)}) {
                            Text("shift 7 Lead")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [.command])
                    
                    Button(action: {
                        viewModel.shiftSelectedCell(rowOffset: 0, colOffset: 7)}) {
                            Text("shift 7 Trail")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [.command])
                    Button(action: {
                        viewModel.escapeSelectedCell()
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
                    if !viewModel.selectedDateRanges.isEmpty {
                        ForEach(viewModel.selectedDateRanges, id: \.self) { selectedRange in
                            let height = viewModel.lineAreaGridHeight
                            let dayDifference = Calendar.current.dateComponents([.day], from: selectedRange.start, to: selectedRange.end).day!
                            let width = CGFloat(dayDifference + 1)
                            let positionStart = CGFloat(Calendar.current.dateComponents([.day], from: Date(), to: selectedRange.start).day! + 1)
                            
                            Rectangle()
                                .fill(Color.red.opacity(0.8))
                                .overlay(Rectangle().stroke(Color.blue, lineWidth: 1))
                                .frame(width: width * viewModel.gridWidth, height: height)
                                .position(x: (positionStart + (width / 2) - CGFloat(viewModel.shiftedCol)) * viewModel.gridWidth, y: 100 + viewModel.lineAreaGridHeight / 2)
                        }
                    }
                    if let temporaryRange = temporarySelectedGridRange {
                        let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewModel.lineAreaGridHeight
                        let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewModel.gridWidth
                        let isStartRowSmaller: Bool = temporaryRange.start.row <= temporaryRange.end.row
                        let isStartColSmaller: Bool = temporaryRange.start.col <= temporaryRange.end.col
                        Rectangle()
                            .fill(Color.gray.opacity(0.05))
                            .frame(width: width, height: height)
                            .position(x:
                                        isStartColSmaller ? CGFloat(temporaryRange.start.col - viewModel.shiftedCol) * viewModel.gridWidth + width / 2 :
                                        CGFloat(temporaryRange.end.col - viewModel.shiftedCol) * viewModel.gridWidth + width / 2,
                                      y:
                                        isStartRowSmaller ? CGFloat(temporaryRange.start.row) * viewModel.lineAreaGridHeight + height / 2 :
                                        CGFloat(temporaryRange.end.row) * viewModel.lineAreaGridHeight + height / 2)
                    }
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
                                .position(x: isStartColSmaller ? CGFloat(selectedRange.start.col - viewModel.shiftedCol) * viewModel.gridWidth + width / 2 :
                                            CGFloat(selectedRange.end.col - viewModel.shiftedCol) * viewModel.gridWidth + width / 2,
                                          y: isStartRowSmaller ? CGFloat(selectedRange.start.row - viewModel.shiftedRow) * viewModel.lineAreaGridHeight + height / 2 :
                                            CGFloat(selectedRange.end.row - viewModel.shiftedRow) * viewModel.lineAreaGridHeight + height / 2)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onChange(of: exceededDirection) { direction in
                if temporarySelectedGridRange != nil {
                    switch direction {
                    case [true, false, false, false]:
                        viewModel.shiftedCol -= 1
                        viewModel.exceededCol -= 1
                    case [false, true, false, false]:
                        viewModel.shiftedCol += 1
                        viewModel.exceededCol += 1
                    case [false, false, true, false]:
                        viewModel.shiftedRow -= 1
                        viewModel.exceededRow -= 1
                    case [false, false, false, true]:
                        viewModel.shiftedRow += 1
                        viewModel.exceededRow += 1
                    default: break
                    }
                }
            }
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
                        /// local 뷰 기준 절대적인 드래그 시작점과 끝 점.
                        let dragEnd = gesture.location
                        let dragStart = gesture.startLocation
                        /// 드래그된 값을 기준으로 시작점과 끝점의 Row, Col 계산
                        let startRow = Int(dragStart.y / viewModel.lineAreaGridHeight)
                        let startCol = Int(dragStart.x / viewModel.gridWidth)
                        let endRow = Int(dragEnd.y / viewModel.lineAreaGridHeight)
                        let endCol = Int(dragEnd.x / viewModel.gridWidth)
                        /// 드래그 해서 화면 밖으로 나갔는지 Bool로 반환 (Left, Right, Top, Bottom)
                        exceededDirection = [dragEnd.x < 0, dragEnd.x > geometry.size.width, dragEnd.y < 0, dragEnd.y > geometry.size.height]
                        if !viewModel.isCommandKeyPressed {
                            if !viewModel.isShiftKeyPressed {
                                ///  selectedGridRanges을 초기화하고,  temporaryGridRange에 shifted된 값을 더한 값을 임시로 저장한다. 이 값은 onEnded상태에서 selectedGridRanges에 append 될 예정
                                viewModel.selectedGridRanges = []
                                temporarySelectedGridRange = nil
                                temporarySelectedGridRange = SelectedGridRange(start: (startRow + viewModel.shiftedRow, startCol + viewModel.shiftedCol - viewModel.exceededCol),
                                                                               end: (endRow + viewModel.shiftedRow, endCol + viewModel.shiftedCol))
                            } else {
                                /// Shift가 클릭된 상태에서는, selectedGridRanges의 마지막 Range 끝 점의 Row, Col을 selectedGridRanges에 직접 담는다. 드래그 중에도 영역이 변하길 기대하기 때문.
                                if let lastIndex = viewModel.selectedGridRanges.indices.last {
                                    var updatedRange = viewModel.selectedGridRanges[lastIndex]
                                    updatedRange.end.row = endRow + viewModel.shiftedRow
                                    updatedRange.end.col = endCol + viewModel.shiftedCol
                                    viewModel.selectedGridRanges = [updatedRange]
                                }
                            }
                        } else {
                            if !viewModel.isShiftKeyPressed {
                                /// Command가 클릭된 상태에서는 onEnded에서 append하게 될 temporarySelectedGridRange를 업데이트 한다.
                                self.temporarySelectedGridRange = SelectedGridRange(start: (startRow + viewModel.shiftedRow, startCol + viewModel.shiftedCol),
                                                                                    end: (endRow + viewModel.shiftedRow, endCol + viewModel.shiftedCol))
                            } else {
                                /// Command와 Shift가 클릭된 상태에서는 selectedGridRanges의 마지막 Range의 끝점을 업데이트 해주어 selectedGridRanges에 직접 담는다. 드래그 중에도 영역이 변하길 기대하기 때문.
                                if let lastIndex = viewModel.selectedGridRanges.indices.last {
                                    var updatedRange = viewModel.selectedGridRanges[lastIndex]
                                    updatedRange.end.row = endRow + viewModel.shiftedRow
                                    updatedRange.end.col = endCol + viewModel.shiftedCol
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
                        exceededDirection = [false, false, false, false]
                        viewModel.exceededCol = 0
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
