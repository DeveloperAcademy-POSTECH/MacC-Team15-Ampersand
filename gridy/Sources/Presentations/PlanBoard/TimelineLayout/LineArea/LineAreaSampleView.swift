//
//  LineAreaSampleView.swift
//  gridy
//
//  Created by 최민규 on 10/12/23.
//

import SwiftUI

struct LineAreaSampleView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    private let colors: [Color] = [.red, .purple, .yellow, .green, .blue]
    
    @State private var columnStroke: CGFloat = 0.1
    @State private var rowStroke: CGFloat = 0.5
    @State var geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            Color.white
            
            let visibleCol = Int(geometry.size.width / viewModel.gridWidth) + 1
            let visibleRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) + 1
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
            
            if viewModel.isHovering {
                Rectangle()
                    .stroke(.gray, lineWidth: 1)
                    .frame(width: viewModel.gridWidth, height: viewModel.lineAreaGridHeight)
                    .position(x: CGFloat(viewModel.hoveringCellCol) * viewModel.gridWidth + viewModel.gridWidth / 2, y: CGFloat(viewModel.hoveringCellRow) * viewModel.lineAreaGridHeight + viewModel.lineAreaGridHeight / 2)
            }
            
            if !viewModel.selectedRanges.isEmpty {
                ZStack {
                    ForEach(viewModel.selectedRanges, id: \.self) { selectedRange in
                        let width = CGFloat(selectedRange.end.0 + 1 - selectedRange.start.0) * viewModel.gridWidth
                        let height = CGFloat(selectedRange.end.1 + 1 - selectedRange.start.1) * viewModel.lineAreaGridHeight
                        Rectangle()
                            .fill(Color.blue.opacity(0.05))
                            .overlay(Rectangle().stroke(Color.blue, lineWidth: 1))
                            .frame(width: width, height: height)
                            .position(x: CGFloat(selectedRange.start.0) * viewModel.gridWidth + width / 2, y: CGFloat(selectedRange.start.1) * viewModel.lineAreaGridHeight + height / 2)
                        
                    }
                }
            }
        }
        .onTapGesture(count: 1, coordinateSpace: .local) { position in
            viewModel.tappedCellCol = Int(position.x / viewModel.gridWidth)
            viewModel.tappedCellRow = Int(position.y / viewModel.lineAreaGridHeight)
            viewModel.selectedRanges = [SelectedRange(start: (viewModel.tappedCellCol!, viewModel.tappedCellRow!), end: (viewModel.tappedCellCol!, viewModel.tappedCellRow!))]
            print(viewModel.selectedRanges)
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
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { gesture in
                    let dragEnd = gesture.location
                    let dragStart = gesture.startLocation
                    
                    let startCol = min(Int(dragStart.x / viewModel.gridWidth), Int(dragEnd.x / viewModel.gridWidth))
                    let endCol = max(Int(dragStart.x / viewModel.gridWidth), Int(dragEnd.x / viewModel.gridWidth))
                    let startRow = min(Int(dragStart.y / viewModel.lineAreaGridHeight), Int(dragEnd.y / viewModel.lineAreaGridHeight))
                    let endRow = max(Int(dragStart.y / viewModel.lineAreaGridHeight), Int(dragEnd.y / viewModel.lineAreaGridHeight))
                    
                    viewModel.selectedRanges = [SelectedRange(start: (startCol, startRow), end: (endCol, endRow))]
                    print(viewModel.selectedRanges)
                }
        )
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
//    func moveSelectedCell(dx: Int, dy: Int) {
//        if let firstSelectedCell = (viewModel.selectedRanges.last.start.0, viewModel.selectedRanges.last.start.1) {
//            
//        }
//    }
}
//struct LineAreaSampleView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineAreaSampleView()
//            .previewLayout(.fixed(width: 1000, height: 500))
//    }
//}
