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
        var map: [String: [String]]
        var searchPlanTypesResult = [PlanType]()
        var existingPlanTypes = [String: PlanType]()
        var existingAllPlans = [String: Plan]()
        
        @BindingState var keyword = ""
        var selectedColorCode = Color.red
        
        /// 그리드 규격에 대한 변수들입니다.
        var columnStroke = CGFloat(1)
        var rowStroke = CGFloat(1)
        var gridWidth = CGFloat(50)
        let minGridSize = CGFloat(20)
        let maxGridSize = CGFloat(70)
        var lineAreaGridHeight = CGFloat(50)
        var scheduleAreaGridHeight = CGFloat(25)
        
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
        case createPlanType(planID: String)
        case createPlanTypeResponse(TaskResult<PlanType>)
        case searchExistingPlanTypes(with: String)
        case searchExistingPlanTypesResponse(TaskResult<[PlanType]>)
        case fetchAllPlanTypes
        case fetchAllPlanTypesResponse(TaskResult<[PlanType]>)
        
        // MARK: - plan
        case createPlan(layer: Int, row: Int, target: Plan, startDate: Date?, endDate: Date?)
        case createPlanResponse(TaskResult<[String: [String]]>)
        case updatePlan(planID: String, planTypeID: String)
        case fetchAllPlans
        case fetchAllPlansResponse(TaskResult<[String: Plan]>)
        
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
        case setHoveredCell(PlanBoardAreaName, Bool, CGPoint?)
        case dragGestureChanged(LineAreaDragType, SelectedGridRange?)
        case dragGestureEnded(SelectedGridRange?)
        case magnificationChangedInListArea(CGFloat, CGSize)
        
        // MARK: - list area
        case createLayer(layerIndex: Int)
        case createLayerResponse(TaskResult<[String: [String]]>)
        case emptyListItemDoubleClicked(Bool)
        case listItemDoubleClicked(Bool)
        case keywordChanged(String)
        
        case setSheet(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
                // MARK: - user action
            case .onAppear:
                return .run { send in
                    await send(.fetchAllPlans)
                    await send(.fetchAllPlanTypes)
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
            case let .createPlanType(planID):
                let keyword = state.keyword
                let colorCode = state.selectedColorCode.getUIntCode()
                let projectID = state.rootProject.id
                state.keyword = ""
                return .run { send in
                    let createdID = try await apiService.createPlanType(
                        PlanType(
                            id: "", /// APIService에서 자동 생성
                            title: keyword,
                            colorCode: colorCode
                        ),
                        planID,
                        projectID
                    )
                    await send(.createPlanTypeResponse(
                        TaskResult {
                            PlanType(
                                id: createdID,
                                title: keyword,
                                colorCode: colorCode
                            )
                        }
                    ))
                }
                
            case let .createPlanTypeResponse(.success(response)):
                state.existingPlanTypes[response.id] = response
                return .none
                
            case .fetchAllPlanTypes:
                let projectID = state.rootProject.id
                return .run { send in
                    await send(.fetchAllPlanTypesResponse(
                        TaskResult {
                            try await apiService.readAllPlanTypes(projectID)
                        }
                    ))
                }
                
            case let .fetchAllPlanTypesResponse(.success(responses)):
                responses.forEach { response in
                    state.existingPlanTypes[response.id] = response
                }
                return .none
                
            case let .searchExistingPlanTypes(with: keyword):
                state.keyword = keyword
                let projectID = state.rootProject.id
                return .run { send in
                    await send(.searchExistingPlanTypesResponse(
                        TaskResult {
                            try await apiService.searchPlanTypes(keyword, projectID)
                        }
                    ))
                }
                
            case let .searchExistingPlanTypesResponse(.success(response)):
                state.searchPlanTypesResult = response
                return .none
                
                // MARK: - plan
            case let .createPlan(layer, row, target, startDate, endDate):
                // TODO: - 나중에 삭제해도 되는 코드인듯! 헨리 확인 부탁해요~
                let projectID = state.rootProject.id
                
                var newPlan: Plan?
                if let startDate = startDate, let endDate = endDate {
                    newPlan = Plan(id: "", // APIService에서 자동 생성
                                   planTypeID: target.planTypeID,
                                   parentLaneID: target.parentLaneID,
                                   periods: [0: [startDate, endDate]],
                                   description: target.description,
                                   laneIDs: []
                    )
                    state.selectedDateRanges.append(SelectedDateRange(start: startDate, end: endDate))
                } else {
                    newPlan = Plan(id: "", // APIService에서 자동 생성
                                   planTypeID: target.planTypeID,
                                   parentLaneID: target.parentLaneID,
                                   periods: [:],
                                   description: target.description,
                                   laneIDs: []
                    )
                }
                let planToBeCreated = newPlan!
                return .run { send in
                    await send(.createPlanResponse(
                        TaskResult {
                            try await apiService.createPlan(planToBeCreated, layer, row, projectID)
                        }
                    ), animation: .easeIn)
                }
                
            case let .createPlanResponse(.success(response)):
                state.map = response
                return .none
                
            case let .updatePlan(planID, planTypeID):
                let projectID = state.rootProject.id
                return .run { _ in
                    try await apiService.updatePlan(planID, planTypeID, projectID)
                }
                
            case .fetchAllPlans:
                let projectID = state.rootProject.id
                return .run { send in
                    await send(.fetchAllPlansResponse(
                        TaskResult {
                            try await apiService.readAllPlans(projectID)
                        }
                    ))
                }
                
            case let .fetchAllPlansResponse(.success(response)):
                state.existingAllPlans = response
                return .none
                
                // MARK: - listArea
            case let .createLayer(layerIndex):
                let projectId = state.rootProject.id
                return .run { send in
                    await send(.createLayerResponse(
                        TaskResult {
                            try await apiService.createLayer(layerIndex, projectId)
                        }
                    ))}
                
            case let .createLayerResponse(.success(response)):
                state.map = response
                return .none
                
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
                    
                    let planId = state.map[String(state.selectedListColumn!)]![state.selectedListRow!]
                    state.keyword = planId
                } else {
                    state.selectedListRow = nil
                    state.selectedListColumn = nil
                }
                return .none
                
            case let .keywordChanged(newKeyword):
                state.keyword = newKeyword
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
                
            default:
                return .none
            }
        }
    }
}
