//
//  ProjectBoardView.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardView: View {
    let store: StoreOf<ProjectBoard>
    let windowManager: WindowManager
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isUserSettingPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isUserSettingPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .userSettingButton,
                            bool: newValue
                        ))
                    }
                )
            }
            var isThemeSettingButton: Binding<Bool> {
                Binding(
                    get: { viewStore.isThemeSettingPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .themeSettingButton,
                            bool: newValue
                        ))
                    }
                )
            }
            var currentShowingPlanBoardID: String {
                viewStore.showingProject!.id
            }
            VStack(alignment: .leading, spacing: 0) {
                
                TabBarView(store: store, isMaximized: windowManager.isMaximized)
                    .frame(height: 36)
                    .zIndex(2)
                if viewStore.tabBarFocusGroupClickedItem == .homeButton {
                    systemBorder(.horizontal)
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            userSettingArea
                                .popover(
                                    isPresented: isUserSettingPresented,
                                    attachmentAnchor: .point(.bottom),
                                    arrowEdge: .bottom
                                ) {
                                    UserSettingView(store: store)
                                        .popover(isPresented: isThemeSettingButton, arrowEdge: .trailing) {
                                            themeSelect
                                        }
                                }
                            systemBorder(.horizontal)
                            calendarArea
                                .frame(height: 280)
                                .padding(.horizontal, 16)
                            systemBorder(.horizontal)
                            boardSearchArea
                            projectListArea
                            Spacer()
                        }
                        .background(Color.sideBar.shadow(
                            color: .black.opacity(0.2),
                            radius: 16,
                            x: 8
                        ))
                        .frame(width: 280)
                        .zIndex(1)
                        systemBorder(.vertical)
                        listArea
                    }
                } else {
                    IfLetStore(
                        store.scope(
                            state: \.planBoards[id: currentShowingPlanBoardID],
                            action: { .planBoardAction(id: currentShowingPlanBoardID, action: $0) }
                        )
                    ) {
                        PlanBoardView(store: $0)
                    } else: {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension ProjectBoardView {
    var userSettingArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isSettingsViewPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isSettingsViewPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .settingButton,
                            bool: newValue
                        ))
                    }
                )
            }
            var isLogoutViewPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isLogoutViewPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .logoutButton,
                            bool: newValue
                        ))
                    }
                )
            }
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .foregroundStyle(Color.blackWhite)
                    .frame(width: 24, height: 24)
                Text(viewStore.user.username)
                    .foregroundStyle(Color.title)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .foregroundStyle(Color.subtitle)
            }
            .padding(8)
            .background {
                if viewStore.isUserSettingPresented ||
                    viewStore.hoveredItem == .userSettingButton {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(Color.itemHovered)
                }
            }
            .padding(8)
            .frame(height: 48)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .userSettingButton : "")
                )
            }
            .onTapGesture {
                viewStore.send(.popoverPresent(
                    button: .userSettingButton,
                    bool: !viewStore.isUserSettingPresented
                ))
            }
            .sheet(isPresented: isSettingsViewPresented) {
                SettingsView(store: store)
            }
            .sheet(isPresented: isLogoutViewPresented) {
                LogoutView(store: store)
            }
        }
    }
}

extension ProjectBoardView {
    var calendarArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(viewStore.hoveredItem == "calendarArea" ? Color.itemHovered : .item)
                .frame(width: 248, height: 248)
                .overlay {
                    GeometryReader { _ in
                        VStack(alignment: .center, spacing: 4) {
                            HStack(alignment: .center, spacing: 16) {
                                Text("\(viewStore.currentDate.formattedMonth) 월")
                                    .foregroundStyle(Color.black)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .font(.body)
                                    .foregroundColor(Color.gray)
                                    .onTapGesture { viewStore.send(.changeMonth(monthIndex: -1))}
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .foregroundColor(Color.gray)
                                    .onTapGesture { viewStore.send(.changeMonth(monthIndex: 1))}
                            }
                            .padding(.horizontal, 24)
                            HStack(alignment: .top, spacing: 5) {
                                ForEach(viewStore.days, id: \.self) { day in
                                    Text(day)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(day == "일" ? Color.gray : .black)
                                        .frame(width: 25, height: 25)
                                }
                            }
                            let columns = Array(repeating: GridItem(.fixed(25), spacing: 5), count: 7)
                            LazyVGrid(columns: columns, spacing: viewStore.currentDate.extractDate().count > 35 ? 0 : 6) {
                                ForEach(viewStore.currentDate.extractDate()) { value in
                                    cardView(value: value)
                                }
                            }
                            Spacer()
                        }
                    }
                    .offset(y: 24)
                }
                .scaleEffect(viewStore.hoveredItem == "calendarArea" ? 1.02 : 1)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "calendarArea" : ""))
                }
        }
    }
    
    @ViewBuilder
    func cardView(value: DateValue) -> some View {
        ZStack {
            if value.day != -1 {
                let isToday = Calendar.current.isDateInToday(value.date)
                let isSunday = value.date.dayOfSunday() == 1
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(isToday ? Color.black : .clear)
                Text("\(value.day)")
                    .font(.title3)
                    .bold(isToday ? true : false)
                    .foregroundColor(isSunday ? Color.gray : isToday ? Color.white : .black)
            }
        }
    }
}

extension ProjectBoardView {
    var boardSearchArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(viewStore.hoveredItem == "searchTextFieldHover" ? Color.itemHovered : .item)
                    .frame(height: 32)
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 20, height: 20)
                    TextField(
                        "Search",
                        text: viewStore.binding(
                            get: \.searchPlanBoardText,
                            send: { .searchTitleChanged($0) }
                        )
                    )
                    .textFieldStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
            .padding(8)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? "searchTextFieldHover" : ""))
            }
        }
    }
}

extension ProjectBoardView {
    var projectListArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isDisclosureGroupExpanded: Binding<Bool> {
                Binding(
                    get: { viewStore.isDisclosureGroupExpanded },
                    set: { newValue in
                        viewStore.send(.disclosurePresent(
                            button: .disclosureFolderButton,
                            bool: newValue
                        ))
                    }
                )
            }
            Section(header: Text("Projects")
                .fontWeight(.medium)
                .padding(.leading, 16)
                .padding(.bottom, 8)
            ) {
                ScrollView(showsIndicators: false) {
                    DisclosureGroup(isExpanded: isDisclosureGroupExpanded) {
                        ForEach(0..<4, id: \.self) { index in
                            Folder(store: store, id: index)
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: viewStore.isDisclosureGroupExpanded ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.subtitle)
                                )
                            Label("Personal Project", systemImage: "person.crop.square.fill")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.title)
                                .frame(height: 40)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .onHover { isHovered in
                            viewStore.send(.hoveredItem(name: isHovered ? "personalProject" : ""))
                        }
                        .background(
                            viewStore.isDisclosureGroupExpanded || viewStore.hoveredItem == "personalProject" ?
                            Color.itemHovered : .clear
                        )
                        .onTapGesture {
                            viewStore.send(.disclosurePresent(
                                button: .disclosureFolderButton,
                                bool: !viewStore.isDisclosureGroupExpanded
                            ))
                            viewStore.send(.clickedItem(
                                focusGroup: .projectListFocusGroup,
                                name: "personalProject")
                            )
                        }
                    }
                }
                .disclosureGroupStyle(MyDisclosureStyle())
            }
        }
    }
    
    private struct Folder: View {
        let store: StoreOf<ProjectBoard>
        var id: Int
        
        var body: some View {
            // TODO: - 현재 폴더 없는 상태. 더미로 보여주고 있는 폴더 일단은 숨기기
            WithViewStore(store, observe: { $0 }) { viewStore in
                HStack(alignment: .center, spacing: 0) {
                    Text("Folder")
                        .foregroundStyle(Color.title)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.leading, 64)
                .frame(height: 40)
                .background(viewStore.hoveredItem == "folderId_\(id)" ||
                            viewStore.folderListFocusGroupClickedItem == "folderId_\(id)" ?
                            Color.itemHovered.opacity(0.5) : .clear)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(
                        name: isHovered ?
                        "folderId_\(id)" : "")
                    )
                }
                .onTapGesture {
                    viewStore.send(.clickedItem(
                        focusGroup: .folderListFocusGroup,
                        name: "folderId_\(id)")
                    )
                }
            }
        }
    }
    
    private struct MyDisclosureStyle: DisclosureGroupStyle {
        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                configuration.label
                if configuration.isExpanded {
                    configuration.content
                }
            }
        }
    }
}

extension ProjectBoardView {
    var listArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isCreatePlanBoardPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isCreatePlanBoardPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .createPlanBoardButton,
                            bool: newValue
                        ))
                    }
                )
            }
            var isEditPlanBoardPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isEditPlanBoardPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .editPlanBoardButton,
                            bool: newValue
                        ))
                    }
                )
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(viewStore.hoveredItem == .galleryBackButton ? Color.title : .subtitle)
                        .fontWeight(viewStore.hoveredItem == .galleryBackButton ? .bold : .medium)
                        .padding(8)
                        .frame(width: 32, height: 32)
                        .scaleEffect(viewStore.hoveredItem == .galleryBackButton ? 1.02 : 1)
                        .onTapGesture {
                            // TODO: - Back Button Clicked
                        }
                        .onHover { isHovered in
                            viewStore.send(.hoveredItem(name: isHovered ? .galleryBackButton : ""))
                        }
                    Text("Folder")
                        .font(.title)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        viewStore.send(.popoverPresent(
                            button: .createPlanBoardButton,
                            bool: true
                        ))
                    } label: {
                        RoundedRectangle(cornerRadius: 22)
                            .foregroundStyle(viewStore.hoveredItem == .createPlanBoardButton ?
                                             Color.boardSelectedBorder : .button)
                            .shadow(
                                color: .black.opacity(0.25),
                                radius: 4,
                                y: 4
                            )
                            .frame(width: 125, height: 44)
                            .overlay(
                                Text("+ Plan Board")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.buttonText)
                            )
                    }
                    .buttonStyle(.link)
                    .scaleEffect(viewStore.hoveredItem == .createPlanBoardButton ? 1.01 : 1)
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .createPlanBoardButton : ""))
                    }
                }
                .padding(16)
                .padding(.trailing, 16)
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEachStore(
                                store.scope(
                                    state: \.projects,
                                    action: { .projectItemTapped(id: $0, action: $1) }
                                )
                            ) {
                                PlanBoardItem(store: $0)
                            }
                        }
                        .padding(32)
                    }
                    .background(Color.folder)
                    LinearGradient(colors: [.clear, .folder], startPoint: .top, endPoint: .bottom)
                        .frame(height: 48)
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(.leading, 32)
                .padding([.trailing, .bottom], 16)
            }
            .background(Color.project)
            .sheet(isPresented: isCreatePlanBoardPresented) {
                CreatePlanBoardView(store: store)
            }
            .sheet(isPresented: isEditPlanBoardPresented) {
                EditPlanBoardView(store: store)
            }
        }
    }
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 240, maximum: 360), spacing: 32)]
    }
    
    private struct PlanBoardItem: View {
        let store: StoreOf<ProjectItem>
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(Color.board)
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(viewStore.isSelected ? Color.blue : viewStore.hoveredItem == .planBoardItemButton + "\(viewStore.id)" ? Color.boardHoveredBorder : .clear)
                            .shadow(
                                color: viewStore.hoveredItem == .planBoardItemButton + "\(viewStore.id)" ? .black.opacity(0.25) : .clear,
                                radius: 8
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }
                    .aspectRatio(3/2, contentMode: .fit)
                    .shadow(
                        color: viewStore.hoveredItem == .planBoardItemButton + "\(viewStore.id)" ? .black.opacity(0.25) : .clear,
                        radius: 4,
                        y: 4
                    )
                    .highPriorityGesture(TapGesture(count: 1).onEnded({
                        viewStore.$isSelected.wrappedValue.toggle()
                    }))
                    .simultaneousGesture(TapGesture(count: 2).onEnded {
                        viewStore.$isTapped.wrappedValue.toggle()
                    })
                    Spacer().frame(height: 8)
                    Text(viewStore.project.title)
                        .fontWeight(.medium)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.title)
                    Text("2023.10.01 ~ 2023.11.14")
                        .font(.caption)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.subtitle)
                    Text("Last updated on \(viewStore.project.lastModifiedDate.formattedDate)")
                        .font(.caption)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.textInactive)
                }
                .scaleEffect(viewStore.hoveredItem == .planBoardItemButton + "\(viewStore.id)" ? 1.02 : 1)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .planBoardItemButton + "\(viewStore.id)" : ""))
                }
                .contextMenu {
                    Button("Edit") {
                        viewStore.$isEditing.wrappedValue.toggle()
                    }
                    
                    Button("Delete") {
                        viewStore.$isDeleted.wrappedValue.toggle()
                    }
                }
            }
        }
    }
}

extension ProjectBoardView {
    var themeSelect: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Automatic")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.title)
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(viewStore.themeFocusGroupClickedItem == .automaticButton ? Color.title : .clear)
                }
                .frame(height: 40)
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(
                            viewStore.themeFocusGroupClickedItem == .automaticButton ?
                            Color.blackWhite : viewStore.hoveredItem == "automatic" ? Color.blackWhite : .clear
                        )
                )
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "automatic" : ""))
                }
                .onTapGesture {
                    viewStore.send(.clickedItem(
                        focusGroup: .themeFocusGroup,
                        name: .automaticButton
                    ))
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Text("Light")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.title)
                    Spacer()
                    Image(systemName: "checkmark").foregroundStyle(viewStore.themeFocusGroupClickedItem == .lightButton ? Color.title : .clear)
                }
                .frame(height: 40)
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(
                            viewStore.themeFocusGroupClickedItem == .lightButton ?
                            Color.blackWhite : viewStore.hoveredItem == "light" ? Color.blackWhite : .clear
                        )
                )
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "light" : ""))
                }
                .onTapGesture {
                    viewStore.send(.clickedItem(
                        focusGroup: .themeFocusGroup,
                        name: .lightButton
                    ))
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Text("Dark")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.title)
                    Spacer()
                    Image(systemName: "checkmark").foregroundStyle(viewStore.themeFocusGroupClickedItem == .darkButton ? Color.title : .clear)
                }
                .frame(height: 40)
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(
                            viewStore.themeFocusGroupClickedItem == .darkButton ?
                            Color.blackWhite : viewStore.hoveredItem == "dark" ? Color.blackWhite : .clear
                        )
                )
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "dark" : ""))
                }
                .onTapGesture {
                    viewStore.send(.clickedItem(
                        focusGroup: .themeFocusGroup,
                        name: .darkButton
                    ))
                }
            }
            .padding(16)
            .frame(width: 170, height: 168)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.blackWhite.opacity(0.3))
            )
        }
    }
}
