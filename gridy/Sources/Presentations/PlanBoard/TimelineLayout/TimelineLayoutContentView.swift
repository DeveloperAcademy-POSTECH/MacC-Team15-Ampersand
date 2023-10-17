//
//  TimelineLayoutContentView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutContentView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    @Namespace var scrollSpace
    @State var scrollOffset = CGFloat.zero
    @State var leftmostDate = Date()
    @Binding var showingIndexArea: Bool
    @Binding var proxy: ScrollViewProxy?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if showingIndexArea {
                VStack(spacing: 0) {
                    ScheduleIndexAreaView()
                        .frame(height: 140)
                    Rectangle()
                        .frame(height: 60)
                    LineIndexAreaView()
                }
                .frame(width: 35)
            }
            VStack(alignment: .leading, spacing: 0) {
                BlackPinkInYourAreaView()
                    .frame(height: 200)
                ListAreaView()
                    .environmentObject(viewModel)
            }
            .frame(width: 266)

                    GeometryReader { geometry in
                        let maxCol = Int(geometry.size.width / viewModel.gridWidth + 1)
                        let maxScheduleAreaRow = Int(140 / viewModel.scheduleAreaGridHeight + 1)
                        let maxLineAreaRow = Int((geometry.size.height - 200) / viewModel.lineAreaGridHeight + 1)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ScheduleAreaView()
                                .frame(height: 140)
                            
                            TimeAxisAreaView(leftmostDate: $leftmostDate, proxy: $proxy)
                                .frame(height: 60)
                                .background(
                                    GeometryReader { geo in
                                        let offset = -geo.frame(in: .named(scrollSpace)).minX
                                        Color.clear
                                            .preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                                    }
                                )
                                .environmentObject(viewModel)
                            
                            LineAreaSampleView()
                                .environmentObject(viewModel)
                            
                        }
                    }
        }
    }
}

//struct TimelineLayoutContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimelineLayoutContentView(showingIndexArea: .constant(true))
//    }
//}
