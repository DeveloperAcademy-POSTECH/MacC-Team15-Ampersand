//
//  ObservableScrollView.swift
//  gridy
//
//  Created by SY AN on 2023/10/05.
//

import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ObservableScrollView<Content>: View where Content: View {
    @Namespace var scrollSpace
    @Binding var scrollOffset: CGFloat
    @Binding var leftmostDate: Date
    
    let content: (ScrollViewProxy) -> Content
    
    init(scrollOffset: Binding<CGFloat>,
         leftmostDate: Binding<Date>,
         @ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
        _scrollOffset = scrollOffset
        _leftmostDate = leftmostDate
        self.content = content
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                content(proxy)
                    .background(
                        GeometryReader { geo in
                        let offset = -geo.frame(in: .named(scrollSpace)).minX
                        Color.clear
                            .preference(key: ScrollViewOffsetPreferenceKey.self,
                                        value: offset)
                    })
            }
        }
//        .coordinateSpace(name: scrollSpace)
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            scrollOffset = value
            
            let leftmostVisibleDate = Calendar.current.date(byAdding: .day, value: Int(value / 50), to: Date())
            
            leftmostDate = leftmostVisibleDate!
            
        }
    }
}

