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
        var plans = [[Plan]]()
        var searchPlanTypesResult = [PlanType]()
        var existingPlanTypes = [String: PlanType]()
        
        var keyword = ""
        var selectedColorCode = Color.red
    }
    
    enum Action: Equatable {
        // MARK: - user action
        case onAppear
        case selectColorCode(Color)
        
        // MARK: - plan type
        case createPlanType
        case createPlanTypeResponse(TaskResult<PlanType>)
        case searchExistingPlanTypes(with: String)
        case searchExistingPlanTypesResponse(TaskResult<[PlanType]>)
        case fetchAllPlanTypes
        case fetchAllPlanTypesResponse(TaskResult<[PlanType]>)
        
        // MARK: - plan
        case creat
        case createPlan(layer: Int, row: Int, selectedPlanTypeID: String, description: String)
        case createPlanResponse(Int, Int, TaskResult<Plan>)
        case fetchAllPlans
        case fetchAllPlansResponse(TaskResult<[[Plan]]>)
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
            case .createPlanType:
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
            case let .createPlan(layer, row, selectedPlanTypeID, description):
                let projectID = state.rootProject.id
                let createdPlanID = UUID().uuidString
                
                let newPlan = Plan(id: "", // APIService에서 자동 생성
                                   planTypeID: selectedPlanTypeID,
                                   parentID: "",
                                   description: description)
                return .run { send in
                    await send(.createPlanResponse(
                        layer, row,
                        TaskResult {
                            try await apiService.createPlan(Plan(id: createdPlanID), layer, row, projectID)
                        }
                    ), animation: .easeIn)
                }
                
            case let .createPlanResponse(layer, row, .success(response)):
                state.plans[layer].insert(response, at: row)
                return .none
                
            case .fetchAllPlans:
                let projectID = state.rootProject.id
                return .run { send in
                    await send(.fetchAllPlansResponse(
                        TaskResult {
                            try await apiService.readAllPlans(projectID)
                        }
                    ), animation: .easeIn)
                }
                
            case let .fetchAllPlansResponse(.success(response)):
                state.plans = response
                return .none
                
            default:
                return .none
            }
        }
    }
}
