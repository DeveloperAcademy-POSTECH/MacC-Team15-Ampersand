//
//  ProjectBoardView.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardView: View {
    @State var bellButtonClicked = false
    @State var userSettingHover = false
    @State var userSettingClicked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TabBarView(bellButtonClicked: $bellButtonClicked).frame(height: 36)
            borderSpacer(.horizontal)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    userSettingArea
                    borderSpacer(.horizontal)
                    calendarArea
                    borderSpacer(.horizontal)
                    boardSearchArea
                    borderSpacer(.horizontal)
                    projectListArea
                }
                .frame(width: 280)
                borderSpacer(.vertical)
                listArea
            }
        }
        .sheet(isPresented: $bellButtonClicked) {
            NotificationView()
        }
        .sheet(isPresented: $userSettingClicked) {
            UserSettingView()
        }
    }
}

extension ProjectBoardView {
    var userSettingArea: some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .padding(.leading, 8)
            Text("HongGilDong").foregroundStyle(.white)
            Image(systemName: "chevron.down").foregroundStyle(.white)
        }
        .padding(8)
        .background {
            if userSettingClicked || userSettingHover {
                RoundedRectangle(cornerRadius: 8).foregroundStyle(.gray)
                    .padding(.leading, 8)
            }
        }
        .frame(height: 48)
        .onHover { proxy in
            userSettingHover = proxy
        }
        .onTapGesture { userSettingClicked.toggle() }
    }
}
extension ProjectBoardView {
    var calendarArea: some View {
        RoundedRectangle(cornerRadius: 32)
            .foregroundStyle(.white)
            .frame(width: 248, height: 248)
            .padding()
            .overlay(Text("CalendarArea").foregroundStyle(.black))
    }
}
extension ProjectBoardView {
    var boardSearchArea: some View {
        Text("boardSearchArea")
    }
}
extension ProjectBoardView {
    var projectListArea: some View {
        Text("projectListArea")
    }
}
extension ProjectBoardView {
    var listArea: some View {
        Text("listArea")
    }
}

func borderSpacer(_ direction: Edge.Set) -> some View {
    Rectangle()
        .foregroundStyle(.black)
        .frame(width: direction == .vertical ? 1 : .infinity)
        .frame(height: direction == .horizontal ? 1 : .infinity)
}
