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

enum PlanBoardAreaName {
    case scheduleArea
    case timeAxisArea
    case listArea
    case lineArea
}

struct PlanBoard: Reducer {
    
    @Dependency(\.apiService) var apiService
    
    struct State: Equatable {
        var rootProject: Project
        var rootPlan = Plan.mock
        var map: [[String]] = [[]]
        var searchPlanTypesResult = [PlanType]()
        var existingPlanTypes = [PlanType.emptyPlanType.id: PlanType.emptyPlanType]
        var existingPlans = [String: Plan]()
        
        @BindingState var keyword = ""
        var selectedColorCode = Color.red
        
        /// 그리드 규격에 대한 변수들입니다.
        var columnStroke = CGFloat(1)
        var rowStroke = CGFloat(1)
        let minGridSize = CGFloat(20)
        let maxGridSize = CGFloat(70)

        var gridWidth = CGFloat(45)
        var scheduleAreaGridHeight = CGFloat(45)
        var lineAreaGridHeight = CGFloat(45)
        var horizontalMagnification = CGFloat(1.0)
        var verticalMagnification = CGFloat(1.0)
        
        /// hover나 click된 영역을 구분합니다.
        var hoveredArea: PlanBoardAreaName?
        var clickedArea: PlanBoardAreaName?
        
        /// ScheduleArea의 local 영역에서 마우스가 호버링 된 위치의 셀정보를 담습니다.
        var scheduleAreaHoveredCellLocation: CGPoint = .zero
        var scheduleAreaHoveredCellRow = 0
        var scheduleAreaHoveredCellCol = 0
        
        /// TimeAxisArea의 local 영역에서 마우스가 호버링 된 위치의 셀정보를 담습니다.
        var timeAxisAreaHoveredCellLocation: CGPoint = .zero
        var timeAxisAreaHoveredCellRow = 0
        var timeAxisAreaHoveredCellCol = 0
        
        /// ListArea의 local 영역에서 마우스가 호버링 된 위치의 셀정보를 담습니다.
        var listAreaHoveredCellLocation: CGPoint = .zero
        var listAreaHoveredCellRow = -1
        var listAreaHoveredCellCol = -1
        
        /// LineArea의 local 영역에서 마우스가 호버링 된 위치의 셀정보를 담습니다.
        var lineAreaHoveredCellLocation: CGPoint = .zero
        var lineAreaHoveredCellRow = 0
        var lineAreaHoveredCellCol = 0
        
        /// 선택된 영역을 배열로 담습니다. selectedDateRange는 Plan생성 API가 들어오면 삭제될 변수입니다.
        var temporarySelectedGridRange: SelectedGridRange?
        var selectedGridRanges: [SelectedGridRange] = []
        var selectedDateRanges: [SelectedDateRange] = []
        var exceededDirection = [false, false, false, false]
        
        /// GeometryReader proxy값의 변화에 따라 Max 그리드 갯수가 변화합니다.
        var maxCol = 0
        var maxLineAreaRow = 14
        var maxScheduleAreaRow = 6
        
        /// 뷰가 움직인 크기를 나타내는 변수입니다. ListArea, LineArea가 공유합니다.
        var shiftedRow = 0
        var shiftedCol = 0
        var exceededRow = 0
        var exceededCol = 0
        
        /// NSEvent로 받아온 Shift와 Command 눌린 상태값입니다.
        var isShiftKeyPressed = false
        var isCommandKeyPressed = false
        
        /// TimeAxisArea에서 사용
        var holidays = [Date]()
        
        /// ListArea
        var selectedEmptyRow: Int?
        var selectedEmptyColumn: Int?
        var selectedListRow: Int?
        var selectedListColumn: Int?
        
        /// focusGroupClickedItems
        var hoveredItem = ""
        var topToolBarFocusGroupClickedItem = ""
        var rightToolBarFocusGroupClickedItem = ""
        var isHoveredOnLineArea = false
        var isHoveredOnListArea = false
        
        /// popover
        var isShareImagePresented = false
        var isBoardSettingPresented = false
        var isRightToolBarPresented = true
    }
    
    enum Action: Equatable {
        // MARK: - user action
        case onAppear
        case selectColorCode(Color)
        case hoveredItem(name: String)
        case clickedItem(focusGroup: String, name: String)
        case popoverPresent(button: String, bool: Bool)
        
        // MARK: - plan type
        case createPlanType(_ targetPlanID: String, _ text: String, _ colorCode: UInt)
        case readPlanTypes
        case readPlanTypesResponse(TaskResult<[PlanType]>)
        case updatePlanTypeOnList(targetPlanID: String, text: String, colorCode: UInt)
        case updatePlanTypeOnLine(planID: String, text: String, colorCode: UInt, period: [Date])
        
        // MARK: - plan
        case createPlanOnList(layer: Int, row: Int, text: String, colorCode: UInt?)
        case createPlanOnLine(row: Int, startDate: Date, endDate: Date)
        case readPlans
        
        case readPlansResponse(TaskResult<[Plan]>)
        case updatePlan(targetPlanID: String, updateTo: Plan)
        
        // MARK: - list area
        case createLayerButtonClicked(layer: Int)
        case createLaneButtonClicked(row: Int, createOnTop: Bool)
        case deleteLayer(layer: Int)
        case deleteLayerContents(layer: Int)
        case deletePlanOnList(layer: Int, row: Int)
        case deletePlanOnLine(selectedRanges: [SelectedGridRange])
        case deleteLaneOnLine(row: Int)
        case deleteLaneConents(rows: [Int])
        case mergePlans(layer: Int, planIDs: [String])
        
        // MARK: - TimelineLayout
        case isShiftKeyPressed(Bool)
        case isCommandKeyPressed(Bool)
        
        // MARK: - GridSizeController
        case changeWidthButtonTapped(CGFloat)
        case changeHeightButtonTapped(CGFloat)
        
        // MARK: - ScheduleAreaView
        case magnificationChangedInScheduleArea(CGFloat)
        
        // MARK: - LineAreaView
        case dragGestureChanged(LineAreaDragType, SelectedGridRange?)
        case dragGestureEnded(SelectedGridRange?)
        case dragExceeded(shiftedRow: Int, shiftedCol: Int, exceededRow: Int, exceededCol: Int)
        case dragToChangePeriod(planID: String, originPeriod: [Date], updatedPeriod: [Date])
        case dragToMoveLine(Int, Int)
        
        /// source, destication: layer 내의 인덱스. row값은 또 따로 받음
        case dragToMovePlanInList(targetPlanID: String, source: Int, destination: Int, row: Int, layer: Int)
        case dragToMovePlanInLine(Int, String, Date, Date)
        case shiftSelectedCell(rowOffset: Int, colOffset: Int)
        case shiftToToday
        case escapeSelectedCell
        case windowSizeChanged(CGSize)
        case gridSizeChanged(CGSize)
        case onContinuousHover(Bool, CGPoint?)
        case setHoveredCell(PlanBoardAreaName, Bool, CGPoint?)
        case magnificationChangedInListArea(CGFloat, CGSize)
        
        // MARK: - list area
        case emptyListItemDoubleClicked(Bool)
        case listItemDoubleClicked(Bool)
        case keywordChanged(String)
        
        case setSheet(Bool)

        // MARK: - map
        case reloadMap
        case fetchRootPlan
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
                // MARK: - user action
            case .fetchRootPlan:
                if let foundRootPlan = state.existingPlans[state.rootProject.rootPlanID] {
                    state.rootPlan = foundRootPlan
                } else {
                    state.rootPlan.id = state.rootProject.rootPlanID
                }
                
                return .run { send in
                    await send(.reloadMap)
                }
                
            case .onAppear:
                return .run { send in
                    await send(.readPlans)
                    await send(.readPlanTypes)
                    // TODO: - 삭제
                    await Task.sleep(2 * 1_000_000_000)
                    await send(.fetchRootPlan)
                }
                
            case let .selectColorCode(selectedColor):
                state.selectedColorCode = selectedColor
                return .none
                
            case let .hoveredItem(name: hoveredItem):
                state.hoveredItem = hoveredItem
                return .none
                
            case let .clickedItem(focusGroup: focusGroup, name: clickedItem):
                switch focusGroup {
                case .topToolBarFocusGroup:
                    state.topToolBarFocusGroupClickedItem = clickedItem
                default:
                    break
                }
                return .none
                
            case let .popoverPresent(button: buttonName, bool: bool):
                switch buttonName {
                case .shareImageButton:
                    state.isShareImagePresented = bool
                case .boardSettingButton:
                    state.isBoardSettingPresented = bool
                case .rightToolBarButton:
                    state.isRightToolBarPresented = bool
                default:
                    break
                }
                return .none
                
                // MARK: - plan type
            case let .createPlanType(targetPlanID, text, colorCode):
                let projectID = state.rootProject.id
                if let originType = state.existingPlanTypes.values.first(where: { $0.title == text && $0.colorCode == colorCode}) {
                    /// planType이 있는데 나와 같은게 들어온 경우 > 실행 안 함
                    if state.existingPlans[targetPlanID]!.planTypeID == originType.id {
                        return .none
                    }
                    /// planType이 있는데 나와 다른게 들어온 경우 >  해당 ID로 변경
                    state.existingPlans[targetPlanID]!.planTypeID = originType.id
                    let planToUpdate = state.existingPlans[targetPlanID]!
                    return .run { _ in
                        try await apiService.updatePlans(
                            [planToUpdate],
                            projectID
                        )
                    }
                }
                
                /// planType이 없어 생성해야 하는 경우
                let newPlanTypeID = UUID().uuidString
                let newPlanType = PlanType(
                    id: newPlanTypeID,
                    title: text,
                    colorCode: colorCode
                )
                state.existingPlanTypes[newPlanTypeID] = newPlanType
                state.existingPlans[targetPlanID]!.planTypeID = newPlanTypeID
                
                return .run { _ in
                    try await apiService.createPlanType(
                        newPlanType,
                        targetPlanID,
                        projectID
                    )
                }
                
            case .readPlanTypes:
                let projectID = state.rootProject.id
                return .run { send in
                    await send(.readPlanTypesResponse(
                        TaskResult {
                            try await apiService.readPlanTypes(projectID)
                        }
                    ))
                }
                
            case let .readPlanTypesResponse(.success(responses)):
                responses.forEach { response in
                    state.existingPlanTypes[response.id] = response
                }
                return .none
                
            case let .updatePlanTypeOnList(targetPlanID, text, colorCode):
                return .run { send in
                    await send(.createPlanType(targetPlanID, text, colorCode))
                }
                
            case let .updatePlanTypeOnLine(planID, text, colorCode, period):
                let projectID = state.rootProject.id
                let foundPlanType = state.existingPlanTypes.first(where: { $0.value.title == text && $0.value.colorCode == colorCode })
                /// 이미 존재하는 타입이면 update만
                if let foundPlanTypeID = foundPlanType?.key {
                    /// 부모부터 찾자
                    for parentPlanID in state.map.last! {
                        let childLines = state.existingPlans[parentPlanID]!.childPlanIDs
                        if childLines.values.flatMap({ $0 }).contains(planID) {
                            /// 그럼 이제는 해당하는 레인을 찾아보자
                            let lineIndex = childLines.first { $0.value.contains(planID) }!.key
                            let lines = childLines["\(lineIndex)"]!
                            for planIDInLine in lines {
                                if planIDInLine == planID { continue }
                                
                                let currentPlan = state.existingPlans[planIDInLine]!
                                /// 동일 타입의 플랜이 이미 존재하는 경우
                                if currentPlan.planTypeID == foundPlanTypeID {
                                    /// periods 이식
                                    let currentPlanPeriodInArray = currentPlan.periods.map({ $0.values })!.flatMap({ $0 })
                                    var (startDateToPlant, endDateToPlant) = (period[0], period[1])
                                    /// (current plan startDate, target plan endDate)
                                    let dayBeforeStartDate = Calendar.current.date(byAdding: .day, value: -1, to: startDateToPlant)!
                                    if currentPlanPeriodInArray.contains(dayBeforeStartDate) {
                                        let periodIndex = currentPlan.periods!.first(where: { $0.value.contains(dayBeforeStartDate) })!.key
                                        startDateToPlant = state.existingPlans[planIDInLine]!.periods![periodIndex]![0]
                                        state.existingPlans[planIDInLine]!.periods![periodIndex] = [startDateToPlant, endDateToPlant]
                                    } else {
                                        /// (target period startDate, current plan endDate)
                                        let dayAfterEndDate = Calendar.current.date(byAdding: .day, value: 1, to: endDateToPlant)!
                                        if currentPlanPeriodInArray.contains(dayAfterEndDate) {
                                            let periodIndex = currentPlan.periods!.first(where: { $0.value.contains(dayAfterEndDate) })!.key
                                            endDateToPlant = state.existingPlans[planIDInLine]!.periods![periodIndex]![0]
                                            state.existingPlans[planIDInLine]!.periods![periodIndex] = [startDateToPlant, endDateToPlant]
                                        } else {
                                            /// 붙어있는 period가 없으므로 새로 추가
                                            let periodsCount = state.existingPlans[planIDInLine]!.periods!.count
                                            state.existingPlans[planIDInLine]!.periods!["\(periodsCount)"] = [startDateToPlant, endDateToPlant]
                                        }
                                    }
                                    
                                    /// 플랜이 가진 Periods가 하나뿐이었다면 플랜 본인을 삭제
                                    if state.existingPlans[planID]!.periods!.count < 2 {
                                        /// 부모의 child에서 이식이 완료된 플랜 아이디 삭제
                                        state.existingPlans[parentPlanID]?.childPlanIDs[lineIndex]?.remove(at: lines.firstIndex(of: planID)!)
                                        let plansToUpdate = [state.existingPlans[parentPlanID]!, state.existingPlans[planIDInLine]!]
                                        let plansToDelete = [state.existingPlans[planID]!]
                                        state.existingPlans[planID] = nil
                                        return .run { send in
                                            try await apiService.updatePlans(
                                                plansToUpdate,
                                                projectID
                                            )
                                            try await apiService.deletePlans(
                                                plansToDelete,
                                                projectID
                                            )
                                            await send(.reloadMap)
                                        }
                                    }
                                }
                            }
                            state.existingPlans[planID]!.planTypeID = foundPlanTypeID
                            let planToUpdate = state.existingPlans[planID]!
                            /// 반복문이 끝났는데도 return되지 않았다면 같은 레인에 동일 타입의 플랜이 존재하지 않는 것이므로 updatePlanType만 해준다
                            return .run { _ in
                                try await apiService.updatePlans(
                                    [planToUpdate],
                                    projectID
                                )
                            }
                        }
                    }
                }
                /// 발견된 플랜타입이 없다면 무조건 create후 update
                return .run { send in
                    await send(.createPlanType(planID, text, colorCode))
                }
                
                // MARK: - plan
            case let .createPlanOnList(layer, row, text, colorCode):
                if text.isEmpty { return .none }
                
                let projectID = state.rootProject.id
                var createdPlans = [Plan]()
                var createdPlanType = PlanType.emptyPlanType
                // TODO: - state.rootPlan.id로 바꾸기. 현재 자꾸 nil이 들어와서 임시방편
                var parentPlanID = state.rootProject.rootPlanID
                var newPlanID = UUID().uuidString
                var childPlanID = UUID().uuidString
                var newPlanTypeID = PlanType.emptyPlanType.id
                
                let originPlanTypeID = state.existingPlanTypes.values.first(where: { $0.title == text && $0.colorCode == colorCode })?.id ?? nil
                
                /// map에 dummy 생성
                for rowIndex in state.map[layer].count...row {
                    for layerIndex in 0..<state.map.count {
                        /// 특정 row, col일 때는 text를 title로 하는 planType을 가지고 생성
                        if (rowIndex == row) && (layerIndex == layer) {
                            /// 이미 있는 planType일 경우
                            if let foundPlanTypeID = originPlanTypeID {
                                newPlanTypeID = foundPlanTypeID
                            } else {
                                /// 새로운 planType을 생성해야 하는 경우
                                let newPlanType = PlanType(
                                    id: UUID().uuidString,
                                    title: text,
                                    colorCode: colorCode ?? PlanType.emptyPlanType.colorCode
                                )
                                state.existingPlanTypes[newPlanType.id] = newPlanType
                                newPlanTypeID = newPlanType.id
                                createdPlanType = newPlanType
                            }
                        }
                        /// dummy로 넣어줄 plan 생성
                        let newPlan = Plan(
                            id: newPlanID,
                            planTypeID: newPlanTypeID,
                            childPlanIDs: ["0": layerIndex == state.map.count - 1 ? [] : [childPlanID]]
                        )
                        state.existingPlans[newPlanID] = newPlan
                        createdPlans.append(newPlan)
                        if layerIndex == 0 {
                            /// root의 childPlan에 넣어주어야 할 plan들
                            state.existingPlans[parentPlanID]!.childPlanIDs["\(rowIndex)"] = [newPlanID]
                            state.rootPlan.childPlanIDs["\(rowIndex)"] = [newPlanID]
                            state.existingPlans[state.rootPlan.id] = state.rootPlan
                        }
                        parentPlanID = newPlanID
                        newPlanID = childPlanID
                        childPlanID = UUID().uuidString
                        newPlanTypeID = PlanType.emptyPlanType.id
                    }
                    parentPlanID = state.rootPlan.id
                    newPlanID = UUID().uuidString
                }
                
                let plansToCreate = createdPlans
                let newPlanType = createdPlanType
                let planID = parentPlanID
                state.existingPlans[planID]!.planTypeID = originPlanTypeID ?? newPlanType.id
                let planToUpdate = state.existingPlans[planID]!
                let rootPlanToUpdate = state.rootPlan
                let rootProjectToUpdate = state.rootProject
                
                return .run { send in
                    await send(.reloadMap)
                    try await apiService.updateProjects(
                        [rootProjectToUpdate]
                    )
                    try await apiService.createPlans(
                        plansToCreate,
                        projectID
                    )
                    try await apiService.updatePlans(
                        [rootPlanToUpdate],
                        projectID
                    )
                    
                    if let _ = originPlanTypeID {
                        /// colorCode가 있으면 다른 action(dragToMovePlanInList)에서 호출하는 것이기 때문에 기존에 존재하는 planType일 것이므로 업데이트만 한다.
                        try await apiService.updatePlans(
                            [planToUpdate],
                            projectID
                        )
                    } else {
                        /// colorCode가 없으면 새 타입을 생성하고, emptyType일 planID의 타입을 생성된 타입으로 변경한다.
                        if newPlanType != PlanType.emptyPlanType {
                            try await apiService.createPlanType(
                                newPlanType,
                                planID,
                                projectID
                            )
                        }
                    }
                }
                
            case let .createPlanOnLine(row, startDate, endDate):
                var plansToCreate = [Plan]()
                var plansToUpdate = [Plan]()
                
                /// 0. row를 child로 포함하는 parentPlan이 있는지 먼저 확인
                var currentRowCount = -1
                var targetLaneParent: Plan?
                var targetLaneIndex: Int?
                for parentPlanID in state.map[state.map.count - 1] {
                    let laneCount = state.existingPlans[parentPlanID]!.childPlanIDs.count
                    if currentRowCount < row, row <= currentRowCount + laneCount {
                        targetLaneParent = state.existingPlans[parentPlanID]
                        targetLaneIndex = row - currentRowCount + 1
                        break
                    }
                    currentRowCount += laneCount
                }
                /// 1.  parentPlan이 없는데 라인을 먼저 그은 경우: lane을 먼저 만들어야 함
                var prevParentPlanID = state.rootPlan.id
                var newDummyPlanID = UUID().uuidString
                if targetLaneParent == nil {
                    for _ in currentRowCount+1...row {
                        for currentLayerIndex in 0..<state.map.count {
                            if currentLayerIndex == 0 {
                                state.rootPlan.childPlanIDs["\(state.map[0].count)"] = [newDummyPlanID]
                                state.existingPlans[state.rootPlan.id]?.childPlanIDs["\(state.map[0].count)"] = [newDummyPlanID]
                            } else {
                                state.existingPlans[prevParentPlanID]?.childPlanIDs["0"] = [newDummyPlanID]
                            }
                            let newDummyPlan = Plan(
                                id: newDummyPlanID,
                                planTypeID: PlanType.emptyPlanType.id,
                                childPlanIDs: [:]
                            )
                            state.existingPlans[newDummyPlanID] = newDummyPlan
                            state.map[currentLayerIndex].append(newDummyPlanID)
                            
                            /// 다음 더미 생성을 위한 세팅
                            prevParentPlanID = newDummyPlanID
                            newDummyPlanID = UUID().uuidString
                            
                            /// DB에 생성해줄 플랜들 담아
                            plansToCreate.append(state.existingPlans[prevParentPlanID]!)
                        }
                    }
                    targetLaneParent = state.existingPlans[state.map[state.map.count-1][row]]
                    targetLaneIndex = 0
                }
                
                /// 2. (row, layer)에 플랜이 존재하는 경우: 새 플랜을 생성하고 childIDs에 넣어주면 된다.
                let newPlanOnLine = Plan(
                    id: UUID().uuidString,
                    planTypeID: PlanType.emptyPlanType.id,
                    childPlanIDs: [:],
                    periods: ["0": [startDate, endDate]]
                )
                
                let lastLayerIndex = state.map.count - 1
                state.existingPlans[state.map[lastLayerIndex][row]]?.childPlanIDs["\(targetLaneIndex!)"]?.append(newPlanOnLine.id)
                
                /// 3. parentPlan의 total period를 업데이트
                if let prevTotalPeriod = state.existingPlans[state.map[lastLayerIndex][row]]?.totalPeriod {
                    state.existingPlans[state.map[lastLayerIndex][row]]?.totalPeriod![0] = min(startDate, prevTotalPeriod[0])
                    state.existingPlans[state.map[lastLayerIndex][row]]?.totalPeriod![1] = min(endDate, prevTotalPeriod[1])
                } else {
                    state.existingPlans[state.map[lastLayerIndex][row]]?.totalPeriod![0] = startDate
                    state.existingPlans[state.map[lastLayerIndex][row]]?.totalPeriod![0] = endDate
                }
                
                plansToCreate.append(newPlanOnLine)
                plansToUpdate.append(state.rootPlan)
                plansToUpdate.append(state.existingPlans[state.map[lastLayerIndex][row]]!)
                let plansToCreateImmutable = plansToCreate
                let plansToUpdateImmutable = plansToUpdate
                let projectID = state.rootProject.id
                return .run { _ in
                    try await apiService.createPlans(
                        plansToCreateImmutable,
                        projectID
                    )
                    try await apiService.updatePlans(
                        plansToUpdateImmutable,
                        projectID
                    )
                }
                
            case .readPlans:
                let projectID = state.rootProject.id
                return .run { send in
                    await send(.readPlansResponse(
                        TaskResult {
                            try await apiService.readPlans(projectID)
                        }
                    ))
                }
                
            // TODO: - 삭제
            case let .readPlansResponse(.failure(_)):
                print("fail")
                return .none
                
            case let .readPlansResponse(.success(responses)):
                for response in responses {
                    state.existingPlans[response.id] = response
                }
                return .none
                
            case let .updatePlan(targetPlanID, updateTo):
                let projectID = state.rootProject.id
                state.existingPlans[targetPlanID] = updateTo
                let planToUpdate = [state.existingPlans[targetPlanID]!]
                return .run { _ in
                    try await apiService.updatePlans(
                        planToUpdate,
                        projectID
                    )
                }
                
                // MARK: - listArea
            case let .createLayerButtonClicked(layer):
                let projectID = state.rootProject.id
                var updatedPlans = [Plan]()
                var createdPlans = [Plan]()
                state.map.insert([], at: layer)
                state.rootProject.countLayerInListArea += 1
                let prevLayerPlanIDs = layer == 0 ? [state.rootPlan.id] : state.map[layer - 1]
                if state.map.flatMap({ $0 }).isEmpty {
                    return .none
                }
                for prevPlanID in prevLayerPlanIDs {
                    let prevPlan = state.existingPlans[prevPlanID]!
                    for index in 0..<prevPlan.childPlanIDs.count {
                        let childPlanIDs = prevPlan.childPlanIDs[String(index)]!
                        let newPlan = Plan(
                            id: UUID().uuidString,
                            planTypeID: PlanType.emptyPlanType.id,
                            childPlanIDs: ["0": childPlanIDs]
                        )
                        state.existingPlans[newPlan.id] = newPlan
                        createdPlans.append(newPlan)
                        state.existingPlans[prevPlanID]!.childPlanIDs[String(index)] = [newPlan.id]
                        if prevPlanID != state.rootPlan.id {
                            updatedPlans.append(state.existingPlans[prevPlanID]!)
                        }
                    }
                    if prevPlanID == state.rootPlan.id && state.existingPlans[prevPlanID]!.childPlanIDs.isEmpty {
                        updatedPlans.append(state.existingPlans[prevPlanID]!)
                    }
                }
                let plansToUpdate = updatedPlans
                let plansToCreate = createdPlans
                let projectToUpdate = state.rootProject
                return .run { send in
                    try await apiService.updateProjects([projectToUpdate])
                    try await apiService.createPlans(
                        plansToCreate,
                        projectID
                    )
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                    await send(.reloadMap)
                }
                
            case let .createLaneButtonClicked(row, createOnTop):
                let projectID = state.rootProject.id
                var laneCount = -1
                let rootChildIDs = state.rootPlan.childPlanIDs.values.flatMap({ $0 })
                if state.map.count == 1 {
                    /// layer가 하나뿐이라면,
                    for rootChildID in rootChildIDs {
                        let rootChildLanes = state.existingPlans[rootChildID]!.childPlanIDs
                        let rootChildLaneCount = rootChildLanes.count
                        if laneCount < row, row <= laneCount + rootChildLaneCount {
                            /// row 발견
                            if createOnTop {
                                for index in stride(from: rootChildLaneCount - 1, through: -1, by: -1) {
                                    state.existingPlans[rootChildID]?.childPlanIDs["\(index + 1)"] = rootChildLanes["\(index)"]
                                }
                                state.existingPlans[rootChildID]!.childPlanIDs["0"] = []
                            } else {
                                state.existingPlans[rootChildID]!.childPlanIDs["\(rootChildLaneCount)"] = []
                            }
                            let planToUpdate = state.existingPlans[rootChildID]!
                            return .run { send in
                                try await apiService.updatePlans(
                                    [planToUpdate],
                                    projectID
                                )
                                await send(.reloadMap)
                            }
                        }
                        laneCount += rootChildLaneCount
                    }
                }
                /// layer가 두개라면, root (layer0)의 child부터 순회
                for rootChildID in rootChildIDs {
                    /// layer 1의 plan들을 순회
                    let rootChildPlan = state.existingPlans[rootChildID]!
                    let firstLayerPlanIDs = rootChildPlan.childPlanIDs
                    let mappingByPlanIDs = firstLayerPlanIDs.map { $0.value }.flatMap { $0 }
                    for firstLayerPlanID in mappingByPlanIDs {
                        let firstLayerPlanLanes = state.existingPlans[firstLayerPlanID]!.childPlanIDs
                        let firstLayerPlanLaneCount = firstLayerPlanLanes.count
                        if laneCount <= row, row <= laneCount + firstLayerPlanLaneCount {
                            /// row 발견
                            let newChildPlan = Plan(
                                id: UUID().uuidString,
                                planTypeID: PlanType.emptyPlanType.id,
                                childPlanIDs: ["0": []]
                            )
                            state.existingPlans[newChildPlan.id] = newChildPlan
                            if createOnTop {
                                for index in stride(from: firstLayerPlanLaneCount - 1, through: -1, by: -1) {
                                    state.existingPlans[rootChildID]?.childPlanIDs["\(index + 1)"] = firstLayerPlanLanes["\(index)"]
                                }
                                state.existingPlans[firstLayerPlanID]!.childPlanIDs["0"] = [newChildPlan.id]
                            } else {
                                state.existingPlans[firstLayerPlanID]!.childPlanIDs["\(firstLayerPlanLaneCount)"] = [newChildPlan.id]
                            }
                            let planToUpdate = state.existingPlans[firstLayerPlanID]!
                            return .run { send in
                                try await apiService.createPlans(
                                    [newChildPlan],
                                    projectID
                                )
                                try await apiService.updatePlans(
                                    [planToUpdate],
                                    projectID
                                )
                                await send(.reloadMap)
                            }
                        }
                    }
                }
                return .none
                
            case let .deleteLayer(layer):
                let projectID = state.rootProject.id
                var deletedPlans = [Plan]()
                var updatedPlans = [Plan]()
                state.rootProject.countLayerInListArea -= 1
                /// layer가 하나인데 layer 삭제를 했을 때는 view에서 막아야 함. 혹시나 해서.
                if state.map.count == 1 {
                    return .none
                } else {
                    /// layer 2개 일 때
                    let parentPlanIDs = layer == 0 ? [state.rootPlan.id] : state.map[layer - 1]
                    for parentPlanID in parentPlanIDs {
                        let parentPlan = state.existingPlans[parentPlanID]!
                        let childPlanIDs = parentPlan.childPlanIDs.compactMap { $0 }
                        let sortedChildPlanIDs = childPlanIDs.sorted { Int($0.key)! < Int($1.key)! }
                        let soltedChildPlanIDsArray = sortedChildPlanIDs.map { $0.value }.flatMap { $0 }
                        var newChildIDs: [String: [String]] = [:]
                        for childPlanID in soltedChildPlanIDsArray {
                            let childPlan = state.existingPlans[childPlanID]!
                            let lanes = childPlan.childPlanIDs
                            for lane in lanes {
                                let index = newChildIDs.count
                                newChildIDs[String(index)] = lane.value
                            }
                            /// 사라지는 layer에 속한 plan들 삭제
                            state.existingPlans[childPlanID] = nil
                            deletedPlans.append(childPlan)
                        }
                        state.existingPlans[parentPlanID]!.childPlanIDs = newChildIDs
                        updatedPlans.append(parentPlan)
                        if parentPlanID == state.rootPlan.id {
                            state.rootPlan.childPlanIDs = newChildIDs
                        }
                    }
                }
                let plansToUpdate = updatedPlans
                let plansToDelete = deletedPlans
                let projectToUpdate = state.rootProject
                return .run { send in
                    try await apiService.updateProjects([projectToUpdate])
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                    if !plansToDelete.isEmpty {
                        try await apiService.deletePlans(
                            plansToDelete,
                            projectID
                        )
                    }
                    await send(.reloadMap)
                }
                
            case let .deleteLayerContents(layer):
                let projectID = state.rootProject.id
                var updatedPlanIDs = Set<String>()
                let planIDsArray = state.map[layer]
                
                for planID in planIDsArray {
                    state.existingPlans[planID]!.planTypeID = PlanType.emptyPlanType.id
                    updatedPlanIDs.insert(planID)
                }
                let plansToUpdate = updatedPlanIDs.map({ state.existingPlans[$0]! })
                return .run { send in
                    await send(.reloadMap)
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                }
                
            case let .deletePlanOnList(layer, row):
                let projectID = state.rootProject.id
                var createdPlans = [Plan]()
                var updatedPlans = [Plan]()
                var deletedPlans = [Plan]()
                /// layer에 있는 plan들의 높이 구하기
                var planHeightsArray = [String: Int]()
                for planID in state.map[layer] {
                    let childPlanIDsArray = state.existingPlans[planID]!.childPlanIDs
                    planHeightsArray[planID] = childPlanIDsArray.count
                }
                /// click된 위치에 있는 planID 찾기
                var sumOfHeights = 0
                var targetPlanID = ""
                for planID in state.map[layer] {
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
                    let childPlanIDs = state.existingPlans[parentPlanID]!.childPlanIDs
                    for childPlanIDsArray in childPlanIDs where childPlanIDsArray.value.contains(targetPlanID) {
                        targetParentPlanID = parentPlanID
                        targetKey = childPlanIDsArray.key
                        break
                    }
                }
                /// 현재 listArea에 보여지는 Plan들은 부모의 childIDs 배열에서 한 lane에 나만 속해있다. 하나의 레인에 나 외에 다른 플랜들이 있는 상황은 가정하지 않음. 따라서 부모의 레인들 중 내가 속한 레인에서 나를 빼면 그 레인은 당연히 0이 됨.
                /// 부모가 내 레인만 들고 있었을 경우
                if state.existingPlans[targetParentPlanID]!.childPlanIDs.count == 1 {
                    /// 그 부모가 root일 경우: Layer가 0
                    if targetParentPlanID == state.rootPlan.id {
                        state.existingPlans[targetParentPlanID]!.childPlanIDs = [:]
                        /// 부모의 childs를 지워주면 map에 layer2개 이상이었을 때에도 layer는 1개만 보여지므로, map의 크기만큼 map에 빈 배열을 추가하고 빠져나감.
                        if state.map.count != 1 {
                            var newMap: [[String]] = []
                            for _ in 0..<state.map.count {
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
                        state.existingPlans[newPlanID] = newPlan
                        createdPlans.append(newPlan)
                        state.existingPlans[targetParentPlanID]!.childPlanIDs = ["0": [newPlanID]]
                    }
                    /// 부모가 나말고 다른 레인도 들고 있었을 경우
                } else {
                    /// 부모의 childPlanIDs에서 내 레인을 제거하고
                    state.existingPlans[targetParentPlanID]!.childPlanIDs.removeValue(forKey: targetKey)
                    /// 인덱스에 맞게 key를 다시 부여한다.
                    let sortedChildPlanIDs = state.existingPlans[targetParentPlanID]!.childPlanIDs.sorted { Int($0.key)! < Int($1.key)! }
                    var orderedChildPlanIDs = [String: [String]]()
                    for index in 0..<sortedChildPlanIDs.count {
                        orderedChildPlanIDs[String(index)] = sortedChildPlanIDs[index].value
                    }
                    state.existingPlans[targetParentPlanID]!.childPlanIDs = orderedChildPlanIDs
                }
                updatedPlans.append(state.existingPlans[targetParentPlanID]!)
                
                /// 삭제한 plan과 그 하위 플랜들을 삭제해줌.
                let deletedPlanID = state.existingPlans[targetParentPlanID]!.childPlanIDs[targetKey]!.last!
                var planIDsQ: [String] = [deletedPlanID]
                var tempLayer: [String] = []
                while !planIDsQ.isEmpty {
                    for planID in planIDsQ {
                        deletedPlans.append(state.existingPlans[planID]!)
                        let plan = state.existingPlans[planID]!
                        for index in 0..<plan.childPlanIDs.count {
                            tempLayer.append(contentsOf: plan.childPlanIDs[String(index)]!)
                        }
                    }
                    planIDsQ.removeAll()
                    planIDsQ.append(contentsOf: tempLayer)
                }
                for deletedPlan in deletedPlans {
                    state.existingPlans[deletedPlan.id] = nil
                }
                
                let plansToCreate = createdPlans
                let plansToUpdate = updatedPlans
                let plansToDelete = deletedPlans
                return .run { send in
                    await send(.reloadMap)
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
                    try await apiService.deletePlans(
                        plansToDelete,
                        projectID
                    )
                }
                
            case let .deletePlanOnLine(selectedRanges):
                let projectID = state.rootProject.id
                var updatedPlans = [Plan]()
                var deletedPlans = [Plan]()
                let layer = state.map.count - 1
                
                /// 리스트에서 보여주는 마지막 Row의 높이를 계산
                var planHeightsArray = [String: Int]()
                for planID in state.map[layer] {
                    let childPlanIDsArray = state.existingPlans[planID]!.childPlanIDs
                    planHeightsArray[planID] = childPlanIDsArray.count
                }
                
                /// 선택된 범위의 개수만큼 순회한다.
                for selectedRange in selectedRanges {
                    let startRow = min(selectedRange.start.row, selectedRange.end.row)
                    let endRow = max(selectedRange.start.row, selectedRange.end.row)
                    // TODO: - 기준 날짜로 대체
                    let startDate = Calendar.current.date(
                        byAdding: .day,
                        value: min(
                            selectedRange.start.col,
                            selectedRange.end.col
                        ),
                        to: Date().filteredDate
                    )!
                    let endDate = Calendar.current.date(
                        byAdding: .day,
                        value: max(
                            selectedRange.start.col,
                            selectedRange.end.col
                        ),
                        to: Date().filteredDate
                    )!
                    /// 범위 내의 row마다 순회한다.
                    for row in startRow...endRow {
                        /// row가 어떤 Plan을 가리키고
                        var sumOfHeights = 0
                        var targetPlanID = ""
                        for planID in state.map[layer] {
                            sumOfHeights += planHeightsArray[planID]!
                            if row < sumOfHeights {
                                targetPlanID = planID
                                break
                            }
                        }
                        /// 몇 번째 레인인지 계산한다
                        let targetPlan = state.existingPlans[targetPlanID]!
                        let rowDifference = (sumOfHeights - 1) - row
                        let targetKey = (targetPlan.childPlanIDs.count - 1) - rowDifference
                        /// 해당 레인에 있는 planID마다 순회한다
                        let childIDs = state.existingPlans[targetPlanID]!.childPlanIDs[String(targetKey)]!
                        for planID in childIDs {
                            /// period가 있는 plan이라면 period만큼 순회한다.
                            if let periods = state.existingPlans[planID]!.periods {
                                for period in periods {
                                    let start = period.value[0]
                                    let end = period.value[1]
                                    
                                    if end < startDate || start > endDate {
                                        /// period가 범위 밖에 있는 경우 > 아무것도 안 함
                                        break
                                    } else if (start < startDate) && (end <= endDate) {
                                        /// period의 끝 날짜가 범위에 걸친 경우 >  끝 날짜를 startDate로 업데이트 해줌
                                        state.existingPlans[planID]!.periods![period.key] = [start, startDate]
                                    } else if (start >= startDate) && (end > endDate) {
                                        /// period의 시작 날짜가 범위에 걸친 경우 > 시작 날짜를 endDate로 업데이트 해줌
                                        state.existingPlans[planID]!.periods![period.key] = [endDate, end]
                                    } else if (start >= startDate) && (end <= endDate) {
                                        /// period가 범위 내에 속할 경우 > period 삭제
                                        state.existingPlans[planID]!.periods!.removeValue(forKey: String(period.key))
                                        /// 만약 plan이 가진 periods가 없어졌으면
                                        if state.existingPlans[planID]!.periods!.isEmpty {
                                            /// updatedPlans에 삭제할 plan의 ID 있다면 삭제해주고
                                            if let index = updatedPlans.firstIndex(where: { $0.id == planID }) {
                                                updatedPlans.remove(at: index)
                                            }
                                            /// 삭제할 plan에 추가
                                            state.existingPlans[planID] = nil
                                            deletedPlans.append(state.existingPlans[planID]!)
                                            /// 나를 들고 있는 plan의 childPlans에서 나를 빼주고(lane은 남아있음), updatedPlans에 나를 들고 있는 plan 추가
                                            if var array = state.existingPlans[targetPlanID]!.childPlanIDs[String(targetKey)] {
                                                array = array.filter { $0 != planID }
                                                state.existingPlans[targetPlanID]!.childPlanIDs[String(targetKey)]! = array
                                            }
                                        } else {
                                            /// period 원소들을 key값에 따라 정렬해줌
                                            let sortedPeriods = state.existingPlans[planID]!.periods!.sorted { Int($0.key)! < Int($1.key)! }
                                            var orderedPeriods = [String: [Date]]()
                                            for index in 0..<sortedPeriods.count {
                                                orderedPeriods[String(index)] = sortedPeriods[index].value
                                            }
                                            state.existingPlans[planID]!.periods = orderedPeriods
                                        }
                                    } else if (start < startDate) && (end > endDate) {
                                        /// period 내에 범위가 속할 경우 [시작날짜, startDate], [endDate, end]로 나눠줌
                                        state.existingPlans[planID]!.periods![period.key] = [start, startDate]
                                        let lastIndex = state.existingPlans[planID]!.periods!.count
                                        state.existingPlans[planID]!.periods![String(lastIndex)] = [endDate, end]
                                    }
                                    if updatedPlans.firstIndex(where: { $0.id == planID }) == nil {
                                        updatedPlans.append(state.existingPlans[planID]!)
                                    }
                                }
                            }
                        }
                    }
                }
                let plansToUpdate = updatedPlans
                let plansToDelete = deletedPlans
                return .run { send in
                    await send(.reloadMap)
                    if !plansToUpdate.isEmpty {
                        try await apiService.updatePlans(
                            plansToUpdate,
                            projectID
                        )
                    }
                    if !plansToDelete.isEmpty {
                        try await apiService.deletePlans(
                            plansToDelete,
                            projectID
                        )
                    }
                }
                
            case let .deleteLaneOnLine(row):
                let projectID = state.rootProject.id
                var updatedPlans = [Plan]()
                var deletedPlans = [Plan]()
                let layer = state.map.count - 1
                
                let planIDsArray = state.map[layer]
                var planHeightsArray = [String: Int]()
                for planID in planIDsArray {
                    let childPlanIDsArray = state.existingPlans[planID]!.childPlanIDs
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
                
                let targetParentPlanID = targetPlanID
                let targetParentPlan = state.existingPlans[targetParentPlanID]!
                /// 내 row가 내가 속한 부모 Plan의 childIDs에서 몇번째인지 계산
                let rowDifference = (sumOfHeights - 1) - row
                let targetKey = (targetParentPlan.childPlanIDs.count - 1) - rowDifference
                for planID in state.existingPlans[targetPlanID]!.childPlanIDs[String(targetKey)]! {
                    state.existingPlans[planID] = nil
                    deletedPlans.append(state.existingPlans[planID]!)
                }
                /// 내 부모가 내 lane만 들고 있었을 경우
                if state.existingPlans[targetParentPlanID]!.childPlanIDs.count == 1 {
                    state.existingPlans[targetParentPlanID]!.childPlanIDs = ["0": []]
                } else {
                    state.existingPlans[targetParentPlanID]!.childPlanIDs.removeValue(forKey: String(targetKey))
                    /// 인덱스에 맞게 key를 다시 부여한다.
                    let sortedChildPlanIDs = state.existingPlans[targetParentPlanID]!.childPlanIDs.sorted { Int($0.key)! < Int($1.key)! }
                    var orderedChildPlanIDs = [String: [String]]()
                    for index in 0..<sortedChildPlanIDs.count {
                        orderedChildPlanIDs[String(index)] = sortedChildPlanIDs[index].value
                    }
                    state.existingPlans[targetParentPlanID]!.childPlanIDs = orderedChildPlanIDs
                }
                updatedPlans.append(state.existingPlans[targetParentPlanID]!)
                let plansToUpdate = updatedPlans
                let plansToDelete = deletedPlans
                return .run { send in
                    await send(.reloadMap)
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                    if !plansToDelete.isEmpty {
                        try await apiService.deletePlans(
                            plansToDelete,
                            projectID
                        )
                    }
                }
                
            case let .deleteLaneConents(rows):
                let projectID = state.rootProject.id
                var updatedPlans = [Plan]()
                var deletedPlans = [Plan]()
                
                let startRow = rows[0]
                let endRow = rows[1]
                var changedPlanIDs = [String]()
                
                /// 선택된 row에 보이는 childPlanIDs를 빈 레인으로 갈아끼워줌
                let layer = state.map.count - 1
                let planIDsArray = state.map[layer]
                var planHeightsArray = [String: Int]()
                
                for planID in planIDsArray {
                    let childPlanIDsArray = state.existingPlans[planID]!.childPlanIDs
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
                    
                    let targetParentPlan = state.existingPlans[targetPlanID]!
                    /// 내 row가 내가 속한 부모 Plan의 childIDs에서 몇번째인지 계산
                    let rowDifference = (sumOfHeights - 1) - row
                    let targetKey = (targetParentPlan.childPlanIDs.count - 1) - rowDifference
                    /// lane을 빈 lane으로 갈아끼워 줌
                    state.existingPlans[targetPlanID]!.childPlanIDs[String(targetKey)] = []
                    updatedPlans.append(state.existingPlans[targetPlanID]!)
                    /// lane에 속한 plan들은 삭제해줌
                    for planID in state.existingPlans[targetPlanID]!.childPlanIDs[String(targetKey)]! {
                        state.existingPlans[planID] = nil
                        deletedPlans.append(state.existingPlans[planID]!)
                    }
                    changedPlanIDs.append(targetPlanID)
                }
                
                /// 상위 레이어에 대해서도 row값이 어떤 plan인지 찾아줌
                let upperPlanIDsArray = layer == 0 ? [state.rootPlan.id] : state.map[layer - 1]
                var upperPlanHeightsArray = [String: Int]()
                for upperPlanID in upperPlanIDsArray {
                    let childPlanIDsArray = state.existingPlans[upperPlanID]!.childPlanIDs
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
                for planID in numOfChangePerPlan.keys where numOfChangePerPlan[planID] == state.existingPlans[planID]!.childPlanIDs.count {
                    state.existingPlans[planID]!.planTypeID = PlanType.emptyPlanType.id
                    updatedPlans.append(state.existingPlans[planID]!)
                }
                let plansToUpdate = updatedPlans
                return .run { send in
                    await send(.reloadMap)
                    
                    try await apiService.updatePlans(
                        plansToUpdate,
                        projectID
                    )
                }
                
            case let .mergePlans(layer, planIDs):
                var planIDsToUpdate = Set<String>()
                if planIDs.count < 1 { return .none }
                
                var currentTopPlanChildCount = state.existingPlans[planIDs[0]]!.childPlanIDs.count
                
                for (index, planID) in planIDs.enumerated() {
                    if index == 0 { continue }
                    
                    /// 1. 최상위 플랜에 child들을 모두 병합
                    let childPlanIDsToAppend = state.existingPlans[planID]!.childPlanIDs
                    for (key, childValue) in childPlanIDsToAppend {
                        state.existingPlans[planIDs[0]]!.childPlanIDs["\(currentTopPlanChildCount + Int(key)!)"] = childValue
                    }
                    currentTopPlanChildCount += childPlanIDsToAppend.count
                    
                    /// 2. 병합된 플랜들을 map에서 삭제
                    state.map[layer].remove(at: state.map[layer].firstIndex(of: planID)!)
                    
                    /// 3 병합된 플랜들을 부모에서 삭제
                    if layer == 0 {
                        /// root에서 삭제
                        let rootChildIDs = state.rootPlan.childPlanIDs
                        var indexToDelete: Int?
                        for (index, currentRootChild) in rootChildIDs.enumerated() {
                            if index == rootChildIDs.count - 1 { break }
                            if currentRootChild.value.contains(planID) {
                                indexToDelete = index
                            }
                            if indexToDelete == nil {
                                state.rootPlan.childPlanIDs["\(index)"] = state.rootPlan.childPlanIDs["\(index + 1)"]
                            }
                        }
                        state.rootPlan.childPlanIDs["\(rootChildIDs.count - 1)"] = nil
                        state.existingPlans[state.rootPlan.id] = state.rootPlan
                        planIDsToUpdate.insert(state.rootPlan.id)
                    } else {
                        for parentID in state.map[layer-1] {
                            let parentPlan = state.existingPlans[parentID]!
                            
                            /// 부모를 발견했다
                            if parentPlan.childPlanIDs.map({$0.value}).flatMap({$0}).contains(planID) {
                                /// 부모가 가진 레인이 하나이고, 그 레인 내에 차일드가 병합된 플랜 하나라면 빈 레인으로 갈아끼워준다
                                if parentPlan.childPlanIDs.count == 1,
                                   parentPlan.childPlanIDs["0"]!.count == 1 {
                                    state.existingPlans[parentID]?.childPlanIDs["0"] = []
                                    planIDsToUpdate.insert(parentID)
                                    break
                                }
                                
                                let laneIndex = parentPlan.childPlanIDs.first(where: { $0.value.contains(planID) })!.key
                                let indexInLane = parentPlan.childPlanIDs[laneIndex]!.firstIndex(of: planID)!
                                /// 병합된 플랜이 속한 레인에 child가 이거 하나라면 레인을 삭제하고 나머지 레인들을 다시 정렬
                                if parentPlan.childPlanIDs[laneIndex]!.count == 1 {
                                    for currentLaneIndex in Int(laneIndex)!..<parentPlan.childPlanIDs.count {
                                        state.existingPlans[parentID]!.childPlanIDs["\(currentLaneIndex)"] = state.existingPlans[parentID]!.childPlanIDs["\(currentLaneIndex + 1)"]
                                    }
                                    state.existingPlans[parentID]!.childPlanIDs["\(parentPlan.childPlanIDs.count - 1)"] = nil
                                } else { /// 아니라면 해당 레인에서 병합된 플랜만 삭제
                                    state.existingPlans[parentID]!.childPlanIDs[laneIndex]!.remove(at: indexInLane)
                                }
                                planIDsToUpdate.insert(parentID)
                                break
                            }
                        }
                    }
                }
                planIDsToUpdate.insert(planIDs[0])
                let projectID = state.rootProject.id
                let plansToUpdate = planIDsToUpdate.map { state.existingPlans[$0]! }
                let plansToDelete = Array(planIDs[1..<planIDs.count])
                return .run { send in
                    try await apiService.updatePlans(plansToUpdate, projectID)
                    try await apiService.deletePlansCompletely(plansToDelete, projectID)
                    await send(.reloadMap)
                }
                
                // MARK: - TimelineLayout
            case let .isShiftKeyPressed(isPressed):
                state.isShiftKeyPressed = isPressed
                return .none
                
            case let .isCommandKeyPressed(isPressed):
                state.isCommandKeyPressed = isPressed
                return .none
                
                // MARK: - GridSizeController
            case let .changeWidthButtonTapped(diff):
                state.gridWidth += diff
                return .none
                
            case let .changeHeightButtonTapped(diff):
                state.lineAreaGridHeight += diff
                return .none
                
                // MARK: - scheduleAreaView
            case let .magnificationChangedInScheduleArea(value):
                state.gridWidth = min(max(state.gridWidth * min(max(value, 0.5), 2.0), state.minGridSize), state.maxGridSize)
                state.scheduleAreaGridHeight = min(max(state.scheduleAreaGridHeight * min(max(value, 0.5), 2.0), state.minGridSize), state.maxGridSize)
                return .none
                
                // MARK: - LineAreaView
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
                
            case let .dragExceeded(shiftedRow, shiftedCol, exceededRow, exceededCol):
                state.shiftedRow += shiftedRow
                state.shiftedCol += shiftedCol
                state.exceededRow += exceededRow
                state.exceededCol += exceededCol
                return .none
                
            case let .dragToChangePeriod(planID, originPeriod, updatedPeriod):
                if originPeriod == updatedPeriod { return .none }
                let periodIndex = state.existingPlans[planID]?.periods?.first(where: { $0.value == originPeriod })!.key
                state.existingPlans[planID]!.periods![periodIndex!]! = updatedPeriod
                
                var foundParentID: String?
                /// 부모 plan의 totalPeriod를 업데이트
                for parentPlanID in state.map[state.map.count-1] {
                    var parentPlan = state.existingPlans[parentPlanID]!
                    if parentPlan.childPlanIDs.map({$0.value}).flatMap({$0}).contains(planID) {
                        foundParentID = parentPlanID
                        parentPlan.totalPeriod![0] = min(parentPlan.totalPeriod![0], updatedPeriod[0])
                        parentPlan.totalPeriod![1] = min(parentPlan.totalPeriod![1], updatedPeriod[1])
                        break
                    }
                }
                
                let plansToUpdate = [state.existingPlans[planID]!, state.existingPlans[foundParentID!]!]
                let projectID = state.rootProject.id
                return .run { _ in
                    try await apiService.updatePlans(plansToUpdate, projectID)
                }
                
            case let .dragToMoveLine(sourceIndexToMove, destinationIndexToMove):
                if sourceIndexToMove == destinationIndexToMove { return .none }
                let projectID = state.rootProject.id
                /// 옮기려는 레인의 부모플랜과 그 child 내에서의 인덱스를 구함
                let parentLayer = state.map[state.map.count - 1]
                var laneCount = -1
                var foundSourceParentPlan = state.rootPlan
                var foundDestinationParentPlan: Plan?
                var sourceLaneIndexInParent = 0
                var destinationLaneIndexInParent = 0
                
                for parentPlanID in parentLayer {
                    let parentPlan = state.existingPlans[parentPlanID]!
                    let childCount = parentPlan.childPlanIDs.count
                    if laneCount < sourceIndexToMove, sourceIndexToMove <= laneCount + childCount {
                        foundSourceParentPlan = parentPlan
                        sourceLaneIndexInParent = laneCount + 1 - sourceIndexToMove
                    }
                    if laneCount + 1 < destinationIndexToMove, destinationIndexToMove < laneCount + childCount {
                        foundDestinationParentPlan = parentPlan
                        destinationLaneIndexInParent = laneCount + 1 - destinationIndexToMove
                    }
                    laneCount += childCount
                }
                
                if let foundDestinationParentPlan = foundDestinationParentPlan {
                    /// source와 dest의 부모가 같다면 child 내에서만 순서 바꾸어주면 됨
                    if foundDestinationParentPlan.id == foundSourceParentPlan.id {
                        /// 위에 있던 것을 아래로 옮겨줄 때
                        if sourceLaneIndexInParent < destinationLaneIndexInParent {
                            for laneIndex in sourceLaneIndexInParent..<destinationLaneIndexInParent {
                                state.existingPlans[foundDestinationParentPlan.id]!.childPlanIDs["\(laneIndex)"] = foundDestinationParentPlan.childPlanIDs["\(laneIndex + 1)"]
                            }
                            state.existingPlans[foundSourceParentPlan.id]!.childPlanIDs["\(destinationLaneIndexInParent)"] = foundSourceParentPlan.childPlanIDs["\(sourceLaneIndexInParent)"]
                        } else {
                            /// 아래에 있던 것을 위로 옮겨줄 때
                            for laneIndex in stride(from: sourceLaneIndexInParent - 1, through: destinationLaneIndexInParent - 1, by: -1) {
                                state.existingPlans[foundDestinationParentPlan.id]!.childPlanIDs["\(laneIndex + 1)"] = foundDestinationParentPlan.childPlanIDs["\(laneIndex)"]
                            }
                            state.existingPlans[foundSourceParentPlan.id]!.childPlanIDs["\(destinationLaneIndexInParent)"] = foundSourceParentPlan.childPlanIDs["\(sourceLaneIndexInParent)"]
                        }
                    } else { /// source와 dest의 부모가 다르지만, 발견된 destination의 부모가 있다면 해당 부모의 child로 편입
                        for laneIndex in destinationLaneIndexInParent+1..<foundDestinationParentPlan.childPlanIDs.count {
                            state.existingPlans[foundDestinationParentPlan.id]!.childPlanIDs["\(laneIndex)"] = foundDestinationParentPlan.childPlanIDs["\(laneIndex+1)"]
                        }
                        state.existingPlans[foundDestinationParentPlan.id]!.childPlanIDs["\(destinationLaneIndexInParent)"] = foundSourceParentPlan.childPlanIDs["\(sourceLaneIndexInParent)"]
                        
                        // !!!: - 중복코드 (바로 아래)
                        /// 기존 source 부모의 child에서 삭제
                        for laneIndex in sourceLaneIndexInParent+1..<foundSourceParentPlan.childPlanIDs.count {
                            state.existingPlans[foundSourceParentPlan.id]!.childPlanIDs["\(laneIndex-1)"] = foundSourceParentPlan.childPlanIDs["\(laneIndex)"]
                        }
                        state.existingPlans[foundSourceParentPlan.id]!.childPlanIDs["\(foundSourceParentPlan.childPlanIDs.count - 1)"] = nil
                    }
                } else {
                    // !!!: - 중복코드 (바로 윗줄)
                    /// 기존 source 부모의 child에서 삭제
                    for laneIndex in sourceLaneIndexInParent+1..<foundSourceParentPlan.childPlanIDs.count {
                        state.existingPlans[foundSourceParentPlan.id]!.childPlanIDs["\(laneIndex-1)"] = foundSourceParentPlan.childPlanIDs["\(laneIndex)"]
                    }
                    state.existingPlans[foundSourceParentPlan.id]!.childPlanIDs["\(foundSourceParentPlan.childPlanIDs.count - 1)"] = nil
                    let plansToUpdate = [state.existingPlans[foundSourceParentPlan.id]!]
                    let foundSourceParentPlanImmutable = foundSourceParentPlan
                    return .run { send in
                        await send(.createLaneButtonClicked(row: destinationIndexToMove, createOnTop: true))
                        await send(.updatePlan(
                            targetPlanID: foundSourceParentPlanImmutable.id,
                            updateTo: foundSourceParentPlanImmutable)
                        )
                        try await apiService.updatePlans(plansToUpdate, projectID)
                        await send(.reloadMap)
                    }
                }
                
                let plansToUpdate = [state.existingPlans[foundSourceParentPlan.id]!, state.existingPlans[foundDestinationParentPlan!.id]!]
                return .run { send in
                    await send(.reloadMap)
                    try await apiService.updatePlans(plansToUpdate, projectID)
                }
                
            case let .dragToMovePlanInList(targetID, source, destination, row, layer):
                if source == destination { return .none }
                let projectID = state.rootProject.id
                if layer == 0 {
                    /// 0번 레이어일 때는 root의 childs에서 순서만 바꿔주면 된다
                    if source < destination {
                        for index in source..<destination {
                            state.rootPlan.childPlanIDs["\(index)"] = state.rootPlan.childPlanIDs["\(index + 1)"]
                        }
                    } else {
                        for index in stride(from: source, through: destination, by: -1) {
                            state.rootPlan.childPlanIDs["\(index)"] = state.rootPlan.childPlanIDs["\(index - 1)"]
                        }
                    }
                    state.rootPlan.childPlanIDs["\(destination)"] = [targetID]
                    state.map[0].remove(at: source)
                    state.map[0].insert(targetID, at: destination)
                    state.existingPlans[state.rootPlan.id] = state.rootPlan
                    
                    let planToUpdate = [state.rootPlan]
                    return .run { send in
                        try await apiService.updatePlans(planToUpdate, projectID)
                        await send(.reloadMap)
                    }
                } else {
                    /// 플랜이 생성되어 있지 않은 곳으로 옮기는 경우
                    let targetPlan = state.existingPlans[targetID]!
                    let targetPlanType = state.existingPlanTypes[targetPlan.planTypeID]!
                    if state.map[layer].count <= destination {
                        return .run { send in
                            await send(.createPlanOnList(
                                layer: layer,
                                row: row,
                                text: targetPlanType.title,
                                colorCode: targetPlanType.colorCode)
                            )
                            await send(.updatePlan(
                                targetPlanID: targetPlan.id,
                                updateTo: targetPlan)
                            )
                            await send(.reloadMap)
                        }
                    }
                    
                    /// 플랜이 이미 생성되어 있는 위치로 옮기는 경우
                    let parentLayer = state.map[layer - 1]
                    var targetParentPlan = state.rootPlan
                    var targetLaneIndexInParent = "0"
                    
                    let currentPlanIDInDestinaton = state.map[layer][destination]
                    var destinationParentPlan = state.rootPlan
                    var destinationLaneIndexInParent = "0"
                    
                    for parentPlanID in parentLayer {
                        let parentPlan = state.existingPlans[parentPlanID]!
                        let childsForArray = parentPlan.childPlanIDs.map({ $0.value }).flatMap({ $0 })
                        if childsForArray.contains(targetID) {
                            targetParentPlan = parentPlan
                            targetLaneIndexInParent = parentPlan.childPlanIDs.filter({ $0.value.contains(targetID) })[0].key
                        }
                        if childsForArray.contains(currentPlanIDInDestinaton) {
                            destinationParentPlan = parentPlan
                            destinationLaneIndexInParent = parentPlan.childPlanIDs.filter({ $0.value.contains(currentPlanIDInDestinaton)})[0].key
                        }
                    }
                    
                    /// 동일 부모 내에서 순서만 바꾸는 경우
                    if destinationParentPlan.id == targetParentPlan.id {
                        /// 그런데 destination의 laneIndex가 위아래 끝이면 위치가 바뀌는게 아니라 새 레인이 생긴다
                        let destinationParentChilds = destinationParentPlan.childPlanIDs
                        let countDestinationParentChilds = destinationParentChilds.map({ $0.value }).flatMap({ $0 }).count
                        if Int(destinationLaneIndexInParent)! % countDestinationParentChilds == 0 {
                            return .run { send in
                                await send(.createPlanOnList(
                                    layer: layer,
                                    row: row,
                                    text: targetPlanType.title,
                                    colorCode: targetPlanType.colorCode)
                                )
                                await send(.updatePlan(
                                    targetPlanID: targetPlan.id,
                                    updateTo: targetPlan)
                                )
                                await send(.reloadMap)
                            }
                        } else {
                            /// 동일 레인이라면, source가 dest 위치로 이동
                            if targetLaneIndexInParent == destinationLaneIndexInParent {
                                state.existingPlans[targetParentPlan.id]!.childPlanIDs[targetLaneIndexInParent]!
                                    .remove(at: destinationParentChilds[targetLaneIndexInParent]!.firstIndex(where: { $0 == targetID})!)
                                state.existingPlans[targetParentPlan.id]!.childPlanIDs[targetLaneIndexInParent]!.insert(targetID, at: destination)
                                state.map[layer].remove(at: source)
                                state.map[layer].insert(targetID, at: destination)
                            }
                            let plansToUpdate = [state.existingPlans[targetParentPlan.id]!]
                            return .run { _ in
                                try await apiService.updatePlans(
                                    plansToUpdate,
                                    projectID
                                )
                            }
                        }
                    }
                    
                    // !!!: - layer가 #0, #1만 있을 때 사용가능한 로직
                    /// dest 부모의 그 부모(layer0)의 인덱스를 파악
                    var indexInRoot = 0
                    for (index, firstLayerPlanID) in state.map[0].enumerated() {
                        let firstLayerChildIDs = state.existingPlans[firstLayerPlanID]!.childPlanIDs
                        let firstLayerChildIDsInArray = firstLayerChildIDs.map({ $0.value }).flatMap({ $0 })
                        if firstLayerChildIDsInArray.contains(destinationParentPlan.id) {
                            indexInRoot = index
                        }
                    }
                    
                    /// 서로 다른 부모와 부모 플랜 사이에 생성하는 경우: 새 부모 플랜 생성
                    var planIDsToCreate = Set<String>()
                    var newParentPlan = state.rootPlan
                    for currentLayerIndex in 0..<layer {
                        let newPlan = Plan(id: UUID().uuidString, planTypeID: PlanType.emptyPlanType.id, childPlanIDs: [:])
                        state.existingPlans[newPlan.id] = newPlan
                        if newParentPlan.childPlanIDs["0"] != nil {
                            state.existingPlans[newParentPlan.id]!.childPlanIDs["0"]!.insert(newPlan.id, at: indexInRoot)
                        } else {
                            state.existingPlans[newParentPlan.id]!.childPlanIDs["0"] = [newPlan.id]
                        }
                        newParentPlan = newPlan
                        if currentLayerIndex > 0 {
                            planIDsToCreate.insert(newPlan.id)
                        }
                    }
                    state.existingPlans[newParentPlan.id]!.childPlanIDs["0"] = [targetID]
                    
                    /// 기존 부모 플랜의 레인이 가진 플랜이 나 하나뿐이라면 날 삭제하고도 레인은 남아있어야 함
                    state.existingPlans[targetParentPlan.id]!.childPlanIDs[targetLaneIndexInParent]!.remove(at: targetParentPlan.childPlanIDs[targetLaneIndexInParent]!.firstIndex(of: targetID)!)
                    
                    let plansToCreate = planIDsToCreate.map({ state.existingPlans[$0]! })
                    let plansToUpdate = [state.rootPlan, state.existingPlans[targetParentPlan.id]!]
                    return .run { send in
                        await send(.reloadMap)
                        try await apiService.createPlans(
                            plansToCreate,
                            projectID
                        )
                        try await apiService.updatePlans(
                            plansToUpdate,
                            projectID
                        )
                    }
                }
                
            case let .dragToMovePlanInLine(moveRowTo, targetPlanID, startDate, endDate):
                let projectID = state.rootProject.id
                let targetPlan = state.existingPlans[targetPlanID]!
                var currentRowCount = -1
                var targetParentPlan = state.rootPlan
                var destinationParentPlan: Plan?
                var laneIndexInParent = 0
                
                /// 지우려는 targetPlan의 현재 부모를 찾는다
                for parentPlanID in state.map[state.map.count - 1] {
                    let parentPlan = state.existingPlans[parentPlanID]!
                    if parentPlan.childPlanIDs.map({ $0.value }).flatMap({ $0 }).contains(targetPlanID) {
                        targetParentPlan = parentPlan
                    }
                    if currentRowCount < moveRowTo, moveRowTo <= currentRowCount + parentPlan.childPlanIDs.count {
                        destinationParentPlan = parentPlan
                        laneIndexInParent = currentRowCount - moveRowTo
                    }
                    currentRowCount += parentPlan.childPlanIDs.count
                }
                /// targetPlan이 periods가 여러개인 경우
                if state.existingPlans[targetPlanID]!.periods!.count > 1 {
                    /// 기존 parent에서 해당하는 period만 삭제
                    let periodsIndex = state.existingPlans[targetPlanID]!.periods!.filter { $0.value == [startDate, endDate] }[0].key
                    for currentPeriodsIndex in Int(periodsIndex)!..<targetPlan.periods!.count-1 {
                        state.existingPlans[targetPlanID]!.periods!["\(currentPeriodsIndex)"] = targetPlan.periods!["\(currentPeriodsIndex + 1)"]
                    }
                    state.existingPlans[targetPlanID]!.periods!["\(targetPlan.periods!.count - 1)"] = nil
                } else {
                    /// targetPlan이 periods가 단 하나인 경우
                    /// 기존 parent의 child lane에서 플랜을 삭제하는데, 플랜이 이 레인이 이거 하나뿐이었더라도 레인은 삭제되지 않음
                    state.existingPlans[targetParentPlan.id]!.childPlanIDs["\(laneIndexInParent)"]!.remove(at: targetParentPlan.childPlanIDs["\(laneIndexInParent)"]!.firstIndex(of: targetPlanID)!)
                }
                
                if let destinationParentPlan = destinationParentPlan {
                    /// 이미 존재하는 plan에게 종속시키는 경우
                    state.existingPlans[destinationParentPlan.id]!.periods!["\(destinationParentPlan.periods!.count)"] = [startDate, endDate]
                    let plansToUpdate = [state.existingPlans[targetParentPlan.id]!, state.existingPlans[destinationParentPlan.id]!, state.existingPlans[targetPlanID]!]
                    return .run { send in
                        await send(.reloadMap)
                        try await apiService.updatePlans(plansToUpdate, projectID)
                    }
                } else {
                    let plansToUpdate = [state.existingPlans[targetParentPlan.id]!, state.existingPlans[targetPlanID]!]
                    /// 없는 lane에 갖다넣은 경우
                    return .run { send in
                        await send(.createPlanOnLine(row: moveRowTo, startDate: startDate, endDate: endDate))
                        await send(.reloadMap)
                        try await apiService.updatePlans(plansToUpdate, projectID)
                    }
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
                
            case let .windowSizeChanged(newSize):
                state.maxLineAreaRow = Int(newSize.height / state.lineAreaGridHeight) + 1
                state.maxCol = Int(newSize.width / state.gridWidth) + 1
                return .none
                
            case let .gridSizeChanged(geometrySize):
                state.maxLineAreaRow = Int(geometrySize.height / state.lineAreaGridHeight) + 1
                state.maxCol = Int(geometrySize.width / state.gridWidth) + 1
                return .none
                
            case let .onContinuousHover(isActive, location):
                state.isHoveredOnLineArea = isActive
                if isActive {
                    state.lineAreaHoveredCellLocation = location!
                    state.lineAreaHoveredCellRow = Int(state.lineAreaHoveredCellLocation.y / state.lineAreaGridHeight)
                    state.lineAreaHoveredCellCol = Int(state.lineAreaHoveredCellLocation.x / state.gridWidth)
                }
                return .none
                
            case let .setHoveredCell(area, isActive, location):
                if area == .listArea {
                    state.isHoveredOnListArea = isActive
                    if isActive {
                        state.listAreaHoveredCellLocation = location!
                        state.listAreaHoveredCellRow = Int(state.listAreaHoveredCellLocation.y / state.lineAreaGridHeight)
                        state.listAreaHoveredCellCol = Int(state.listAreaHoveredCellLocation.x / 150)
                    } else {
                        state.listAreaHoveredCellRow = -1
                        state.listAreaHoveredCellCol = -1
                    }
                }
                return .none
                
            case let .emptyListItemDoubleClicked(clicked):
                if clicked {
                    state.keyword = ""
                    state.selectedEmptyRow = state.listAreaHoveredCellRow
                    state.selectedEmptyColumn = state.listAreaHoveredCellCol
                } else {
                    state.keyword = ""
                    state.selectedEmptyRow = nil
                    state.selectedEmptyColumn = nil
                }
                return .none
                
            case let .listItemDoubleClicked(clicked):
                if clicked {
                    state.selectedListRow = state.listAreaHoveredCellRow
                    state.selectedListColumn = state.listAreaHoveredCellCol
                    
                    let planId = state.map[state.selectedListColumn!][state.selectedListRow!]
                    state.keyword = planId
                } else {
                    state.selectedListRow = nil
                    state.selectedListColumn = nil
                }
                return .none
                
            case let .keywordChanged(newKeyword):
                state.keyword = newKeyword
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
                
            case .reloadMap:
                var newMap: [[String]] = []
                var planIDsQ: [String] = [state.rootPlan.id]
                var tempLayer: [String] = []
                var totalLoop = 0
                
                while !planIDsQ.isEmpty && totalLoop < state.rootProject.countLayerInListArea {
                    for planID in planIDsQ {
                        let plan = state.existingPlans[planID]!
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
                    totalLoop += 1
                }
                state.map = newMap.isEmpty ? [[]] : newMap
                return .none
                
            default:
                return .none
            }
        }
    }
}
