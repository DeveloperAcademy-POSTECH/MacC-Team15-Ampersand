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
        }
    }
}

extension TabBarView {
    var windowControlsButton: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().foregroundStyle(.red).frame(width: 12, height: 12)
            Circle().foregroundStyle(.yellow).frame(width: 12, height: 12)
            Circle().foregroundStyle(.green).frame(width: 12, height: 12)
        }
        .padding(.horizontal, 12)
    }
}
extension TabBarView {
    var homeButton: some View {
        Rectangle()
            .foregroundStyle(homeButtonClicked ? .white : homeButtonHover ? .gray : .clear)
            .overlay(
                Image(systemName: "house.fill")
                    .foregroundStyle(.black)
            )
            .frame(width: 36)
            .onHover { proxy in
                homeButtonHover = proxy
            }
            .onTapGesture { homeButtonClicked = true }
    }
}
extension TabBarView {
    var planBoardTab: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("BoardNamed")
                .padding(.leading, 16)
                .foregroundStyle(planBoardTabClicked ? .black : planBoardTabHover ? .black : .white)
            Rectangle()
                .foregroundStyle(.clear)
                .frame(width: 32)
                .overlay(
                    Image(systemName: "xmark").foregroundStyle(planBoardTabClicked ? .black : planBoardTabHover ? .black : .clear)
                )
        }
        .background(planBoardTabClicked ? .white : planBoardTabHover ? .gray : .clear)
        .onHover { proxy in
            planBoardTabHover = proxy
        }
        .onTapGesture { planBoardTabClicked = true
            print("ZZ")}
    }
}
extension TabBarView {
    var notificationButton: some View {
        Rectangle()
            .foregroundStyle(bellButtonClicked ? .white : bellButtonHover ? .gray : .clear)
            .overlay(
                Image(systemName: "bell.fill")
                    .foregroundStyle(.black)
            )
            .frame(width: 48)
            .onHover { proxy in
                bellButtonHover = proxy
            }
            .onTapGesture { bellButtonClicked = true }
    }
}
