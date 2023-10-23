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
        var id: String { project.id }
        @BindingState var delete = false
        @BindingState var showSheet = false
        @BindingState var isTapped = false
        var isHovering = false
        var isNavigateActivated = false
        
        /// Navigation
        var optionalPlanBoard: PlanBoard.State?
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case isHovering(hovered: Bool)
        
        /// Navigation
        case optionalPlanBoard(PlanBoard.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
        case activeNavigation(isActivated: Bool)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .isHovering(hovered):
                state.isHovering = hovered
                return .none
                
                /// Navigation
            case .setNavigation(isActive: true):
                return .run { send in
                    try await continuousClock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.optionalPlanBoard = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationIsActiveDelayCompleted:
                state.optionalPlanBoard = PlanBoard.State(rootProject: state.project)
                return .none
                
            case .optionalPlanBoard:
                return .none
                
            case let .activeNavigation(isActivated):
                state.isNavigateActivated = isActivated
                return .none
            }
        }
        .ifLet(\.optionalPlanBoard, action: /Action.optionalPlanBoard) {
            PlanBoard()
        }
    }
}
