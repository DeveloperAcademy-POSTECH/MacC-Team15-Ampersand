//
//  TabBarView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct TabBarView: View {
    let store: StoreOf<ProjectBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isNotificationPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isNotificationPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .notificationButton,
                            bool: newValue
                        ))
                    }
                )
            }
            HStack(alignment: .center, spacing: 0) {
                windowControlsButton
                systemBorder(.vertical)
                homeButton
                systemBorder(.vertical)
                ForEach(viewStore.showingProjects, id: \.self) { id in
                    TabItemView(
                        store: store,
                        projectID: id
                    )
                    systemBorder(.vertical)
                }
                Spacer()
                systemBorder(.vertical)
                notificationButton
                    .popover(isPresented: isNotificationPresented, attachmentAnchor: .point(.bottom)) {
                        NotificationView(store: store)
                    }
            }
            .background(Color.tabBar)
        }
    }
}

extension TabBarView {
    var windowControlsButton: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .foregroundStyle(.red)
                .frame(width: 12, height: 12)
            Circle()
                .foregroundStyle(.yellow)
                .frame(width: 12, height: 12)
            Circle()
                .foregroundStyle(.green)
                .frame(width: 12, height: 12)
        }
        .padding(.horizontal, 12)
    }
}

extension TabBarView {
    var homeButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundStyle(
                        viewStore.hoveredItem == .homeButton ||
                        viewStore.tabBarFocusGroupClickedItem == .homeButton ?
                        Color.tabHovered : .clear
                    )
                Image(systemName: "house.fill")
                    .foregroundStyle(Color.tabLabel)
            }
            .frame(width: 36)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .homeButton : ""))
            }
            .onTapGesture {
                viewStore.send(.clickedItem(
                    focusGroup: .tabBarFocusGroup,
                    name: .homeButton
                ))
            }
        }
    }
}

extension TabBarView {
    var notificationButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isNotificationPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isNotificationPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .notificationButton,
                            bool: newValue
                        ))
                    }
                )
            }
            ZStack {
                Rectangle()
                    .foregroundStyle(
                        viewStore.hoveredItem == .notificationButton ||
                        viewStore.isNotificationPresented ?
                        Color.tabHovered : .clear
                    )
                    .overlay(
                        Image(systemName: "bell.fill")
                            .foregroundStyle(Color.title)
                    )
                    .frame(width: 48)
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .notificationButton : ""))
                    }
                    .onTapGesture {
                        viewStore.send(.popoverPresent(
                            button: .notificationButton,
                            bool: true
                        ))
                    }
                Circle()
                    .foregroundColor(Color.red)
                    .frame(width: 5, height: 5)
                    .offset(x: 3, y: -3)
            }
        }
    }
}

struct TabItemView: View {
    let store: StoreOf<ProjectBoard>
    let projectID: String
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .center, spacing: 0) {
                ZStack {
                    Rectangle()
                        .foregroundStyle(Color.clear)
                    Text(viewStore.projects[id: projectID]!.project.title)
                        .fontWeight(.medium)
                        .padding(.leading, 16)
                        .foregroundStyle(
                            viewStore.hoveredItem == projectID ||
                            viewStore.hoveredItem == .tabItemDeleteButton + projectID ||
                            viewStore.tabBarFocusGroupClickedItem == projectID ?
                            Color.tabLabel : Color.tabLabelInactive
                        )
                }
                .frame(height: 36)
                .fixedSize()
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? projectID : ""))
                }
                Rectangle()
                    .foregroundStyle(Color.clear)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "xmark")
                            .foregroundStyle(
                                viewStore.hoveredItem == .tabItemDeleteButton + projectID ?
                                Color.tabLabel : viewStore.hoveredItem == projectID ||
                                viewStore.tabBarFocusGroupClickedItem == projectID ?
                                Color.subtitle : Color.clear
                            )
                    )
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .tabItemDeleteButton + projectID : ""))
                    }
                    .onTapGesture {
                        viewStore.send(.deleteShowingTab(projectID: projectID))
                    }
            }
            .background(
                viewStore.hoveredItem == projectID ||
                viewStore.hoveredItem == .tabItemDeleteButton + projectID ||
                viewStore.tabBarFocusGroupClickedItem == projectID ?
                Color.tabHovered : Color.tabBar
            )
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? projectID : ""))
            }
            .onTapGesture {
                viewStore.send(.clickedItem(
                    focusGroup: .tabBarFocusGroup,
                    name: projectID
                ))
                viewStore.send(.setShowingTab(
                    project: viewStore.projects[id: projectID]!.project
                ))
            }
        }
    }
}
