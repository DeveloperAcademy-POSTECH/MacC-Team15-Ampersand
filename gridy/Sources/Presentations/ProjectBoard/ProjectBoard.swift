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
    
    private enum CancelID { case load }
    
    struct State: Equatable {
        var projects: IdentifiedArrayOf<ProjectItem.State> = []
        var successToFetchData = false
        var isInProgress = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case onAppear
        case createNewProjectButtonTapped
        case readAllButtonTapped
        case fetchAllProjects
        case fetchAllProjectsResponse(TaskResult<[Project]?>)
        case setProcessing(Bool)
        
        case binding(BindingAction<State>)
        case deleteProjectButtonTapped(id: ProjectItem.State.ID, action: ProjectItem.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.fetchAllProjects)
                }
                
            case .createNewProjectButtonTapped:
                return .run { send in
                    try await apiService.create()
                    await send(.fetchAllProjects)
                }
                
            case .readAllButtonTapped:
                return .run { send in
                    await send(.fetchAllProjects)
                }
                
            case .fetchAllProjects:
                return .run { send in
                    await send(.setProcessing(true))
                    await send(.fetchAllProjectsResponse(
                        TaskResult {
                            try await apiService.readAllProjects()
                        }
                    ), animation: .spring)
                    await send(.setProcessing(false))
                }
                
            case let .fetchAllProjectsResponse(.success(response)):
                guard let response = response else { return .none }
                state.projects = []
                for project in response {
                    state.projects.insert(
                        ProjectItem.State(project: project),
                        at: state.projects.count
                    )
                }
                state.successToFetchData = true
                return .none
                
            case .fetchAllProjectsResponse(.failure):
                return .none
                
            case let .setProcessing(isInProgress):
                state.isInProgress = isInProgress
                return .none
                
            case .binding:
                return .none
                
            case let .deleteProjectButtonTapped(id: id, action: .binding(\.$delete)):
                return .run { send in
                    try await apiService.delete(id)
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
