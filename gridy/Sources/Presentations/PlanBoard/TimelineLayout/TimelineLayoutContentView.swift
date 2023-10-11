//
//  TimelineLayoutContentView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutContentView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    @EnvironmentObject var dataModel: DataModel

    @Binding var showingIndexArea: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
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
            VStack(alignment: .leading, spacing: 0) {
                BlackPinkInYourAreaView()
                    .frame(height: 168)
                ListAreaView()
            }
            .frame(width: 140)
            ScrollViewReader { proxy in
                 ScrollView(.horizontal) {
                    VStack(alignment: .leading, spacing: 0) {
                        ScheduleAreaView()
                            .frame(height: 140)
                        
                        LazyHStack(alignment: .top, spacing: 0) {
                            ForEach(0..<viewModel.numOfCol) { col in
                                Rectangle()
                                    .foregroundColor(.blue)
                                    .frame(width: viewModel.gridWidth)
                                    .overlay(
                                        ZStack {
                                            Text("\(col)")
                                                .font(.body)
                                            Rectangle()
                                                .strokeBorder(lineWidth: 0.3)
                                                .foregroundColor(.white)
                                        }
                                    )
                                    .id(col)
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            proxy.scrollTo(col, anchor: .leading)
                                        }
                                    }
                            }
                        }
                        .frame(height: 28)
                        
                        LineAreaHenryView()
                            .environmentObject(viewModel)
                            .environmentObject(dataModel)
                    }
                }
            }
        }
    }
}

struct TimelineLayoutContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutContentView(showingIndexArea: .constant(true))
    }
}
