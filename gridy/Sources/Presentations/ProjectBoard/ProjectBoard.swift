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
        var isCreationViewPresented = false
        var isEditViewPresented = false
        var projectIdToEdit = ""
        @BindingState var title = ""
        var tappedProjectID: ProjectItem.State.ID?
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case onAppear
        case createNewProjectButtonTapped
        case readAllButtonTapped
        case fetchAllProjects
        case fetchAllProjectsResponse(TaskResult<[Project]?>)
        case setProcessing(Bool)
        case titleChanged(String)
        case projectTitleChanged
        case binding(BindingAction<State>)
        case setSheet(isPresented: Bool)
        case setEditSheet(isPresented: Bool)
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
                let title = state.title
                return .run { send in
                    try await apiService.createProject(title)
                    await send(.fetchAllProjects)
                    await send(.setSheet(isPresented: false))
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
                
            case let .setSheet(isPresented: isPresented):
                state.title = ""
                state.isCreationViewPresented = isPresented
                return .none
                
            case let .setEditSheet(isPresented: isPresented):
                state.isEditViewPresented = isPresented
                return .none
                
            case let .titleChanged(changedTitle):
                state.title = changedTitle
                return .none
                
            case .projectTitleChanged:
                let id = state.projectIdToEdit
                let changedTitle = state.title
                return .run { send in
                    try await apiService.updateProjectTitle(id, changedTitle)
                    await send(.fetchAllProjects)
                    await send(.setEditSheet(isPresented: false))
                }
                
            case .binding:
                return .none
                
            case let .deleteProjectButtonTapped(id: id, action: .binding(\.$delete)):
                return .run { send in
                    await send(.fetchAllProjects)
                }
                
            case let .deleteProjectButtonTapped(id: id, action: .binding(\.$showSheet)):
                let projectId = id
                if let projectItem = state.projects[id: projectId] {
                    state.title = projectItem.project.title
                }
                state.projectIdToEdit = id
                state.isEditViewPresented = true
                return .none
                
            case let .deleteProjectButtonTapped(id: id, action: .binding(\.$isTapped)):
                let projectID = id
                state.tappedProjectID = projectID
                if let projectItem = state.projects[id: projectID] {
                    for project in state.projects {
                        state.projects[id: project.id]?.isTapped = (project.id == projectID)
                    }
                }
                return .none
                
            case .deleteProjectButtonTapped:
                return .none
            }
        }
        .forEach(\.projects, action: /Action.deleteProjectButtonTapped(id:action:)) {
            ProjectItem()
        }
    }
}
