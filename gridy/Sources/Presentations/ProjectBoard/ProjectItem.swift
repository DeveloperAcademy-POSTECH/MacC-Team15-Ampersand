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
        
        /// Navigation
        var isNavigationActive = false
        var optionalPlanBoard: PlanBoard.State?
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case isHovering(hovered: Bool)
        
        /// Navigation
        case optionalPlanBoard(PlanBoard.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
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
                state.isNavigationActive = true
                return .run { send in
                    try await continuousClock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.isNavigationActive = false
                state.optionalPlanBoard = nil
                state.isHovering = false
                return .cancel(id: CancelID.load)
                
            case .setNavigationIsActiveDelayCompleted:
                // TODO: -
//                state.optionalPlanBoard = PlanBoard.State(rootProject: state.project, map: [[]])
                return .none
                
            case .optionalPlanBoard:
                return .none
            }
        }
        .ifLet(\.optionalPlanBoard, action: /Action.optionalPlanBoard) {
            PlanBoard()
        }
    }
}
