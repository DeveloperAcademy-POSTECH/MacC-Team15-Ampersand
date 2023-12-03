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
                    TopToolBarView(store: store, selfView: self)
                        .frame(height: 48)
                        .zIndex(5)
                    planBoardBorder(.horizontal)
                        .zIndex(5)
                    HStack(alignment: .top, spacing: 0) {
                        HStack(alignment: .top, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                scheduleIndexArea
                                    .frame(height: 134)
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
                                    .frame(height: 134)
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
                                    .frame(height: 80)
                                    .zIndex(2)
                                planBoardBorder(.horizontal)
                                milestoneArea
                                    .frame(height: 53)
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
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                    /// hover되면 보이는 사각형
                    if let hoveredRow = viewStore.lineIndexAreaHoveredCellRow {
                        Rectangle()
                            .fill(Color.itemHovered.opacity(0.5))
                            .frame(
                                width: geometry.size.width,
                                height: viewStore.lineAreaGridHeight
                            )
                            .opacity(viewStore.hoveredArea == .lineIndexArea ? 1 : 0)
                            .position(
                                x: geometry.size.width / 2,
                                y: CGFloat(Double(hoveredRow) + 0.5) * viewStore.lineAreaGridHeight
                            )
                    }
                    /// drag중일 때 보이는 사각형
                    if viewStore.clickedArea == .lineIndexArea,
                        let temporaryRange = viewStore.temporarySelectedLineIndexRows {
                        let height = CGFloat((temporaryRange.last! - temporaryRange.first!).magnitude + 1) * viewStore.lineAreaGridHeight
                        let yPosition = CGFloat(temporaryRange.min()!) * viewStore.lineAreaGridHeight
                        Rectangle()
                            .foregroundStyle(Color.boardSelectedBorder.opacity(0.1))
                            .frame(width: geometry.size.width, height: height)
                            .position(x: geometry.size.width / 2, y: yPosition + height / 2)
                    }
                    /// drag가 끝나고 보이는 border있는 사각형
                    if viewStore.clickedArea == .lineIndexArea,
                        let selectedRange = viewStore.selectedLineIndexRows {
                        let height = CGFloat((selectedRange.last! - selectedRange.first!).magnitude + 1) * viewStore.lineAreaGridHeight
                        let yPosition = CGFloat(selectedRange.min()!) * viewStore.lineAreaGridHeight
                        Rectangle()
                            .foregroundStyle(Color.boardSelectedBorder.opacity(0.1))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.boardSelectedBorder, lineWidth: 1)
                            )
                            .frame(width: geometry.size.width, height: height)
                            .position(x: geometry.size.width / 2, y: yPosition + height / 2)
                            .contextMenu {
                                if let rows = viewStore.selectedLineIndexRows {
                                    Button("Clear lanes") {
                                        viewStore.send(.deleteLaneContents(rows: rows))
                                        viewStore.send(.setClickedArea(areaName: .none))
                                    }
                                    Button("Add a lane above") {
                                        // TODO: - create a lane on lineIndex
                                    }
                                    Button("Add a lane below") {
                                        // TODO: - create a lane on lineIndex
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
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            let dragEnd = gesture.location
                            let dragStart = gesture.startLocation
                            let startRow = Int(dragStart.y / viewStore.lineAreaGridHeight)
                            let endRow = Int(dragEnd.y / viewStore.lineAreaGridHeight)
                            
                            viewStore.send(.lineIndexDragGestureChanged(range: [startRow, endRow]))
                        }
                        .onEnded { _ in
                            viewStore.send(.setCurrentModifyingPlan("", nil))
                            viewStore.send(.setCurrentModifyingSchedule(""))
                            viewStore.send(.lineIndexDragGestureEnded)
                        }
                )
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
                                    .onTapGesture { viewStore.send(.listControlAreaClicked(layer: layerIndex)) }
                                
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
                                if viewStore.clickedArea == .listControlArea, 
                                    let layer = viewStore.selectedLayer, layer == layerIndex {
                                    RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(Color.blue)
                                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.itemHovered))
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundStyle(viewStore.hoveredItem.contains("layerControl") && viewStore.hoveredItem.contains(String(layerIndex)) ?
                                                         Color.itemHovered : .item
                                        )
                                }
                            }
                            .contextMenu {
                                Button("Clear Layer") {
                                    viewStore.send(.deleteLayerContents(layer: layerIndex))
                                    viewStore.send(.setClickedArea(areaName: .none))
                                }
                                
                                Button("Delete Layer") {
                                    viewStore.send(.deleteLayer(layer: layerIndex))
                                    viewStore.send(.setClickedArea(areaName: .none))
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
                    Button("deletePlanContents") {
                        if viewStore.clickedArea == .listArea, 
                            let ranges = viewStore.selectedListGridRanges {
                            viewStore.send(.deletePlanContents(ranges: ranges))
                            viewStore.send(.setClickedArea(areaName: .none))
                        }
                    }
                    .keyboardShortcut(.delete, modifiers: [])
                    
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
                    /// layer가 선택되었을 때
                    if viewStore.clickedArea == .listControlArea, 
                        let selectedLayer = viewStore.selectedLayer {
                        Rectangle()
                            .fill(Color.itemHovered.opacity(0.5))
                            .frame(
                                width: viewStore.listGridWidth,
                                height: geometry.size.height
                            )
                            .position(
                                x: CGFloat(Double(selectedLayer) + 0.5) * viewStore.listGridWidth,
                                y: geometry.size.height / 2
                            )
                    }
                    /// hover 되었을 때
                    if let hoveredRow = viewStore.listAreaHoveredCellRow,
                       let hoveredCol = viewStore.listAreaHoveredCellCol {
                        Rectangle()
                            .fill(Color.itemHovered.opacity(0.5))
                            .frame(
                                width: gridWidth,
                                height: viewStore.lineAreaGridHeight
                            )
                            .position(
                                x: gridWidth / 2 + (gridWidth + viewStore.columnStroke) * CGFloat(hoveredCol),
                                y: CGFloat(Double(hoveredRow) + 0.5) * viewStore.lineAreaGridHeight
                            )
                            .contextMenu {
                                /// Dummy ListItem View에도 일관성을 주기 위한 버튼으로 아무 액션도 수행하지 않음
                                Button("Delete this Plan") { }
                            }
                            .opacity(viewStore.hoveredArea == .listArea ? 1 : 0)
                    }
                    /// drag중일 때 보이는 사각형
                    if viewStore.clickedArea == .listArea, 
                        let temporaryRange = viewStore.temporarySelectedListGridRanges {
                        let height = CGFloat((temporaryRange.end.row - temporaryRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                        let width = CGFloat((temporaryRange.end.col - temporaryRange.start.col).magnitude + 1) * viewStore.listGridWidth
                        let xPosition = CGFloat(temporaryRange.minCol() - viewStore.shiftedCol - viewStore.scrolledCol) * viewStore.listGridWidth + width / 2
                        let yPosition = CGFloat(temporaryRange.minRow() - viewStore.shiftedRow - viewStore.scrolledRow) * viewStore.lineAreaGridHeight + height / 2
                        Rectangle()
                            .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                            .frame(width: width, height: height)
                            .position(x: xPosition, y: yPosition)
                    }
                    /// drag가 끝나고 보이는 border있는 사각형
                    if viewStore.clickedArea == .listArea, 
                        let selectedRanges = viewStore.selectedListGridRanges {
                        ForEach(selectedRanges, id: \.self) { selectedRange in
                            let height = CGFloat((selectedRange.end.row - selectedRange.start.row).magnitude + 1) * viewStore.lineAreaGridHeight
                            let width = CGFloat((selectedRange.end.col - selectedRange.start.col).magnitude + 1) * viewStore.listGridWidth
                            let xPosition = CGFloat(selectedRange.minCol()) * width + width / 2
                            let yPosition = CGFloat(selectedRange.minRow()) * viewStore.lineAreaGridHeight + height / 2
                            Rectangle()
                                .foregroundStyle(Color.boardSelectedBorder.opacity(0.05))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.boardSelectedBorder, lineWidth: 1)
                                )
                                .frame(width: width, height: height)
                                .position(x: xPosition, y: yPosition)
                        }
                    }
                    /// map에 있는 정보
                    listMap
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
                                    viewStore.send(.dismissTextFieldOnList)
                                }
                                .onExitCommand {
                                    viewStore.send(.dismissTextFieldOnList)
                                }
                            )
                        // TODO: - 높이 수정
                            .frame(
                                width: viewStore.listGridWidth - viewStore.columnStroke / 2,
                                height: viewStore.lineAreaGridHeight - viewStore.rowStroke * 2
                            )
                            .position(
                                x: CGFloat(Double(columnOffset) + 0.5) * viewStore.listGridWidth - viewStore.columnStroke / 2,
                                y: CGFloat(Double(rowOffset) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke
                            )
                    }
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredLocation(.listArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredLocation(.listArea, false, nil))
                    }
                }
                .highPriorityGesture(TapGesture(count: 2).onEnded({
                    listItemFocused = true
                    viewStore.send(.setCurrentModifyingPlan("", nil))
                    viewStore.send(.setCurrentModifyingSchedule(""))
                    viewStore.send(.listItemDoubleClicked)
                    viewStore.send(.setHoveredLocation(.none, false, nil))
                }))
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            let dragEnd = gesture.location
                            let dragStart = gesture.startLocation
                            let startRow = Int(dragStart.y / viewStore.lineAreaGridHeight)
                            let startCol = Int(dragStart.x / viewStore.listGridWidth)
                            let endRow = Int(dragEnd.y / viewStore.lineAreaGridHeight)
                            let endCol = Int(min(dragEnd.x, geometry.size.width - 1) / viewStore.listGridWidth)
                            let newRange = SelectedGridRange(
                                start: (startRow + viewStore.shiftedRow + viewStore.scrolledRow - viewStore.exceededRow,
                                        startCol + viewStore.shiftedCol + viewStore.scrolledCol - viewStore.exceededCol),
                                end: (endRow + viewStore.shiftedRow + viewStore.scrolledRow,
                                      endCol + viewStore.shiftedCol + viewStore.scrolledCol)
                            )
                            viewStore.send(.setHoveredLocation(.none, false, nil))
                            viewStore.send(.listDragGestureChanged(cmdPressed: viewStore.isCommandKeyPressed, range: newRange))
                        }
                        .onEnded { _ in
                            viewStore.send(.setCurrentModifyingPlan("", nil))
                            viewStore.send(.setCurrentModifyingSchedule(""))
                            viewStore.send(.listDragGestureEnded)
                        }
                )
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
                                                viewStore.send(.updatePlanTypeOnList(
                                                    targetPlanID: layer[rowIndex],
                                                    text: viewStore.keyword,
                                                    colorCode: PlanType.emptyPlanType.colorCode
                                                ))
                                                viewStore.send(.dismissTextFieldOnList)
                                            }
                                            .onExitCommand { viewStore.send(.dismissTextFieldOnList) }
                                        )
                                        .frame(height: viewStore.lineAreaGridHeight * CGFloat(plan.childPlanIDs.count) - viewStore.rowStroke)
                                } else {
                                    ZStack(alignment: .topLeading) {
                                        Rectangle()
                                            .fill(
                                                viewStore.listMapHoveredCellCol == layerIndex && viewStore.listMapHoveredCellRow == rowIndex ?
                                                Color.itemHovered.opacity(0.5) : Color.clear
                                            )
                                        VStack {
                                            Circle()
                                                .fill(.clear)
                                                .overlay(
                                                    Image(systemName: "chevron.up")
                                                        .padding(2)
                                                        .foregroundStyle(viewStore.isCreateOnTopHovered ? .red : .red.opacity(0.5))
                                                )
                                                .onHover { isHovered in
                                                    viewStore.send(.createPlanButtonHovered(button: .createPlanOnTopButton, hovered: isHovered))
                                                }
                                                .onTapGesture {
                                                    // TODO: - Add Plan On List
                                                }
                                            Spacer()
                                            Circle()
                                                .fill(.clear)
                                                .overlay(
                                                    Image(systemName: "chevron.down")
                                                        .padding(2)
                                                        .foregroundStyle(viewStore.isCreateAtBottomHovered ? .blue : .blue.opacity(0.5))
                                                )
                                                .onHover { isHovered in
                                                    viewStore.send(.createPlanButtonHovered(button: .createPlanAtBottomButton, hovered: isHovered))
                                                }
                                                .onTapGesture {
                                                    // TODO: - Add Plan On List
                                                }
                                        }
                                        .background {
                                            RoundedRectangle(cornerRadius: 16)
                                                .backgroundStyle(Color.item.opacity(0.3))
                                        }
                                        .opacity(viewStore.listMapHoveredCellCol == layerIndex && viewStore.listMapHoveredCellRow == rowIndex ? 1: 0)
                                        .frame(width: 16)
                                        .padding(2)
                                    }
                                    .overlay {
                                        let planID = viewStore.map[layerIndex][rowIndex]
                                        let plan = viewStore.existingPlans[planID] ?? Plan.mock
                                        let planTypeID = plan.planTypeID
                                        let planType = viewStore.existingPlanTypes[planTypeID] ?? PlanType.emptyPlanType
                                        
                                        Text("\(planType.title)")
                                            .opacity(viewStore.selectedListRow == rowIndex && viewStore.selectedListColumn == layerIndex ? 0 : 1)
                                    }
                                    .onContinuousHover { phase in
                                        switch phase {
                                        case .active:
                                            viewStore.send(.setHoveredListItem(areaName: .listArea, row: rowIndex, column: layerIndex))
                                        case .ended:
                                            viewStore.send(.setHoveredListItem(areaName: .none, row: nil, column: nil))
                                        }
                                    }
                                    .contextMenu {
                                        Button("Delete this Plan") {
                                            viewStore.send(.deletePlanOnList(layer: layerIndex, row: rowIndex))
                                            viewStore.send(.setClickedArea(areaName: .none))
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
    var milestoneArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
