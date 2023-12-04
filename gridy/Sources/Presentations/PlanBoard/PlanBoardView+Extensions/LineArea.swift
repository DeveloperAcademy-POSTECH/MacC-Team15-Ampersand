//
//  LineArea.swift
//  gridy
//
//  Created by 제나 on 12/2/23.
//

import SwiftUI
import ComposableArchitecture

extension PlanBoardView {
    var lineArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    HStack {
                        if !viewStore.selectedGridRanges.isEmpty {
                            Button {
                                let today = Date().filteredDate
                                let lastRange = viewStore.selectedGridRanges.last!
                                let startDate = min(
                                    Calendar.current.date(
                                        byAdding: .day,
                                        value: lastRange.start.col,
                                        to: today
                                    )!.filteredDate,
                                    Calendar.current.date(
                                        byAdding: .day,
                                        value: lastRange.end.col,
                                        to: today
                                    )!.filteredDate
                                )
                                let endDate = max(
                                    Calendar.current.date(
                                        byAdding: .day,
                                        value: lastRange.start.col,
                                        to: today
                                    )!.filteredDate,
                                    Calendar.current.date(
                                        byAdding: .day,
                                        value: lastRange.end.col,
                                        to: today
                                    )!.filteredDate
                                )
                                let row = min(lastRange.start.row, lastRange.end.row)
                                viewStore.send(.createPlanOnLine(row: row, startDate: startDate, endDate: endDate))
                            } label: {
                                Text("create plan")
                            }
                            .keyboardShortcut(.return, modifiers: [])
                        }
                        
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
                            viewStore.send(.escapeAll)
                        } label: { }
                        .keyboardShortcut(.escape, modifiers: [])
                        Button {
                            viewStore.send(.magnificationChangedInListArea(1.05, geometry.size))
                        } label: { }
                            .keyboardShortcut("+", modifiers: [.command])
                        Button {
                            viewStore.send(.magnificationChangedInListArea(0.95, geometry.size))
                        } label: { }
                            .keyboardShortcut("-", modifiers: [.command])
                        if !viewStore.selectedGridRanges.isEmpty {
                            Button {
                                viewStore.send(.deletePlanOnLineWithRanges)
                            } label: { }
                                .keyboardShortcut(.delete, modifiers: [])
                        }
                    }
                    Color.lineArea
                    Path { path in
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                    Path { path in
                        for columnIndex in 0..<viewStore.maxCol {
                            let xLocation = CGFloat(columnIndex) * viewStore.gridWidth
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.verticalLine, lineWidth: viewStore.columnStroke)
                    
                    ZStack {
                        /// lineArea에 hover될 때 나타나는 뷰
                        Rectangle()
                            .foregroundStyle(Color.hoveredCell.opacity(0.5))
                            .frame(width: viewStore.gridWidth, height: viewStore.lineAreaGridHeight)
                            .position(
                                x: CGFloat(viewStore.lineAreaHoveredCellCol) * viewStore.gridWidth + viewStore.gridWidth / 2,
                                y: CGFloat(viewStore.lineAreaHoveredCellRow) * viewStore.lineAreaGridHeight + viewStore.lineAreaGridHeight / 2
                            )
                            .opacity(viewStore.hoveredArea == .lineArea ? 1 :0)
                        /// timeAxisArea에 hover될 때 나타나는 뷰
                        Rectangle()
                            .foregroundStyle(Color.hoveredCell.opacity(0.5))
                            .frame(width: viewStore.gridWidth, height: geometry.size.height)
                            .position(
                                x: CGFloat(viewStore.timeAxisAreaHoveredCellCol) * viewStore.gridWidth + viewStore.gridWidth / 2,
                                y: geometry.size.height / 2
                            )
                            .opacity(viewStore.hoveredArea == .timeAxisArea ? 1 : 0)
                        
                        if let lineIndexAreaHoveredCellRow = viewStore.lineIndexAreaHoveredCellRow {
                            Rectangle()
                                .foregroundStyle(Color.hoveredCell.opacity(0.5))
                                .frame(width: geometry.size.width * 2, height: viewStore.lineAreaGridHeight)
                                .position(
                                    x: 0,
                                    y: CGFloat(lineIndexAreaHoveredCellRow) * viewStore.lineAreaGridHeight + viewStore.lineAreaGridHeight / 2
                                )
                                .opacity(viewStore.hoveredArea == .lineIndexArea ? 1 : 0)
                        }
                        
                        planItems(geometry: geometry)
                        
                        if viewStore.clickedArea == .lineArea,
                           let temporaryRange = viewStore.temporarySelectedGridRange {
                            let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                            let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewStore.gridWidth
                            let xPosition = CGFloat(temporaryRange.minCol() - viewStore.shiftedCol - viewStore.scrolledCol) * viewStore.gridWidth + width / 2
                            let yPosition = CGFloat(temporaryRange.minRow() - viewStore.shiftedRow - viewStore.scrolledRow) * viewStore.lineAreaGridHeight + height / 2
                            Rectangle()
                                .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                                .frame(
                                    width: width,
                                    height: height
                                )
                                .position(
                                    x: xPosition,
                                    y: yPosition
                                )
                        }
                        if viewStore.clickedArea == .lineArea && !viewStore.selectedGridRanges.isEmpty {
                            ForEach(viewStore.selectedGridRanges, id: \.self) { selectedRange in
                                let height = CGFloat((selectedRange.end.row - selectedRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                                let width = CGFloat((selectedRange.end.col - selectedRange.start.col).magnitude + 1) * viewStore.gridWidth
                                let xPosition = CGFloat(Int(selectedRange.minCol()) - Int(viewStore.shiftedCol) - Int(viewStore.scrolledCol)) * viewStore.gridWidth + width / 2
                                let yPosition = (CGFloat(selectedRange.minRow()) - CGFloat(viewStore.shiftedRow) - CGFloat(viewStore.scrolledRow)) * CGFloat(viewStore.lineAreaGridHeight) + CGFloat(height / 2)
                                Rectangle()
                                    .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.boardSelectedBorder, lineWidth: 1)
                                    )
                                    .frame(
                                        width: width,
                                        height: height
                                    )
                                    .position(x: xPosition, y: yPosition)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onReceive(timer) { _ in
                    onReceiveTimer(viewStore: viewStore)
                }
                .onAppear {
                    viewStore.send(.windowSizeChanged(geometry.size))
                }
                .onChange(of: geometry.size) {
                    viewStore.send(.windowSizeChanged($0))
                }
                .onChange(of: [viewStore.gridWidth, viewStore.lineAreaGridHeight]) { _ in
                    viewStore.send(.gridSizeChanged(geometry.size))
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredLocation(.lineArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredLocation(.none, false, nil))
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
                            /// 드래그 해서 화면 밖으로 나갔는지 Bool로 반환 (Left, Right, Top, Bottom)
                            let exceededDirection = [
                                dragEnd.x < 0,
                                dragEnd.x > geometry.size.width,
                                dragEnd.y < 0,
                                dragEnd.y > geometry.size.height
                            ]
                            viewStore.send(.setExceededDirection(exceededDirection))
                            if !viewStore.isCommandKeyPressed {
                                if !viewStore.isShiftKeyPressed {
                                    ///  selectedGridRanges을 초기화하고,  temporaryGridRange에 shifted된 값을 더한 값을 임시로 저장한다. 이 값은 onEnded상태에서 selectedGridRanges에 append 될 예정
                                    let temporarySelectedGridRange = SelectedGridRange(
                                        start: (startRow + viewStore.shiftedRow + viewStore.scrolledRow - viewStore.exceededRow,
                                                startCol + viewStore.shiftedCol + viewStore.scrolledCol - viewStore.exceededCol),
                                        end: (endRow + viewStore.shiftedRow + viewStore.scrolledRow,
                                              endCol + viewStore.shiftedCol + viewStore.scrolledCol)
                                    )
                                    viewStore.send(.dragGestureChanged(.pressNothing, temporarySelectedGridRange))
                                } else {
                                    /// Shift가 클릭된 상태에서는, selectedGridRanges의 마지막 Range 끝 점의 Row, Col을 selectedGridRanges에 직접 담는다. 드래그 중에도 영역이 변하길 기대하기 때문.
                                    if let lastIndex = viewStore.selectedGridRanges.indices.last {
                                        var updatedRange = viewStore.selectedGridRanges[lastIndex]
                                        updatedRange.end.row = endRow + viewStore.shiftedRow + viewStore.scrolledRow
                                        updatedRange.end.col = endCol + viewStore.shiftedCol + viewStore.scrolledCol
                                        viewStore.send(.dragGestureChanged(.pressOnlyShift, updatedRange))
                                    }
                                }
                            } else {
                                if !viewStore.isShiftKeyPressed {
                                    /// Command가 클릭된 상태에서는 onEnded에서 append하게 될 temporarySelectedGridRange를 업데이트 한다.
                                    let temporarySelectedGridRange = SelectedGridRange(
                                        start: (startRow + viewStore.shiftedRow + viewStore.scrolledRow - viewStore.exceededRow,
                                                startCol + viewStore.shiftedCol + viewStore.scrolledCol - viewStore.exceededCol),
                                        end: (endRow + viewStore.shiftedRow + viewStore.scrolledRow,
                                              endCol + viewStore.shiftedCol + viewStore.scrolledCol)
                                    )
                                    viewStore.send(.dragGestureChanged(.pressOnlyCommand, temporarySelectedGridRange))
                                } else {
                                    /// Command와 Shift가 클릭된 상태에서는 selectedGridRanges의 마지막 Range의 끝점을 업데이트 해주어 selectedGridRanges에 직접 담는다. 드래그 중에도 영역이 변하길 기대하기 때문.
                                    if let lastIndex = viewStore.selectedGridRanges.indices.last {
                                        var updatedRange = viewStore.selectedGridRanges[lastIndex]
                                        updatedRange.end.row = endRow + viewStore.shiftedRow + viewStore.scrolledRow
                                        updatedRange.end.col = endCol + viewStore.shiftedCol + viewStore.scrolledCol
                                        viewStore.send(.dragGestureChanged(.pressBoth, updatedRange))
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            viewStore.send(.escapeSelectedCell)
                            viewStore.send(.setCurrentModifyingSchedule(""))
                            viewStore.send(.dragGestureEnded)
                            viewStore.send(.setExceededDirection([false, false, false, false]))
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            viewStore.send(.magnificationChangedInListArea(value, geometry.size))
                        }
                )
            }
            .background(Color.lineArea)
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    viewStore.send(.scrollGesture(event))
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                    viewStore.send(.isShiftKeyPressed(event.modifierFlags.contains(.shift)))
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                    viewStore.send(.isCommandKeyPressed(event.modifierFlags.contains(.command)))
                    return event
                }
            }
        }
    }
    
    func planItems(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let today = Date().filteredDate.integerDate
            ForEach(viewStore.listMap.indices, id: \.self) { lineIndex in
                let plans = viewStore.listMap[lineIndex]
                ForEach(plans, id: \.self) { plan in
                    if let periods = plan.periods {
                        let selectedDateRanges = periods.map({
                            SelectedDateRange(
                                start: $0.value[0],
                                end: $0.value[1]
                            )
                        })
                        ForEach(selectedDateRanges, id: \.self) { selectedRange in
                            let plan: Plan = plan
                            var isUpdatePlanTypePresented: Binding<Bool> {
                                Binding(
                                    get: { viewStore.updatePlanTypePresented
                                        && viewStore.currentModifyingPlanID == plan.id
                                        && viewStore.currentModifyingPlanPeriod == selectedRange },
                                    set: { newValue in
                                        viewStore.send(.popoverPresent(
                                            button: .updatePlanTypeButton,
                                            bool: newValue
                                        ))
                                    }
                                )
                            }
                            let isBeingModified = viewStore.currentModifyingPlanID == plan.id && viewStore.currentModifyingPlanPeriod == selectedRange
                            let planType: PlanType = viewStore.existingPlanTypes[plan.planTypeID]!
                            let height = viewStore.lineAreaGridHeight * 0.5
                            let dayDifference = CGFloat(selectedRange.end.integerDate - selectedRange.start.integerDate)
                            let width = CGFloat(dayDifference + 1)
                            let widthInHalf = CGFloat(width / 2)
                            // TODO: - 축소, 확대할 때 선이 안맞는 버그가 있습니다 보정 필요 (지금 하드코딩한 보정값)
                            let correctionValue = CGFloat(viewStore.lineAreaGridHeight / 2) + 10
                            let position = CGFloat(selectedRange.start.integerDate - today)
                            let negativeShiftedRow = -viewStore.shiftedRow - viewStore.scrolledRow
                            ZStack {
                                if let previewRange = viewStore.previewGridRange,
                                   isBeingModified,
                                   viewStore.currentModifyingPlanPeriod == selectedRange {
                                    let previewWidth = CGFloat(previewRange.end.integerDate - previewRange.start.integerDate + 1)
                                    let offsetValue = (viewStore.showPreviewLeading ? width - previewWidth : previewWidth - width) * CGFloat(viewStore.gridWidth) / CGFloat(2)
                                    RoundedRectangle(cornerRadius: CGFloat(viewStore.lineAreaGridHeight * 0.5))
                                        .foregroundStyle(Color(hex: planType.colorCode).opacity(0.3))
                                        .frame(
                                            width: previewWidth * CGFloat(viewStore.gridWidth),
                                            height: height
                                        )
                                        .offset(
                                            x: offsetValue
                                        )
                                }
                                RoundedRectangle(cornerRadius: viewStore.lineAreaGridHeight * 0.5)
                                    .fill(Color(hex: planType.colorCode)
                                    .opacity(viewStore.isDragging && isBeingModified ? 0.5 : 0.7))
                                    .overlay(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: viewStore.lineAreaGridHeight * 0.5)
                                                .stroke(Color.white.opacity(isBeingModified ? 1 : 0.8), lineWidth: isBeingModified ? 2 : 1)
                                            if isBeingModified,
                                               viewStore.currentModifyingPlanPeriod == selectedRange {
                                                Button {
                                                    viewStore.send(.deletePlanOnLine)
                                                } label: { }
                                                    .keyboardShortcut(.delete, modifiers: [])
                                                    .opacity(0)
                                                HStack {
                                                    Circle()
                                                        .foregroundStyle(Color.white.opacity(0.01))
                                                        .overlay(
                                                            HalfCircleShapeLeft()
                                                                .stroke(lineWidth: 6)
                                                                .scaleEffect(0.6)
                                                        )
                                                        .gesture(DragGesture()
                                                            .onChanged({ value in
                                                                let currentX = value.location.x
                                                                let prevX = value.startLocation.x
                                                                let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                                let modifiedDate = Calendar.current.date(
                                                                    byAdding: .day,
                                                                    value: Int(countMovedLocation),
                                                                    to: selectedRange.start
                                                                )!
                                                                if modifiedDate > selectedRange.end { return }
                                                                viewStore.send(.dragToPreview(
                                                                    SelectedDateRange(
                                                                        start: modifiedDate,
                                                                        end: selectedRange.end
                                                                    ),
                                                                    showLeading: true
                                                                ))
                                                            })
                                                                .onEnded({ value in
                                                                    viewStore.send(.setCurrentModifyingSchedule(""))
                                                                    viewStore.send(.escapeSelectedCell)
                                                                    let currentX = value.location.x
                                                                    let prevX = value.startLocation.x
                                                                    let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                                    let modifiedDate = Calendar.current.date(
                                                                        byAdding: .day,
                                                                        value: Int(countMovedLocation),
                                                                        to: selectedRange.start
                                                                    )!
                                                                    if modifiedDate > selectedRange.end { return }
                                                                    viewStore.send(.setCurrentModifyingPlan(
                                                                        plan.id,
                                                                        SelectedDateRange(
                                                                            start: modifiedDate,
                                                                            end: selectedRange.end
                                                                        )
                                                                    ))
                                                                    viewStore.send(.dragToPreview(nil, showLeading: false))
                                                                    viewStore.send(.dragToChangePeriod(
                                                                        planID: plan.id,
                                                                        originPeriod: [selectedRange.start, selectedRange.end],
                                                                        updatedPeriod: [modifiedDate, selectedRange.end]
                                                                    ))
                                                                })
                                                        )
                                                    Spacer()
                                                    Circle()
                                                        .foregroundStyle(Color.white.opacity(0.01))
                                                        .overlay(
                                                            HalfCircleShapeRight()
                                                                .stroke(lineWidth: 6)
                                                                .scaleEffect(0.6)
                                                        )
                                                        .gesture(DragGesture()
                                                            .onChanged({ value in
                                                                let currentX = value.location.x
                                                                let prevX = value.startLocation.x
                                                                let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                                let modifiedDate = Calendar.current.date(
                                                                    byAdding: .day,
                                                                    value: Int(countMovedLocation),
                                                                    to: selectedRange.end
                                                                )!
                                                                if modifiedDate < selectedRange.start { return }
                                                                viewStore.send(.dragToPreview(
                                                                    SelectedDateRange(
                                                                        start: selectedRange.start,
                                                                        end: modifiedDate
                                                                    ),
                                                                    showLeading: false
                                                                ))
                                                            })
                                                                .onEnded({ value in
                                                                    viewStore.send(.setCurrentModifyingSchedule(""))
                                                                    viewStore.send(.escapeSelectedCell)
                                                                    let currentX = value.location.x
                                                                    let prevX = value.startLocation.x
                                                                    let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                                    let modifiedDate = Calendar.current.date(
                                                                        byAdding: .day,
                                                                        value: Int(countMovedLocation),
                                                                        to: selectedRange.end
                                                                    )!
                                                                    if modifiedDate < selectedRange.start { return }
                                                                    viewStore.send(.setCurrentModifyingPlan(
                                                                        plan.id,
                                                                        SelectedDateRange(
                                                                            start: selectedRange.start,
                                                                            end: modifiedDate
                                                                        )
                                                                    ))
                                                                    viewStore.send(.dragToPreview(nil, showLeading: false))
                                                                    viewStore.send(.dragToChangePeriod(
                                                                        planID: plan.id,
                                                                        originPeriod: [selectedRange.start, selectedRange.end],
                                                                        updatedPeriod: [selectedRange.start, modifiedDate]
                                                                    ))
                                                                })
                                                        )
                                                }
                                            }
                                        }
                                    )
                                    .offset(isBeingModified ? viewStore.dragOffset : CGSize.zero)
                                    .frame(
                                        width: width * CGFloat(viewStore.gridWidth),
                                        height: height
                                    )
                                    .shadow(
                                        color: .black.opacity(isBeingModified ? 0.8 : 0),
                                        radius: 6,
                                        x: 8,
                                        y: 8
                                    )
                                
                                Text(planType.title)
                                    .foregroundStyle(Color.white)
                                    .padding(.bottom, 45)
                                    .offset(x: -width * viewStore.gridWidth / 2 + viewStore.gridWidth / 2)
                            }
                            .contextMenu {
                                Button {
                                    viewStore.send(.deletePlanOnLine)
                                } label: {
                                    Text("Delete")
                                }
                                .keyboardShortcut(.delete, modifiers: [])
                                .opacity(0)
                            }
                            .popover(
                                isPresented: isUpdatePlanTypePresented,
                                attachmentAnchor: .point(.trailing),
                                arrowEdge: .trailing
                            ) {
                                VStack {
                                    HStack(spacing: 20) {
                                        TextField(
                                            "제목을 입력하세요",
                                            text: viewStore.binding(
                                                get: \.keyword,
                                                send: { .keywordChanged($0) }
                                            )
                                        )
                                        ColorPicker(
                                            "color",
                                            selection: viewStore.binding(
                                                get: \.selectedColorCode,
                                                send: PlanBoard.Action.selectColorCode
                                            )
                                        )
                                    }
                                    Button {
                                        viewStore.send(.updatePlan)
                                    } label: {
                                        Text("확인")
                                    }
                                    .keyboardShortcut(.return, modifiers: [])
                                }
                                .padding()
                                .frame(width: 250, height: 80)
                            }
                            .frame(width: width * CGFloat(viewStore.gridWidth), height: height)
                            .position(
                                x: (CGFloat(position) - CGFloat(viewStore.shiftedCol) - CGFloat(viewStore.scrolledCol) + widthInHalf) * CGFloat(viewStore.gridWidth),
                                y: CGFloat(Int(negativeShiftedRow) + Int(lineIndex)) * CGFloat(viewStore.lineAreaGridHeight) + CGFloat(correctionValue)
                            )
                            .highPriorityGesture(TapGesture(count: 1).onEnded({
                                viewStore.send(.setCurrentModifyingSchedule(""))
                                viewStore.send(.escapeSelectedCell)
                                viewStore.send(.setCurrentModifyingPlan(plan.id, selectedRange))
                                viewStore.send(.popoverPresent(button: .rightToolBarButton, bool: true))
                            }))
                            .simultaneousGesture(TapGesture(count: 2).onEnded({
                                viewStore.send(.setCurrentModifyingSchedule(""))
                                viewStore.send(.escapeSelectedCell)
                                viewStore.send(.modifyPlanType(plan.id, selectedRange))
                            }))
                            .gesture(DragGesture()
                                .onChanged({ gesture in
                                    if !isBeingModified { return }
                                    viewStore.send(.dragChanged(gesture.translation))
                                })
                                    .onEnded({ value in
                                        if !isBeingModified { return }
                                        viewStore.send(.dragEnded)
                                        viewStore.send(.setCurrentModifyingSchedule(""))
                                        viewStore.send(.escapeSelectedCell)
                                        let currentX = value.location.x
                                        let prevX = value.startLocation.x
                                        let countMovedLocationX = (currentX - prevX) / viewStore.gridWidth
                                        let modifiedStartDate = Calendar.current.date(
                                            byAdding: .day,
                                            value: Int(countMovedLocationX),
                                            to: selectedRange.start
                                        )!
                                        let modifiedEndDate = Calendar.current.date(
                                            byAdding: .day,
                                            value: Int(countMovedLocationX),
                                            to: selectedRange.end
                                        )!
                                        let currentY = value.location.y
                                        let prevY = value.startLocation.y
                                        let countMovedLocationY = (currentY - prevY) / viewStore.lineAreaGridHeight
                                        if countMovedLocationY == 0 { return }
                                        viewStore.send(.dragToMovePlanInLine(
                                            lineIndex + Int(countMovedLocationY),
                                            plan.id,
                                            [selectedRange.start, selectedRange.end],
                                            [modifiedStartDate, modifiedEndDate])
                                        )
                                    })
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func onReceiveTimer(viewStore: ViewStoreOf<PlanBoard>) {
        switch viewStore.exceededDirection {
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
        case [true, false, true, false]:
            viewStore.send(
                .dragExceeded(
                    shiftedRow: -1,
                    shiftedCol: -1,
                    exceededRow: -1,
                    exceededCol: -1
                )
            )
        case [true, false, false, true]:
            viewStore.send(
                .dragExceeded(
                    shiftedRow: 1,
                    shiftedCol: -1,
                    exceededRow: 1,
                    exceededCol: -1
                )
            )
        case [false, true, true, false]:
            viewStore.send(
                .dragExceeded(
                    shiftedRow: -1,
                    shiftedCol: 1,
                    exceededRow: -1,
                    exceededCol: 1
                )
            )
        case [false, true, false, true]:
            viewStore.send(
                .dragExceeded(
                    shiftedRow: 1,
                    shiftedCol: 1,
                    exceededRow: 1,
                    exceededCol: 1
                )
            )
        default:
            break
        }
    }
}

struct HalfCircleShapeLeft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = rect.height / 2.0
        let center = CGPoint(x: rect.minX + radius, y: rect.midY)
        
        path.addArc(center: center, radius: radius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: -90), clockwise: false)
        
        return path
    }
}

struct HalfCircleShapeRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = rect.height / 2.0
        let center = CGPoint(x: rect.minX + radius, y: rect.midY)
        
        path.addArc(center: center, radius: radius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: -90), clockwise: true)
        
        return path
    }
}
