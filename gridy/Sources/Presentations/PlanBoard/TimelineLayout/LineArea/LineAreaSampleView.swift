//
//  LineAreaSampleView.swift
//  grirowOffset
//
//  Created by 최민규 on 10/12/23.
//

import SwiftUI

struct LineAreaSampleView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    private let colors: [Color] = [.red, .purple, .yellow, .green, .blue]
    
    @State private var columnStroke: CGFloat = 0.1
    @State private var rowStroke: CGFloat = 0.5
    @State private var maxCol: Int = 0
    @State private var maxRow: Int = 0
    @State private var temporarySelectedRange: SelectedRange?
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Button(action: {
                        maxCol = Int(geometry.size.width / viewModel.gridWidth) - 1
                        maxRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) - 1
                        moveSelectedCell(colOffset: 0, rowOffset: -1, isShiftPressed: viewModel.isShiftKeyPressed)}) {
                            Text("UP")
                        }
                        .keyboardShortcut(.upArrow, modifiers: [])
                    
                    Button(action: {
                        maxCol = Int(geometry.size.width / viewModel.gridWidth) - 1
                        maxRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) - 1
                        moveSelectedCell(colOffset: 0, rowOffset: 1, isShiftPressed: viewModel.isShiftKeyPressed)}) {
                            Text("DOWN")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                    
                    Button(action: {
                        maxCol = Int(geometry.size.width / viewModel.gridWidth) - 1
                        maxRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) - 1
                        moveSelectedCell(colOffset: -1, rowOffset: 0, isShiftPressed: viewModel.isShiftKeyPressed)}) {
                            Text("LEFT")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                    
                    Button(action: {
                        maxCol = Int(geometry.size.width / viewModel.gridWidth) - 1
                        maxRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) - 1
                        moveSelectedCell(colOffset: 1, rowOffset: 0, isShiftPressed: viewModel.isShiftKeyPressed)}) {
                            Text("RIGHT")
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                }
                
                Color.white
                
                let visibleCol = Int(geometry.size.width / viewModel.gridWidth) + 1
                let visibleRow = Int(geometry.size.height / viewModel.lineAreaGridHeight) + 1
                Path { path in
                    for columnIndex in 0..<visibleCol {
                        let xLocation = CGFloat(columnIndex) * viewModel.gridWidth - columnStroke
                        path.move(to: CGPoint(x: xLocation, y: 0))
                        path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                    }
                }
                .stroke(Color.blue, lineWidth: columnStroke)
                Path { path in
                    for rowIndex in 0..<visibleRow {
                        let yLocation = CGFloat(rowIndex) * viewModel.lineAreaGridHeight - rowStroke
                        path.move(to: CGPoint(x: 0, y: yLocation))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                    }
                }
                .stroke(Color.red, lineWidth: rowStroke)
                
                if !viewModel.selectedRanges.isEmpty {
                    ZStack {
                        ForEach(viewModel.selectedRanges, id: \.self) { selectedRange in
                            let width = CGFloat((selectedRange.end.0 - selectedRange.start.0).magnitude + 1) * viewModel.gridWidth
                            let height = CGFloat((selectedRange.end.1 - selectedRange.start.1).magnitude + 1) * viewModel.lineAreaGridHeight
                            let isStartColSmaller: Bool = selectedRange.start.0 <= selectedRange.end.0
                            let isStartRowSmaller: Bool = selectedRange.start.1 <= selectedRange.end.1
                            Rectangle()
                                .fill(Color.blue.opacity(0.05))
                                .overlay(Rectangle().stroke(Color.blue, lineWidth: 1))
                                .frame(width: width, height: height)
                                .position(x: isStartColSmaller ? CGFloat(selectedRange.start.0) * viewModel.gridWidth + width / 2 : CGFloat(selectedRange.end.0) * viewModel.gridWidth + width / 2, y: isStartRowSmaller ? CGFloat(selectedRange.start.1) * viewModel.lineAreaGridHeight + height / 2 : CGFloat(selectedRange.end.1) * viewModel.lineAreaGridHeight + height / 2)
                        }
                    }
                }
            }
            .border(.blue)
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
                        
                        if !viewModel.isShiftKeyPressed {
                            let startCol = Int(dragStart.x / viewModel.gridWidth)
                            let endCol = Int(dragEnd.x / viewModel.gridWidth)
                            let startRow = Int(dragStart.y / viewModel.lineAreaGridHeight)
                            let endRow = Int(dragEnd.y / viewModel.lineAreaGridHeight)
                            
                            viewModel.selectedRanges = [SelectedRange(start: (startCol, startRow), end: (endCol, endRow))]
                        }
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
    }
    
    func moveSelectedCell(colOffset: Int, rowOffset: Int, isShiftPressed: Bool) {
        if !viewModel.selectedRanges.isEmpty {
            if !isShiftPressed {
                let movedStartCol = min(max(viewModel.selectedRanges.last!.start.0 + colOffset, 0), maxCol)
                let movedStartRow = min(max(viewModel.selectedRanges.last!.start.1 + rowOffset, 0), maxRow)
                viewModel.selectedRanges = [SelectedRange(start: (movedStartCol, movedStartRow), end: (movedStartCol, movedStartRow))]
                print(viewModel.selectedRanges)
                viewModel.exceededCol = max(viewModel.selectedRanges.last!.start.0 + colOffset - maxCol, 0)
                viewModel.exceededRow = max(viewModel.selectedRanges.last!.start.1 + rowOffset - maxRow, 0)
            } else {
                let startCol = Int(viewModel.selectedRanges.last!.start.0)
                let endCol = Int(viewModel.selectedRanges.last!.end.0) + colOffset
                let startRow = Int(viewModel.selectedRanges.last!.start.1)
                let endRow = Int(viewModel.selectedRanges.last!.end.1) + rowOffset
                viewModel.selectedRanges = [SelectedRange(start: (startCol, startRow), end: (endCol, endRow))]
            }
        }
    }
}

//struct LineAreaSampleView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineAreaSampleView()
//            .previewLayout(.fixed(width: 1000, height: 500))
//    }
//}
