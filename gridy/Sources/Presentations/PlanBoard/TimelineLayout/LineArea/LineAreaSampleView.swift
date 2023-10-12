//
//  LineAreaSampleView.swift
//  gridy
//
//  Created by 최민규 on 10/12/23.
//

import SwiftUI

struct LineAreaSampleView: View {
    @EnvironmentObject var dataModel: DataModel
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    private let colors: [Color] = [.red, .purple, .yellow, .green, .blue]
    
    @State private var columnStroke: CGFloat = 0.1
    @State private var rowStroke: CGFloat = 0.5
    @State var geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            Color.white
            
            let visibleCol = Int(geometry.size.width / viewModel.gridWidth)
            let visibleRow = Int(geometry.size.height / viewModel.lineAreaGridHeight)

            Path { path in
                for columnIndex in 0..<visibleCol {
                    let xLocation = CGFloat(columnIndex) * viewModel.gridWidth
                    path.move(to: CGPoint(x: xLocation, y: 0))
                    path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                }
            }
            .stroke(Color.blue, lineWidth: columnStroke)
            Path { path in
                for rowIndex in 0..<visibleRow {
                    let yLocation = CGFloat(rowIndex) * viewModel.lineAreaGridHeight
                    path.move(to: CGPoint(x: 0, y: yLocation))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                }
            }
            .stroke(Color.red, lineWidth: rowStroke)
        }
        .onTapGesture(count: 1, coordinateSpace: .local) { position in
            viewModel.tappedCellCol = Int(position.x / viewModel.gridWidth)
            viewModel.tappedCellRow = Int(position.y / viewModel.lineAreaGridHeight)
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
//struct LineAreaSampleView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineAreaSampleView()
//            .previewLayout(.fixed(width: 1000, height: 500))
//    }
//}
