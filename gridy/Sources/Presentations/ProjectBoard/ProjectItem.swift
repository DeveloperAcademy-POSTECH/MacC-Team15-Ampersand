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
        @BindingState var isSelected = false
        var isHovering = false
        var hoveredItem = ""
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case isHovering(hovered: Bool)
        case hoveredItem(name: String)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .hoveredItem(name: hoveredItem):
                state.hoveredItem = hoveredItem
                return .none
                
            case let .isHovering(hovered):
                state.isHovering = hovered
                return .none
                
            default:
                return .none
            }
        }
    }
}
