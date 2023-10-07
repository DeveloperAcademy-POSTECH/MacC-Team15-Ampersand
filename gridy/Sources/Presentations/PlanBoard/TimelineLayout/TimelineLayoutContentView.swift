//
//  TimelineLayoutContentView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutContentView: View {
    @Namespace var scrollSpace
    @State var scrollOffset = CGFloat.zero
    @State var leftmostDate = Date()
    @Binding var showingIndexArea: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if showingIndexArea {
                VStack(spacing: 0) {
                    ScheduleIndexAreaView()
                        .frame(height: 140)
                    Rectangle()
                        .frame(height: 28)
                    LineIndexAreaView()
                }
                .frame(width: 35)
            }
            VStack(spacing: 0) {
                BlackPinkInYourAreaView()
                    .frame(height: 168)
                ListAreaView()
            }
            .frame(width: 140)
            ScrollView(.horizontal) {
                ScrollViewReader { _ in
                    VStack {
                        ScheduleAreaView()
                            .frame(height: 140)
                        TimeAxisAreaView(leftmostDate: $leftmostDate)
                            .frame(height: 50)
                            .border(.red)
                            .background(
                                GeometryReader { geo in
                                    let offset = -geo.frame(in: .named(scrollSpace)).minX
                                    Color.clear
                                        .preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                                }
                            )
                            
                        LineAreaView()
                    }
                    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        let leftmostVisibleDate = Calendar.current.date(byAdding: .day, value: Int(value/50), to: Date())
                        leftmostDate = leftmostVisibleDate!
                    }
                }
            }
            .coordinateSpace(name: scrollSpace)
        }
    }
}

struct TimelineLayoutContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutContentView(showingIndexArea: .constant(true))
    }
}
