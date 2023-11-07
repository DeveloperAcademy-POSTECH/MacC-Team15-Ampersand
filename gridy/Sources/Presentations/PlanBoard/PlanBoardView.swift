//
//  PlanBoardView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//

import SwiftUI
import ComposableArchitecture

struct PlanBoardView: View {
    @State private var temporarySelectedGridRange: SelectedGridRange?
    @State private var exceededDirection = [false, false, false, false]
    @State private var timer: Timer?
        
    let store: StoreOf<PlanBoard>
    let tabID: String
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                systemBorder(.horizontal)
                TopToolBarView(store: store, tabID: tabID)
                    .frame(height: 48)
                    .zIndex(4)
                planBoardBorder(.horizontal)
                HStack(alignment: .top, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            scheduleIndexArea
                                .frame(height: 143)
                            planBoardBorder(.horizontal)
                            extraArea
                                .frame(height: 48)
                            planBoardBorder(.horizontal)
                            lineIndexArea
                        }
                        .frame(width: 20)
                        planBoardBorder(.vertical)
                        VStack(alignment: .leading, spacing: 0) {
                            blackPinkInYourArea
                                .frame(height: 143)
                            planBoardBorder(.horizontal)
                            listControlArea
                                .frame(height: 48)
                            planBoardBorder(.horizontal)
                            listArea
                        }
                        .frame(width: 150)
                        planBoardBorder(.vertical)
                    }
                    .zIndex(3)
                    .background(
                        Color.white
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 4)
                    )
                    GeometryReader { _ in
                        VStack(alignment: .leading, spacing: 0) {
                            scheduleArea
                                .frame(height: 143)
                                .zIndex(0)
                            planBoardBorder(.horizontal)
                            timeAxisArea
                                .frame(height: 48)
                                .zIndex(2)
                            planBoardBorder(.horizontal)
                            lineArea
                                .zIndex(1)
                        }
                        .background(Color.lineArea)
                    }
                    if viewStore.isRightToolBarPresented {
                        RightToolBarView()
                            .frame(width: 240)
                            .zIndex(3)
                            .background(
                                Color.white
                                    .shadow(color: .black.opacity(0.25), radius: 8, x: -4)
                            )
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var scheduleIndexArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var extraArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var lineIndexArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var blackPinkInYourArea: some View {
        Color.listItem
    }
}

extension PlanBoardView {
    var listControlArea: some View {
        Color.listItem
    }
}

extension PlanBoardView {
    var listArea: some View {
        Color.list
    }
}

extension PlanBoardView {
    var scheduleArea: some View {
        Color.lineArea
    }
}

extension PlanBoardView {
    var timeAxisArea: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: 0) {
                    ForEach(0..<viewStore.maxCol, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset + viewStore.shiftedCol, to: Date())!
                        let dateInfo = DateInfo(date: date, isHoliday: viewStore.holidays.contains(date))
                        VStack(alignment: .center, spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.boardSelectedBorder.opacity(0.8))
                                    .padding(2)
                                    .opacity("Month: \(dateInfo.month)" == viewStore.hoveredItem ? 1 : 0)
                                Text("\(dateInfo.month)월")
                                    .foregroundStyle(dateInfo.month == viewStore.hoveredItem ? Color.white : Color.textInactive)
                                    .font(.title3)
                            }
                            .opacity(dateInfo.isFirstOfMonth || dayOffset == 0 ? 1 : 0)
                            .onHover { isHovered in
                                viewStore.send(.hoveredItem(name: isHovered ? "Month: \(dateInfo.month)" : ""))
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.indexHovered)
                                    .padding(2)
                                    .opacity(dayOffset == viewStore.hoveringCellCol ? 1 : 0)
                                    .opacity(viewStore.isHovering ? 1 : 0)
                                Text("\(dateInfo.day)")
                                    .foregroundColor(dateInfo.fontColor)
                                    .font(.body)
                                    .scaleEffect("Day: \(dateInfo.day)" == viewStore.hoveredItem ? 1.2 : 1)
                            }
                            .onHover { isHovered in
                                viewStore.send(.hoveredItem(name: isHovered ? "Day: \(dateInfo.day)" : ""))
                            }
                        }
                        .frame(width: viewStore.gridWidth)
                    }
                }
            }
            .onAppear {
                // TODO: holiday를 비동기 작업으로 받아오는 로직을 TCA로 변경할 것
//                Task {
//                    do {
//                        let fetchedHolidays = try await fetchKoreanHolidays()
//                        viewStore.holidays = fetchedHolidays
//                    } catch {
//                        print("오류 발생: \(error.localizedDescription)")
//                    }
//                }
            }
        }
    }
}

extension PlanBoardView {
    var lineArea: some View {
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
                                viewStore.send(.createPlan(
                                    // TODO: - Need arguments #1, #2
                                    layer: 1,
                                    row: 0,
                                    target: Plan(
                                        id: "",
                                        parentLaneID: nil, // TODO: - root layer가 아니라면 parentLaneID 필요
                                        periods: [:],
                                        laneIDs: []
                                    ),
                                    startDate: startDate,
                                    endDate: endDate
                                ))
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
                    
                    Path { path in
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight - viewStore.rowStroke
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                    Path { path in
                        for columnIndex in 0..<viewStore.maxCol {
                            let xLocation = CGFloat(columnIndex) * viewStore.gridWidth - viewStore.columnStroke
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.verticalLine, lineWidth: viewStore.columnStroke)
                    
//                    /// VECTORMODE
//                    LinearGradient(colors: [Color.white.opacity(0.1), Color.clear], startPoint: .topLeading, endPoint: .trailing)
                    
                    ZStack {
                            Rectangle()
                                .foregroundStyle(Color.hoveredCell.opacity(0.5))
                                .frame(width: viewStore.gridWidth, height: viewStore.lineAreaGridHeight)
                                .position(x:
                                            CGFloat(viewStore.hoveringCellCol) * viewStore.gridWidth + viewStore.gridWidth / 2,
                                          y:
                                            CGFloat(viewStore.hoveringCellRow) * viewStore.lineAreaGridHeight + viewStore.lineAreaGridHeight / 2
                                )
                        ForEach(viewStore.selectedDateRanges, id: \.self) { selectedRange in
                            let today = Date().filteredDate
                            let height = viewStore.lineAreaGridHeight * 0.5 - 4
                            let dayDifference = CGFloat(selectedRange.end.integerDate - selectedRange.start.integerDate)
                            let width = CGFloat(dayDifference + 1)
                            let position = CGFloat(selectedRange.start.integerDate - today.integerDate)
                            RoundedRectangle(cornerRadius: viewStore.lineAreaGridHeight * 0.5)
                                .foregroundStyle(Color.boardSelectedBorder.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: viewStore.lineAreaGridHeight * 0.5)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                                .frame(width: width * viewStore.gridWidth, height: height)
                                .position(x: (position + (width / 2) - CGFloat(viewStore.shiftedCol)) * viewStore.gridWidth, y: 100 + viewStore.lineAreaGridHeight / 2)
                        }
                        if let temporaryRange = temporarySelectedGridRange {
                            let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                            let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewStore.gridWidth
                            let isStartRowSmaller: Bool = temporaryRange.start.row <= temporaryRange.end.row
                            let isStartColSmaller: Bool = temporaryRange.start.col <= temporaryRange.end.col
                            Rectangle()
                                .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
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
                                    .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.boardSelectedBorder, lineWidth: 1)
                                    )
                                    .frame(width: width, height: height)
                                    .position(x: isStartColSmaller ? CGFloat(selectedRange.start.col - viewStore.shiftedCol) * viewStore.gridWidth + width / 2 :
                                                CGFloat(selectedRange.end.col - viewStore.shiftedCol) * viewStore.gridWidth + width / 2,
                                              y: isStartRowSmaller ? CGFloat(selectedRange.start.row - viewStore.shiftedRow) * viewStore.lineAreaGridHeight + height / 2 :
                                                CGFloat(selectedRange.end.row - viewStore.shiftedRow) * viewStore.lineAreaGridHeight + height / 2)
                            }
                        }
                
                    }
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
                .onAppear {
                    viewStore.send(.windowSizeChanged(geometry.size))
                }
                .onChange(of: geometry.size) { newSize in
                    viewStore.send(.windowSizeChanged(newSize))
                }
                .onChange(of: [viewStore.gridWidth, viewStore.lineAreaGridHeight]) { _ in
                    // TODO: - Action에서 처리해야 될 것 같은데
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
                            let dragEnd = gesture.location
                            let dragStart = gesture.startLocation
                            /// 드래그된 값을 기준으로 시작점과 끝점의 Row, Col 계산
                            let startRow = Int(dragStart.y / viewStore.lineAreaGridHeight)
                            let startCol = Int(dragStart.x / viewStore.gridWidth)
                            let endRow = Int(dragEnd.y / viewStore.lineAreaGridHeight)
                            let endCol = Int(dragEnd.x / viewStore.gridWidth)
                            viewStore.send(.onContinuousHover(true, dragEnd))
                            /// 드래그 해서 화면 밖으로 나갔는지 Bool로 반환 (Left, Right, Top, Bottom)
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
                        .onEnded { _ in
                            viewStore.send(.dragGestureEnded(temporarySelectedGridRange))
                            if temporarySelectedGridRange != nil {
                                temporarySelectedGridRange = nil
                            }
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
