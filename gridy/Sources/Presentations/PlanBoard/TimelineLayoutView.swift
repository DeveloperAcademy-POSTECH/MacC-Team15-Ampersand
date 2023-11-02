//
//  TimelineLayoutView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//


import SwiftUI
import ComposableArchitecture

struct TimelineLayoutView: View {
    
//    let store: StoreOf<PlanBoard>
    
    @State var bellButtonClicked = false
    @State var shareImageClicked = false
    @State var shareImageHover = false
    @State var boardSettingClicked = false
    @State var boardSettingHover = false
    @State var rightToolBarHover = false
    @State var rightToolBarClicked = false
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TabBarView(bellButtonClicked: $bellButtonClicked).frame(height: 36)
            borderSpacer(.horizontal)
            TopToolBarArea(shareImageClicked: $shareImageClicked, boardSettingClicked: $boardSettingClicked, rightToolBarClicked: $rightToolBarClicked).frame(height: 36)
            HStack(alignment: .top, spacing: 0) {
                scheduleIndexArea
                borderSpacer(.vertical)
                blackPinkInYourArea
                borderSpacer(.vertical)
                scheduleArea
            }
            borderSpacer(.horizontal)
            HStack(alignment: .top, spacing: 0) {
                extraArea
                borderSpacer(.vertical)
                listControlArea
                borderSpacer(.vertical)
                timeAxisArea
            }
            borderSpacer(.horizontal)
            HStack(alignment: .top, spacing: 0) {
                lineIndexArea
                borderSpacer(.vertical)
                listArea
                borderSpacer(.vertical)
                lineArea
            }
            
        }
        .sheet(isPresented: $bellButtonClicked) {
            NotificationView()
        }
        .sheet(isPresented: $shareImageClicked) {
            ShareImageView()
        }
        .sheet(isPresented: $boardSettingClicked) {
            BoardSettingView()
        }
        .sheet(isPresented: $rightToolBarClicked) {
            RightToolBarView()
        }
    }
}
    
    extension TimelineLayoutView {
        var scheduleIndexArea: some View {
            Color.tabBar
//                .frame(width:32, height:167)
        }
    }
    
    extension TimelineLayoutView {
        var blackPinkInYourArea: some View {
            Color.white
            
            
        }
    }
    
    extension TimelineLayoutView {
        var scheduleArea: some View {
            Color.white
        }
    }
    
    extension TimelineLayoutView {
        var extraArea: some View {
            Color.white
        }
    }
    
    extension TimelineLayoutView {
        var listControlArea: some View {
            Color.white
        }
    }
    extension TimelineLayoutView {
        var timeAxisArea: some View {
            Color.white
        }
    }
    extension TimelineLayoutView {
        var lineIndexArea: some View {
            Color.white
        }
    }
    extension TimelineLayoutView {
        var listArea: some View {
            Color.white
        }
    }
    
    extension TimelineLayoutView {
        var lineArea: some View {
            Color.white
        }
    }
    

