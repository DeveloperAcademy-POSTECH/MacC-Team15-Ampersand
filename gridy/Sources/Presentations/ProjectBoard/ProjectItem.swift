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
    
    struct State: Equatable, Identifiable {
        @BindingState var project = Project.mock
        var id: String { project.id }
        @BindingState var delete = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case titleChanged(String)
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .titleChanged(newTitle):
                let id = state.project.id
                state.project.title = newTitle
                return .run { _ in
                    try await apiService.updateProjectTitle(id, newTitle)
                }
            case .binding:
                return .none
            }
        }
    }
}
