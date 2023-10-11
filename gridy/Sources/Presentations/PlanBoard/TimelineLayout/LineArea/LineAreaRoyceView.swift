//
//  LineAreaRoyceView.swift
//  gridy
//
//  Created by Jin Sang woo on 2023/10/05.
//


import SwiftUI




struct ContentView: View {
    @State private var gridItems: [[GridItemModel]] = Array(repeating: Array(repeating: GridItemModel(), count: 30), count: 30)
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
    
    
    @State private var copiedCells: [[GridItemModel]] = []
    
    @State private var undoStack: [GridState] = []
    
    
    
    var body: some View {
        ScrollView(.horizontal){
            ScrollView(.vertical){
                ZStack(alignment: .topLeading){
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(80), spacing: 0), count: 30), alignment: .leading, spacing: 0) {
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
                
                
            }
        }
        
        
        HStack {
            Button(action: {copySelectedCells()}) {
                Text("C")
            }
            .keyboardShortcut("c")
            
            Button(action: {pasteCopiedCells()}) {
                Text("V")
            }
            .keyboardShortcut("v")
            
            Button(action: {  handleRKeyPressed()  }) {
                Text("Press 'r' key to change color")
            }
            .keyboardShortcut("r")
            
            Button(action: undo) {
                Text("Undo (Cmd+Z)")
            }
            .keyboardShortcut("z", modifiers: .command)
        }
        
        
        
    }
    
    
    func copySelectedCells() {
        // 복사할 셀의 데이터를 복사
        copiedCells.removeAll() // 기존 복사 데이터를 비웁니다.
        
        for i in startRow...endRow {
            var copiedRow: [GridItemModel] = []
            for j in startCol...endCol {
                if i < gridItems.count && j < gridItems[i].count {
                    copiedRow.append(gridItems[i][j])
                }
            }
            copiedCells.append(copiedRow)
        }
        
        undoStack.append(GridState(gridItems: gridItems))

    }
    
    func pasteCopiedCells() {
        guard !copiedCells.isEmpty else { return }
        
        var pasteRow = startRow
        for i in 0..<copiedCells.count {
            var pasteCol = startCol
            for j in 0..<copiedCells[i].count {
                if pasteRow < gridItems.count && pasteCol < gridItems[pasteRow].count {
                    gridItems[pasteRow][pasteCol] = copiedCells[i][j]
                }
                pasteCol += 1
            }
            pasteRow += 1
        }
        
        undoStack.append(GridState(gridItems: gridItems))

    }
    
    func handleRKeyPressed() {
        for row in startRow...endRow {
            for col in startCol...endCol {
                gridItems[row][col].isSelected = true

            }
        }
        
        undoStack.append(GridState(gridItems: gridItems))

    }
    
    func undo() {
        guard let previousState = undoStack.popLast() else {
            return
        }
        
        gridItems = previousState.gridItems
        
        for row in 0..<gridItems.count {
                for col in 0..<gridItems[row].count {
                    if previousState.gridItems[row][col].isSelected != gridItems[row][col].isSelected {
                        // 이전 상태와 현재 상태가 다르면 선택 상태를 복원합니다.
                        gridItems[row][col].isSelected = previousState.gridItems[row][col].isSelected
                    }
                }
            }
    }
    
    
    
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
            .fill(gridItem.isSelected ? Color.cyan.opacity(0.3) : Color.white) // 선택된 경우 배경색을 시안색으로, 아닌 경우 흰색으로 변경
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
    var isSelected = false // isSelected 속성 추가
    
}

struct GridState {
    var gridItems: [[GridItemModel]]
}

