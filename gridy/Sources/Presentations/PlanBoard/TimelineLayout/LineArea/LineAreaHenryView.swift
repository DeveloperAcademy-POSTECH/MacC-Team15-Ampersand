//
//  LineAreaHenryView.swift
//  gridy
//
//  Created by 최민규 on 2023/10/04.
//

import SwiftUI

struct LineAreaHenryView: View {
    @EnvironmentObject var dataModel: DataModel
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    private let colors: [Color] = [.red, .purple, .yellow, .green, .blue]
    private let initialRows = 10
    
    //TODO: 나중에 @State Property Wrapper로된 property로 교체할 것
    var gridRows: Array<GridItem> { return Array(repeating: GridItem(.fixed(viewModel.gridWidth)), count: 1) }
    var gridColumns: Array<GridItem> { return Array(repeating: GridItem(.fixed(viewModel.gridWidth)), count: 1) }
    
    var body: some View {
        ScrollView(.vertical) {
            HStack(alignment: .top, spacing: 0) {
                LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 0) {
                    ForEach(Item.sampleItems) { item in
                        GridItemView(width: viewModel.gridWidth, height: viewModel.lineAreaGridHeight, item: item)
                    }
                }
                .fixedSize()
                .border(.red)
                LazyVStack(alignment: .leading, spacing: 0) {
//                    ForEach(0..<30, id: \.self) { row in
                        LazyHGrid(rows: gridRows, alignment: .top, spacing: 0) {
                            ForEach(Item.sampleItems) { item in
                                GridItemView(width: viewModel.gridWidth, height: viewModel.lineAreaGridHeight, item: item)
//                                    .onTapGesture { _ in
//                                        let rectTopLeft = CGPoint(x: CGFloat(row) * viewModel.gridWidth, y: CGFloat(row) * viewModel.lineAreaGridHeight)
//                                        viewModel.tappedCellTopLeftPoint = rectTopLeft
//                                        viewModel.tappedCellCol = row
//                                        viewModel.tappedCellRow = row
//                                    }
                            }
//                        }
                    }
                }
                .border(.blue)
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
