//
//  ScheduleAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct ScheduleAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    @State private var columnStroke: CGFloat = 0.1
    @State private var rowStroke: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                Path { path in
                    for rowIndex in 0..<viewModel.numOfScheduleAreaRow {
                        let yLocation = CGFloat(rowIndex) * viewModel.scheduleAreaGridHeight - rowStroke
                        path.move(to: CGPoint(x: 0, y: yLocation))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                    }
                }
                .stroke(Color.gray, lineWidth: rowStroke)
                Path { path in
                    for columnIndex in 0..<viewModel.maxCol {
                        let xLocation = CGFloat(columnIndex) * viewModel.gridWidth - columnStroke
                        path.move(to: CGPoint(x: xLocation, y: 0))
                        path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                    }
                }
                .stroke(Color.gray, lineWidth: columnStroke)
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
}

struct ScheduleAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleAreaView()
    }
}
