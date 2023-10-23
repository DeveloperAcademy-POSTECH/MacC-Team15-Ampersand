//
//  TimelineLayoutContentView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI
import ComposableArchitecture

struct TimelineLayoutContentView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    @Namespace var scrollSpace
    @State var scrollOffset = CGFloat.zero
    @Binding var showingIndexArea: Bool
    @Binding var proxy: ScrollViewProxy?
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if showingIndexArea {
                VStack(spacing: 0) {
                    ScheduleIndexAreaView()
                        .frame(height: 140)
                    Rectangle()
                        .foregroundStyle(.white)
                        .border(.black)
                        .frame(height: 60)
                    LineIndexAreaView()
                }
                .frame(width: 35)
                .zIndex(1)
            }
            VStack(alignment: .leading, spacing: 0) {
                BlackPinkInYourAreaView()
                    .frame(height: 200)
                ListAreaView()
                    .environmentObject(viewModel)
            }
            .frame(width: 266)
            .zIndex(1)
            GeometryReader { _ in                
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottom) {
                        ScheduleAreaView()
                            .environmentObject(viewModel)
                            .frame(height: 200)
            
                        TimeAxisAreaView()
                            .environmentObject(viewModel)
                            .frame(height: 80)
                    }
                    .zIndex(1)
                    
                    LineAreaView(store: store)
                        .environmentObject(viewModel)
                        .zIndex(0)
                }
            }
        }
    }
}
