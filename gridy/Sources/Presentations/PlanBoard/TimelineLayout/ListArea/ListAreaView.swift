//
//  ListAreaView.swift
//  gridy
//
//  Created by SY AN on 10/20/23.
//

import SwiftUI
import ComposableArchitecture

struct ListAreaView: View {
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    // MARK: - Grid Background
                    Color.white
                    
                    Path { path in
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight - viewStore.rowStroke
                            /// 현재 보여주고 있는 layer 수
                            let numOfShowingLayers = viewStore.showingLayers.count
                            /// 현재 보여주고 있는 layer 수에 따른 col의 너비 값을 저장한 배열.
                            let currentColsWidthArray = viewStore.listColumnWidth[numOfShowingLayers]!
                            
                            var xLocation = CGFloat.zero
                            
                            for forIndex in 0..<currentColsWidthArray.count {
                                xLocation += (forIndex == 0 ? 0 : currentColsWidthArray[forIndex-1] + 2)
                                path.move(to: CGPoint(x: xLocation, y: yLocation))
                                path.addLine(to: CGPoint(x: xLocation + currentColsWidthArray[forIndex], y: yLocation))
                            }
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.rowStroke)
                    
                    Path { path in
                        /// 현재 보여주고 있는 layer 수
                        let numOfShowingLayers = viewStore.showingLayers.count
                        /// 현재 보여주고 있는 layer 수에 따른 col의 너비 값을 저장한 배열.
                        let currentColsWidthArray = viewStore.listColumnWidth[numOfShowingLayers]!
                        /// 2n - 1: 2 col 보여줄 땐 줄 3개, 3col 보여줄 땐 줄 5개
                        let numOfStrokes = numOfShowingLayers == 0 ? 1 : 2 * numOfShowingLayers - 1
                        
                        var xLocation = CGFloat.zero
                        
                        for forIndex in 0..<numOfStrokes {
                            /// index가 짝수 일 때는 배열 안의 값을 더해주고 홀수일 때는 2를 더해줘서 스페이싱을 준다.
                            xLocation += (forIndex%2 == 0 ? currentColsWidthArray[(forIndex / 2)] : CGFloat(2 * (forIndex % 2)))
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.columnStroke)
                    
                    if viewStore.showingLayers.isEmpty {
                        Rectangle()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .overlay(
                            Text("All spreaded")
                            )
                    } else {
                        // MARK: - ListArea Contents
                        HStack(alignment: .top, spacing: 2) {
                            ForEach(Array(viewStore.showingLayers.indices), id: \.self) { forIndex in
                                let layer = viewStore.showingLayers[forIndex]
                                let layerArray = viewStore.map[String(layer)]!
                                var layerSize = layerArray.count
                                
                                var height = 0
                                var numOfChild = 0
                                /// 내 leaf의 lane 수를 찾아야 함
                                ForEach(0..<viewStore.showingLayers.count, id: \.self) { index in
                                    let layerIndex = layer + index
                                    Color.clear.onAppear { print(layerIndex) }
                                }
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    
                                    var showingAtFirst = (viewStore.showingLayers.count == 3 && forIndex == 0)
                                    
                                    /// 기존에 맵이 들고있는 layer들을 먼저 뿌려줌
                                    if viewStore.map.count > 0 {
                                        ForEach(Array(viewStore.map[String(layer)]!.indices), id: \.self) { row in
                                            ListItemView(store: store, layerIndex: layer, rowIndex: row)
                                        }
                                    }
                                    
                                    // TODO: map이 가진 lane수가 viewStore.showingRows보다 크면 showingRows를 lane개수 + showingRows로 업데이트
                                    // TODO: showingRows->maxRow 변화할 때마다 업데이트
                                    /// 그 아래에 빈 listItemView를 뿌려주어서 Plan 생성이 가능하도록 함
                                    ForEach(layerSize..<viewStore.showingRows, id: \.self) { row in
                                        ListItemEmptyView(store: store, layerIndex: layer, rowIndex: row)
                                    }
                                }
                                .frame(width: viewStore.listColumnWidth[viewStore.showingLayers.count]![forIndex])
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ListAreaView(store: Store(initialState: PlanBoard.State(rootProject: Project.mock, map: Project.mock.map), reducer: { PlanBoard() }))
}
