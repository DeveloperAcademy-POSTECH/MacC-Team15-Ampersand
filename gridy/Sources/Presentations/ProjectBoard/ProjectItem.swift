//
//  ProjectItem.swift
//  gridy
//
//  Created by 제나 on 10/8/23.
//

import Foundation
import ComposableArchitecture

struct ProjectItem: Reducer {
    
    @Dependency(\.apiService) var apiService
    @Dependency(\.continuousClock) var continuousClock
    
    private enum CancelID { case load }
    
    struct State: Equatable, Identifiable {
        @BindingState var project = Project.mock
        var id: String { project.pid }
        @BindingState var delete = false
        
        /// Navigation
        var isNavigationActive = false
        var optionalPlanBoard = PlanBoard.State()
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case titleChanged(String)
        case binding(BindingAction<State>)
        
        /// Navigation
        case projectItemAreaTapped
        case optionalPlanBoard(PlanBoard.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .titleChanged(newTitle):
                let pid = state.project.pid
                state.project.title = newTitle
                return .run { _ in
                    try await apiService.updateProjectTitle(pid, newTitle)
                }
            case .binding:
                return .none
                
            case .projectItemAreaTapped:
                return .run { send in
                    await send(.setNavigation(isActive: true))
                }
                
                /// Navigation
            case .setNavigation(isActive: true):
                state.isNavigationActive = true
                return .run { send in
                    try await continuousClock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.isNavigationActive = false
//                state.optionalPlanBoard = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationIsActiveDelayCompleted:
                state.optionalPlanBoard = PlanBoard.State()
                return .none
                
            case .optionalPlanBoard:
                return .none
            }
        }
        Scope(state: \.optionalPlanBoard, action: /Action.optionalPlanBoard) {
            PlanBoard()
        }
    }
}
