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
        var map = [String: [String]]()
        var searchPlanTypesResult = [PlanType]()
        var existingPlanTypes = [String: PlanType]()
        
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
        
    }
    
    enum Action: Equatable {
        // MARK: - user action
        case onAppear
        case selectColorCode(Color)
        
        // MARK: - plan type
        case createPlanType(layer: Int, row: Int, target: Plan, startDate: Date, endDate: Date)
        case createPlanTypeResponse(TaskResult<PlanType>)
        case searchExistingPlanTypes(with: String)
        case searchExistingPlanTypesResponse(TaskResult<[PlanType]>)
        case fetchAllPlanTypes
        case fetchAllPlanTypesResponse(TaskResult<[PlanType]>)
        
        // MARK: - plan
        case createPlan(layer: Int, target: Plan, startDate: Date?, endDate: Date?)
        case createPlanResponse(TaskResult<[String: [String]]>)
        case fetchAllPlans
        
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
                
                // MARK: - plan type
            case let .createPlanType(layer, parentLaneID, target, startDate, endDate):
                let keyword = state.keyword
                let colorCode = state.selectedColorCode.getUIntCode()
                state.keyword = ""
                return .run { send in
                    let createdID = try await apiService.createPlanType(
                        PlanType(
                            id: "", // APIService에서 자동 생성
                            title: keyword,
                            colorCode: colorCode
                        )
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
                    await send(
                        .createPlan(
                            layer: layer,
                            target: Plan(
                                id: target.id,
                                planTypeID: createdID,
                                parentLaneID: target.parentLaneID,
                                periods: target.periods,
                                description: target.description,
                                laneIDs: target.laneIDs
                            ),
                            startDate: startDate,
                            endDate: endDate
                        )
                    )
                }
                
            case let .createPlanTypeResponse(.success(response)):
                state.existingPlanTypes[response.id] = response
                return .none
                
            case .fetchAllPlanTypes:
                return .run { send in
                    await send(.fetchAllPlanTypesResponse(
                        TaskResult {
                            try await apiService.readAllPlanTypes()
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
                return .run { send in
                    await send(.searchExistingPlanTypesResponse(
                        TaskResult {
                            try await apiService.searchPlanTypes(keyword)
                        }
                    ))
                }
                
            case let .searchExistingPlanTypesResponse(.success(response)):
                state.searchPlanTypesResult = response
                return .none
                
                // MARK: - plan
            case let .createPlan(layer, target, startDate, endDate):
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
                            try await apiService.createPlan(planToBeCreated, layer, projectID)
                        }
                    ), animation: .easeIn)
                }
                
            case let .createPlanResponse(.success(response)):
                state.map = response
                return .none
                
            case .fetchAllPlans:
                state.map = state.rootProject.map
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
                
                // TODO: esc 눌렀을 때 row가 보정되지 않는 로직을 수정
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
                
            default:
                return .none
            }
        }
    }
}
