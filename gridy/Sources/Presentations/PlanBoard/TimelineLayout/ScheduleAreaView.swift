//  ScheduleAreaView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/14/23.
//

import SwiftUI
import ComposableArchitecture

struct DrawnLine: Identifiable, Equatable {
    let id = UUID()
    var startRow: Int
    var startCol: Int
    var endRow: Int
    var endCol: Int
}

struct ScheduleAreaView: View {
    @State private var scheduleTemporarySelectedGridRange: SelectedGridRange?
    @State private var completedLines: [DrawnLine] = []
    @State private var drawingLine: DrawnLine?
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    Color.white
                    
                    Path { path in
                        for rowIndex in 0..<viewStore.numOfScheduleAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.scheduleAreaGridHeight - viewStore.rowStroke
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                        for columnIndex in 0..<viewStore.maxCol {
                            let xLocation = CGFloat(columnIndex) * viewStore.gridWidth - viewStore.columnStroke
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.columnStroke)
                    
                    if let selectedRange = scheduleTemporarySelectedGridRange {
                        let startY = CGFloat(selectedRange.start.row) * viewStore.scheduleAreaGridHeight
                        let endY = CGFloat(selectedRange.end.row + 1) * viewStore.scheduleAreaGridHeight
                        let startX = CGFloat(selectedRange.start.col) * viewStore.gridWidth
                        let endX = CGFloat(selectedRange.end.col + 1) * viewStore.gridWidth
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: endX - startX, height: endY - startY)
                            .position(x: (startX + endX) / 2, y: (startY + endY) / 2)
                    }
                    
                    ForEach(completedLines) { line in
                        let startY = CGFloat(line.startRow + 1) * viewStore.scheduleAreaGridHeight
                        let startX = CGFloat(line.startCol) * viewStore.gridWidth - CGFloat(viewStore.shiftedCol) * viewStore.gridWidth
                        let endX = CGFloat(line.endCol + 1) * viewStore.gridWidth - CGFloat(viewStore.shiftedCol) * viewStore.gridWidth
                        
                        Path { path in
                            path.move(to: CGPoint(x: startX, y: startY))
                            path.addLine(to: CGPoint(x: endX, y: startY))
                        }
                        .stroke(Color.black, lineWidth: 2)
                        
                        let diamondSize: CGFloat = 10
                        let diamondStart = CGPoint(x: startX, y: startY)
                        let diamondEnd = CGPoint(x: endX, y: startY)
                        
                        Path { path in
                            path.move(to: CGPoint(x: diamondStart.x, y: diamondStart.y - diamondSize / 2))
                            path.addLine(to: CGPoint(x: diamondStart.x + diamondSize / 2, y: diamondStart.y))
                            path.addLine(to: CGPoint(x: diamondStart.x, y: diamondStart.y + diamondSize / 2))
                            path.addLine(to: CGPoint(x: diamondStart.x - diamondSize / 2, y: diamondStart.y))
                            path.closeSubpath()
                            
                            path.move(to: CGPoint(x: diamondEnd.x, y: diamondEnd.y - diamondSize / 2))
                            path.addLine(to: CGPoint(x: diamondEnd.x + diamondSize / 2, y: diamondEnd.y))
                            path.addLine(to: CGPoint(x: diamondEnd.x, y: diamondEnd.y + diamondSize / 2))
                            path.addLine(to: CGPoint(x: diamondEnd.x - diamondSize / 2, y: diamondEnd.y))
                            path.closeSubpath()
                        }
                        .fill(Color.purple)
                    }
                    Button(action: {
                        guard let tempRange = scheduleTemporarySelectedGridRange else { return }
                        let startRow = tempRange.start.row
                        let startCol = tempRange.start.col + viewStore.shiftedCol
                        let endCol = tempRange.end.col + viewStore.shiftedCol
                        let newLine = DrawnLine(startRow: startRow, startCol: startCol, endRow: startRow, endCol: endCol)
                        self.completedLines.append(newLine)
                        viewStore.send(.addCompletedLine(newLine))
                        scheduleTemporarySelectedGridRange = nil
                        self.drawingLine = nil
                    }) {
                        EmptyView()
                    }
                    .keyboardShortcut(.defaultAction)
                    .hidden()
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            scheduleTemporarySelectedGridRange = nil
                            let dragStart = gesture.startLocation
                            let dragEnd = gesture.location
                            let startCol = Int(dragStart.x / viewStore.gridWidth)
                            let endCol = Int(dragEnd.x / viewStore.gridWidth)
                            let startRow = Int(dragStart.y / viewStore.scheduleAreaGridHeight)
                            let endRow = Int(dragEnd.y / viewStore.scheduleAreaGridHeight)
                            scheduleTemporarySelectedGridRange = SelectedGridRange(
                                start: (startRow, startCol),
                                end: (endRow, endCol)
                            )
                            self.drawingLine = DrawnLine(startRow: startRow, startCol: startCol, endRow: startRow, endCol: endCol)
                        }
                        .onEnded { gesture in
                            let dragStart = gesture.startLocation
                            let dragEnd = gesture.location
                            let startRow = Int(dragStart.y / viewStore.scheduleAreaGridHeight)
                            let startCol = Int(dragStart.x / viewStore.gridWidth) + viewStore.shiftedCol
                            let endCol = Int(dragEnd.x / viewStore.gridWidth) + viewStore.shiftedCol
                            self.drawingLine = nil
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            viewStore.send(.magnificationChangedInScheduleArea(value))
                        }
                )
            }
        }
    }
}
