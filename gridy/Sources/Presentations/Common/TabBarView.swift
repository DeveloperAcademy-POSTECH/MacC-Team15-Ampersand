//
//  TabBarView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct TabBarView: View {
    @State var homeButtonHover: Bool = false
    @State var homeButtonClicked: Bool = false
    @State var planBoardTabHover: Bool = false
    @State var planBoardTabClicked: Bool = false
    @State var bellButtonHover: Bool = false
    @Binding var bellButtonClicked: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            windowControlsButton
            borderSpacer(.vertical)
            homeButton
            borderSpacer(.vertical)
            planBoardTab
            Spacer()
            notificationButton
                .popover(isPresented: $bellButtonClicked, attachmentAnchor: .point(.bottom)) {
                    NotificationView()
                }
        }
        .background(Color.tabBar)
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
        Rectangle()
            .foregroundStyle(homeButtonClicked ? Color.tabHovered : homeButtonHover ? Color.tabHovered : Color.clear)
            .overlay(
                Image(systemName: "house.fill")
                    .foregroundStyle(Color.tabLabel)
            )
            .frame(width: 36)
            .onHover { proxy in
                homeButtonHover = proxy
            }
            .onTapGesture {
                homeButtonClicked = true
            }
    }
}

extension TabBarView {
    var planBoardTab: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("BoardNamed")
                .fontWeight(.medium)
                .padding(.leading, 16)
                .foregroundStyle(planBoardTabClicked ? Color.title : planBoardTabHover ? Color.title : Color.title)
            Rectangle()
                .foregroundStyle(.clear)
                .frame(width: 32)
                .overlay(
                    Image(systemName: "xmark").foregroundStyle(planBoardTabClicked ? Color.title : planBoardTabHover ? Color.textInactive : .clear)
                )
        }
        .background(planBoardTabClicked ? Color.tabHovered : planBoardTabHover ? Color.tabHovered : Color.tab)
        .onHover { proxy in
            planBoardTabHover = proxy
        }
        .onTapGesture {
            planBoardTabClicked = true
        }
    }
}

extension TabBarView {
    var notificationButton: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(bellButtonClicked ? Color.tabHovered : bellButtonHover ? Color.tabHovered : Color.clear)
                .overlay(
                    Image(systemName: "bell.fill")
                        .foregroundStyle(Color.title)
                )
                .frame(width: 48)
                .onHover { proxy in
                    bellButtonHover = proxy
                }
                .onTapGesture {
                    bellButtonClicked = true
                }
            Circle()
                .foregroundColor(Color.red)
                .frame(width: 5, height: 5)
                .offset(x: 3, y: -3)
        }
    }
}
