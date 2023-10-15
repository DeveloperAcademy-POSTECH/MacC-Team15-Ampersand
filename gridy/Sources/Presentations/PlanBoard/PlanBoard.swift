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
        var existingPlanTypesResult = [PlanType]()
        
        var keyword = ""
        var selectedColorCode = Color.red
    }
    
    enum Action: Equatable {
        // MARK: - user action
        case onAppear
        
        // MARK: - plan type
        case fetchExistingPlanTypes(with: String)
        case fetchExistingPlanTypesResponse(TaskResult<[PlanType]>)
        case selectColorCode(Color)
        case createPlanType
        
        // MARK: - plan
        case createPlan(String, String, String)
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
                let planIDs = state.rootProject.planIDs
                return .run { send in
                    await send(.fetchAllPlansResponse(
                        TaskResult {
                            try await apiService.readAllPlans(planIDs)
                        }
                    ))
                }
                
            case let .fetchAllPlansResponse(.success(response)):
                state.plans = response
                return .none
                
            case let .fetchExistingPlanTypes(with: keyword):
                state.keyword = keyword
                return .run { send in
                    await send(.fetchExistingPlanTypesResponse(
                        TaskResult {
                            try await apiService.existingPlanTypes(keyword)
                        }
                    ))
                }
                
            case let .fetchExistingPlanTypesResponse(.success(response)):
                state.existingPlanTypesResult = response
                return .none
                
            case let .selectColorCode(selectedColor):
                state.selectedColorCode = selectedColor
                return .none
                
            case .createPlanType:
                let keyword = state.keyword
                let colorCode = state.selectedColorCode.getUIntCode()
                print("=== colorCode: \(colorCode)")
                state.keyword = ""
                return .run { send in
                    try await apiService.createPlanType(
                        PlanType(
                            id: "", // APIService에서 자동 생성
                            title: keyword,
                            colorCode: colorCode
                        )
                    )
                }
                
            case let .createPlan(selectedPlanTypeID, parentID, description):
                let newPlan = Plan(id: "", // APIService에서 자동 생성
                                   planTypeID: selectedPlanTypeID,
                                   parentID: parentID,
                                   description: description)
                return .run { send in
                    await send(.createPlanResponse(
                        TaskResult {
                            try await apiService.createPlan(newPlan)
                        }
                    ))
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
