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
    
    struct State: Equatable {
        var projects: IdentifiedArrayOf<ProjectItem.State> = []
    }
    
    enum Action: BindableAction, Equatable {
        case createNewProjectButtonTapped
        case readAllProjectsButtonTapped
        case fetchAllProject
        case fetchAllProjectsResponse(TaskResult<[Project]?>)
        
        case binding(BindingAction<State>)
        case titleChanged(id: ProjectItem.State.ID, action: ProjectItem.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .createNewProjectButtonTapped:
                return .run { _ in
                    try await apiService.create()
                }
                
            case .readAllProjectsButtonTapped:
                return .send(.fetchAllProject)
                
            case .fetchAllProject:
                return .run { send in
                    await send(.fetchAllProjectsResponse(
                        TaskResult {
                            try await apiService.readAllProjects()
                        }
                    ))
                }
                
            case let .fetchAllProjectsResponse(.success(response)):
                guard let response = response else { return .none }
                for project in response {
                    state.projects.insert(ProjectItem.State(project: project), at: state.projects.count)
                }
                return .none
                
            case .fetchAllProjectsResponse(.failure):
                return .none
                
            case .binding:
                return .none
                
            case .titleChanged(id: _, action: .binding(\.$project)):
                return .none
                
            case .titleChanged:
                return .none
            }
        }
        .forEach(\.projects, action: /Action.titleChanged(id:action:)) {
            ProjectItem()
        }
    }
}
