//
//  ScheduleAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct ScheduleAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel

    var body: some View {
        ScrollView(.vertical) {
        LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(0..<viewModel.numOfScheduleAreaRow) { row in
                    LazyHStack(alignment: .top, spacing: 0) {
                        ForEach(0..<viewModel.numOfCol) { col in
                            Rectangle()
                                .foregroundColor(.orange)
                                .frame(width: viewModel.gridWidth, height: viewModel.scheduleAreaGridHeight)
                                .overlay(
                                        Rectangle()
                                            .strokeBorder(lineWidth: 0.3)
                                            .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    print(value)
                    viewModel.gridWidth = min(max(viewModel.gridWidth * min(max(value, 0.5), 2.0), viewModel.minGridSize), viewModel.maxGridSize)
                    viewModel.scheduleAreaGridHeight = min(max(viewModel.scheduleAreaGridHeight * min(max(value, 0.5), 2.0), viewModel.minGridSize), viewModel.maxGridSize)
                }
        )
    }
}

struct ScheduleAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleAreaView()
    }
}
