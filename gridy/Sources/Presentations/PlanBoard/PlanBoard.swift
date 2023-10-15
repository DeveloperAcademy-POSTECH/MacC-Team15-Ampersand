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
        var plans = [Plan]()
        var searchPlanTypesResult = [PlanType]()
        
        var keyword = ""
        var selectedColorCode = Color.red
    }
    
    enum Action: Equatable {
        // MARK: - user action
        case onAppear
        
        // MARK: - plan type
        case searchExistingPlanTypes(with: String)
        case searchExistingPlanTypesResponse(TaskResult<[PlanType]>)
        case selectColorCode(Color)
        case createPlanType(parentID: String, description: String)
        
        // MARK: - plan
        case createPlan(selectedPlanTypeID: String, parentID: String, description: String)
        case createPlanResponse(TaskResult<Plan>)
        case fetchAllPlans
        case fetchAllPlansResponse(TaskResult<[Plan]>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.fetchAllPlans)
                }
                
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
                
            case let .searchExistingPlanTypes(with: keyword):
                state.keyword = keyword
                return .run { send in
                    await send(.searchExistingPlanTypesResponse(
                        TaskResult {
                            try await apiService.existingPlanTypes(keyword)
                        }
                    ))
                }
                
            case let .searchExistingPlanTypesResponse(.success(response)):
                state.searchPlanTypesResult = response
                return .none
                
            case let .selectColorCode(selectedColor):
                state.selectedColorCode = selectedColor
                return .none
                
            case let .createPlanType(parentID, description):
                let keyword = state.keyword
                let colorCode = state.selectedColorCode.getUIntCode()
                print("=== colorCode: \(colorCode)")
                state.keyword = ""
                return .run { send in
                    let createdID = try await apiService.createPlanType(
                        PlanType(
                            id: "", // APIService에서 자동 생성
                            title: keyword,
                            colorCode: colorCode
                        )
                    )
                    await send(.createPlan(
                        selectedPlanTypeID: createdID,
                        parentID: parentID,
                        description: description)
                    )
                }
                
            case let .createPlan(selectedPlanTypeID, parentID, description):
                let newPlan = Plan(id: "", // APIService에서 자동 생성
                                   planTypeID: selectedPlanTypeID,
                                   parentID: parentID,
                                   description: description)
                let projectID = state.rootProject.id
                return .run { send in
                    await send(.createPlanResponse(
                        TaskResult {
                            try await apiService.createPlan(newPlan, projectID)
                        }
                    ), animation: .easeIn)
                }
                
            case let .createPlanResponse(.success(response)):
                state.plans.append(response)
                return .none
                
            default:
                return .none
            }
        }
    }
}
