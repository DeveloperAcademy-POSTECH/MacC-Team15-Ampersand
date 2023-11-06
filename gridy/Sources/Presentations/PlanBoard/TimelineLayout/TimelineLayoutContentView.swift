////
////  TimelineLayoutContentView.swift
////  gridy
////
////  Created by xnoag on 2023/09/27.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//struct TimelineLayoutContentView: View {
//    @Namespace var scrollSpace
//    @State var scrollOffset = CGFloat.zero
//    @Binding var proxy: ScrollViewProxy?
//    let store: StoreOf<PlanBoard>
//    
//    var body: some View {
//        WithViewStore(store, observe: { $0 }) { _ in
//            VStack(spacing: 0) {
//                // MARK: - Above the LayerControlArea
//                HStack(alignment: .top, spacing: 0) {
//                    VStack(alignment: .leading, spacing: 0) {
//                        ScheduleIndexAreaView()
//                            .frame(height: 160)
//                        Rectangle()
//                            .foregroundStyle(.white)
//                            .border(.gray)
//                            .frame(height: 40)
//                    }
//                    .frame(width: 35)
//                    
//                    VStack(alignment: .leading, spacing: 0) {
//                        BlackPinkInYourAreaView(store: store)
//                            .frame(height: 160)
//                        Rectangle()
//                            .foregroundStyle(.white)
//                            .border(.gray)
//                            .frame(height: 40)
//                    }
//                    .frame(width: 266)
//                    
//                    GeometryReader { _ in
//                        VStack(alignment: .leading, spacing: 0) {
//                            ZStack(alignment: .bottom) {
//                                ScheduleAreaView(store: store)
//                                TimeAxisAreaView(store: store)
//                                    .frame(height: 80)
//                            }
//                        }
//                    }
//                }
//                .frame(height: 200)
//                .zIndex(1)
//                
//                // MARK: - LayerControlArea
//                LayerControlAreaView(store: store)
//                    .frame(height: 32)
//                    .zIndex(1)
//                
//                // MARK: - Below the LayerControlArea
//                HStack(alignment: .top, spacing: 0) {
//                    LineIndexAreaView()
//                        .frame(width: 35)
//                        .zIndex(1)
//                    ListAreaView(store: store)
//                        .frame(width: 266)
//                        .zIndex(1)
//                    LineAreaView(store: store)
//                        .zIndex(0)
//                }
//            }
//        }
//    }
//}
