//
//  PlanBoardView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//

import SwiftUI
import ComposableArchitecture

extension String {
    static let homeButton = "homeButton"
    static let notificationButton = "notificationButton"
    static let userSettingButton = "userSettingButton"
    static let createPlanBoardButton = "userSettingButton"
    static let shareImageButton = "shareImageButton"
    static let boardSettingButton = "boardSettingButton"
    static let rightToolBarButton = "rightToolBarButton"
}

class PlanBoardViewModel: ObservableObject {
    @Published var hoveredItem = ""
    @Published var tabBarViewClickedItem = String.homeButton
    @Published var topToolBarClickedItem = ""
}
struct PlanBoardView: View {
    @State var isNotificationPresented = false
    @State var isShareImagePresented = false
    @State var isBoardSettingPresented = false
    @State var isRightToolBarPresented = false
    
    @State private var temporarySelectedGridRange: SelectedGridRange?
    @State private var exceededDirection = [false, false, false, false]
    @State private var timer: Timer?
    @StateObject var viewModel = PlanBoardViewModel()
    
    //    let store: StoreOf<PlanBoard>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TabBarView(isNotificationButtonClicked: $isNotificationPresented)
                .environmentObject(viewModel)
            .frame(height: 36)
            systemBorder(.horizontal)
            TopToolBarView(isNotificationPresented: $isNotificationPresented, isShareImagePresented: $isShareImagePresented, isBoardSettingPresented: $isBoardSettingPresented, isRightToolBarPresented: $isRightToolBarPresented)
                .environmentObject(viewModel)
            .frame(height: 48)
            .zIndex(2)
            planBoardBorder(.horizontal)
            HStack(alignment: .top, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        scheduleIndexArea
                            .frame(height: 143)
                        planBoardBorder(.horizontal)
                        extraArea
                            .frame(height: 48)
                        planBoardBorder(.horizontal)
                        lineIndexArea
                    }
                    .frame(width: 20)
                    planBoardBorder(.vertical)
                    VStack(alignment: .leading, spacing: 0) {
                        blackPinkInYourArea
                            .frame(height: 143)
                        planBoardBorder(.horizontal)
                        listControlArea
                            .frame(height: 48)
                        planBoardBorder(.horizontal)
                        listArea
                    }
                    .frame(width: 150)
                    planBoardBorder(.vertical)
                }
                .zIndex(1)
                .background(
                    Color.white
                        .shadow(color: .black.opacity(0.25),
                                radius: 8,
                                x: 4)
                )
                GeometryReader { _ in
                    VStack(alignment: .leading, spacing: 0) {
                        scheduleArea
                            .frame(height: 143)
                        planBoardBorder(.horizontal)
                        timeAxisArea
                            .frame(height: 48)
                        planBoardBorder(.horizontal)
                        lineArea
                    }
                }
                if isRightToolBarPresented {
                    RightToolBarView()
                        .frame(width: 240)
                        .zIndex(1)
                        .background(
                            Color.white
                                .shadow(color: .black.opacity(0.25),
                                        radius: 8,
                                        x: -4)
                        )
                }
            }
            
        }
    }
}

extension PlanBoardView {
    var scheduleIndexArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var extraArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var lineIndexArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var blackPinkInYourArea: some View {
        Color.listItem
    }
}

extension PlanBoardView {
    var listControlArea: some View {
        Color.listItem
    }
}

extension PlanBoardView {
    var listArea: some View {
        Color.list
    }
}

extension PlanBoardView {
    var scheduleArea: some View {
        Color.lineArea
    }
}

extension PlanBoardView {
    var timeAxisArea: some View {
        Color.lineArea
    }
}

extension PlanBoardView {
    var lineArea: some View {
        Color.lineArea
    }
}
