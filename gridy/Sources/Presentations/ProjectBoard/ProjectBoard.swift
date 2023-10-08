//
//  ProjectBoard.swift
//  gridy
//
//  Created by 제나 on 2023/10/07.
//

import Foundation
import ComposableArchitecture
import FirebaseAuth

struct ProjectBoard: Reducer {
    
    @Dependency(\.apiService) var apiService
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var continuousClock
    
    struct State: Equatable {
        var projects: IdentifiedArrayOf<ProjectItem.State> = []
    }
    
    enum Action: BindableAction, Equatable {
        case createNewProjectButtonTapped
        case readAllButtonTapped
        case fetchAllProjects
        case fetchAllProjectsResponse(TaskResult<[Project]?>)
        
        case binding(BindingAction<State>)
        case deleteProjectButtonTapped(id: ProjectItem.State.ID, action: ProjectItem.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .createNewProjectButtonTapped:
                return .run { send in
                    try await apiService.create()
                    await send(.fetchAllProjects)
                }
                
            case .readAllButtonTapped:
                return .run(operation: { send in
                    await send(.fetchAllProjects)
                })
                
            case .fetchAllProjects:
                return .run { send in
                    await send(.fetchAllProjectsResponse(
                        TaskResult {
                            try await apiService.readAllProjects()
                        }
                    ), animation: .spring)
                }
                
            case let .fetchAllProjectsResponse(.success(response)):
                guard let response = response else { return .none }
                state.projects = []
                for project in response {
                    state.projects.insert(ProjectItem.State(project: project), at: state.projects.count)
                }
                return .none
                
            case .fetchAllProjectsResponse(.failure):
                return .none
                
            case .binding:
                return .none
                
            case let .deleteProjectButtonTapped(id: pid, action: .binding(\.$delete)):
                return .run { send in
                    try await apiService.delete(pid)
                    await send(.fetchAllProjects)
                }
                
            case .deleteProjectButtonTapped:
                return .none
            }
        }
        .forEach(\.projects, action: /Action.deleteProjectButtonTapped(id:action:)) {
            ProjectItem()
        }
    }
}

