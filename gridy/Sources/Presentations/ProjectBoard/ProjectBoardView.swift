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
    @State var planBoardButtonHover = false
    @State var planBoardButtonClicked = false
    @State private var isExpanded: Bool = true
    
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
        .sheet(isPresented: $planBoardButtonClicked) {
            CreatePlanBoardView()
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
        RoundedRectangle(cornerRadius: 8)
            .frame(width: 264, height: 32)
            .overlay(Text("BoardSearchArea").foregroundStyle(.black))
            .padding(8)
    }
}
extension ProjectBoardView {
    var projectListArea: some View {
        List {
            Section("Projects") {
                DisclosureGroup(isExpanded: $isExpanded) {
                    ForEach(0..<4, id: \.self) { _ in
                        Text("Folder")
                    }
                } label: {
                    Label("Personal Project", systemImage: "person.crop.square.fill").foregroundStyle(.white)
                }
                .listRowSeparator(.hidden)
            }
        }
    }
}
extension ProjectBoardView {
    var listArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "chevron.left").foregroundStyle(.white).padding(8)
                    .onTapGesture {
                        // TODO: - Back Button Clicked
                    }
                Text("Folder").font(.title)
                Spacer()
                Button {
                    planBoardButtonClicked = true
                } label: {
                    RoundedRectangle(cornerRadius: 22)
                        .foregroundStyle(planBoardButtonHover ? .purple : .gray)
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
                        .frame(width: 125, height: 44)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .overlay(Text("+ Plan Board").foregroundStyle(.white))
                }
                .buttonStyle(.link)
                .scaleEffect(planBoardButtonHover ? 1.01 : 1)
                .onHover { proxy in
                    withAnimation {
                        planBoardButtonHover = proxy
                    }
                }
            }
            .padding(.top)
            .padding(.bottom, 8)
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 32)
                    .foregroundStyle(.black)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 32) {
                        ForEach(0..<20, id: \.self) { index in
                            ProjectBoardItem(id: index)
                        }
                    }
                    .padding(.top, 32)
                }
                .padding(.leading, 16)
            }
            .padding(.leading, 32)
        }
        .padding([.trailing, .bottom], 16)
    }
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 240, maximum: 240), spacing: 32)]
    }
    private struct ProjectBoardItem: View {
        @State var projectBoardItemHover: Bool = false
        var id: Int
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.gray)
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(projectBoardItemHover ? .white : .clear)
                }
                .frame(width: 240, height: 160)
                .shadow(color: projectBoardItemHover ? .white.opacity(0.25) : .clear, radius: projectBoardItemHover ? 4 : 0, y: projectBoardItemHover ? 4 : 0)
                Text("Board Name").font(.title)
                Text("2023.10.01 ~ 2023.11.14").font(.caption)
                Text("Last updated on 2023.10.17").font(.caption)
            }
            .scaleEffect(projectBoardItemHover ? 1.01 : 1)
            .onHover { proxy in
                withAnimation {
                    projectBoardItemHover = proxy
                }
            }
        }
    }
}

func borderSpacer(_ direction: Edge.Set) -> some View {
    Rectangle()
        .foregroundStyle(.black)
        .frame(width: direction == .vertical ? 1 : .infinity)
        .frame(height: direction == .horizontal ? 1 : .infinity)
}
