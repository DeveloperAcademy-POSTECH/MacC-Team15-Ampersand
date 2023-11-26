//
//  PlanBoardView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//

import SwiftUI
import ComposableArchitecture

struct PlanBoardView: View {
    @FocusState var listItemFocused: Bool
    @FocusState var planItemFocused: Bool

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.loadInProgress {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                        .onAppear { viewStore.send(.initializeState) }
                    Spacer()
                }
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    systemBorder(.horizontal)
                        .zIndex(5)
                    TopToolBarView(store: store)
                        .frame(height: 48)
                        .zIndex(5)
                    planBoardBorder(.horizontal)
                        .zIndex(5)
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
                            .frame(width: viewStore.listGridWidth * CGFloat(viewStore.map.count))
                            planBoardBorder(.vertical)
                        }
                        .zIndex(4)
                        .background(
                            Color.white
                                .shadow(color: .black.opacity(0.25), radius: 8, x: 4)
                        )
                        GeometryReader { _ in
                            VStack(alignment: .leading, spacing: 0) {
                                scheduleArea
                                    .frame(height: 143)
                                    .zIndex(2)
                                planBoardBorder(.horizontal)
                                timeAxisArea
                                    .frame(height: 48)
                                    .zIndex(3)
                                planBoardBorder(.horizontal)
                                lineArea
                                    .zIndex(-1)
                            }
                        }
                        if viewStore.isRightToolBarPresented {
                            RightToolBarView()
                                .frame(width: 240)
                                .zIndex(4)
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
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    Color.index
                    Path { path in
                        let maxRow = viewStore.maxLineAreaRow == 0 ? viewStore.defaultLineAreaRow : viewStore.maxLineAreaRow
                        for rowIndex in 1...maxRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight - viewStore.rowStroke / 2
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                    
                    if viewStore.hoveredItem == PlanBoardAreaName.lineIndexArea.rawValue {
                        if let hoveredRow = viewStore.lineIndexAreaHoveredCellRow {
                            Rectangle()
                                .fill(Color.itemHovered)
                                .frame(
                                    width: geometry.size.width,
                                    height: viewStore.lineAreaGridHeight - viewStore.rowStroke
                                )
                                .opacity(viewStore.selectedLineIndexRow == hoveredRow ? 0 : 1)
                                .position(
                                    x: geometry.size.width / 2,
                                    y: CGFloat(Double(hoveredRow) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke / 2
                                )
                                .onTapGesture {
                                    viewStore.send(.lineIndexAreaClicked(true))
                                }
                        }
                    }
                    if let clickedRow = viewStore.selectedLineIndexRow {
                        Rectangle()
                            .fill(Color.itemHovered)
                            .border(.blue)
                            .frame(
                                width: geometry.size.width,
                                height: viewStore.lineAreaGridHeight - viewStore.rowStroke
                            )
                            .position(
                                x: geometry.size.width / 2,
                                y: CGFloat(Double(clickedRow) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke / 2
                            )
                            .contextMenu {
                                Button("Clear this lane") {
                                    if viewStore.selectedLineIndexRow! < viewStore.map.last!.count {
                                        viewStore.send(.deleteLaneConents(
                                            rows: [viewStore.selectedLineIndexRow!, viewStore.selectedLineIndexRow!]
                                        ))
                                        viewStore.send(.lineIndexAreaClicked(false))
                                    }
                                }
                            }
                    }
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredLocation(.lineIndexArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredLocation(.lineIndexArea, false, nil))
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var blackPinkInYourArea: some View {
        Color.listItem
    }
}

extension PlanBoardView {
    var listControlArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.listArea
                HStack {
                    ForEach(0..<viewStore.map.count, id: \.self) { layerIndex in
                        VStack {
                            Spacer()
                            HStack(alignment: .center, spacing: 0) {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .overlay(
                                        Image(systemName: "chevron.left")
                                            .fontWeight(.bold)
                                            .foregroundStyle(viewStore.hoveredItem == .layerControlLeft + String(layerIndex) ? .red : .red.opacity(0.5))
                                            .opacity(viewStore.map.count > 1 ? 0 : 1)
                                    )
                                    .frame(width: 25)
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlLeft + String(layerIndex) : ""))
                                    }
                                    .onTapGesture {
                                        viewStore.send(.createLayerButtonClicked(layer: layerIndex))
                                    }
                                
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlButton + String(layerIndex) : ""))
                                    }
                                
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .overlay(
                                        Image(systemName: "chevron.right")
                                            .fontWeight(.bold)
                                            .foregroundStyle(viewStore.hoveredItem == .layerControlRight + String(layerIndex) ? .blue : .blue.opacity(0.5))
                                            .opacity(viewStore.map.count > 1 ? 0 : 1)
                                    )
                                    .frame(width: 25)
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlRight + String(layerIndex) : ""))
                                    }
                                    .onTapGesture {
                                        viewStore.send(.createLayerButtonClicked(layer: layerIndex + 1))
                                    }
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundStyle(viewStore.hoveredItem.contains("layerControl") && viewStore.hoveredItem.contains(String(layerIndex)) ?
                                                     Color.itemHovered : .item
                                    )
                            }
                            .contextMenu {
                                Button("Clear Layer") {
                                    viewStore.send(.deleteLayerContents(layer: layerIndex))
                                }
                                
                                Button("Delete Layer") {
                                    viewStore.send(.deleteLayer(layer: layerIndex))
                                }
                                .disabled(viewStore.map.count == 1)
                            }
                            .frame(height: 20)
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var listArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    Color.listArea
                    Path { path in
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                    
                    Path { path in
                        if viewStore.map.count > 1 {
                            let xLocation = geometry.size.width / 2
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.verticalLine, lineWidth: viewStore.columnStroke)
                    
                    let gridWidth = (geometry.size.width - viewStore.columnStroke * CGFloat(viewStore.map.count - 1)) / CGFloat(viewStore.map.count)
                    /// hover 되었을 때
                    if viewStore.hoveredItem == PlanBoardAreaName.listArea.rawValue {
                        if let hoveredRow = viewStore.listAreaHoveredCellRow,
                           let hoveredCol = viewStore.listAreaHoveredCellCol {
                            Rectangle()
                                .fill(Color.itemHovered)
                                .frame(
                                    width: gridWidth,
                                    height: viewStore.lineAreaGridHeight - viewStore.rowStroke
                                )
                                .position(
                                    x: gridWidth / 2 + (gridWidth + viewStore.columnStroke) * CGFloat(hoveredCol),
                                    y: CGFloat(Double(hoveredRow) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke / 2
                                )
                                .highPriorityGesture(TapGesture(count: 1).onEnded({
                                    // TODO: - click 시 선택되어 보이는 사각형, drag와 함께 작업
                                    viewStore.send(.lineIndexAreaClicked(false))
                                }))
                                .simultaneousGesture(TapGesture(count: 2).onEnded({
                                    listItemFocused = true
                                    viewStore.send(.listItemDoubleClicked(.listItem, false))
                                    viewStore.send(.listItemDoubleClicked(.emptyListItem, true))
                                    viewStore.send(.setHoveredLocation(.listArea, false, nil))
                                }))
                                .contextMenu {
                                    Button("Delete this Plan") {
                                        /// Dummy ListItem View에도 일관성을 주기 위한 버튼으로 아무 액션도 수행하지 않음
                                    }
                                }
                                .opacity((viewStore.selectedEmptyRow == hoveredRow) && (viewStore.selectedEmptyColumn == hoveredCol) ? 0 : 1)
                        }
                    }
                    
                    /// double click 되었을 때
                    if let columnOffset = viewStore.selectedEmptyColumn,
                       let rowOffset = viewStore.selectedEmptyRow {
                        Rectangle()
                            .fill(Color.clear)
                            .overlay(
                                TextField(
                                    "editing",
                                    text: viewStore.binding(
                                        get: \.keyword,
                                        send: { .keywordChanged($0) }
                                    )
                                )
                                .focused($listItemFocused)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 16)
                                .onSubmit {
                                    viewStore.send(.createPlanOnList(
                                        layer: viewStore.selectedEmptyColumn!,
                                        row: viewStore.selectedEmptyRow!,
                                        text: viewStore.keyword,
                                        colorCode: PlanType.emptyPlanType.colorCode
                                    ))
                                    viewStore.send(.listItemDoubleClicked(.emptyListItem, false))
                                }
                                    .onExitCommand {
                                        viewStore.send(.listItemDoubleClicked(.emptyListItem, false))
                                    }
                            )
                            .frame(width: viewStore.listGridWidth - viewStore.columnStroke / 2, height: viewStore.lineAreaGridHeight - viewStore.rowStroke * 2)
                            .position(
                                x: CGFloat(Double(columnOffset) + 0.5) * viewStore.listGridWidth - viewStore.columnStroke / 2,
                                y: CGFloat(Double(rowOffset) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke
                            )
                    }
                    /// map에 있는 정보
                    listMap
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredLocation(.listArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredLocation(.listArea, false, nil))
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var listMap: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                let gridWidth = (geometry.size.width - viewStore.columnStroke * CGFloat(viewStore.map.count - 1)) / CGFloat(viewStore.map.count)
                
                HStack(alignment: .top, spacing: viewStore.columnStroke) {
                    ForEach(0..<viewStore.map.count, id: \.self) { layerIndex in
                        let layer = viewStore.map[layerIndex]
                        VStack(alignment: .leading, spacing: viewStore.rowStroke) {
                            ForEach(layer.indices, id: \.self) { rowIndex in
                                let plan = viewStore.existingPlans[layer[rowIndex]] ?? Plan.mock
                                /// doubleClick 되었을 떄
                                if viewStore.selectedListRow == rowIndex && viewStore.selectedListColumn == layerIndex {
                                    Rectangle()
                                        .fill(Color.listArea)
                                        .overlay(
                                            TextField(
                                                "editing",
                                                text: viewStore.binding(
                                                    get: \.keyword,
                                                    send: { .keywordChanged($0) }
                                                )
                                            )
                                            .focused($listItemFocused)
                                            .multilineTextAlignment(.center)
                                            .textFieldStyle(.plain)
                                            .padding(.horizontal, 16)
                                            .onSubmit {
                                                viewStore.send(.updatePlanTypeOnList(
                                                    targetPlanID: layer[rowIndex],
                                                    text: viewStore.keyword,
                                                    colorCode: PlanType.emptyPlanType.colorCode
                                                ))
                                                viewStore.send(.listItemDoubleClicked(.listItem, false))
                                            }
                                                .onExitCommand {
                                                    viewStore.send(.listItemDoubleClicked(.listItem, false))
                                                }
                                        )
                                        .frame(height: viewStore.lineAreaGridHeight * CGFloat(plan.childPlanIDs.count) - viewStore.rowStroke)
                                } else {
                                    Rectangle()
                                        .fill(
                                            viewStore.listAreaHoveredCellCol == layerIndex && viewStore.listAreaHoveredCellRow == rowIndex ?
                                            Color.itemHovered : Color.listArea
                                        )
                                        .overlay {
                                            let planID = viewStore.map[layerIndex][rowIndex]
                                            let plan = viewStore.existingPlans[planID] ?? Plan.mock
                                            let planTypeID = plan.planTypeID
                                            let planType = viewStore.existingPlanTypes[planTypeID] ?? PlanType.emptyPlanType
                                            
                                            Text("\(planType.title)")
                                        }
                                        .highPriorityGesture(TapGesture(count: 1).onEnded({
                                            // TODO: - click 시 선택되어 보이는 사각형, drag와 함께 작업
                                            viewStore.send(.lineIndexAreaClicked(false))
                                        }))
                                        .simultaneousGesture(TapGesture(count: 2).onEnded({
                                            listItemFocused = true
                                            viewStore.send(.listItemDoubleClicked(.emptyListItem, false))
                                            viewStore.send(.listItemDoubleClicked(.listItem, true))
                                        }))
                                        .contextMenu {
                                            Button("Delete this Plan") {
                                                viewStore.send(.deletePlanOnList(layer: layerIndex, row: rowIndex))
                                            }
                                        }
                                        .frame(height: viewStore.lineAreaGridHeight * CGFloat(plan.childPlanIDs.count) - viewStore.rowStroke)
                                }
                            }
                            .frame(width: gridWidth)
                        }
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var scheduleArea: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            GeometryReader { _ in
                ZStack {
                    Color.lineArea
                }
                .background(Color.lineArea)
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredLocation(.scheduleArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredLocation(.none, false, nil))
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var timeAxisArea: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            GeometryReader { _ in
                HStack(alignment: .center, spacing: 0) {
                    ForEach(0..<viewStore.maxCol, id: \.self) { dayOffset in
                        let date = Calendar.current.date(
                            byAdding: .day,
                            value: dayOffset + viewStore.shiftedCol + viewStore.scrolledCol,
                            to: Date()
                        )!
                        let dateInfo = DateInfo(date: date, isHoliday: viewStore.holidays.contains(date))
                        VStack(alignment: .center, spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.boardSelectedBorder.opacity(0.8))
                                    .padding(2)
                                    .opacity("Month: \(dateInfo.month) + \(dayOffset)" == viewStore.hoveredItem ? 1 : 0)
                                Text("\(dateInfo.month)월")
                                    .foregroundStyle(dateInfo.month == viewStore.hoveredItem ? Color.white : Color.textInactive)
                                    .font(.title3)
                            }
                            .opacity(dateInfo.isFirstOfMonth || dayOffset == 0 ? 1 : 0)
                            .onHover { isHovered in
                                viewStore.send(.hoveredItem(name: isHovered ? "Month: \(dateInfo.month) + \(dayOffset)" : ""))
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.indexHovered)
                                    .padding(2)
                                    .opacity(dayOffset == viewStore.lineAreaHoveredCellCol ? 1 : 0)
                                    .opacity(viewStore.hoveredArea == .lineArea ? 1 : 0)
                                Text("\(dateInfo.day)")
                                    .foregroundColor(dateInfo.fontColor)
                                    .font(.body)
                                    .scaleEffect("Day: \(dayOffset)" == viewStore.hoveredItem ? 1.2 : 1)
                            }
                            .onHover { isHovered in
                                viewStore.send(.hoveredItem(name: isHovered ? "Day: \(dayOffset)" : ""))
                            }
                        }
                        .frame(width: viewStore.gridWidth)
                    }
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredLocation(.timeAxisArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredLocation(.none, false, nil))
                    }
                }
                .background(Color.lineArea)
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
}

extension PlanBoardView {
    var lineArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    ZStack {
                        shortcutButtons()
                        Color.lineArea
                        horizontalGrid(geometry: geometry)
                        verticalGrid(geometry: geometry)
                        hoveringRectangle()
                        hoveringVerticalRectangle(geometry: geometry)
                        planItem()
                        draggingRectangle()
                        draggedRectangle()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onReceive(timer) { _ in
                        if viewStore.exceededDirection.contains(true) {
                            viewStore.send(.onReceiveTimer)
                        }
                    }
                    .onAppear {
                        viewStore.send(.windowSizeChanged(geometry.size))
                    }
                    .onChange(of: geometry.size) { geometrySize in
                        viewStore.send(.windowSizeChanged(geometrySize))
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
                                viewStore.send(.dragGestureOnChanged(gesture))
                            }
                            .onEnded { _ in
                                viewStore.send(.dragGestureOnEnded)
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                viewStore.send(.magnificationChangedInListArea(value))
                            }
                    )
                    planItemEdit()
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
    }
    
    func shortcutButtons() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    if !viewStore.selectedGridRanges.isEmpty {
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
                    }
                } label: {
                    Text("create Plan")
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(viewStore.updatePlanTypePresented)
                
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
        }
    }
    
    func horizontalGrid(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Path { path in
                for rowIndex in 0..<viewStore.maxLineAreaRow {
                    let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight
                    path.move(to: CGPoint(x: 0, y: yLocation))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                }
            }
            .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
        }
    }
    
    func verticalGrid(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Path { path in
                for columnIndex in 0..<viewStore.maxCol {
                    let xLocation = CGFloat(columnIndex) * viewStore.gridWidth
                    path.move(to: CGPoint(x: xLocation, y: 0))
                    path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                }
            }
            .stroke(Color.verticalLine, lineWidth: viewStore.columnStroke)
        }
    }
    
    func hoveringRectangle() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Rectangle()
                .foregroundStyle(Color.hoveredCell.opacity(0.5))
                .frame(width: viewStore.gridWidth, height: viewStore.lineAreaGridHeight)
                .position(
                    x: CGFloat(viewStore.lineAreaHoveredCellCol) * viewStore.gridWidth + viewStore.gridWidth / 2,
                    y: CGFloat(viewStore.lineAreaHoveredCellRow) * viewStore.lineAreaGridHeight + viewStore.lineAreaGridHeight / 2
                )
                .opacity(viewStore.hoveredArea == .lineArea ? 1 : 0)
        }
    }
    
    func hoveringVerticalRectangle(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Rectangle()
                .foregroundStyle(Color.hoveredCell.opacity(0.5))
                .frame(width: viewStore.gridWidth, height: geometry.size.height)
                .position(
                    x: CGFloat(viewStore.timeAxisAreaHoveredCellCol) * viewStore.gridWidth + viewStore.gridWidth / 2,
                    y: geometry.size.height / 2
                )
                .opacity(viewStore.hoveredArea == .timeAxisArea ? 1 : 0)
        }
    }
    
    func planItem() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let today = Date().filteredDate.integerDate
            ForEach(viewStore.listMap.indices, id: \.self) { lineIndex in
                let plans = viewStore.listMap[lineIndex]
                ForEach(plans, id: \.self) { plan in
                    if let periods = plan.periods {
                        let selectedDateRanges = periods.map({ SelectedDateRange(start: $0.value[0], end: $0.value[1]) })
                        ForEach(selectedDateRanges, id: \.self) { selectedRange in
                            let plan: Plan = plan
                            let planType: PlanType = viewStore.existingPlanTypes[plan.planTypeID]!
                            let width = CGFloat(selectedRange.end.integerDate - selectedRange.start.integerDate + 1) * CGFloat(viewStore.gridWidth)
                            let height = viewStore.lineAreaGridHeight
                            let positionX = (CGFloat(selectedRange.start.integerDate - today) - CGFloat(viewStore.shiftedCol) - CGFloat(viewStore.scrolledCol)) * CGFloat(viewStore.gridWidth) + CGFloat(width * 0.5)
                            let positionY = (CGFloat(lineIndex) - CGFloat(viewStore.shiftedRow) - CGFloat(viewStore.scrolledRow)) * CGFloat(viewStore.lineAreaGridHeight) + CGFloat(height * 0.5)
                            let barHeight = height * 0.45
                            Rectangle()
                                .foregroundStyle(Color.clear)
                                .overlay(
                                    ZStack {
                                        HStack {
                                            Text(planType.title)
                                                .foregroundStyle(Color.title)
                                                .padding(.leading, 4)
                                                .frame(height: height * 0.5)
                                            Spacer()
                                        }
                                        .offset(y: -height * 0.25)
                                        RoundedRectangle(cornerRadius: height)
                                            .foregroundStyle(
                                                Color(hex: planType.colorCode)
                                                .opacity(0.9))
                                            .frame(height: barHeight)
                                            .offset(y: barHeight * 0.5)
                                            .scaleEffect(viewStore.clickedPlan == plan ? 1.03 : 1)
                                    }
                                )
                                .frame(width: width, height: height)
                                .position(x: positionX, y: positionY)
                                .onTapGesture(count: 2) {
                                    viewStore.send(.setCurrentModifyingPlan(plan.id))
                                    viewStore.send(.getRowIndexFromPlanID(plan.id))
                                    planItemFocused = true
                                }
                                .contextMenu {
                                    Button("Delete") {
                                        viewStore.send(.deletePlanOnLineWithID(planID: plan.id))
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    func draggingRectangle() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let temporaryRange = viewStore.temporarySelectedGridRange {
                let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewStore.gridWidth
                let positionX = CGFloat(min(temporaryRange.start.col, temporaryRange.end.col) - viewStore.shiftedCol - viewStore.scrolledCol) * CGFloat(viewStore.gridWidth) + CGFloat(width * 0.5)
                let positionY = CGFloat(min(temporaryRange.start.row, temporaryRange.end.row) - viewStore.shiftedRow - viewStore.scrolledRow) * CGFloat(viewStore.lineAreaGridHeight) + CGFloat(height * 0.5)
                Rectangle()
                    .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                    .frame(width: width, height: height)
                    .position(x: positionX, y: positionY)
            }
        }
    }
    
    func draggedRectangle() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if !viewStore.selectedGridRanges.isEmpty {
                ForEach(viewStore.selectedGridRanges, id: \.self) { selectedRange in
                    let height = CGFloat((selectedRange.end.row - selectedRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                    let width = CGFloat((selectedRange.end.col - selectedRange.start.col).magnitude + 1) * viewStore.gridWidth
                    let positionX = CGFloat(min(selectedRange.start.col, selectedRange.end.col) - viewStore.shiftedCol - viewStore.scrolledCol) * CGFloat(viewStore.gridWidth) + CGFloat(width * 0.5)
                    let positionY = CGFloat(min(selectedRange.start.row, selectedRange.end.row) - viewStore.shiftedRow - viewStore.scrolledRow) * CGFloat(viewStore.lineAreaGridHeight) + CGFloat(height * 0.5)
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .overlay(
                            Rectangle()
                                .stroke(Color.boardSelectedBorder, lineWidth: 1)
                        )
                        .frame(width: width, height: height)
                        .position(x: positionX, y: positionY)
                }
            }
        }
    }
    
    func planItemEdit() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.updatePlanTypePresented {
                let plan = viewStore.clickedPlan!
                if let firstPeriod = plan.periods?.first?.value {
                    let width = CGFloat(firstPeriod[1].integerDate - firstPeriod[0].integerDate + 1) * CGFloat(viewStore.gridWidth)
                    let height = viewStore.lineAreaGridHeight
                    let today = Date().filteredDate.integerDate
                    var row = viewStore.clickedPlanRow
                    let positionX = (CGFloat(firstPeriod[0].integerDate - today) - CGFloat(viewStore.shiftedCol) - CGFloat(viewStore.scrolledCol)) * CGFloat(viewStore.gridWidth) + CGFloat(width * 0.5)
                    let positionY = (CGFloat(row) - CGFloat(viewStore.shiftedRow) - CGFloat(viewStore.scrolledRow)) * CGFloat(viewStore.lineAreaGridHeight) + CGFloat(height * 0.5)
                    HStack {
                        TextField(
                            "Title",
                            text: viewStore.binding(
                                get: \.keyword,
                                send: { .keywordChanged($0) }
                            ),
                            onCommit: {
                                viewStore.send(.updatePlan)
                            }
                        )
                        .focused($planItemFocused)
                        .foregroundStyle(Color.title)
                        .padding(.leading, 4)
                        .frame(height: height * 0.5)
                        Spacer()
                        ColorPicker(
                            "",
                            selection: viewStore.binding(
                                get: \.selectedColorCode,
                                send: PlanBoard.Action.selectColorCode
                            )
                        )
                    }
                    .frame(width: width, height: height)
                    .position(x: positionX, y: positionY)
                    .offset(y: -height * 0.25)
                }
            } else {
                EmptyView()
            }
        }
    }
}
