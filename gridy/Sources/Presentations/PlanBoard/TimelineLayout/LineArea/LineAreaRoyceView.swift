//
//  LineAreaRoyceView.swift
//  gridy
//
//  Created by Jin Sang woo on 2023/10/05.
//


import SwiftUI

struct LineAreaRoyceView: View {
    @State private var gridItems: [[GridItemModel]] = Array(repeating: Array(repeating: GridItemModel(), count: 12), count: 2)
    @State private var selectedCells: [(row: Int, col: Int)] = []
    @State private var startCell: (row: Int, col: Int)?
    
    @State private var dragStart: CGPoint?
    @State private var dragEnd: CGPoint?
    
    @State private var dragStartTmp: CGPoint?
    @State private var dragEndTmp: CGPoint?
    
    @State private var isDrawing = false // Rectangle을 그릴지 여부를 나타내는 상태 변수
    @State private var startRect = CGRect.zero // 시작하는 CGRect
    @State private var endRect = CGRect.zero // 끝나는 CGRect
    
    @State private var startRow: Int = 0
    @State private var endRow: Int = 0
    @State private var startCol: Int = 0
    @State private var endCol: Int = 0
    
    
    var body: some View {
        //        ScrollView(.horizontal){
        ScrollView(.vertical){
            ZStack(alignment: .topLeading){
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(80), spacing: 0), count: 2), alignment: .top, spacing: 0) {
                    ForEach(0..<gridItems.count, id: \.self) { row in
                        ForEach(0..<gridItems[row].count, id: \.self) { col in
                            DraggableGridItemView(gridItem: $gridItems[row][col], selectedCell: $selectedCells, row: row, col: col, dragStart: $dragStart, dragEnd: $dragEnd, startRow: $startRow, endRow: $endRow, startCol: $startCol, endCol: $endCol)
                                .frame(width: 80, height: 30)
                                .border(Color.gray, width: 1)
                                .id("\(row)-\(col)")
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { gesture in
                        // 드래그 중에 끝점을 업데이트합니다.
                        dragEnd = gesture.location
                        if dragStart == nil {
                            // 드래그가 시작되면 시작 위치를 현재 위치로 설정합니다.
                            self.dragStart = gesture.startLocation
                        }
                        // 시작 CGRect와 끝 CGRect를 생성합니다.
                        var startRect = CGRect(origin:
                                                dragStart!, size: CGSize(width: 80, height: 30))
                        let endRect = CGRect(origin: dragEnd!, size: CGSize(width: 80, height: 30))
                        // 드래그 중인 영역을 선택합니다.
                        selectCellsInDragRange(startRect: startRect, endRect: endRect)
                        
                        isDrawing = false
                        
                        if let dragStart = dragStart, let dragEnd = dragEnd {
                            startRow = min(Int(dragStart.y / 30), Int(dragEnd.y / 30))
                            endRow = max(Int(dragStart.y / 30), Int(dragEnd.y / 30))
                            startCol = min(Int(dragStart.x / 80), Int(dragEnd.x / 80))
                            endCol = max(Int(dragStart.x / 80), Int(dragEnd.x / 80))
                            
                        }
                    }
                
                    .onEnded { _ in
                        // 드래그 종료 시 필요한 작업을 수행합니다.
                        
                        if let dragStart = dragStart, let dragEnd = dragEnd {
                            // 선택된 영역의 CGRect를 생성합니다.
                            self.startRect = CGRect(x: dragStart.x, y: dragStart.y, width: abs(dragEnd.x - dragStart.x), height: abs(dragEnd.y - dragStart.y))
                        }
                        isDrawing = true
                        
                        dragStartTmp = dragStart
                        dragEndTmp = dragEnd
                        
                        dragStart = nil
                        dragEnd = nil
                        
                        
                        
                    }
            )
            
            if let dragStartTmp = dragStartTmp, let dragEndTmp = dragEndTmp {
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .background(Color.blue.opacity(0.3))
                    .frame(width: startRect.width, height: startRect.height)
                    .offset(x: ((dragStartTmp.x) + (dragEndTmp.x))/2, y: ((dragStartTmp.y) + (dragEndTmp.y))/2) // dragStart를 기준으로 설정
                    .opacity(isDrawing ? 1.0 : 0.0)
            }
        }
    }
    //        }
    
    private func selectCellsInDragRange(startRect: CGRect, endRect: CGRect) {
        selectedCells.removeAll()
        
        for row in 0..<self.gridItems.count { // self를 사용하여 ContentView 내의 gridItems 변수를 참조합니다.
            for col in 0..<self.gridItems[row].count {
                let cellRect = CGRect(x: CGFloat(col) * 80, y: CGFloat(row) * 30, width: 80, height: 30)
                if cellRect.intersects(startRect) || cellRect.intersects(endRect) {
                    selectedCells.append((row, col))
                }
            }
        }
    }
}

struct DraggableGridItemView: View {
    @Binding var gridItem: GridItemModel
    @Binding var selectedCell: [(row: Int, col: Int)]
    let row: Int
    let col: Int
    @Binding var dragStart: CGPoint?
    @Binding var dragEnd: CGPoint?
    
//    @State private var colorBlue: Bool = false // @State로 선언
    @Binding var startRow: Int
    @Binding var endRow: Int
    @Binding var startCol: Int
    @Binding var endCol: Int
    
    var colorBlue: Bool {
            return (startCol <= col) && (endCol >= col) && (startRow <= row) && (endRow >= row)
        }
    
    var body: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 80, height: 30)
            .border(Color.gray, width: 1)
        
        
            .overlay(
                Text(gridItem.text)
                    .padding(5)
                    .font(.system(size: 16))
            )
            .overlay(
                Color.red.opacity(0.1)
                    .opacity(colorBlue ? 1.0 : 0)
            )

    }
}

struct GridItemModel: Identifiable {
    var id = UUID()
    var text: String = ""
}


