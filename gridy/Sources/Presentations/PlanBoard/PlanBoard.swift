//
//  PlanBoard.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import SwiftUI
import ComposableArchitecture

struct PlanBoard: Reducer {
    
    @Dependency(\.apiService) var apiService
    
    struct State: Equatable {
        var rootProject: Project
        var map = [String: [String]]()
        var searchPlanTypesResult = [PlanType]()
        var existingPlanTypes = [String: PlanType]()
        
        var keyword = ""
        var selectedColorCode = Color.red
        
        // MARK: - list area
        var showingLayers: [Int] = [0]
        var showingRows = 20
    }
    
    enum Action: Equatable {
        // MARK: - user action
        case onAppear
        case selectColorCode(Color)
        
        // MARK: - plan type
        case createPlanType(layer: Int, row: Int, target: Plan)
        case createPlanTypeResponse(TaskResult<PlanType>)
        case searchExistingPlanTypes(with: String)
        case searchExistingPlanTypesResponse(TaskResult<[PlanType]>)
        case fetchAllPlanTypes
        case fetchAllPlanTypesResponse(TaskResult<[PlanType]>)
        
        // MARK: - plan
        case createPlan(layer: Int, row: Int, target: Plan)
        case createPlanResponse(TaskResult<[String: [String]]>)
        case fetchAllPlans
        
        // MARK: - list area
        case createLayer(layerIndex: Int)
        case showUpperLayer
        case showLowerLayer
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
            case let .createPlanType(layer, row, target):
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
                            row: row,
                            target: Plan(
                                id: target.id,
                                planTypeID: createdID,
                                parentLaneID: target.parentLaneID,
                                periods: target.periods,
                                description: target.description,
                                laneIDs: target.laneIDs
                            )
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
            case let .createPlan(layer, row, target):
                let projectID = state.rootProject.id
                let createdPlanID = UUID().uuidString
                
                let newPlan = Plan(id: createdPlanID, // APIService에서 자동 생성
                                   planTypeID: target.planTypeID,
                                   parentLaneID: target.parentLaneID,
                                   periods: [0: [Date(), Date()]],
                                   description: target.description)
                return .run { send in
                    await send(.createPlanResponse(
                        TaskResult {
                            try await apiService.createPlan(newPlan, layer, row, projectID)
                        }
                    ), animation: .easeIn)
                }
                
            case let .createPlanResponse(.success(response)):
                state.map = response
                return .none
                
            case .fetchAllPlans:
                state.map = state.rootProject.map
                return .none
                
            case .showUpperLayer:
                let lastShowingIndex = state.showingLayers.last!
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
                
            /// 나와 똑같은 개수의 lane을 가진 layer를 내 index에 insert
            case let .createLayer(layerIndex):
                let projectId = state.rootProject.id
                return .run { send in
                    let createdLayer = try await apiService.newLayerCreated(layerIndex, projectId)
                    await send(.fetchAllPlans)
                }
                
            default:
                return .none
            }
        }
    }
}
