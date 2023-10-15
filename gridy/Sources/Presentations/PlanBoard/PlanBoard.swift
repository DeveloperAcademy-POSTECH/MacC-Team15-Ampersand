//
//  PlanBoard.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import ComposableArchitecture

struct PlanBoard: Reducer {
    
    @Dependency(\.apiService) var apiService
    struct State: Equatable {
        var rootProject: Project
        var plans = [Plan]()
    }
    
    enum Action: Equatable {
        case onAppear
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
                
            case .fetchAllPlansResponse(.failure):
                return .none
            }
        }
    }
}
