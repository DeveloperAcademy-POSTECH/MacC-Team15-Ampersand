//
//  PlanBoard.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import SwiftUI
import ComposableArchitecture

enum LineAreaDragType {
    case pressNothing /// no command, no shift
    case pressOnlyShift
    case pressOnlyCommand
    case pressBoth
}

struct PlanBoard: Reducer {
    
    @Dependency(\.apiService) var apiService
    
    struct State: Equatable {
        var rootProject: Project
        var rootPlan: Plan
        var map: [[String]]
        var searchPlanTypesResult = [PlanType]()
        var existingPlanTypes = [String: PlanType]()
        var existingAllPlans = [String: Plan]()
        
        var keyword = ""
        var selectedColorCode = Color.red
        
        /// ScheduleArea의 Row 갯수로, 나중에는 View의 크기에 따라 max갯수를 계산시키는 로직으로 변경되면서 maxScheduleAreaRow라는 변수가 될 예정입니다.
        var numOfScheduleAreaRow = 5
        
        /// 그리드 Path의 두께를 결정합니다. Line Area, ScheduleArea에서 따르고 있으며, ListArea는 별도의 Stroke를 가질 것으로 생각됩니다.
        var columnStroke = CGFloat(0.1)
        var rowStroke = CGFloat(0.5)
        
        /// 그리드의 사이즈에 대한 변수들입니다. RightToolBarArea에서 변수를 조정할 수 있습니다. Magnificationn과 min/maxSIze는 사용자가 확대했을 때 최대 최소 크기를 지정하기 위해 필요한 제한 값입니다.
        let minGridSize = CGFloat(20)
        let maxGridSize = CGFloat(70)
        var gridWidth = CGFloat(45)
        var scheduleAreaGridHeight = CGFloat(45)
        var lineAreaGridHeight = CGFloat(45)
        // TODO: - 나중에 추가될 코드 ... 헨리가 뭔가 준비만 해뒀다고 했음!
        //        var horizontalMagnification = CGFloat(1.0)
        //         var verticalMagnification = CGFloat(1.0)
        
        /// LineArea의 local 영역에서 마우스가 호버링 된 위치의 셀정보를 담습니다. 아직은 RightToolBarArea에서 확인용으로만 사용하고 있습니다.
        var hoverLocation: CGPoint = .zero
        var hoveringCellRow = 0
        var hoveringCellCol = 0
        var isHovering = false
        
        /// 선택된 영역을 배열로 담습니다. selectedDateRange는 Plan생성 API가 들어오면 삭제될 변수입니다.
        var selectedGridRanges: [SelectedGridRange] = []
        var selectedDateRanges: [SelectedDateRange] = []
        
        /// 뷰의 GeometryReader값의 변화에 따라 Max 그리드 갯수가 변호합니다.
        var maxLineAreaRow = 0
        var maxCol = 0
        
        /// 뷰가 움직인 크기를 나타내는 변수입니다.
        var shiftedRow = 0
        var shiftedCol = 0
        
        /// 마우스로 드래그 할 때 화면 밖으로 벗어난 치수를 담고있는 변수입니다만, 현재 shiftedRow/Col과 역할이 비슷하여 하나로 합치는 것을 고려 중입니다.
        var exceededRow = 0
        var exceededCol = 0
        
        /// NSEvent로 받아온 Shift와 Command 눌린 상태값입니다.
        var isShiftKeyPressed = false
        var isCommandKeyPressed = false
        
        // MARK: - list area
        var showingLayers = [0]
        var showingRows = 20
        var listColumnWidth: [Int: [CGFloat]] = [0: [266.0], 1: [266.0], 2: [132.0, 132.0], 3: [24.0, 119.0, 119.0]]
    }
    
    enum Action: Equatable {
        // MARK: - user action
        case onAppear
        case selectColorCode(Color)
        
        // MARK: - plan type
        case createPlanType(layer: Int, row: Int, text: String, colorCode: UInt)
        case updatePlanType(layer: Int, row: Int, text: String, colorCode: UInt)
        
        // MARK: - plan
        case createPlanOnList(layer: Int, row: Int, text: String)
        case createPlanOnLine(layer: Int, row: Int, startDate: Date, endDate: Date)
        case updatePlan(planID: String, planTypeID: String)
        
        case shiftSelectedCell(rowOffset: Int, colOffset: Int)
        case shiftToToday
        case escapeSelectedCell
        
        // MARK: - TimelineLayout
        case isShiftKeyPressed(Bool)
        case isCommandKeyPressed(Bool)
        
        // MARK: - GridSizeController
        case changeWidthButtonTapped(CGFloat)
        case changeHeightButtonTapped(CGFloat)
        
        // MARK: - ScheduleAreaView
        case magnificationChangedInScheduleArea(CGFloat)
        
        // MARK: - LineAreaView
        case dragExceeded(shiftedRow: Int, shiftedCol: Int, exceededRow: Int, exceededCol: Int)
        case windowSizeChanged(CGSize)
        case gridSizeChanged(CGSize)
        case onContinuousHover(Bool, CGPoint?)
        case dragGestureChanged(LineAreaDragType, SelectedGridRange?)
        case dragGestureEnded(SelectedGridRange?)
        case magnificationChangedInListArea(CGFloat, CGSize)
        
        // MARK: - list area
        case showUpperLayer
        case showLowerLayer
        case createLayerBtnClicked(layer: Int)
        case deleteLayer(layer: Int)
        case deleteLayerText(layer: Int)
        
        // MARK: - map
        case fetchMap
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                // MARK: - user action
            case .onAppear:
                // TODO: - 삭제
                state.existingAllPlans = [state.rootPlan.id: state.rootPlan]
                state.existingPlanTypes = [PlanType.emptyPlanType.id: PlanType.emptyPlanType]
                return .none
                
            case let .selectColorCode(selectedColor):
                state.selectedColorCode = selectedColor
                return .none
                
                // MARK: - plan type
            case let .createPlanType(layer, row, text, colorCode):
                let projectID = state.rootProject.id
                let existingPlanID = state.map[layer][row]
                let existingPlan = state.existingAllPlans[existingPlanID]!
                
                let newPlanTypeID = UUID().uuidString
                let newPlanType = PlanType(
                    id: newPlanTypeID,
                    title: text,
                    colorCode: colorCode
                )
                
                state.existingPlanTypes[newPlanTypeID] = newPlanType
                state.existingAllPlans[existingPlanID]!.planTypeID = newPlanTypeID
                
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.createPlanType(
                        newPlanType,
                        existingPlanID,
                        projectID
                    )
                }
                
            case let .updatePlanType(layer, row, text, colorCode):
                let projectID = state.rootProject.id
                
                let planIDsArray = state.map[layer]
                var planHeightsArray = [String: Int]()
                for planID in planIDsArray {
                    let childPlanIDsArray = state.existingAllPlans[planID]!.childPlanIDs
                    planHeightsArray[planID] = childPlanIDsArray.count
                }
                
                var sumOfHeights = 0
                var targetPlanID = ""
                for planID in planIDsArray {
                    sumOfHeights += planHeightsArray[planID]!
                    if row < sumOfHeights {
                        targetPlanID = planID
                        break
                    }
                }
                
                let existingPlanID = targetPlanID
                let existingPlan = state.existingAllPlans[existingPlanID]!
                let existingPlanTypeID = existingPlan.planTypeID
                let existingPlanType = state.existingPlanTypes[existingPlanTypeID]
                
                /// planType이 없는 경우
                if state.existingPlanTypes.values.first(where: { $0.title == text && $0.colorCode  == colorCode}) == nil {
                    return .run { send in
                        await send(
                            .createPlanType(layer: layer, row: row, text: text, colorCode: colorCode)
                        )
                    }
                }
                
                /// planType이 있는데 나와 같은게 들어온 경우 > 실행 안 함
                if existingPlanTypeID == state.existingPlanTypes.values.first(where: { $0.title == text && $0.colorCode  == colorCode})!.id {
                    return .none
                }
                
                /// planType이 있는데 나와 다른게 들어온 경우 >  해당 ID로 변경
                let foundPlanTypeID = state.existingPlanTypes.values.first(where: { $0.title == text && $0.colorCode  == colorCode})!.id
                    state.existingAllPlans[existingPlanID]!.planTypeID = foundPlanTypeID
               
                return .run { send in
                    await send(.fetchMap)
                    try await apiService.updatePlanType(
                        existingPlanID,
                        foundPlanTypeID,
                        projectID
                    )
                }
                
                // MARK: - plan
            case let .createPlanOnList(layer, row, text):
                if text.isEmpty {
                    return .none
                }
                
                let projectID = state.rootProject.id

                var createdPlans: [Plan] = []
                var createdPlanType = PlanType.emptyPlanType
                
                var parentPlanID = state.rootPlan.id
                var newPlanID = UUID().uuidString
                var childPlanID = UUID().uuidString
                var newPlanTypeID = PlanType.emptyPlanType.id
                
                /// map에 dummy 생성
                for rowIndex in state.map[layer].count...row {
                    for layerIndex in 0..<state.map.count {
                        /// 맨 마지막일 때는 text를 title로 하는 planType을 가지고 생성
                        if (rowIndex == row) && (layerIndex == layer) {
                            let newPlanType = PlanType(
                                id: UUID().uuidString,
                                title: text,
                                colorCode: PlanType.emptyPlanType.colorCode
                            )
                            state.existingPlanTypes[newPlanType.id] = newPlanType
                            newPlanTypeID = newPlanType.id
                            createdPlanType = newPlanType
                        }
                        
                        /// dummy로 넣어줄 plan 생성
                        let newPlan = Plan(
                            id: newPlanID,
                            planTypeID: newPlanTypeID,
                            childPlanIDs: ["0": layerIndex == state.map.count - 1 ? [] : [childPlanID]]
                        )
                        state.existingAllPlans[newPlanID] = newPlan
                        createdPlans.append(newPlan)
                        
                        if layerIndex == 0 {
                            /// root의 childPlan에 넣어주어야 할 plan들
                            state.existingAllPlans[parentPlanID]!.childPlanIDs[String(rowIndex)] = [newPlanID]
                            state.rootPlan.childPlanIDs[String(rowIndex)] = [newPlanID]
                        }
                        
                        parentPlanID = newPlanID
                        newPlanID = childPlanID
                        childPlanID = UUID().uuidString
                        newPlanTypeID = PlanType.emptyPlanType.id
                    }
                    parentPlanID = state.rootPlan.id
                    newPlanID = UUID().uuidString
                    childPlanID = UUID().uuidString
                }
                
                let plansToCreate = createdPlans
                let layerIndex = layer
                let newPlanType = createdPlanType
                let planID = parentPlanID
                
                return .run { send in
                    await send(.fetchMap)
                    try await apiService.createPlanOnListArea(
                        plansToCreate,
                        layerIndex,
                        projectID
                    )
                    
                    try await apiService.createPlanType(
                        newPlanType,
                        planID,
                        projectID
                    )
                }
                
            case let .createPlanOnLine(layer, row, startDate, endDate):
                var plansToCreate = [Plan]()
                var plansToUpdate = [Plan]()
                
                /// 1.  parentPlan인 map[layer][row]이 없는데 라인을 먼저 그은 경우: lane을 먼저 만들어야 함
                var prevParentPlanID = state.rootPlan.id
                var newDummyPlanID = UUID().uuidString
                var currentLayerCount = state.map[layer].count
                if currentLayerCount - 1 < row {
                    for dummyCount in 0..<currentLayerCount {
                        if dummyCount == 0 {
                            state.rootPlan.childPlanIDs["\(state.map[0].count)"] = [newDummyPlanID]
                            state.existingAllPlans[state.rootPlan.id]?.childPlanIDs["\(state.map[0].count)"] = [newDummyPlanID]
                        } else {
                            state.existingAllPlans[prevParentPlanID]?.childPlanIDs["0"] = [newDummyPlanID]
                        }
                        let newDummyPlan = Plan(id: newDummyPlanID, planTypeID: PlanType.emptyPlanType.id, childPlanIDs: [:])
                        state.existingAllPlans[newDummyPlanID] = newDummyPlan
                        state.map[dummyCount].append(newDummyPlanID)
                        
                        /// 다음 더미 생성을 위한 세팅
                        prevParentPlanID = newDummyPlanID
                        newDummyPlanID = UUID().uuidString
                        
                        /// DB에 생성해줄 플랜들 담아
                        if dummyCount < currentLayerCount - 1, dummyCount > 0 {
                            plansToCreate.append(state.existingAllPlans[prevParentPlanID]!)
                        }
                    }
                }
                
                /// 2. (row, layer)에 플랜이 존재하는 경우: 새 플랜을 생성하고 childIDs에 넣어주면 된다.
                var newPlanOnLineID = UUID().uuidString
                var newPlanOnLine = Plan(
                    id: newPlanOnLineID,
                    planTypeID: PlanType.emptyPlanType.id,
                    childPlanIDs: [:],
                    periods: ["0": [startDate, endDate]]
                )

                var currentRow = 0
                var laneStartAt = -1
                for eachRowPlanID in state.map[layer] {
                    if let plan = state.existingAllPlans[eachRowPlanID] {
                        let countChildLane = plan.childPlanIDs.count
                        if currentRow <= row,
                            currentRow + countChildLane >= row {
                            laneStartAt = currentRow - 1
                            break
                        }
                        currentRow += countChildLane
                    } else {
                        fatalError("=== 📛 Map has semantic ERROR")
                    }
                }
                
                let laneIndexToCreate = row - laneStartAt
                state.existingAllPlans[state.map[layer][row]]?.childPlanIDs["\(laneIndexToCreate)"]?.append(newPlanOnLineID)
                
                /// 3. parentPlan의 total period를 업데이트
                if let prevTotalPeriod = state.existingAllPlans[state.map[layer][row]]?.totalPeriod {
                    state.existingAllPlans[state.map[layer][row]]?.totalPeriod![0] = min(startDate, prevTotalPeriod[0])
                    state.existingAllPlans[state.map[layer][row]]?.totalPeriod![1] = min(endDate, prevTotalPeriod[1])
                } else {
                    state.existingAllPlans[state.map[layer][row]]?.totalPeriod![0] = startDate
                    state.existingAllPlans[state.map[layer][row]]?.totalPeriod![0] = endDate
                }
                
                plansToCreate.append(newPlanOnLine)
                plansToUpdate.append(state.rootPlan)
                plansToUpdate.append(state.existingAllPlans[state.map[layer][row]]!)
                let plansToCreateImmutable = plansToCreate
                let plansToUpdateImmutable = plansToUpdate
                let projectID = state.rootProject.id
                return .run { _ in
                    try await apiService.createPlanOnLineArea(plansToCreateImmutable, plansToUpdateImmutable, projectID)
                }
                    
            case let .updatePlan(planID, planTypeID):
                let projectID = state.rootProject.id
                return .run { _ in
                    try await apiService.updatePlanType(planID, planTypeID, projectID)
                }
               
                // MARK: - listArea
            case .showUpperLayer:
                let lastShowingIndex = state.showingLayers.isEmpty ? -1 : state.showingLayers.last!
                if state.showingLayers.count < 3 {
                    state.showingLayers.append(lastShowingIndex + 1)
                } else {
                    state.showingLayers.removeFirst()
                    state.showingLayers.append(lastShowingIndex + 1)
                }
                return .none
                
            case .showLowerLayer:
                let firstShowingIndex = state.showingLayers.first!
                if firstShowingIndex == 0 {
                    state.showingLayers.removeLast()
                } else {
                    state.showingLayers.removeLast()
                    state.showingLayers.insert(firstShowingIndex - 1, at: 0)
                }
                return .none
                
            case let .createLayerBtnClicked(layer):
                let projectID = state.rootProject.id
                var updatedPlans: [Plan] = []
                var createdPlans: [Plan] = []
                
                state.map.insert([], at: layer)
                
                let prevLayerPlanIDs = layer == 0 ? [state.rootPlan.id] : state.map[layer-1]
                
                if state.map.flatMap({ $0 }).isEmpty {
                    return .none
                }
                
                for prevPlanID in prevLayerPlanIDs {
                    let prevPlan = state.existingAllPlans[prevPlanID]!
                    
                    for index in 0..<prevPlan.childPlanIDs.count {
                        let childPlanIDs = prevPlan.childPlanIDs[String(index)]!
                        
                        let newPlanID = UUID().uuidString
                        let newPlan = Plan(id: newPlanID, planTypeID: PlanType.emptyPlanType.id, childPlanIDs: ["0": childPlanIDs])
                        
                        state.existingAllPlans[newPlanID] = newPlan
                        createdPlans.append(newPlan)
                        
                        state.existingAllPlans[prevPlanID]!.childPlanIDs[String(index)] = [newPlanID]
                        
                        if prevPlanID != state.rootPlan.id {
                            updatedPlans.append(state.existingAllPlans[prevPlanID]!)
                        }
                    }
                    if prevPlanID == state.rootPlan.id && state.existingAllPlans[prevPlanID]!.childPlanIDs.isEmpty {
                        updatedPlans.append(state.existingAllPlans[prevPlanID]!)
                    }
                }
                
                let plansToUpdate = updatedPlans
                let plansToCreate = createdPlans
                
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.createLayer(
                        plansToUpdate,
                        plansToCreate,
                        projectID
                    )
                }
                
            case let .deleteLayer(layer):
                /// layer가 하나인데 layer 삭제를 했을 때는 view에서 막아야 함. 혹시나 해서.
                if state.map.count == 1 {
                    return .none
                } else {
                    /// layer 2개 일 때
                    let parentPlanIDs = layer == 0 ? [state.rootPlan.id] : state.map[layer - 1]
                    
                    for parentPlanID in parentPlanIDs {
                        let parentPlan = state.existingAllPlans[parentPlanID]!
                        let childPlanIDs = parentPlan.childPlanIDs.flatMap { $0 }
                        let sortedChildPlanIDs = childPlanIDs.sorted { Int($0.key)! < Int($1.key)! }
                        let soltedChildPlanIDsArray = sortedChildPlanIDs.map { $0.value }.flatMap { $0 }
                        var newChildIDs: [String: [String]] = [:]
                        
                        for childPlanIndex in 0..<soltedChildPlanIDsArray.count {
                            let childPlanID = soltedChildPlanIDsArray[childPlanIndex]
                            let childPlan = state.existingAllPlans[childPlanID]!
                            let lanes = childPlan.childPlanIDs
                            
                            for lane in lanes {
                                let index = newChildIDs.count
                                newChildIDs[String(index)] = lane.value
                            }
                            state.existingAllPlans[childPlanID]?.childPlanIDs = ["0": []]
                        }
                        state.existingAllPlans[parentPlanID]!.childPlanIDs = newChildIDs
                        if parentPlanID == state.rootPlan.id {
                            state.rootPlan.childPlanIDs = newChildIDs
                        }
                    }
                }
                
                return .run { send in
                    await send(.fetchMap)
                    // TODO: - api Service
                }
                
            case let .deleteLayerText(layer):
                let planIDsArray = state.map[layer]
                
                for planID in planIDsArray {
                    state.existingAllPlans[planID]!.planTypeID = PlanType.emptyPlanType.id
                }
                
                return .run { send in
                    await send(.fetchMap)
                    // TODO: - api Service
                }
                
            case let .shiftSelectedCell(rowOffset, colOffset):
                if !state.selectedGridRanges.isEmpty {
                    if !state.isShiftKeyPressed {
                        /// 넓은 범위를 선택한 상태에서 방향키를 눌렀을 때, 시작점의 위치 - 2로 화면이 이동하는 기능
                        if state.selectedGridRanges.last!.start.col != state.selectedGridRanges.last!.end.col {
                            if state.selectedGridRanges.last!.start.col < state.shiftedCol {
                                state.shiftedCol = state.selectedGridRanges.last!.start.col - 2
                            } else if state.selectedGridRanges.last!.start.col > state.shiftedCol + state.maxCol + 2 {
                                state.shiftedCol = state.selectedGridRanges.last!.start.col - 2
                            }
                        }
                        /// 선택영역 중 마지막 영역의 시작지점과 끝 지점 모두 colOffset, rowOffset만큼 이동한다. Command가 눌리지 않았기 때문에 selectedRanges는 1개의 크기만을 가진다.
                        let movedRow = max(Int(state.selectedGridRanges.last!.start.row) + rowOffset, 0)
                        let movedCol = Int(state.selectedGridRanges.last!.start.col) + colOffset
                        state.selectedGridRanges = [SelectedGridRange(start: (movedRow, movedCol), end: (movedRow, movedCol))]
                    } else {
                        /// Shift를 누른 상태에서는 선택영역 중 마지막 영역의 끝 지점만 모두 colOffset, rowOffset만큼 이동한다. Command가 눌리지 않았기 때문에 selectedRanges는 1개의 크기만을 가진다.
                        let startRow = max(Int(state.selectedGridRanges.last!.start.row), 0)
                        let startCol = Int(state.selectedGridRanges.last!.start.col)
                        let movedEndRow = max(Int(state.selectedGridRanges.last!.end.row) + rowOffset, 0)
                        let movedEndCol = Int(state.selectedGridRanges.last!.end.col) + colOffset
                        state.selectedGridRanges = [SelectedGridRange(start: (startRow, startCol), end: (movedEndRow, movedEndCol))]
                    }
                    /// 선택영역 중 마지막 영역의  끝지점 Col이 현재 뷰의 영점인 shiftedCol보다 작거나, 현재 뷰의 최대점인  maxCol + shiftedCol - 2 을 넘어갈 떄 화면이 스크롤된다.
                    if Int(state.selectedGridRanges.last!.end.col) < state.shiftedCol ||
                        Int(state.selectedGridRanges.last!.end.col) > state.maxCol + state.shiftedCol - 2 {
                        state.shiftedCol += colOffset
                    }
                    /// 선택영역 중 마지막 영역의  끝지점 Row이 현재 뷰의 영점인 shiftedRow보다 작거나, 현재 뷰의 최대점인  maxRow + shiftedRow - 2 을 넘어갈 떄 화면이 스크롤된다.
                    if Int(state.selectedGridRanges.last!.end.row) < state.shiftedRow ||
                        Int(state.selectedGridRanges.last!.end.row) > state.maxLineAreaRow + state.shiftedRow - 2 {
                        state.shiftedRow = max(state.shiftedRow + rowOffset, 0)
                    }
                }
                return .none
                
            case .shiftToToday:
                state.shiftedCol = 0
                if let lastSelected = state.selectedGridRanges.last {
                    state.selectedGridRanges = [SelectedGridRange(
                        start: (lastSelected.start.row, 0),
                        end: (lastSelected.start.row, 0)
                    )]
                }
                return .none
                
                // TODO: - esc 눌렀을 때 row가 보정되지 않는 로직을 수정
            case .escapeSelectedCell:
                /// esc를 눌렀을 때 마지막 선택영역의 시작점이 선택된다.
                if let lastSelected = state.selectedGridRanges.last {
                    state.selectedGridRanges = [SelectedGridRange(
                        start: (lastSelected.start.row, lastSelected.start.col),
                        end: (lastSelected.start.row, lastSelected.start.col)
                    )]
                }
                /// 만약 위 영역이 화면을 벗어났다면 화면을 스크롤 시킨다.
                if Int(state.selectedGridRanges.last!.start.col) < state.shiftedCol ||
                    Int(state.selectedGridRanges.last!.start.col) > state.maxCol + state.shiftedCol - 2 {
                    state.shiftedCol = state.selectedGridRanges.last!.start.col - 2
                }
                if Int(state.selectedGridRanges.last!.start.row) < state.shiftedRow ||
                    Int(state.selectedGridRanges.last!.start.row) > state.maxLineAreaRow + state.shiftedRow - 2 {
                    state.shiftedRow = max(state.selectedGridRanges.last!.start.row, 0)
                }
                return .none
                
            case let .isShiftKeyPressed(isPressed):
                state.isShiftKeyPressed = isPressed
                return .none
                
            case let .isCommandKeyPressed(isPressed):
                state.isCommandKeyPressed = isPressed
                return .none
                
            case let .changeWidthButtonTapped(diff):
                state.gridWidth += diff
                return .none
                
            case let .changeHeightButtonTapped(diff):
                state.lineAreaGridHeight += diff
                return .none
                
            case let .magnificationChangedInScheduleArea(value):
                state.gridWidth = min(max(state.gridWidth * min(max(value, 0.5), 2.0), state.minGridSize), state.maxGridSize)
                state.scheduleAreaGridHeight = min(max(state.scheduleAreaGridHeight * min(max(value, 0.5), 2.0), state.minGridSize), state.maxGridSize)
                return .none
                
            case let .dragExceeded(shiftedRow, shiftedCol, exceededRow, exceededCol):
                state.shiftedRow += shiftedRow
                state.shiftedCol += shiftedCol
                state.exceededRow += exceededRow
                state.exceededCol += exceededCol
                return .none
                
            case let .windowSizeChanged(newSize):
                state.maxLineAreaRow = Int(newSize.height / state.lineAreaGridHeight) + 1
                state.maxCol = Int(newSize.width / state.gridWidth) + 1
                return .none
                
            case let .gridSizeChanged(geometrySize):
                state.maxLineAreaRow = Int(geometrySize.height / state.lineAreaGridHeight) + 1
                state.maxCol = Int(geometrySize.width / state.gridWidth) + 1
                return .none
                
            case let .onContinuousHover(isActive, location):
                state.isHovering = isActive
                if isActive {
                    state.hoverLocation = location!
                    state.hoveringCellRow = Int(state.hoverLocation.y / state.lineAreaGridHeight)
                    state.hoveringCellCol = Int(state.hoverLocation.x / state.gridWidth)
                }
                return .none
                
            case let .dragGestureChanged(dragType, updatedRange):
                switch dragType {
                case .pressNothing:
                    state.selectedGridRanges = []
                case .pressOnlyShift:
                    if let updatedRange = updatedRange {
                        state.selectedGridRanges = [updatedRange]
                    }
                case .pressOnlyCommand:
                    break
                case .pressBoth:
                    if let lastIndex = state.selectedGridRanges.indices.last,
                       let updatedRange = updatedRange {
                        state.selectedGridRanges[lastIndex] = updatedRange
                    }
                }
                return .none
                
            case let .dragGestureEnded(newRange):
                if let newRange = newRange {
                    state.selectedGridRanges.append(newRange)
                }
                state.exceededCol = 0
                return .none
                
            case let .magnificationChangedInListArea(value, geometrySize):
                state.gridWidth = min(
                    max(
                        state.gridWidth * min(max(value, 0.5), 2.0),
                        state.minGridSize
                    ),
                    state.maxGridSize
                )
                state.lineAreaGridHeight = min(
                    max(
                        state.lineAreaGridHeight * min(max(value, 0.5), 2.0),
                        state.minGridSize
                    ),
                    state.maxGridSize
                )
                state.maxLineAreaRow = Int(geometrySize.height / state.lineAreaGridHeight) + 1
                state.maxCol = Int(geometrySize.width / state.gridWidth) + 1
                return .none
            
            case .fetchMap:
                var newMap: [[String]] = []
                var planIDsQ: [String] = [state.rootPlan.id]
                var tempLayer: [String] = []
                
                while !planIDsQ.isEmpty {
                    for planID in planIDsQ {
                        let plan = state.existingAllPlans[planID]!
                        for index in 0..<plan.childPlanIDs.count {
                            tempLayer.append(contentsOf: plan.childPlanIDs[String(index)]!)
                        }
                    }
                    
                    if !tempLayer.isEmpty {
                        newMap.append(tempLayer)
                    }
                    planIDsQ.removeAll()
                    planIDsQ.append(contentsOf: tempLayer)
                    tempLayer = []
                }
                state.map = newMap.isEmpty ? [[]] : newMap
                return .none
                
            default:
                return .none
            }
        }
    }
}
