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
    @State var listHover = false
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
                    Spacer()
                }
                .background(Color.sideBar)
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
                .foregroundStyle(Color.itemBackground)
                .frame(width: 24, height: 24)
            Text("HongGilDong")
                .foregroundStyle(Color.title)
            Image(systemName: "chevron.down")
                .foregroundStyle(Color.subtitle)
        }
        .padding(8)
        .background {
            if userSettingClicked || userSettingHover {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.itemHovered)
            }
        }
        .padding(8)
        .frame(height: 48)
        .onHover { proxy in
            userSettingHover = proxy
        }
        .onTapGesture {
            userSettingClicked.toggle()
        }
    }
}
extension ProjectBoardView {
    var calendarArea: some View {
        RoundedRectangle(cornerRadius: 32)
            .foregroundStyle(Color.itemBackground)
            .aspectRatio(1, contentMode: .fit)
            .overlay(Text("CalendarArea").foregroundStyle(.black))
            .padding(16)
    }
}
extension ProjectBoardView {
    var boardSearchArea: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(Color.textField)
            .frame(height: 32)
            .overlay(Text("BoardSearchArea").foregroundStyle(.black))
            .padding(16)
    }
}
extension ProjectBoardView {
    var projectListArea: some View {
        Section(header: Text("Projects").padding(.leading, 16).padding(.bottom, 8)) {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(0..<4, id: \.self) { index in
                    Folder(id: index)
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
                        .foregroundStyle(Color.title)
                        .frame(height: 40)
                    Spacer()
                }
                .padding(.leading, 16)
                .background(listHover ? Color.itemSelected : .clear)
                .onHover { proxy in
                    listHover = proxy
                }
            }
            .listRowSeparator(.hidden)
            .disclosureGroupStyle(MyDisclosureStyle())
        }
    }
    private struct Folder: View {
        @State var folderHover = false
        var id: Int
        
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Text("Folder")
                Spacer()
            }
            .frame(height: 40)
            .padding(.leading, 64)
            .background(folderHover ? Color.itemSelected : .clear)
            .onHover { proxy in
                folderHover = proxy
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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.subtitle)
                    .padding(8)
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        // TODO: - Back Button Clicked
                    }
                Text("Folder").font(.title)
                Spacer()
                Button {
                    planBoardButtonClicked = true
                } label: {
                    RoundedRectangle(cornerRadius: 22)
                        .foregroundStyle(planBoardButtonHover ? Color.purple : Color.button)
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
                        .frame(width: 125, height: 44)
                        .overlay(
                            Text("+ Plan Board")
                                .font(.title3)
                                .foregroundStyle(Color.buttonText)
                        )
                }
                .buttonStyle(.link)
                .scaleEffect(planBoardButtonHover ? 1.01 : 1)
                .onHover { proxy in
                    withAnimation {
                        planBoardButtonHover = proxy
                    }
                }
            }
            .padding(16)
            .padding(.trailing, 16)
            ZStack(alignment: .topLeading) {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 32) {
                        ForEach(0..<20, id: \.self) { index in
                            PlanBoardItem(id: index)
                        }
                    }
                    .padding(32)
                }
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .foregroundStyle(Color.sideBar)
                    )
            }
            .padding(.leading, 32)
            .padding([.trailing, .bottom], 16)
        }
        .background(Color.textField)
    }
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 240, maximum: 360), spacing: 32)]
    }
    private struct PlanBoardItem: View {
        @State var planBoardItemHover: Bool = false
        var id: Int
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.itemBackground)
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(planBoardItemHover ? Color.itemSelectedBorder : .clear)
                }
                .aspectRatio(3/2, contentMode: .fit)
                .shadow(color: planBoardItemHover ? .white.opacity(0.25) : .clear, radius: planBoardItemHover ? 4 : 0, y: planBoardItemHover ? 4 : 0)
                Text("Board Name")
                    .font(.title)
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

func borderSpacer(_ direction: Edge.Set) -> some View {
    Rectangle()
        .foregroundStyle(Color.border)
        .frame(width: direction == .vertical ? 1 : nil)
        .frame(height: direction == .horizontal ? 1 : nil)
}
