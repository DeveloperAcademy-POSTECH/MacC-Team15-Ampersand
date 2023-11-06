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
        var existingPlanTypes = [PlanType.emptyPlanType.id: PlanType.emptyPlanType]
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
        case createPlanType(targetPlanID: String, text: String, colorCode: UInt)
        case updatePlanTypeOnList(layer: Int, row: Int, text: String, colorCode: UInt)
        case updatePlanTypeOnLine(planID: String, row: Int, text: String, colorCode: UInt)
        
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
        case dragToChangePeriod(planID: String, originPeriod: [Date], updatedPeriod: [Date])
        
        // MARK: - list area
        case showUpperLayer
        case showLowerLayer
        case createLayerBtnClicked(layer: Int)
        case createLaneButtonClicked(row: Int, createOnTop: Bool)
        case deleteLayer(layer: Int)
        case deleteLayerContents(layer: Int)
        case deletePlanOnList(layer: Int, row: Int)
        case deleteLaneOnLine(row: Int)
        case deleteLaneConents(rows: [Int])
        case mergePlans(layer: Int, planIDs: [String])

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
                return .run { send in
                    await send(.fetchMap)
                }
                
            case let .selectColorCode(selectedColor):
                state.selectedColorCode = selectedColor
                return .none
                
                // MARK: - plan type
            case let .createPlanType(targetPlanID, text, colorCode):
                let projectID = state.rootProject.id
                
                let newPlanTypeID = UUID().uuidString
                let newPlanType = PlanType(
                    id: newPlanTypeID,
                    title: text,
                    colorCode: colorCode
                )
                
                state.existingPlanTypes[newPlanTypeID] = newPlanType
                state.existingAllPlans[targetPlanID]!.planTypeID = newPlanTypeID
                
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.createPlanType(
                        newPlanType,
                        targetPlanID,
                        projectID
                    )
                }
                
            case let .updatePlanTypeOnList(layer, row, text, colorCode):
                // TODO: - 만약 layer에서의 내 index를 준다면 existingPlanID = map[layer][row]
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
                
                /// planType이 없는 경우
                if state.existingPlanTypes.values.first(where: { $0.title == text && $0.colorCode  == colorCode}) == nil {
                    return .run { send in
                        await send(
                            .createPlanType(targetPlanID: existingPlanID, text: text, colorCode: colorCode)
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

            case let .updatePlanTypeOnLine(planID, row, text, colorCode):
                let projectID = state.rootProject.id
                /// 이미 존재하는 타입이면 update만
                if let foundPlanTypeID = state.existingPlanTypes.first(where: { $0.value.title == text && $0.value.colorCode == colorCode })?.key {
                    /// 동일 레인에 동일 타입의 플랜이 존재하면 기존 플랜의 periods를 추가하고 현 플랜은 삭제
                    var currentRowCount = -1
                    let parentLayer = state.map.count == 1 ? state.map[0] : state.map[1]
                    
                    /// 부모부터 찾자
                    for parentPlanID in parentLayer {
                        let childLaneCount = state.existingAllPlans[parentPlanID]!.childPlanIDs.count
                        /// plan이 속하는 row 발견
                        if currentRowCount < row, row <= currentRowCount + childLaneCount {
                            /// 그럼 이제는 해당하는 레인을 찾아보자
                            let laneIndex = state.existingAllPlans[parentPlanID]!.childPlanIDs.first { $0.value.contains(planID) }!.key
                            let lane = state.existingAllPlans[parentPlanID]!.childPlanIDs["\(laneIndex)"]!
                            for planIDInLane in lane {
                                if planIDInLane == planID { continue }
                                
                                /// 동일 타입의 플랜이 이미 존재한다면 플랜 본인을 삭제하고 periods만 추가
                                if state.existingAllPlans[planIDInLane]!.planTypeID == foundPlanTypeID {
                                    let periodsCount = state.existingAllPlans[planIDInLane]!.periods!.count
                                    let periodsToTransplant = state.existingAllPlans[planID]!.periods!
                                    for period in periodsToTransplant {
                                        let index = periodsCount + Int(period.key)!
                                        state.existingAllPlans[planIDInLane]!.periods!["\(index)"] = period.value
                                    }
                                    // TODO: - 11/3~11/4, 11/5~11/6과 같은 periods 처리
                                    /// 부모의 child에서 이식이 완료된 플랜 아이디 삭제
                                    state.existingAllPlans[parentPlanID]?.childPlanIDs[laneIndex]?.remove(at: lane.firstIndex(of: planID)!)
                                    let plansToUpdate = [state.existingAllPlans[parentPlanID]!, state.existingAllPlans[planIDInLane]!]
                                    let plansToDelete = [state.existingAllPlans[planID]!]
                                    state.existingAllPlans[planID] = nil
                                    return .run { send in
                                        try await apiService.updatePlans(
                                            plansToUpdate,
                                            projectID
                                        )
                                        try await apiService.deletePlans(
                                            plansToDelete,
                                            projectID
                                        )
                                        await send(.fetchMap)
                                    }
                                }
                            }
                            /// 반복문이 끝났는데도 return되지 않았다면 같은 레인에 동일 타입의 플랜이 존재하지 않는 것이므로 updatePlanType만 해준다
                            return .run { _ in
                                try await apiService.updatePlanType(
                                    planID,
                                    foundPlanTypeID,
                                    projectID
                                )
                            }
                        }
                        currentRowCount += childLaneCount
                    }
                }
                /// 발견된 플랜타입이 없다면 무조건 create후 update
                return .run { send in
                    await send(.createPlanType(targetPlanID: planID, text: text, colorCode: colorCode))
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
                let projectID = state.rootProject.id
                var updatedPlans: [Plan] = []
                
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
                        
                        for childPlanID in soltedChildPlanIDsArray {
                            let childPlan = state.existingAllPlans[childPlanID]!
                            let lanes = childPlan.childPlanIDs
                            
                            for lane in lanes {
                                let index = newChildIDs.count
                                newChildIDs[String(index)] = lane.value
                            }
                            
                            /// 사라지는 layer에 속한 plan들의 childPlanIDs를 비워줌
                            state.existingAllPlans[childPlanID]!.childPlanIDs = ["0": []]
                            updatedPlans.append(childPlan)
                        }
                        state.existingAllPlans[parentPlanID]!.childPlanIDs = newChildIDs
                        updatedPlans.append(parentPlan)
                        
                        if parentPlanID == state.rootPlan.id {
                            state.rootPlan.childPlanIDs = newChildIDs
                        }
                    }
                }
                
                let plansToUpdate = updatedPlans
                
                return .run { send in
                    await send(.fetchMap)
                   
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                }
            
            case let .deletePlanOnList(layer, row):
                let projectID = state.rootProject.id
                var createdPlans: [Plan] = []
                var updatedPlans: [Plan] = []
                
                /// clicke된 위치에 있는 planID 찾기
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
                
                /// clicked Plan의 부모에서 clickedPlan의 위치 찾기
                let parentPlanIDs = layer == 0 ? [state.rootPlan.id] : state.map[layer - 1]
                var targetParentPlanID = ""
                var targetKey = ""
                
                for parentPlanID in parentPlanIDs {
                    let parentPlan = state.existingAllPlans[parentPlanID]!
                    let childPlanIDs = parentPlan.childPlanIDs
                    
                    for childPlanIDsArray in childPlanIDs where childPlanIDsArray.value.contains(targetPlanID) {
                        targetParentPlanID = parentPlanID
                        targetKey = childPlanIDsArray.key
                        break
                    }
                }
                
                /// 현재 listArea에 보여지는 Plan들은 부모의 childIDs 배열에서 한 lane에 나만 속해있다. 하나의 레인에 나 외에 다른 플랜들이 있는 상황은 가정하지 않음.
                /// 따라서 부모의 레인들 중 내가 속한 레인에서 나를 빼면 그 레인은 당연히 0이 됨.
                
                /// 부모가 내 레인만 들고 있었을 경우
                if state.existingAllPlans[targetParentPlanID]!.childPlanIDs.count == 1 {
                    /// 그 부모가 root일 경우: Layer가 0
                    if targetParentPlanID == state.rootPlan.id {
                        state.existingAllPlans[targetParentPlanID]!.childPlanIDs = [:]
                        /// 부모의 childs를 지워주면 map에 layer2개 이상이었을 때에도 layer는 1개만 보여지므로, map의 크기만큼 map에 빈 배열을 추가하고 빠져나감.
                        if state.map.count != 1 {
                            var newMap: [[String]] = []
                            for index in 0..<state.map.count {
                                newMap.append([])
                            }
                            state.map = newMap
                            return .none
                        }
                    /// 부모가 root가 아닐 경우: Layer가 1 이상
                    } else {
                        let newPlanID = UUID().uuidString
                        let newPlan = Plan(
                            id: newPlanID,
                            planTypeID: PlanType.emptyPlanType.id,
                            childPlanIDs: ["0": []]
                            )
                        /// 새로운 plan을 만들어서 부모의 childPlans에 갈아끼워 준다.
                        state.existingAllPlans[newPlanID] = newPlan
                        createdPlans.append(newPlan)
                        
                        state.existingAllPlans[targetParentPlanID]!.childPlanIDs = ["0": [newPlanID]]
                        updatedPlans.append(state.existingAllPlans[targetParentPlanID]!)
                    }
                /// 부모가 나말고 다른 레인도 들고 있었을 경우
                } else {
                    /// 부모의 childPlanIDs에서 내 레인을 제거하고
                    state.existingAllPlans[targetParentPlanID]!.childPlanIDs.removeValue(forKey: targetKey)
                    /// 인덱스에 맞게 key를 다시 부여한다.
                    let sortedChildPlanIDs = state.existingAllPlans[targetParentPlanID]!.childPlanIDs.sorted { Int($0.key)! < Int($1.key)! }
                    var orderedChildPlanIDs = [String: [String]]()
                    
                    for index in 0..<sortedChildPlanIDs.count {
                        orderedChildPlanIDs[String(index)] = sortedChildPlanIDs[index].value
                    }
                    
                    state.existingAllPlans[targetParentPlanID]!.childPlanIDs = orderedChildPlanIDs
                }
                
                let plansToCreate = createdPlans
                let plansToUpdate = updatedPlans
                
                return .run { send in
                    await send(.fetchMap)
                    if !plansToCreate.isEmpty {
                        try await apiService.createPlans(
                            plansToCreate,
                            projectID
                        )
                    }
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                }
                
            case let .deleteLaneOnLine(row):
                let projectID = state.rootProject.id
                var updatedPlans = [Plan]()
                let layer = state.map.count - 1
                
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
                
                /// 내가 속한 부모 Plan
                let targetParentPlanID = targetPlanID
                let targetParentPlan = state.existingAllPlans[targetParentPlanID]!
                
                /// 내 row가 내가 속한 부모 Plan의 childIDs에서 몇번째인지 계산하는 로직
                let rowDifference = (sumOfHeights - 1) - row
                let targetKey = (targetParentPlan.childPlanIDs.count - 1) - rowDifference
                
                /// 내 부모가 내 lane만 들고 있었을 경우
                if state.existingAllPlans[targetParentPlanID]!.childPlanIDs.count == 1 {
                    state.existingAllPlans[targetParentPlanID]!.childPlanIDs = ["0":[]]
                } else {
                    state.existingAllPlans[targetParentPlanID]!.childPlanIDs.removeValue(forKey: String(targetKey))
                    /// 인덱스에 맞게 key를 다시 부여한다.
                    let sortedChildPlanIDs = state.existingAllPlans[targetParentPlanID]!.childPlanIDs.sorted { Int($0.key)! < Int($1.key)! }
                    var orderedChildPlanIDs = [String: [String]]()
                    
                    for index in 0..<sortedChildPlanIDs.count {
                        orderedChildPlanIDs[String(index)] = sortedChildPlanIDs[index].value
                    }
                    
                    state.existingAllPlans[targetParentPlanID]!.childPlanIDs = orderedChildPlanIDs
                }
                
                updatedPlans.append(state.existingAllPlans[targetParentPlanID]!)
                
                let plansToUpdate = updatedPlans
            
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                }
                
            case let .deleteLayerContents(layer):
                let projectID = state.rootProject.id
                var updatedPlans = [Plan]()
                let planIDsArray = state.map[layer]
                
                for planID in planIDsArray {
                    state.existingAllPlans[planID]!.planTypeID = PlanType.emptyPlanType.id
                }
                let plansToUpdate = updatedPlans
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                }
                
            case let .deleteLaneConents(rows):
                let projectID = state.rootProject.id
                var updatedPlans = [Plan]()
                
                let startRow = rows[0]
                let endRow = rows[1]
                var changedPlanIDs = [String]()
                
                /// 선택된 row에 보이는 childPlanIDs를 빈 레인으로 갈아끼워줌
                let layer = state.map.count - 1
                let planIDsArray = state.map[layer]
                var planHeightsArray = [String: Int]()
                
                for planID in planIDsArray {
                    let childPlanIDsArray = state.existingAllPlans[planID]!.childPlanIDs
                    planHeightsArray[planID] = childPlanIDsArray.count
                }
            
                for row in startRow...endRow {
                    var sumOfHeights = 0
                    var targetPlanID = ""
                    
                    for planID in planIDsArray {
                        sumOfHeights += planHeightsArray[planID]!
                        if row < sumOfHeights {
                            targetPlanID = planID
                            break
                        }
                    }
                    
                    /// 내가 속한 부모 Plan
                    let targetParentPlan = state.existingAllPlans[targetPlanID]!
                    
                    /// 내 row가 내가 속한 부모 Plan의 childIDs에서 몇번째인지 계산하는 로직
                    let rowDifference = (sumOfHeights - 1) - row
                    let targetKey = (targetParentPlan.childPlanIDs.count - 1) - rowDifference
                    
                    /// lane을 빈 lane으로 갈아끼워 줌
                    state.existingAllPlans[targetPlanID]!.childPlanIDs[String(targetKey)] = []
                    updatedPlans.append(state.existingAllPlans[targetPlanID]!)

                    changedPlanIDs.append(targetPlanID)
                }
                
                /// 상위 레이어에 대해서도 row값이 어떤 plan인지 찾아줌
                let upperPlanIDsArray = layer == 0 ? [state.rootPlan.id] : state.map[layer - 1]
                var upperPlanHeightsArray = [String: Int]()
                
                for upperPlanID in upperPlanIDsArray {
                    let childPlanIDsArray = state.existingAllPlans[upperPlanID]!.childPlanIDs
                    upperPlanHeightsArray[upperPlanID] = childPlanIDsArray.count
                }
                
                for row in startRow...endRow {
                    var sumOfHeights = 0
                    var targetPlanID = ""
                    
                    for upperPlanID in upperPlanIDsArray {
                        sumOfHeights += upperPlanHeightsArray[upperPlanID]!
                        if row < sumOfHeights {
                            targetPlanID = upperPlanID
                            break
                        }
                    }
                    
                    /// row가 속한 상위 부모 Plan
                    changedPlanIDs.append(targetPlanID)
                }
                
                /// 한 플랜의 레인들 중 몇 개가 변경 되었는지
                var numOfChangePerPlan = [String: Int]()
                
                for planID in changedPlanIDs {
                    if let count = numOfChangePerPlan[planID] {
                        numOfChangePerPlan[planID] = count + 1
                    } else {
                        numOfChangePerPlan[planID] = 1
                    }
                }
                
                /// 한 ID당 변경된 레인의 개수가 내 chilidIDs.count와 같다면, 내가 가진 모든 lane이 []이 된 것이므로 내 planType은 empty가 되어야 함
                for planID in numOfChangePerPlan.keys {
                    if numOfChangePerPlan[planID] == state.existingAllPlans[planID]!.childPlanIDs.count {
                        state.existingAllPlans[planID]!.planTypeID = PlanType.emptyPlanType.id
                        updatedPlans.append(state.existingAllPlans[planID]!)
                    }
                }
                
                let plansToUpdate = updatedPlans
                
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
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
                
            case let .dragToChangePeriod(planID, originPeriod, updatedPeriod):
                if originPeriod == updatedPeriod { return .none }
                let periodIndex = state.existingAllPlans[planID]?.periods?.first(where: { $0.value == originPeriod })!.key
                state.existingAllPlans[planID]!.periods![periodIndex!]! = updatedPeriod
                
                var foundParentID: String?
                /// 부모 plan의 totalPeriod를 업데이트
                for parentPlanID in state.map[state.map.count-1] {
                    var parentPlan = state.existingAllPlans[parentPlanID]!
                    if parentPlan.childPlanIDs.map({ $0.value }).flatMap({ $0 }).contains(planID) {
                        foundParentID = parentPlanID
                        parentPlan.totalPeriod![0] = min(parentPlan.totalPeriod![0], updatedPeriod[0])
                        parentPlan.totalPeriod![1] = min(parentPlan.totalPeriod![1], updatedPeriod[1])
                        break
                    }
                }
                
                let plansToUpdate = [state.existingAllPlans[planID]!, state.existingAllPlans[foundParentID!]!]
                let projectID = state.rootProject.id
                return .run { _ in
                    try await apiService.updatePlans(plansToUpdate, projectID)
                }
                
            case let .createLaneButtonClicked(row, createOnTop):
                /// row: 새로운 레인이 생성될 인덱스
                let projectID = state.rootProject.id
                var laneCount = -1
                let rootChildIDs = state.rootPlan.childPlanIDs["0"]!
                if state.map.count == 1 {
                    /// layer가 하나뿐이라면,
                    for rootChildID in rootChildIDs {
                        let rootChildLanes = state.existingAllPlans[rootChildID]!.childPlanIDs
                        let rootChildLaneCount = rootChildLanes.count
                        if laneCount < row, row <= laneCount + rootChildLaneCount {
                            /// row 발견
                            if createOnTop {
                                for index in stride(from: rootChildLaneCount - 1, through: -1, by: -1) {
                                    state.existingAllPlans[rootChildID]?.childPlanIDs["\(index + 1)"] = rootChildLanes["\(index)"]
                                }
                                state.existingAllPlans[rootChildID]!.childPlanIDs["0"] = []
                            } else {
                                state.existingAllPlans[rootChildID]!.childPlanIDs["\(rootChildLaneCount)"] = []
                            }
                            let planToUpdate = state.existingAllPlans[rootChildID]!
                            return .run { send in
                                try await apiService.createLane(
                                    planToUpdate,
                                    nil,
                                    projectID
                                )
                                await send(.fetchMap)
                            }
                        }
                        laneCount += rootChildLaneCount
                    }
                }
                /// /// layer가 두개라면, root (layer0)의 child부터 순회
                for rootChildID in rootChildIDs {
                    /// layer 1의 plan들을 순회
                    let rootChildPlan = state.existingAllPlans[rootChildID]!
                    let firstLayerPlanIDs = rootChildPlan.childPlanIDs
                    let mappingByPlanIDs = firstLayerPlanIDs.map { $0.value }.flatMap { $0 }
                    for firstLayerPlanID in mappingByPlanIDs {
                        let firstLayerPlanLanes = state.existingAllPlans[firstLayerPlanID]!.childPlanIDs
                        let firstLayerPlanLaneCount = firstLayerPlanLanes.count
                        if laneCount <= row, row <= laneCount + firstLayerPlanLaneCount {
                            /// row 발견
                            let newChildPlan = Plan(
                                id: UUID().uuidString,
                                planTypeID: PlanType.emptyPlanType.id,
                                childPlanIDs: ["0": []]
                            )
                            state.existingAllPlans[newChildPlan.id] = newChildPlan
                            if createOnTop {
                                for index in stride(from: firstLayerPlanLaneCount - 1, through: -1, by: -1) {
                                    state.existingAllPlans[rootChildID]?.childPlanIDs["\(index + 1)"] = firstLayerPlanLanes["\(index)"]
                                }
                                state.existingAllPlans[firstLayerPlanID]!.childPlanIDs["0"] = [newChildPlan.id]
                            } else {
                                state.existingAllPlans[firstLayerPlanID]!.childPlanIDs["\(firstLayerPlanLaneCount)"] = [newChildPlan.id]
                            }
                            let planToUpdate = state.existingAllPlans[firstLayerPlanID]!
                            return .run { send in
                                try await apiService.createLane(
                                    planToUpdate,
                                    newChildPlan,
                                    projectID
                                )
                                await send(.fetchMap)
                            }
                        }
                    }
                }
                return .none
                
            case let .mergePlans(layer, planIDs):
                var planIDsToUpdate = Set<String>()
                if planIDs.count < 1 { return .none }

                var currentTopPlanChildCount = state.existingAllPlans[planIDs[0]]!.childPlanIDs.count
                
                for (index, planID) in planIDs.enumerated() {
                    if index == 0 { continue }
                    
                    /// 1. 최상위 플랜에 child들을 모두 병합
                    let childPlanIDsToAppend = state.existingAllPlans[planID]!.childPlanIDs
                    for (key, childValue) in childPlanIDsToAppend {
                        state.existingAllPlans[planIDs[0]]!.childPlanIDs["\(currentTopPlanChildCount + Int(key)!)"] = childValue
                    }
                    currentTopPlanChildCount += childPlanIDsToAppend.count
                    
                    /// 2. 병합된 플랜들을 map에서 삭제
                    state.map[layer].remove(at: state.map[layer].firstIndex(of: planID)!)
                    
                    /// 3 병합된 플랜들을 부모에서 삭제
                    if layer == 0 {
                        /// root에서 삭제
                        state.rootPlan.childPlanIDs["0"]!.remove(at: state.rootPlan.childPlanIDs["0"]!.firstIndex(of: planID)!)
                        state.existingAllPlans[state.rootPlan.id] = state.rootPlan
                        planIDsToUpdate.insert(state.rootPlan.id)
                    } else {
                        for parentID in state.map[layer-1] {
                            let parentPlan = state.existingAllPlans[parentID]!
                            
                            /// 부모를 발견했다
                            if parentPlan.childPlanIDs.map({$0.value}).flatMap({$0}).contains(planID) {
                                /// 부모가 가진 레인이 하나이고, 그 레인 내에 차일드가 병합된 플랜 하나라면 빈 레인으로 갈아끼워준다
                                if parentPlan.childPlanIDs.count == 1,
                                   parentPlan.childPlanIDs["0"]!.count == 1 {
                                    state.existingAllPlans[parentID]?.childPlanIDs["0"] = []
                                    planIDsToUpdate.insert(parentID)
                                    break
                                }
                                
                                let laneIndex = parentPlan.childPlanIDs.first(where: { $0.value.contains(planID) })!.key
                                let indexInLane = parentPlan.childPlanIDs[laneIndex]!.firstIndex(of: planID)!
                                /// 병합된 플랜이 속한 레인에 child가 이거 하나라면 레인을 삭제하고 나머지 레인들을 다시 정렬
                                if parentPlan.childPlanIDs[laneIndex]!.count == 1 {
                                    for currentLaneIndex in Int(laneIndex)!..<parentPlan.childPlanIDs.count {
                                        state.existingAllPlans[parentID]!.childPlanIDs["\(currentLaneIndex)"] = state.existingAllPlans[parentID]!.childPlanIDs["\(currentLaneIndex + 1)"]
                                    }
                                    state.existingAllPlans[parentID]!.childPlanIDs["\(parentPlan.childPlanIDs.count - 1)"] = nil
                                } else { /// 아니라면 해당 레인에서 병합된 플랜만 삭제
                                    state.existingAllPlans[parentID]!.childPlanIDs[laneIndex]!.remove(at: indexInLane)
                                }
                                planIDsToUpdate.insert(parentID)
                                break
                            }
                        }
                    }
                }
                planIDsToUpdate.insert(planIDs[0])
                let projectID = state.rootProject.id
                let plansToUpdate = planIDsToUpdate.map { state.existingAllPlans[$0]! }
                let plansToDelete = planIDs[1..<planIDs.count].map { state.existingAllPlans[$0]! }
                return .run { send in
                    try await apiService.updatePlans(plansToUpdate, projectID)
                    try await apiService.deletePlansCompletely(plansToDelete, projectID)
                    await send(.fetchMap)
                }
                
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
            }
        }
    }
}
