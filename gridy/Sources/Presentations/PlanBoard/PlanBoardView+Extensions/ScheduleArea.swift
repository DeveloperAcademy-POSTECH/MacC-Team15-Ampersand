//
//  ScheduleArea.swift
//  gridy
//
//  Created by 제나 on 12/2/23.
//

import SwiftUI
import ComposableArchitecture

extension PlanBoardView {
    var scheduleArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    scheduleShortcutButtons()
                    Color.lineArea
                    scheduleVerticalGrid(geometry: geometry)
                    scheduleHoveringRectangle(geometry: geometry)
                    scheduleDraggingRectangle(geometry: geometry)
                    scheduleDraggedRectangle(geometry: geometry)
                    scheduleItem(geometry: geometry)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredLocation(.scheduleArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredLocation(.none, false, nil))
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            let dragEnd = gesture.location
                            let dragStart = gesture.startLocation
                            let startCol = Int(dragStart.x / viewStore.gridWidth)
                            let endCol = Int(dragEnd.x / viewStore.gridWidth)
                            
                            let exceededDirection = [
                                dragEnd.x < 0,
                                dragEnd.x > geometry.size.width
                            ]
                            let newRange = SelectedScheduleRange(
                                startCol: startCol + viewStore.shiftedCol + viewStore.scrolledCol - viewStore.exceededCol,
                                endCol: endCol + viewStore.shiftedCol + viewStore.scrolledCol
                            )
                            viewStore.send(.setExceededScheduleDirection(exceededDirection))
                            viewStore.send(.dragGestureChangedSchedule(.pressNothing, newRange))
                        }
                        .onEnded { _ in
                            viewStore.send(.setCurrentModifyingPlan("", nil))
                            viewStore.send(.dragGestureEndedSchedule)
                            viewStore.send(.setExceededScheduleDirection([false, false]))
                        }
                )
            }
            .onAppear { viewStore.send(.initializeState) }
        }
    }
    
    func scheduleShortcutButtons() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    if !viewStore.selectedScheduleRanges.isEmpty {
                        let today = Date().filteredDate
                        let scheduleRangeToCreate = viewStore.selectedScheduleRanges.last!
                        let start = min(scheduleRangeToCreate.startCol, scheduleRangeToCreate.endCol)
                        let end = max(scheduleRangeToCreate.startCol, scheduleRangeToCreate.endCol)
                        
                        if let startDay = Calendar.current.date(byAdding: .day, value: start, to: today)?.filteredDate,
                           let endDay = Calendar.current.date(byAdding: .day, value: end, to: today)?.filteredDate {
                            viewStore.send(.createSchedule(startDate: startDay, endDate: endDay))
                        }
                    }
                } label: {
                    Text("create Schedule")
                }
                .keyboardShortcut("u", modifiers: [])
            }
        }
    }
    
    func scheduleVerticalGrid(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Path { path in
                for columnIndex in 0..<viewStore.maxCol {
                    let xLocation = CGFloat(columnIndex) * viewStore.gridWidth - viewStore.columnStroke
                    path.move(to: CGPoint(x: xLocation, y: 0))
                    path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                }
            }
            .stroke(Color.verticalLine, lineWidth: viewStore.columnStroke)
        }
    }
    
    func scheduleHoveringRectangle(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Rectangle()
                .foregroundStyle(Color.hoveredCell.opacity(0.5))
                .frame(width: viewStore.gridWidth, height: geometry.size.height)
                .position(
                    x: CGFloat(viewStore.scheduleAreaHoveredCellCol) * viewStore.gridWidth + viewStore.gridWidth / 2,
                    y: geometry.size.height / 2
                )
                .opacity(viewStore.hoveredArea == .scheduleArea ? 1 : 0)
        }
    }
    
    func scheduleDraggingRectangle(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.clickedArea == .scheduleArea,
                let temporaryRange = viewStore.temporarySelectedScheduleRange {
                let width = CGFloat((temporaryRange.endCol - temporaryRange.startCol).magnitude + 1) * viewStore.gridWidth
                let isStartColSmaller = temporaryRange.startCol <= temporaryRange.endCol
                Rectangle()
                    .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                    .frame(width: width, height: geometry.size.height)
                    .position(
                        x: isStartColSmaller ?
                        CGFloat(temporaryRange.startCol - viewStore.shiftedCol - viewStore.scrolledCol) * viewStore.gridWidth + width / 2 :
                            CGFloat(temporaryRange.endCol - viewStore.shiftedCol - viewStore.scrolledCol) * viewStore.gridWidth + width / 2,
                        y: geometry.size.height / 2
                    )
            }
        }
    }
    
    func scheduleDraggedRectangle(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.clickedArea == .scheduleArea && !viewStore.selectedScheduleRanges.isEmpty {
                ForEach(viewStore.selectedScheduleRanges, id: \.self) { selectedScheduleRange in
                    let width = CGFloat((selectedScheduleRange.endCol - selectedScheduleRange.startCol).magnitude + 1) * viewStore.gridWidth
                    let isStartColSmaller = selectedScheduleRange.startCol <= selectedScheduleRange.endCol
                    Rectangle()
                        .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                        .overlay(
                            Rectangle()
                                .stroke(Color.boardSelectedBorder, lineWidth: 1)
                        )
                        .frame(width: width, height: geometry.size.height)
                        .position(
                            x: isStartColSmaller ?
                            CGFloat(selectedScheduleRange.startCol - viewStore.shiftedCol - viewStore.scrolledCol) * viewStore.gridWidth + width / 2 :
                                CGFloat(selectedScheduleRange.endCol - viewStore.shiftedCol - viewStore.scrolledCol) * viewStore.gridWidth + width / 2,
                            y: geometry.size.height / 2
                        )
                }
            }
        }
    }
    
    func scheduleItem(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ForEach(viewStore.scheduleMap.indices, id: \.self) { scheduleRowIndex in
                let scheduleRow = viewStore.scheduleMap[scheduleRowIndex]
                ForEach(scheduleRow, id: \.self) { scheduleID in
                    var isUpdateSchedulePresented: Binding<Bool> {
                        Binding(
                            get: { viewStore.updateSchedulePresented && viewStore.currentModifyingScheduleID == scheduleID },
                            set: { newValue in
                                viewStore.send(.popoverPresent(
                                    button: .updateScheduleButton,
                                    bool: newValue
                                ))
                            }
                        )
                    }
                    if let schedule = viewStore.existingSchedules[scheduleID] {
                        let today = Date().filteredDate
                        let dayDifference = CGFloat(schedule.endDate.integerDate - schedule.startDate.integerDate)
                        let width = CGFloat(dayDifference + 1)
                        let position = CGFloat(schedule.startDate.integerDate - today.integerDate)
                        
                        ZStack {
                            if let previewRange = viewStore.previewScheduleRange,
                               viewStore.currentModifyingScheduleID == scheduleID {
                                let previewWidth = CGFloat(previewRange.end.integerDate - previewRange.start.integerDate + 1)
                                let offsetValue = (viewStore.showPreviewScheduleLeading ? width - previewWidth : previewWidth - width) * CGFloat(viewStore.gridWidth) / CGFloat(2)
                                RoundedRectangle(cornerRadius: CGFloat(viewStore.lineAreaGridHeight * 0.5))
                                    .foregroundStyle(Color(hex: schedule.colorCode).opacity(0.2))
                                    .frame(
                                        width: previewWidth * CGFloat(viewStore.gridWidth),
                                        height: 19
                                    )
                                    .offset(
                                        x: offsetValue
                                    )
                            }
                            RoundedRectangle(cornerRadius: 19 * 0.5)
                                .foregroundStyle(Color(hex: schedule.colorCode).opacity(0.4))
                                .frame(
                                    width: width * viewStore.gridWidth,
                                    height: 19
                                )
                                .overlay(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 19 * 0.5)
                                            .stroke(Color.white, lineWidth: 1)
                                        if viewStore.currentModifyingScheduleID == scheduleID {
                                            HStack {
                                                Circle()
                                                    .gesture(DragGesture()
                                                        .onChanged({ value in
                                                            let currentX = value.location.x
                                                            let prevX = value.startLocation.x
                                                            let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                            let modifiedDate = Calendar.current.date(
                                                                byAdding: .day,
                                                                value: Int(countMovedLocation),
                                                                to: schedule.startDate
                                                            )!
                                                            if modifiedDate > schedule.endDate { return }
                                                            viewStore.send(.dragToPreviewSchedule(
                                                                SelectedDateRange(
                                                                    start: modifiedDate,
                                                                    end: schedule.endDate
                                                                ),
                                                                showLeading: true
                                                            ))
                                                        })
                                                        .onEnded({ value in
                                                            viewStore.send(.setCurrentModifyingPlan("", nil))
                                                            let currentX = value.location.x
                                                            let prevX = value.startLocation.x
                                                            let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                            let modifiedDate = Calendar.current.date(
                                                                byAdding: .day,
                                                                value: Int(countMovedLocation),
                                                                to: schedule.startDate
                                                            )!
                                                            if modifiedDate > schedule.endDate { return }
                                                            viewStore.send(.dragToPreviewSchedule(nil, showLeading: false))
                                                            viewStore.send(.updateScheduleDate(
                                                                scheduleID: scheduleID,
                                                                originPeriod: [schedule.startDate, schedule.endDate],
                                                                updatedPeriod: [modifiedDate, schedule.endDate]
                                                            ))
                                                        })
                                                    )
                                                Spacer()
                                                Circle()
                                                    .gesture(DragGesture()
                                                        .onChanged({ value in
                                                            let currentX = value.location.x
                                                            let prevX = value.startLocation.x
                                                            let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                            let modifiedDate = Calendar.current.date(
                                                                byAdding: .day,
                                                                value: Int(countMovedLocation),
                                                                to: schedule.endDate
                                                            )!
                                                            if modifiedDate < schedule.startDate { return }
                                                            viewStore.send(.dragToPreviewSchedule(
                                                                SelectedDateRange(
                                                                    start: schedule.startDate,
                                                                    end: modifiedDate
                                                                ),
                                                                showLeading: false
                                                            ))
                                                        })
                                                        .onEnded({ value in
                                                            viewStore.send(.setCurrentModifyingPlan("", nil))
                                                            let currentX = value.location.x
                                                            let prevX = value.startLocation.x
                                                            let countMovedLocation = (currentX - prevX) / viewStore.gridWidth
                                                            let modifiedDate = Calendar.current.date(
                                                                byAdding: .day,
                                                                value: Int(countMovedLocation),
                                                                to: schedule.endDate
                                                            )!
                                                            if modifiedDate < schedule.startDate { return }
                                                            viewStore.send(.dragToPreviewSchedule(nil, showLeading: false))
                                                            viewStore.send(.updateScheduleDate(
                                                                scheduleID: scheduleID,
                                                                originPeriod: [schedule.startDate, schedule.endDate],
                                                                updatedPeriod: [schedule.startDate, modifiedDate]
                                                            ))
                                                        })
                                                    )
                                            }
                                        }
                                    }
                                )
                            
                            Text(schedule.title ?? "")
                                .foregroundStyle(Color.white)
                                .offset(x: -width * viewStore.gridWidth / 2 + viewStore.gridWidth)
                        }
                        .popover(
                            isPresented: isUpdateSchedulePresented,
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
                                    viewStore.send(.updateSchedule)
                                } label: {
                                    Text("확인")
                                }
                            }
                            .padding()
                            .frame(width: 250, height: 80)
                        }
                        .frame(width: width * viewStore.gridWidth)
                        .position(
                            x: (position - CGFloat(viewStore.shiftedCol) - CGFloat(viewStore.scrolledCol) + (width / 2)) * viewStore.gridWidth,
                            y: CGFloat(geometry.size.height - 19/2 - 3) - CGFloat(scheduleRowIndex * 23)
                        )
                        .highPriorityGesture(TapGesture(count: 1).onEnded({
                            viewStore.send(.setCurrentModifyingPlan("", nil))
                            viewStore.send(.setCurrentModifyingSchedule(scheduleID))
                        }))
                        .simultaneousGesture(TapGesture(count: 2).onEnded({
                            viewStore.send(.setCurrentModifyingPlan("", nil))
                            viewStore.send(.editSchedule(scheduleID))
                        }))
                        .gesture(DragGesture()
                            .onEnded({ value in
                                viewStore.send(.setCurrentModifyingPlan("", nil))
                                let currentX = value.location.x
                                let prevX = value.startLocation.x
                                let countMovedLocationX = (currentX - prevX) / viewStore.gridWidth
                                let modifiedStartDate = Calendar.current.date(
                                    byAdding: .day,
                                    value: Int(countMovedLocationX),
                                    to: schedule.startDate
                                )!
                                let modifiedEndDate = Calendar.current.date(
                                    byAdding: .day,
                                    value: Int(countMovedLocationX),
                                    to: schedule.endDate
                                )!
                                viewStore.send(.updateScheduleDate(
                                    scheduleID: scheduleID,
                                    originPeriod: [schedule.startDate, schedule.endDate],
                                    updatedPeriod: [modifiedStartDate, modifiedEndDate]
                                ))
                            })
                        )
                        .contextMenu {
                            Button("Delete") {
                                viewStore.send(.deleteSchedule(scheduleID: scheduleID))
                            }
                        }
                    }
                }
            }
        }
    }
}
