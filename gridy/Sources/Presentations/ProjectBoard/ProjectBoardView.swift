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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TabBarView(bellButtonClicked: $bellButtonClicked).frame(height: 36)
            borderSpacer(.horizontal)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    userSettingArea.frame(height: 60)
                    borderSpacer(.horizontal)
                    boardSearchArea.frame(height: 60)
                    borderSpacer(.horizontal)
                    projectListArea
                }
                .frame(width: 300)
                borderSpacer(.vertical)
                listArea
            }
        }
        .sheet(isPresented: $bellButtonClicked) {
            NotificationView()
        }
    }
}

extension ProjectBoardView {
    var userSettingArea: some View {
        Text("userSettingArea")
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
