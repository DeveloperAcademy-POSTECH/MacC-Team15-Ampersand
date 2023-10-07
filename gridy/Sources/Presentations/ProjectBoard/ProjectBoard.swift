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
        var projects = [Project]()
    }
    
    enum Action: Equatable {
        case createNewProjectButtonTapped
        case readAllProjectsButtonTapped
        case fetchProject
        case fetchProjectsResponse(TaskResult<[Project]?>)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .createNewProjectButtonTapped:
            return .run { _ in
                try await apiService.create()
            }
            
        case .readAllProjectsButtonTapped:
            return .send(.fetchProject)
            
        case .fetchProject:
            return .run { send in
                await send(.fetchProjectsResponse(
                    TaskResult {
                        try await apiService.readAllProjects()
                    }
                ))
            }
            
        case let .fetchProjectsResponse(.success(response)):
            state.projects = response ?? [Project.mock]
            return .none
            
        case .fetchProjectsResponse(.failure):
            return .none
        }
    }
}
