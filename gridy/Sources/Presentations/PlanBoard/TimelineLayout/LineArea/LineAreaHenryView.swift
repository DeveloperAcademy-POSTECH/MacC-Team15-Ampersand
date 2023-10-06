//
//  LineAreaHenryView.swift
//  gridy
//
//  Created by 최민규 on 2023/10/04.
//

import SwiftUI

struct LineAreaHenryView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    let colors: [Color] = [.red, .purple, .yellow, .green, .blue]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(0..<viewModel.numOfLineAreaRow, id: \.self) { row in
                    LazyHStack(alignment: .top, spacing: 0) {
                        ForEach(0..<viewModel.numOfCol, id: \.self) { col in
                            Rectangle()
                                .foregroundColor(colors[(row + col) % colors.count])
                                .frame(width: viewModel.gridWidth, height: viewModel.lineAreaGridHeight)
                                .onTapGesture { _ in
                                    let rectTopLeft = CGPoint(x: CGFloat(col) * viewModel.gridWidth, y: CGFloat(row) * viewModel.lineAreaGridHeight)
                                    viewModel.tappedCellTopLeftPoint = rectTopLeft
                                    viewModel.tappedCellCol = col
                                    viewModel.tappedCellRow = row
                                }
                        }
                    }
                }
            }
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    viewModel.hoverLocation = location
                    viewModel.hoveringCellCol = Int(viewModel.hoverLocation.x / viewModel.gridWidth)
                    viewModel.hoveringCellRow = Int(viewModel.hoverLocation.y / viewModel.lineAreaGridHeight)
                    viewModel.isHovering = true
                case .ended:
                    viewModel.isHovering = false
                }
            }
            .overlay {
                if viewModel.isHovering {
                    Circle()
                        .fill(.white)
                        .opacity(0.5)
                        .frame(width: 30, height: 30)
                        .position(x: viewModel.hoverLocation.x, y: viewModel.hoverLocation.y)
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        print(value)
                        DispatchQueue.main.async {
                                viewModel.gridWidth = min(max(viewModel.gridWidth * min(max(value, 0.5), 2.0), viewModel.minGridSize), viewModel.maxGridSize)
                                viewModel.lineAreaGridHeight = min(max(viewModel.lineAreaGridHeight * min(max(value, 0.5), 2.0), viewModel.minGridSize), viewModel.maxGridSize)
                        }
                    }
            )
        }
    }
}

struct LineAreaHenryView_Previews: PreviewProvider {
    static var previews: some View {
        LineAreaHenryView()
            .previewLayout(.fixed(width: 1000, height: 500))
    }
}
