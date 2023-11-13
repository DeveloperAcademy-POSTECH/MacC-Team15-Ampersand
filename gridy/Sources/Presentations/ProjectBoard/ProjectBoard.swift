//
//  ProjectBoard.swift
//  gridy
//
//  Created by 제나 on 2023/10/07.
//

import Foundation
import ComposableArchitecture
import FirebaseAuth

enum ProjectSortCase: Equatable {
    case dateCreated
    case lastModified
    case alphabetical
}

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
        var showingProject: Project?
        var showingProjects = [String]()
        var sortBy = ProjectSortCase.lastModified
        
        @BindingState var title = ""
        @BindingState var startDate = Date()
        @BindingState var endDate = Date()
        
        var notices = [Notice]()
        
        // MARK: - FocusGroupClickedItems
        var hoveredItem = ""
        var tabBarFocusGroupClickedItem = String.homeButton
        var projectListFocusGroupClickedItem = "personalProject"
        var folderListFocusGroupClickedItem = ""
        var folderLazyVGridFocusGroupClickedItem = ""
        var boardLazyVGridFocusGroupClickedItem = ""
        
        // MARK: - Sheets
        var isNotificationPresented = false
        var isUserSettingPresented = false
        var isCreatePlanBoardPresented = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case onAppear
        case hoveredItem(name: String)
        case clickedItem(focusGroup: String, name: String)
        case popoverPresent(button: String, bool: Bool)
        
        case createNewProjectButtonTapped
        case createProjectResponse(TaskResult<Project>)
        case readAllButtonTapped
        case fetchAllProjects
        case fetchAllProjectsResponse(TaskResult<[Project]?>)
        case setProcessing(Bool)
        case titleChanged(String)
        case projectTitleChanged
        case sortProjectBy
        
        case sendFeedback(String)
        case fetchNotice
        case fetchNoticeResponse(TaskResult<[Notice]>)
        
        case binding(BindingAction<State>)
        case setShowingTap(project: Project)
        case deleteShowingTap(projectID: String)
        case setSheet(isPresented: Bool)
        case setEditSheet(isPresented: Bool)
        case projectItemTapped(id: ProjectItem.State.ID, action: ProjectItem.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.fetchAllProjects)
                }
                
            case let .hoveredItem(name: hoveredItem):
                state.hoveredItem = hoveredItem
                return .none
                
            case let .clickedItem(focusGroup: focusGroup, name: clickedItem):
                switch focusGroup {
                case .tabBarFocusGroup:
                    state.tabBarFocusGroupClickedItem = clickedItem
                case .projectListFocusGroup:
                    state.projectListFocusGroupClickedItem = clickedItem
                case .folderListFocusGroup:
                    state.folderListFocusGroupClickedItem = clickedItem
                case .folderLazyVGridFocusGroup:
                    state.folderLazyVGridFocusGroupClickedItem = clickedItem
                case .boardLazyVGridFocusGroup:
                    state.boardLazyVGridFocusGroupClickedItem = clickedItem
                default:
                    break
                }
                return .none
                
            case let .popoverPresent(button: buttonName, bool: bool):
                switch buttonName {
                case .notificationButton:
                    state.isNotificationPresented = bool
                case .userSettingButton:
                    state.isUserSettingPresented = bool
                case .createPlanBoardButton:
                    state.isCreatePlanBoardPresented = bool
                default:
                    break
                }
                return .none
                
            case .createNewProjectButtonTapped:
                let title = state.title
                let startDate = state.startDate
                let endDate = state.endDate
                
                return .run { send in
                    await send(.createProjectResponse(
                        TaskResult {
                            try await apiService.createProject(title, [startDate, endDate])
                        }
                    ))
                }
                
            case let .createProjectResponse(.success(response)):
                state.projects.insert(ProjectItem.State(project: response), at: 0)
                return .run { send in
                    await send(.sortProjectBy)
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
                            try await apiService.readProjects()
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
                
            case let .setProcessing(isInProgress):
                state.isInProgress = isInProgress
                return .none
                
            case let .setSheet(isPresented: isPresented):
                state.title = ""
                state.isCreationViewPresented = isPresented
                return .none
                
            case let .setShowingTap(project):
                state.showingProject = project
                return .none
                
            case let .deleteShowingTap(projectID):
                /// 보여줄 탭 배열에서 id 제거
                if let index = state.showingProjects.firstIndex(of: projectID) {
                    state.showingProjects.remove(at: index)
                }
                /// 보여줄 탭이 아무것도 없을 때 홈화면 보여줌
                if state.showingProjects.isEmpty {
                    return .run { send in
                        await send(.clickedItem(
                            focusGroup: .tabBarFocusGroup,
                            name: .homeButton
                        ))
                    }
                }
                /// 보여지고 있는 시트를 지웠을 경우
                var clickedProjectID = ""
                if state.tabBarFocusGroupClickedItem == projectID {
                    clickedProjectID = state.showingProjects.last!
                    let project = state.projects[id: clickedProjectID]!.project
                    let showingProjectID = clickedProjectID
                    return .run { send in
                        await send(.setShowingTap(
                            project: project
                        ))
                        await send(.clickedItem(
                            focusGroup: .tabBarFocusGroup,
                            name: showingProjectID
                        ))
                        
                    }
                }
                
                return .none
                
            case let .setEditSheet(isPresented: isPresented):
                state.isEditViewPresented = isPresented
                return .none
                
            case let .titleChanged(changedTitle):
                state.title = changedTitle
                return .none
                
            case .projectTitleChanged:
                let id = state.projectIdToEdit
                state.projects[id: id]!.project.title = state.title
                var projectToEdit = state.projects[id: id]!
                projectToEdit.project.title = state.title
                let projectToEditImmutable = projectToEdit.project
                return .run { send in
                    await send(.sortProjectBy)
                    try await apiService.updateProjects([projectToEditImmutable])
                    await send(.setEditSheet(isPresented: false))
                }
                
            case .sortProjectBy:
                switch state.sortBy {
                case .dateCreated:
                    state.projects.sort(by: { $0.project.createdDate > $1.project.createdDate })
                case .lastModified:
                    state.projects.sort(by: { $0.project.lastModifiedDate > $1.project.lastModifiedDate })
                case .alphabetical:
                    state.projects.sort(by: { $0.project.title < $1.project.title })
                }
                return .none
                
            case let .sendFeedback(contents):
                return .run { _ in
                    try await apiService.sendFeedback(contents)
                }
                
            case .fetchNotice:
                return .run { send in
                    await send(.fetchNoticeResponse(
                        TaskResult {
                            try await apiService.readAllNotices()
                        }
                    ))
                }
                
            case let .fetchNoticeResponse(.success(response)):
                state.notices = response
                return .none
                
            case .projectItemTapped(id: _, action: .binding(\.$delete)):
                return .run { send in
                    await send(.fetchAllProjects)
                }
                
            case let .projectItemTapped(id: id, action: .binding(\.$showSheet)):
                let projectId = id
                if let projectItem = state.projects[id: projectId] {
                    state.title = projectItem.project.title
                }
                state.projectIdToEdit = id
                state.isEditViewPresented = true
                return .none
                
            case let .projectItemTapped(id: id, action: .binding(\.$isTapped)):
                if state.showingProjects.firstIndex(of: id) == nil {
                    state.showingProjects.append(id)
                }
                let project = state.projects[id: id]!.project
                return .run { send in
                    await send(.setShowingTap(
                        project: project
                    ))
                    await send(.clickedItem(
                        focusGroup: .tabBarFocusGroup,
                        name: id
                    ))
                }
                
            default:
                return .none
            }
        }
        .forEach(\.projects, action: /Action.projectItemTapped(id:action:)) {
            ProjectItem()
        }
    }
}
