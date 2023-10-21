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
        var successToFetchData = false
        var isInProgress = false
        var isCreationViewPresented = false
        var isEditViewPresented = false
        var projectIdToEdit = ""
        @BindingState var title = ""
    }
    
    enum Action: BindableAction, Equatable {
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
                    try await apiService.create(title)
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
                    ), animation: .spring) /// 여기 animation 효과 때문에, 타이틀 업데이트 했을 때 타이틀이 먼저 보여지는 현상이 생깁니다. none으로 바꾸면 괜찮아집니다.
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
                
            case let .projectTitleChanged:
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
                    try await apiService.delete(id)
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
                
            case .deleteProjectButtonTapped:
                return .none
            }
        }
        .forEach(\.projects, action: /Action.deleteProjectButtonTapped(id:action:)) {
            ProjectItem()
        }
    }
}
