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
        var projectIdToEdit = ""
        var showingProject: Project?
        var showingProjects = [String]()
        var isDisclosureGroupExpanded = false
        var textFieldSubmit = false
        
        @BindingState var title = ""
        @BindingState var searchPlanBoardText = ""
        @BindingState var folderName = ""
        @BindingState var profileName = ""
        @BindingState var selectionOption = 0
        
        var currentDate: Date = Date()
        let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
        var selectedStartDate = Date()
        var selectedEndDate = Date()
        var jobOptions = ["개발자", "디자이너", "기획자", "부자"]
        
        // MARK: - FocusGroupClickedItems
        var hoveredItem = ""
        var tabBarFocusGroupClickedItem = String.homeButton
        var projectListFocusGroupClickedItem = "personalProject"
        var folderListFocusGroupClickedItem = ""
        var folderLazyVGridFocusGroupClickedItem = ""
        var boardLazyVGridFocusGroupClickedItem = ""
        var themeFocusGroupClickedItem = String.lightButton
        
        // MARK: - Sheets
        var isNotificationPresented = false
        var isUserSettingPresented = false
        var isCreatePlanBoardPresented = false
        var isEditPlanBoardPresented = false
        var isThemeSettingPresented = false
        var isSettingsViewPresented = false
        var isLogoutViewPresented = false
        var startDatePickerPresented = false
        var endDatePickerPresented = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case onAppear
        case hoveredItem(name: String)
        case clickedItem(focusGroup: String, name: String)
        case popoverPresent(button: String, bool: Bool)
        case disclosurePresent(button: String, bool: Bool)
        
        case textFieldSubmit(bool: Bool)
        case createNewProjectButtonTapped
        case readAllButtonTapped
        
        case fetchAllProjects
        case fetchAllProjectsResponse(TaskResult<[Project]?>)
        
        case setProcessing(Bool)
        case titleChanged(String)
        case searchTitleChanged(String)
        case folderTitleChanged(String)
        case profileNameChanged(String)
        case projectTitleChanged
        
        case setShowingProject(project: Project)
        case deleteShowingProjects(projectID: String)
        case setSheet(isPresented: Bool)
        
        case projectItemOneTapped(id: String)
        case changeMonth(monthIndex: Int)
        case selectedStartDateChanged(Date)
        case selectedEndDateChanged(Date)
        case changeOption(Int)

        case projectItemTapped(id: ProjectItem.State.ID, action: ProjectItem.Action)
        case binding(BindingAction<State>)

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
                case .themeFocusGroup:
                    state.themeFocusGroupClickedItem = clickedItem
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
                case .editPlanBoardButton:
                    state.isEditPlanBoardPresented = bool
                case .themeSettingButton:
                    state.isThemeSettingPresented = bool
                case .settingButton:
                    state.isSettingsViewPresented = bool
                case .logoutButton:
                    state.isLogoutViewPresented = bool
                case .startDatePickerButton:
                    state.startDatePickerPresented = bool
                case .endDatePickerButton:
                    state.endDatePickerPresented = bool
                default:
                    break
                }
                return .none
                
            case let .disclosurePresent(button: buttonName, bool: bool):
                switch buttonName {
                case .disclosureFolderButton:
                    state.isDisclosureGroupExpanded = bool
                default:
                    break
                }
                return .none
                
            case let .textFieldSubmit(bool: bool):
                state.textFieldSubmit = bool
                return .none
                
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
                
            case let .setShowingProject(project):
                state.showingProject = project
                return .none
                
            case let .deleteShowingProjects(projectID):
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
                        await send(.setShowingProject(
                            project: project
                        ))
                        await send(.clickedItem(
                            focusGroup: .tabBarFocusGroup,
                            name: showingProjectID
                        ))
                        
                    }
                }
                
                return .none
                
            case let .titleChanged(changedTitle):
                state.title = changedTitle
                return .none
                
            case let .searchTitleChanged(changedSearchTitle):
                state.searchPlanBoardText = changedSearchTitle
                return .none
                
            case let .folderTitleChanged(changedFolderTitle):
                state.folderName = changedFolderTitle
                return .none
                
            case let .profileNameChanged(changedProfileName):
                state.profileName = changedProfileName
                return .none
                
            case .projectTitleChanged:
                let id = state.projectIdToEdit
                let changedTitle = state.title
                return .run { send in
                    try await apiService.updateProjectTitle(id, changedTitle)
                    await send(.fetchAllProjects)
                }
                
            case .binding:
                return .none
                
            case let .projectItemTapped(id: id, action: .binding(\.$isDeleted)):
                return .run { send in
                    try await apiService.deleteProject(id)
                    await send(.fetchAllProjects)
                }
                
            case let .projectItemTapped(id: id, action: .binding(\.$isEditing)):
                let projectId = id
                if let projectItem = state.projects[id: projectId] {
                    state.title = projectItem.project.title
                }
                state.projectIdToEdit = id
                state.isEditPlanBoardPresented = true
                return .none
                
            case let .projectItemTapped(id: id, action: .binding(\.$isSelected)):
                let projectId = id
                
                for projectItem in state.projects {
                    if projectItem.id == projectId {
                        state.projects[id: projectItem.id]?.isSelected = true
                    } else {
                        state.projects[id: projectItem.id]?.isSelected = false
                    }
                }
                return .none
                
            case let .projectItemTapped(id: id, action: .binding(\.$isTapped)):
                if state.showingProjects.firstIndex(of: id) == nil {
                    state.showingProjects.append(id)
                }
                let project = state.projects[id: id]!.project
                return .run { send in
                    await send(.setShowingProject(
                        project: project
                    ))
                    await send(.clickedItem(
                        focusGroup: .tabBarFocusGroup,
                        name: id
                    ))
                }
                
            case let .changeMonth(monthIndex):
                state.currentDate = state.currentDate.moveMonth(movedMonth: monthIndex)
                return .none
                
            case let .selectedStartDateChanged(date):
                state.selectedStartDate = date
                return .none
                
            case let .selectedEndDateChanged(date):
                state.selectedEndDate = date
                return .none
                
            case let .changeOption(option):
                state.selectionOption = option
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.projects, action: /Action.projectItemTapped(id:action:)) {
            ProjectItem()
        }
    }
}
