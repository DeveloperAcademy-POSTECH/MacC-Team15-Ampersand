//
//  LineAreaView.swift
//  gridy
//
//  Created by 최민규 on 10/12/23.
//

import SwiftUI
import ComposableArchitecture

struct DrawnLine: Identifiable, Equatable {
    let id = UUID()
    var start: CGPoint
    var end: CGPoint
}

struct LineAreaView: View {
    
    @State private var temporarySelectedGridRange: SelectedGridRange?
    @State private var exceededDirection = [false, false, false, false]
    @State private var timer: Timer?
    
    @State private var drawnRange: SelectedGridRange?
    @State private var shouldDrawLine: Bool = false
    @State private var drawLine: Bool = false
    @State private var lineStart: CGPoint = .zero
    @State private var lineEnd: CGPoint = .zero
    @State private var diamondPosition: CGPoint = .zero
    @State private var drawnLines: [DrawnLine] = []
    
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    HStack {
                        Button {
                            if !viewStore.selectedGridRanges.isEmpty {
                                let today = Date().filteredDate
                                let startDate = min(
                                    Calendar.current.date(
                                        byAdding: .day, value: viewStore.selectedGridRanges.last!.start.col,
                                        to: today
                                    )!.filteredDate,
                                    Calendar.current.date(
                                        byAdding: .day, value: viewStore.selectedGridRanges.last!.end.col,
                                        to: today
                                    )!.filteredDate
                                )
                                let endDate = max(
                                    Calendar.current.date(
                                        byAdding: .day, value: viewStore.selectedGridRanges.last!.start.col,
                                        to: today
                                    )!.filteredDate,
                                    Calendar.current.date(
                                        byAdding: .day, value: viewStore.selectedGridRanges.last!.end.col,
                                        to: today
                                    )!.filteredDate
                                )
                                // TODO: - Create plan
                            }
                        } label: {
                            Text("create Plan")
                        }
                        .keyboardShortcut(.return, modifiers: [])
                        
                        Button {
                            viewStore.send(.shiftToToday)
                        } label: {
                            Text("shift to today")
                        }
                        .keyboardShortcut(.return, modifiers: [.command])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: -1, colOffset: 0))
                        } label: {
                            Text("shift 1 UP")
                        }
                        .keyboardShortcut(.upArrow, modifiers: [])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: 1, colOffset: 0))
                        } label: {
                            Text("shift 1 Down")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: 0, colOffset: -1))
                        } label: {
                            Text("shift 1 Left")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: 0, colOffset: 1))
                        } label: {
                            Text("shift 1 Right")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: -7, colOffset: 0))
                        } label: {
                            Text("shift 7 Top")
                        }
                        .keyboardShortcut(.upArrow, modifiers: [.command])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: 7, colOffset: 0))
                        } label: {
                            Text("shift 7 Bottom")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [.command])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: 0, colOffset: -7))
                        } label: {
                            Text("shift 7 Lead")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [.command])
                        
                        Button {
                            viewStore.send(.shiftSelectedCell(rowOffset: 0, colOffset: 7))
                        } label: {
                            Text("shift 7 Trail")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [.command])
                        
                        Button {
                            viewStore.send(.escapeSelectedCell)
                        } label: { }
                            .keyboardShortcut(.escape, modifiers: [])
                    }
                    Color.white
                    
                    Path { path in
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight - viewStore.rowStroke
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.rowStroke)
                    Path { path in
                        for columnIndex in 0..<viewStore.maxCol {
                            let xLocation = CGFloat(columnIndex) * viewStore.gridWidth - viewStore.columnStroke
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.columnStroke)
                    
                    ZStack {
                        ForEach(viewStore.selectedDateRanges, id: \.self) { selectedRange in
                            let today = Date().filteredDate
                            let height = viewStore.lineAreaGridHeight
                            let dayDifference = CGFloat(selectedRange.end.integerDate - selectedRange.start.integerDate)
                            let width = CGFloat(dayDifference + 1)
                            let position = CGFloat(selectedRange.start.integerDate - today.integerDate)
                            Rectangle()
                                .fill(Color.red.opacity(0.8))
                                .overlay(Rectangle().stroke(Color.blue, lineWidth: 1))
                                .frame(width: width * viewStore.gridWidth, height: height)
                                .position(x: (position + (width / 2) - CGFloat(viewStore.shiftedCol)) * viewStore.gridWidth, y: 100 + viewStore.lineAreaGridHeight / 2)
                        }
                        if let temporaryRange = temporarySelectedGridRange {
                            let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                            let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewStore.gridWidth
                            let isStartRowSmaller: Bool = temporaryRange.start.row <= temporaryRange.end.row
                            let isStartColSmaller: Bool = temporaryRange.start.col <= temporaryRange.end.col
                            Rectangle()
                                .fill(Color.gray.opacity(0.05))
                                .frame(width: width, height: height)
                                .position(x:
                                            isStartColSmaller ? CGFloat(temporaryRange.start.col - viewStore.shiftedCol) * viewStore.gridWidth + width / 2 :
                                            CGFloat(temporaryRange.end.col - viewStore.shiftedCol) * viewStore.gridWidth + width / 2,
                                          y:
                                            isStartRowSmaller ? CGFloat(temporaryRange.start.row) * viewStore.lineAreaGridHeight + height / 2 :
                                            CGFloat(temporaryRange.end.row) * viewStore.lineAreaGridHeight + height / 2)
                        }
                        if !viewStore.selectedGridRanges.isEmpty {
                            ForEach(viewStore.selectedGridRanges, id: \.self) { selectedRange in
                                let height = CGFloat((selectedRange.end.row - selectedRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                                let width = CGFloat((selectedRange.end.col - selectedRange.start.col).magnitude + 1) * viewStore.gridWidth
                                let isStartRowSmaller = selectedRange.start.row <= selectedRange.end.row
                                let isStartColSmaller = selectedRange.start.col <= selectedRange.end.col
                                Rectangle()
                                    .fill(Color.gray.opacity(0.05))
                                    .overlay(Rectangle().stroke(Color.blue, lineWidth: 1))
                                    .frame(width: width, height: height)
                                    .position(x: isStartColSmaller ? CGFloat(selectedRange.start.col - viewStore.shiftedCol) * viewStore.gridWidth + width / 2 :
                                                CGFloat(selectedRange.end.col - viewStore.shiftedCol) * viewStore.gridWidth + width / 2,
                                              y: isStartRowSmaller ? CGFloat(selectedRange.start.row - viewStore.shiftedRow) * viewStore.lineAreaGridHeight + height / 2 :
                                                CGFloat(selectedRange.end.row - viewStore.shiftedRow) * viewStore.lineAreaGridHeight + height / 2)
                            }
                        }
                    }
                    
                    if shouldDrawLine, let range = drawnRange {
                        let startY = CGFloat(range.start.row + 1) * viewStore.lineAreaGridHeight
                        let endY = CGFloat(range.end.row + 1) * viewStore.lineAreaGridHeight
                        let startX = CGFloat(range.start.col) * viewStore.gridWidth
                        let endX = CGFloat(range.end.col + 1) * viewStore.gridWidth
                        
                        let isHorizontalDrag = abs(endX - startX) > abs(endY - startY)
                        
                        if isHorizontalDrag {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: abs(endX - startX), height: 2)
                                .position(x: (startX + endX) / 2, y: startY) // 수평선을 드래그 시작점과 끝점의 중간점에 위치
                            
                            let startcenterX = startX
                            let centerX = endX
                            let centerY = startY
                            
                            Path { path in
                                let diamondSize: CGFloat = 10
                                
                                path.move(to: CGPoint(x: startcenterX, y: centerY - diamondSize / 2))
                                path.addLine(to: CGPoint(x: startcenterX + diamondSize / 2, y: centerY))
                                path.addLine(to: CGPoint(x: startcenterX, y: centerY + diamondSize / 2))
                                path.addLine(to: CGPoint(x: startcenterX - diamondSize / 2, y: centerY))
                                
                                path.move(to: CGPoint(x: centerX, y: centerY - diamondSize / 2))
                                path.addLine(to: CGPoint(x: centerX + diamondSize / 2, y: centerY))
                                path.addLine(to: CGPoint(x: centerX, y: centerY + diamondSize / 2))
                                path.addLine(to: CGPoint(x: centerX - diamondSize / 2, y: centerY))
                                path.closeSubpath()
                                
                            }
                            .fill(Color.purple)
                        } else {
                            let lineX = endX
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 2, height: abs(endY - startY))
                                .position(x: lineX, y: (startY + endY) / 2)
                            
                            let diamondX = lineX
                            let diamondY = endY
                            let startdiamondY = startY
                            
                            Path { path in
                                let diamondSize: CGFloat = 10
                                path.move(to: CGPoint(x: diamondX, y: startdiamondY - diamondSize / 2))
                                path.addLine(to: CGPoint(x: diamondX + diamondSize / 2, y: startdiamondY))
                                path.addLine(to: CGPoint(x: diamondX, y: startdiamondY + diamondSize / 2))
                                path.addLine(to: CGPoint(x: diamondX - diamondSize / 2, y: startdiamondY))
                                
                                path.move(to: CGPoint(x: diamondX, y: diamondY - diamondSize / 2))
                                path.addLine(to: CGPoint(x: diamondX + diamondSize / 2, y: diamondY))
                                path.addLine(to: CGPoint(x: diamondX, y: diamondY + diamondSize / 2))
                                path.addLine(to: CGPoint(x: diamondX - diamondSize / 2, y: diamondY))
                                path.closeSubpath()
                            }
                            .fill(Color.purple)
                        }
                    }
                    
                    //                    ForEach(viewStore.drawnLines) { line in
                    //
                    //                        Path { path in
                    //                            path.move(to: line.start)
                    //                            path.addLine(to: line.end)
                    //
                    //                        }
                    //                        .stroke(Color.black, lineWidth: 2)
                    //                    }
                }
                
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onChange(of: exceededDirection) { direction in
                    if temporarySelectedGridRange != nil {
                        switch direction {
                            case [true, false, false, false]:
                                viewStore.send(
                                    .dragExceeded(
                                        shiftedRow: 0,
                                        shiftedCol: -1,
                                        exceededRow: 0,
                                        exceededCol: -1
                                    )
                                )
                            case [false, true, false, false]:
                                viewStore.send(
                                    .dragExceeded(
                                        shiftedRow: 0,
                                        shiftedCol: 1,
                                        exceededRow: 0,
                                        exceededCol: 1
                                    )
                                )
                            case [false, false, true, false]:
                                viewStore.send(
                                    .dragExceeded(
                                        shiftedRow: -1,
                                        shiftedCol: 0,
                                        exceededRow: -1,
                                        exceededCol: 0
                                    )
                                )
                            case [false, false, false, true]:
                                viewStore.send(
                                    .dragExceeded(
                                        shiftedRow: 1,
                                        shiftedCol: 0,
                                        exceededRow: 1,
                                        exceededCol: 0
                                    )
                                )
                            default: break
                        }
                    }
                }
                .onChange(of: geometry.size) { newSize in
                    viewStore.send(.windowSizeChanged(newSize))
                }
                .onChange(of: [viewStore.gridWidth, viewStore.lineAreaGridHeight]) { _ in
                    viewStore.send(.gridSizeChanged(geometry.size))
                }
                .onContinuousHover { phase in
                    switch phase {
                        case .active(let location):
                            viewStore.send(.onContinuousHover(true, location))
                        case .ended:
                            viewStore.send(.onContinuousHover(false, nil))
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            /// local 뷰 기준 절대적인 드래그 시작점과 끝 점.
                            let dragStart = gesture.startLocation
                            let dragEnd = gesture.location
                            /// 드래그된 값을 기준으로 시작점과 끝점의 Row, Col 계산
                            let startRow = Int(dragStart.y / viewStore.lineAreaGridHeight)
                            let startCol = Int(dragStart.x / viewStore.gridWidth)
                            let endRow = Int(dragEnd.y / viewStore.lineAreaGridHeight)
                            let endCol = Int(dragEnd.x / viewStore.gridWidth)
                            /// 드래그 해서 화면 밖으로 나갔는지 Bool로 반환 (Left, Right, Top, Bottom)
                            ///
                            // 드래그 방향 판단 (수직 드래그인 경우)
                            let isVerticalDrag = abs(dragEnd.y - dragStart.y) > abs(dragEnd.x - dragStart.x)
                            
                            if isVerticalDrag {
                                let startY = min(dragStart.y, dragEnd.y)
                                let endY = max(dragStart.y, dragEnd.y)
                                let colX = dragEnd.x // 혹은 dragStart.x
                                
                                // 선의 끝점 계산 (오른쪽 끝)
                                let lineEndX = colX + viewStore.gridWidth
                                
                                // 다이아몬드의 위치 결정
                                let diamondY = (startY + endY) / 2 // 세로 방향 중앙
                                let diamondX = lineEndX + 10 // 선의 끝에서 오른쪽으로 10pt
                                
                                // 상태 변수 업데이트
                                self.drawLine = true
                                self.lineStart = CGPoint(x: colX, y: startY)
                                self.lineEnd = CGPoint(x: lineEndX, y: endY)
                                self.diamondPosition = CGPoint(x: diamondX, y: diamondY)
                            }
                            else{
                                let startX = min(dragStart.x, dragEnd.x)
                                let endX = max(dragStart.x, dragEnd.x)
                                let rowY = dragEnd.y // 혹은 dragStart.y
                                
                                // 상태 변수 업데이트
                                self.drawLine = true
                                self.lineStart = CGPoint(x: startX, y: rowY)
                                self.lineEnd = CGPoint(x: endX, y: rowY)
                                self.diamondPosition = CGPoint(x: (startX + endX) / 2, y: rowY - 10)
                            }
                            self.drawLine = true
                            
                            exceededDirection = [
                                dragEnd.x < 0,
                                dragEnd.x > geometry.size.width,
                                dragEnd.y < 0,
                                dragEnd.y > geometry.size.height
                            ]
                            if !viewStore.isCommandKeyPressed {
                                if !viewStore.isShiftKeyPressed {
                                    ///  selectedGridRanges을 초기화하고,  temporaryGridRange에 shifted된 값을 더한 값을 임시로 저장한다. 이 값은 onEnded상태에서 selectedGridRanges에 append 될 예정
                                    viewStore.send(.dragGestureChanged(.pressNothing, nil))
                                    temporarySelectedGridRange = nil
                                    temporarySelectedGridRange = SelectedGridRange(
                                        start: (startRow + viewStore.shiftedRow,
                                                startCol + viewStore.shiftedCol - viewStore.exceededCol),
                                        end: (endRow + viewStore.shiftedRow,
                                              endCol + viewStore.shiftedCol)
                                    )
                                } else {
                                    /// Shift가 클릭된 상태에서는, selectedGridRanges의 마지막 Range 끝 점의 Row, Col을 selectedGridRanges에 직접 담는다. 드래그 중에도 영역이 변하길 기대하기 때문.
                                    if let lastIndex = viewStore.selectedGridRanges.indices.last {
                                        var updatedRange = viewStore.selectedGridRanges[lastIndex]
                                        updatedRange.end.row = endRow + viewStore.shiftedRow
                                        updatedRange.end.col = endCol + viewStore.shiftedCol
                                        viewStore.send(.dragGestureChanged(.pressOnlyShift, updatedRange))
                                    }
                                }
                            } else {
                                if !viewStore.isShiftKeyPressed {
                                    /// Command가 클릭된 상태에서는 onEnded에서 append하게 될 temporarySelectedGridRange를 업데이트 한다.
                                    self.temporarySelectedGridRange = SelectedGridRange(
                                        start: (startRow + viewStore.shiftedRow, startCol + viewStore.shiftedCol),
                                        end: (endRow + viewStore.shiftedRow, endCol + viewStore.shiftedCol))
                                } else {
                                    /// Command와 Shift가 클릭된 상태에서는 selectedGridRanges의 마지막 Range의 끝점을 업데이트 해주어 selectedGridRanges에 직접 담는다. 드래그 중에도 영역이 변하길 기대하기 때문.
                                    if let lastIndex = viewStore.selectedGridRanges.indices.last {
                                        var updatedRange = viewStore.selectedGridRanges[lastIndex]
                                        updatedRange.end.row = endRow + viewStore.shiftedRow
                                        updatedRange.end.col = endCol + viewStore.shiftedCol
                                        viewStore.send(.dragGestureChanged(.pressOnlyCommand, updatedRange))
                                    }
                                }
                            }
                        }
                    
                        .onEnded { gesture in
                            viewStore.send(.dragGestureEnded(temporarySelectedGridRange))
                            
                            if temporarySelectedGridRange != nil {
                                drawnRange = temporarySelectedGridRange
                                shouldDrawLine = true
                                temporarySelectedGridRange = nil
                            }
                            
                            let newLine = DrawnLine(start: self.lineStart, end: self.lineEnd)
                            temporarySelectedGridRange = nil
                            exceededDirection = [false, false, false, false]
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            viewStore.send(.magnificationChangedInListArea(value, geometry.size))
                        }
                )
                
                
            }
        }
    }
}
