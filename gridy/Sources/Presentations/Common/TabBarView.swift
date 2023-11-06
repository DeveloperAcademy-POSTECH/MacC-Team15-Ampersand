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
        WithViewStore(store, observe: { $0 }) { _ in
            HStack(alignment: .center, spacing: 0) {
                windowControlsButton
                systemBorder(.vertical)
                homeButton
                systemBorder(.vertical)
                ForEach(0...2, id: \.self) { index in
                    TabItemView(
                        store: store,
                        index: index
                    )
                    systemBorder(.vertical)
                }
                Spacer()
                systemBorder(.vertical)
                notificationButton
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
            .onHover { proxy in
                viewStore.send(.hoveredItem(name: proxy ? .homeButton : ""))
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
                    .onHover { proxy in
                        viewStore.send(.hoveredItem(name: proxy ? .notificationButton : ""))
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
            .sheet(isPresented: isNotificationPresented) {
                NotificationView()
            }
        }
    }
}

struct TabItemView: View {
    let store: StoreOf<ProjectBoard>
    @State var isDeleteButtonHovered = false
    let index: Int
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .center, spacing: 0) {
                Text("BoardName\(index)")
                    .fontWeight(.medium)
                    .padding(.leading, 16)
                    .foregroundStyle(
                        viewStore.hoveredItem == "tabName:\(index)" ||
                        viewStore.tabBarFocusGroupClickedItem == "tabName:\(index)" ?
                        Color.tabLabel : Color.tabLabelInactive
                    )
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(width: 32)
                    .overlay(
                        Image(systemName: "xmark")
                            .foregroundStyle(
                                isDeleteButtonHovered ?
                                Color.tabLabel : viewStore.hoveredItem == "tabName:\(index)" ||
                                viewStore.tabBarFocusGroupClickedItem == "tabName:\(index)" ?
                                Color.subtitle : Color.clear
                            )
                    )
                    .onHover { proxy in
                        isDeleteButtonHovered = proxy
                    }
            }
            .background(
                viewStore.hoveredItem == "tabName:\(index)" ||
                viewStore.tabBarFocusGroupClickedItem == "tabName:\(index)" ?
                Color.tabHovered : Color.tabBar
            )
            .onHover { proxy in
                viewStore.send(.hoveredItem(name: proxy ? "tabName:\(index)" : ""))
            }
            .onTapGesture {
                viewStore.send(.clickedItem(
                    focusGroup: .tabBarFocusGroup,
                    name: "tabName:\(index)"
                ))
            }
        }
    }
}
