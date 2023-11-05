//
//  TabBarView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var viewModel: PlanBoardViewModel
    @Binding var isNotificationButtonClicked: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            windowControlsButton
            systemBorder(.vertical)
            homeButton
            systemBorder(.vertical)
            ForEach(0...2, id: \.self) { index in
                TabItemView(index: index)
                    .environmentObject(viewModel)
                systemBorder(.vertical)
            }
            Spacer()
            notificationButton
        }
        .background(Color.tabBar)
        .sheet(isPresented: $isNotificationButtonClicked) {
            NotificationView()
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
        ZStack {
            Rectangle()
                .foregroundStyle(
                    viewModel.hoveredItem == .homeButton || viewModel.tabBarViewClickedItem == .homeButton ? Color.tabHovered : .clear
                )
            Image(systemName: "house.fill")
                .foregroundStyle(Color.tabLabel)
        }
        .frame(width: 36)
        .onHover { proxy in
            viewModel.hoveredItem = proxy ? .homeButton : ""
        }
        .onTapGesture {
            viewModel.tabBarViewClickedItem = (viewModel.tabBarViewClickedItem == .homeButton) ? "" : .homeButton
        }
    }
}

extension TabBarView {
    var notificationButton: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(
                    viewModel.hoveredItem == .notificationButton || isNotificationButtonClicked ? Color.tabHovered : .clear
                )
                .overlay(
                    Image(systemName: "bell.fill")
                        .foregroundStyle(Color.title)
                )
                .frame(width: 48)
                .onHover { proxy in
                    viewModel.hoveredItem = proxy ? .notificationButton : ""
                }
                .onTapGesture {
                    isNotificationButtonClicked.toggle()
                }
            Circle()
                .foregroundColor(Color.red)
                .frame(width: 5, height: 5)
                .offset(x: 3, y: -3)
        }
    }
}

struct TabItemView: View {
    @EnvironmentObject var viewModel: PlanBoardViewModel
    @State var isDeleteButtonHovered = false
    let index: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("BoardName\(index)")
                .fontWeight(.medium)
                .padding(.leading, 16)
                .foregroundStyle(
                    viewModel.hoveredItem == "tabName:\(index)" || viewModel.tabBarViewClickedItem == "tabName:\(index)" ? Color.title : Color.subtitle
                )
            Rectangle()
                .foregroundStyle(.clear)
                .frame(width: 32)
                .overlay(
                    Image(systemName: "xmark")
                        .foregroundStyle(
                            isDeleteButtonHovered ? 
                            Color.title :
                                viewModel.hoveredItem == "tabName:\(index)" || viewModel.tabBarViewClickedItem == "tabName:\(index)" ?
                            Color.textInactive : Color.clear
                        )
                    )
                .onHover { proxy in
                    isDeleteButtonHovered = proxy
                }
        }
        .background(
            viewModel.hoveredItem == "tabName:\(index)" || viewModel.tabBarViewClickedItem == "tabName:\(index)" ? Color.tabHovered : Color.tabBar
        )
        .onHover { proxy in
            viewModel.hoveredItem = proxy ? "tabName:\(index)" : ""
        }
        .onTapGesture {
            viewModel.tabBarViewClickedItem = (viewModel.tabBarViewClickedItem == "tabName:\(index)") ? "" : "tabName:\(index)"
        }
    }
}
