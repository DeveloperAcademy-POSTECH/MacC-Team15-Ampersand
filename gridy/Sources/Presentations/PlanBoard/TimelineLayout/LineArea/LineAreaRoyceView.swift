//import SwiftUI
//
//
//
//
//struct ContentView: View {
//    @State private var gridItems: [[GridItemModel]] = Array(repeating: Array(repeating: GridItemModel(), count: 30), count: 30)
//    @State private var selectedCells: [(row: Int, col: Int)] = []
//    @State private var startCell: (row: Int, col: Int)?
//    
//    @State private var cellWidth: CGFloat = 80
//    @State private var cellHeight: CGFloat = 30
//    
//    @State private var dragStart: CGPoint?
//    @State private var dragEnd: CGPoint?
//    
//    @State private var dragStartTmp: CGPoint?
//    @State private var dragEndTmp: CGPoint?
//    
//    @State private var isDrawing = false       // Rectangle을 그릴지 여부를 나타내는 상태 변수
//    @State private var startRect = CGRect.zero // 시작하는 CGRect
//    @State private var endRect = CGRect.zero   // 끝나는 CGRect
//    
//    @State private var startRow: Int = 0
//    @State private var endRow: Int = 0
//    @State private var startCol: Int = 0
//    @State private var endCol: Int = 0
//    
//    @State private var isDraggingRect: Bool = false
//    @State private var isMovingRect: Bool = true
//
//
//    
//    @State private var copiedCells: [[GridItemModel]] = []
//    
//    @State private var undoStack: [GridState] = []
//    
//    
//    
//    
//    var body: some View {
//        ScrollView(.horizontal){
//            ScrollView(.vertical){
//                ZStack(alignment: .topLeading){
//                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellWidth), spacing: 0), count: 30), alignment: .leading, spacing: 0) {
//                        ForEach(0..<gridItems.count, id: \.self) { row in
//                            ForEach(0..<gridItems[row].count, id: \.self) { col in
//                                DraggableGridItemView(gridItem: $gridItems[row][col], selectedCell: $selectedCells, row: row, col: col, dragStart: $dragStart, dragEnd: $dragEnd, startRow: $startRow, endRow: $endRow, startCol: $startCol, endCol: $endCol, cellWidth: $cellWidth, cellHeight: $cellHeight)
//                                    .frame(width: cellWidth, height: cellHeight)
//                                    .border(Color.gray, width: 1)
//                                    .id("\(row)-\(col)")
//                            }
//                        }
//                    }
//                    
//                    if isDrawing {
//                        // 초기 상태에서 고정된 rectWidth 및 rectHeight를 계산
//                        let initialRectWidth = cellWidth * CGFloat(abs(endCol - startCol + 1))
//                        let initialRectHeight = cellHeight * CGFloat(abs(endRow - startRow + 1))
//                        
//                        Rectangle()
////                            .fill(Color.black.opacity(0.00000001))
//                            .stroke(isMovingRect ? Color.cyan : Color.black, lineWidth: isMovingRect ? 10 : 0)
//
////                            .stroke(Color.cyan, lineWidth: 10)
//                            .frame(width: initialRectWidth, height: initialRectHeight)
//                            .position(
//                                x: cellWidth * CGFloat(startCol) + cellWidth * CGFloat(endCol - startCol + 1) / 2,
//                                y: cellHeight * CGFloat(startRow) + cellHeight * CGFloat(endRow - startRow + 1) / 2
//                            )
//                            .gesture(
//                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                                    .onChanged { gesture in
//                                        isDraggingRect.toggle()
//                                        // 드래그하는 동안 변경된 값을 기반으로 위치를 업데이트
//                                        let now_location = gesture.location
//                                        startCol = max(0, min(Int((now_location.x) / cellWidth), gridItems[0].count - 1))
//                                        startRow = max(0, min(Int(now_location.y / cellHeight), gridItems.count - 1))
//                                        endCol = min(gridItems[0].count - 1, startCol + Int(initialRectWidth / cellWidth) - 1)
//                                        endRow = min(gridItems.count - 1, startRow + Int(initialRectHeight / cellHeight) - 1)
//                                    }
//                            )
//                    }
//                    
//                }
//                
//                .gesture(
//                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                        .onChanged { gesture in
//                            // 드래그 중에 끝점을 업데이트합니다.
//                            dragEnd = gesture.location
//                            if dragStart == nil {
//                                // 드래그가 시작되면 시작 위치를 현재 위치로 설정합니다.
//                                self.dragStart = gesture.startLocation
//                            }
//                            // 시작 CGRect와 끝 CGRect를 생성합니다.
//                            var startRect = CGRect(origin:
//                                                    dragStart!, size: CGSize(width: cellWidth, height: cellHeight))
//                            let endRect = CGRect(origin: dragEnd!, size: CGSize(width: cellWidth, height: cellHeight))
//                            // 드래그 중인 영역을 선택합니다.
//                            selectCellsInDragRange(startRect: startRect, endRect: endRect)
//                            
//                            isDrawing = false
//                            
//                            if let dragStart = dragStart, let dragEnd = dragEnd {
//                                startRow = min(Int(dragStart.y / cellHeight), Int(dragEnd.y / cellHeight))
//                                endRow = max(Int(dragStart.y / cellHeight), Int(dragEnd.y / cellHeight))
//                                startCol = min(Int(dragStart.x / cellWidth), Int(dragEnd.x / cellWidth))
//                                endCol = max(Int(dragStart.x / cellWidth), Int(dragEnd.x / cellWidth))
//                                
//                            }
//                        }
//                    
//                        .onEnded { _ in
//                            // 드래그 종료 시 필요한 작업을 수행합니다.
//                            
//                            if let dragStart = dragStart, let dragEnd = dragEnd {
//                                // 선택된 영역의 CGRect를 생성합니다.
//                                self.startRect = CGRect(x: dragStart.x, y: dragStart.y, width: abs(dragEnd.x - dragStart.x), height: abs(dragEnd.y - dragStart.y))
//                            }
//                            isDrawing = true
//                            
//                            dragStartTmp = dragStart
//                            dragEndTmp = dragEnd
//                            
//                            dragStart = nil
//                            dragEnd = nil
//                            
//                            
//                            
//                        }
//                    
//                    
//                )
//                
//                
//            }
//        }
//        
//        
//        HStack {
//            Button(action: {copySelectedCells()}) {
//                Text("C")
//            }
//            .keyboardShortcut("c")
//            
//            Button(action: {pasteCopiedCells()}) {
//                Text("V")
//            }
//            .keyboardShortcut("v")
//            
//            Button(action: {  handleRKeyPressed()  }) {
//                Text("Press 'r' key to change color")
//            }
//            .keyboardShortcut("r")
//            
//            Button(action: undo) {
//                Text("Undo (Cmd+Z)")
//            }
//            .keyboardShortcut("z", modifiers: .command)
//            
//            Button(action: {moveSelectedCells(dx: 0, dy: -1)}) {
//                Text("UP")
//            }
//            .keyboardShortcut(KeyEquivalent.upArrow, modifiers: [])
//
//            Button(action: {moveSelectedCells(dx: 0, dy: 1)}) {
//                Text("DOWN")
//            }
//            .keyboardShortcut(KeyEquivalent.downArrow, modifiers: [])
//            
//            Button(action: {moveSelectedCells(dx: -1, dy: 0)}) {
//                Text("LEFT")
//            }
//            .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [])
//            
//            Button(action: {moveSelectedCells(dx: 1, dy: 0)}) {
//                Text("RIGHT")
//            }
//            .keyboardShortcut(KeyEquivalent.rightArrow, modifiers: [])
//
//        }
//        
//        
//        
//    }
//    
//    
//    func copySelectedCells() {
//        // 복사할 셀의 데이터를 복사
//        copiedCells.removeAll() // 기존 복사 데이터를 비웁니다.
//        
//        for i in startRow...endRow {
//            var copiedRow: [GridItemModel] = []
//            for j in startCol...endCol {
//                if i < gridItems.count && j < gridItems[i].count {
//                    copiedRow.append(gridItems[i][j])
//                }
//            }
//            copiedCells.append(copiedRow)
//        }
//        
//        undoStack.append(GridState(gridItems: gridItems))
//        
//    }
//    
//    func pasteCopiedCells() {
//        guard !copiedCells.isEmpty else { return }
//        
//        var pasteRow = startRow
//        for i in 0..<copiedCells.count {
//            var pasteCol = startCol
//            for j in 0..<copiedCells[i].count {
//                if pasteRow < gridItems.count && pasteCol < gridItems[pasteRow].count {
//                    gridItems[pasteRow][pasteCol] = copiedCells[i][j]
//                }
//                pasteCol += 1
//            }
//            pasteRow += 1
//        }
//        
//        undoStack.append(GridState(gridItems: gridItems))
//        
//    }
//    
//    func handleRKeyPressed() {
//        for row in startRow...endRow {
//            for col in startCol...endCol {
//                gridItems[row][col].isSelected = true
//                
//            }
//        }
//        
//        undoStack.append(GridState(gridItems: gridItems))
//        
//    }
//    
//    func undo() {
//        guard let previousState = undoStack.popLast() else {
//            return
//        }
//        
//        gridItems = previousState.gridItems
//        
//        for row in 0..<gridItems.count {
//            for col in 0..<gridItems[row].count {
//                if previousState.gridItems[row][col].isSelected != gridItems[row][col].isSelected {
//                    // 이전 상태와 현재 상태가 다르면 선택 상태를 복원합니다.
//                    gridItems[row][col].isSelected = previousState.gridItems[row][col].isSelected
//                }
//            }
//        }
//    }
//    func moveSelectedCells(dx: Int, dy: Int) {
//        if let firstSelectedCell = selectedCells.first {
//            let newRow = firstSelectedCell.row + dy
//            let newCol = firstSelectedCell.col + dx
//
//            if newRow >= 0, newRow < gridItems.count, newCol >= 0, newCol < gridItems[newRow].count {
//                // 이동하기 전의 셀을 선택 상태에서 해제하고 색을 원래대로 변경
//                for selectedCell in selectedCells {
//                    gridItems[selectedCell.row][selectedCell.col].isSelected = false
//                    gridItems[selectedCell.row][selectedCell.col].isMoved = true
//                }
//
//                isMovingRect = false
//
//                // 선택된 셀 목록 초기화
//                selectedCells.removeAll()
//
//                // 이동한 셀을 선택 상태로 설정
//                gridItems[newRow][newCol].isSelected = true
//                gridItems[newRow][newCol].isMoved = true
//
//                // 이동한 셀을 선택된 셀 목록에 추가
//                selectedCells.append((newRow, newCol))
//            }
//        }
//    }
//
//    
////    func moveSelectedCells(dx: Int, dy: Int) {
////        if let firstSelectedCell = selectedCells.first {
////            let newRow = firstSelectedCell.row + dy
////            let newCol = firstSelectedCell.col + dx
////
////            if newRow >= 0, newRow < gridItems.count, newCol >= 0, newCol < gridItems[newRow].count {
////                // 이동하기 전의 셀을 선택 상태에서 해제하고 색을 원래대로 변경
////                for selectedCell in selectedCells {
////                    gridItems[selectedCell.row][selectedCell.col].isSelected = false
////                    gridItems[selectedCell.row][selectedCell.col].isMoved = false
////                }
////
////                isMovingRect = false
////
////                // 선택된 셀 목록 초기화
////                selectedCells.removeAll()
////
////                // 이동한 셀을 선택 상태로 설정
////                gridItems[newRow][newCol].isSelected = true
////                gridItems[newRow][newCol].isMoved = true
////
////                // 이동한 셀을 선택된 셀 목록에 추가
////                selectedCells.append((newRow, newCol))
////            }
////        }
////    }
//
//    
//
//
//
//
//
//
//
//    
//    
//    
//    private func selectCellsInDragRange(startRect: CGRect, endRect: CGRect) {
//        selectedCells.removeAll()
//        
//        for row in 0..<self.gridItems.count { // self를 사용하여 ContentView 내의 gridItems 변수를 참조합니다.
//            for col in 0..<self.gridItems[row].count {
//                let cellRect = CGRect(x: CGFloat(col) * cellWidth, y: CGFloat(row) * cellHeight, width: cellWidth, height: cellHeight)
//                if cellRect.intersects(startRect) || cellRect.intersects(endRect) {
//                    selectedCells.append((row, col))
//                }
//            }
//        }
//    }
//}
//
//
//struct DraggableGridItemView: View {
//    @Binding var gridItem: GridItemModel
//    @Binding var selectedCell: [(row: Int, col: Int)]
//    let row: Int
//    let col: Int
//    @Binding var dragStart: CGPoint?
//    @Binding var dragEnd: CGPoint?
//    
//    @Binding var startRow: Int
//    @Binding var endRow: Int
//    @Binding var startCol: Int
//    @Binding var endCol: Int
//    
//    @Binding var cellWidth: CGFloat
//    @Binding var cellHeight: CGFloat
//    
//    var colorBlue: Bool {
//        return (startCol <= col) && (endCol >= col) && (startRow <= row) && (endRow >= row)
//    }
//    
//    
//    
//    var body: some View {
//        
//        Rectangle()
//            .fill(gridItem.isSelected ? Color.cyan.opacity(0.3) : Color.white) // 선택된 경우 배경색을 시안색으로, 아닌 경우 흰색으로 변경
//            .frame(width: cellWidth, height: cellHeight)
//            .border(Color.gray, width: 1)
//        
//        
//        
//            .overlay(
//                Text(gridItem.text)
//                    .padding(5)
//                    .font(.system(size: 16))
//            )
////            .overlay(
////                Color.red.opacity(0.1)
////                    .opacity(colorBlue ? 1.0 : 0)
////            )
//        
//            .overlay(
//                (colorBlue && !gridItem.isMoved) ? Color.red.opacity(0.1) : Color.clear
//            )
//        
//    }
//}
//
//struct GridItemModel: Identifiable {
//    var id = UUID()
//    var text: String = ""
//    var isSelected = false // isSelected 속성 추가
//    
//    var isMoved = false // 이동 상태 여부
//    
//}
//
//struct GridState {
//    var gridItems: [[GridItemModel]]
//}
//
//
