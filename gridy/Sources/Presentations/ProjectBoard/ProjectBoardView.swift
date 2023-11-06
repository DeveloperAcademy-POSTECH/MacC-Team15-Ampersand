//
//  ProjectBoardView.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardView: View {
    @State private var isExpanded = true
    
    let store: StoreOf<ProjectBoard>
    let planBoardStore = Store(
        initialState: PlanBoard.State(
            rootProject: Project(
                id: "id",
                title: "title",
                ownerUid: "uid",
                createdDate: Date(),
                lastModifiedDate: Date(),
                map: ["": [""]]
            ), map: ["": [""]]
        )
    ) {
        PlanBoard()
            ._printChanges()
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                TabBarView(store: store)
                    .frame(height: 36)
                    .zIndex(2)
                if viewStore.tabBarFocusGroupClickedItem == .homeButton {
                    systemBorder(.horizontal)
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            userSettingArea
                            systemBorder(.horizontal)
                            calendarArea.frame(height: 280)
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
                    PlanBoardView(
                        store: planBoardStore,
                        tabID: viewStore.tabBarFocusGroupClickedItem
                    )
                }
            }
        }
    }
}

extension ProjectBoardView {
    var userSettingArea: some View {
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
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .foregroundStyle(Color.blackWhite)
                    .frame(width: 24, height: 24)
                Text("HongGilDong")
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
            .onHover { proxy in
                viewStore.send(.hoveredItem(name: proxy ? .userSettingButton : "")
                )
            }
            .onTapGesture {
                viewStore.send(.popoverPresent(
                    button: .userSettingButton,
                    bool: !viewStore.isUserSettingPresented
                ))
            }
            .sheet(isPresented: isUserSettingPresented) {
                UserSettingView()
            }
        }
    }
}

extension ProjectBoardView {
    var calendarArea: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(Color.item)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Text("CalendarArea")
                        .foregroundStyle(.black)
                )
                .padding(16)
        }
    }
}

extension ProjectBoardView {
    var boardSearchArea: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.item)
                .frame(height: 32)
                .overlay(
                    Text("BoardSearchArea")
                        .foregroundStyle(Color.textInactive)
                )
                .padding(16)
        }
    }
}

extension ProjectBoardView {
    var projectListArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section(header: Text("Projects")
                .fontWeight(.medium)
                .padding(.leading, 16)
                .padding(.bottom, 8)
            ) {
                ScrollView(showsIndicators: false) {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        ForEach(0..<4, id: \.self) { index in
                            Folder(store: store, id: index)
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.subtitle)
                                )
                            Label("Personal Project", systemImage: "person.crop.square.fill")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.title)
                                .frame(height: 40)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .background(
                            viewStore.projectListFocusGroupClickedItem == "personalProject" ?
                            Color.itemHovered : .clear
                        )
                        .onHover { proxy in
                            viewStore.send(.hoveredItem(
                                name: proxy ? "personalProject" : ""
                            )
                            )
                        }
                        .onTapGesture {
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
                .onHover { proxy in
                    viewStore.send(.hoveredItem(
                        name: proxy ?
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
                Button {
                    configuration.isExpanded.toggle()
                } label: {
                    configuration.label
                }
                .buttonStyle(.plain)
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
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.subtitle)
                        .fontWeight(.medium)
                        .padding(8)
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            // TODO: - Back Button Clicked
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
                                             Color.boardSelectedBorder : Color.button)
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
                    .onHover { proxy in
                        viewStore.send(.hoveredItem(name: proxy ? .createPlanBoardButton : ""))
                    }
                }
                .padding(16)
                .padding(.trailing, 16)
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(0..<20, id: \.self) { index in
                                PlanBoardItem(store: store, id: index)
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
                CreatePlanBoardView()
            }
        }
    }
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 240, maximum: 360), spacing: 32)]
    }
    
    private struct PlanBoardItem: View {
        @State var planBoardItemHover = false
        let store: StoreOf<ProjectBoard>
        var id: Int
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { _ in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(Color.board)
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(planBoardItemHover ? Color.boardHoveredBorder : .clear)
                            .shadow(
                                color: planBoardItemHover ? .black.opacity(0.25) : .clear,
                                radius: 8
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }
                    .aspectRatio(3/2, contentMode: .fit)
                    .shadow(
                        color: planBoardItemHover ? .black.opacity(0.25) : .clear,
                        radius: 4,
                        y: 4
                    )
                    Spacer().frame(height: 8)
                    Text("Board Name")
                        .fontWeight(.medium)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.title)
                    Text("2023.10.01 ~ 2023.11.14")
                        .font(.caption)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.subtitle)
                    Text("Last updated on 2023.10.17")
                        .font(.caption)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.textInactive)
                }
                .scaleEffect(planBoardItemHover ? 1.02 : 1)
                .onHover { proxy in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        planBoardItemHover = proxy
                    }
                }
            }
        }
    }
}
