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
                            let currentColsWidthArray = viewStore.listColumnWidth[numOfShowingLayers-1]
                            
                            var xLocation = CGFloat.zero
                            
                            for forIndex in 0..<numOfShowingLayers {
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
                        let currentColsWidthArray = viewStore.listColumnWidth[numOfShowingLayers-1]
                        /// 2n - 1: 2 col 보여줄 땐 줄 3개, 3col 보여줄 땐 줄 5개
                        let numOfStrokes = 2 * numOfShowingLayers - 1
                        
                        var xLocation = CGFloat.zero
                        
                        for forIndex in 0..<numOfStrokes {
                            /// index가 짝수 일 때는 배열 안의 값을 더해주고 홀수일 때는 2를 더해줘서 스페이싱을 준다.
                            xLocation += (forIndex%2 == 0 ? currentColsWidthArray[(forIndex / 2)] : CGFloat(2 * (forIndex % 2)))
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.columnStroke)
                    
                    // MARK: - ListArea Contents
                    VStack(spacing: 0) {
                        // MARK: - LayerIndex Section
                        // TODO: - 이 액션 LayerIndex Area 나오면 옮기기. 지금은 temp.
                        HStack {
                            Button {
                                viewStore.send(
                                    .showLowerLayer
                                )
                            } label: {
                                Text(">> 엎기")
                            }
                            .disabled(viewStore.showingLayers[0] == 0 && viewStore.showingLayers.count == 1)
                            
                            Spacer()
                            
                            Button {
                                viewStore.send(
                                    .showUpperLayer
                                )
                            } label: {
                                Text("엎기 <<")
                            }
                            .disabled(viewStore.showingLayers.last == viewStore.map.count - 1)
                        }
                        .frame(height: viewStore.lineAreaGridHeight / 2)
                        
                        // MARK: - ListItem Section
                        HStack(alignment: .top, spacing: 2) {
                            ForEach(Array(zip(viewStore.showingLayers.indices, viewStore.showingLayers)), id: \.0) { forIndex, layerIndex in
                                VStack(alignment: .leading, spacing: 0) {
                                    let layer = viewStore.showingLayers[forIndex]
                                    let showingAtFirst = (viewStore.showingLayers.count == 3 && forIndex == 0)
                                    
                                    // MARK: - LayerIndex Section
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundStyle(Color.clear)
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray, lineWidth: 0.3)
                                            .overlay(
                                                Text(showingAtFirst ? "L\(layerIndex)": "Layer\(layerIndex)")
                                            )
                                            .font(.custom("Pretendard-Regular", size: 11))
                                    }
                                    .frame(width: viewStore.listColumnWidth[viewStore.showingLayers.count-1][forIndex], height: viewStore.lineAreaGridHeight / 2)
                                    .contextMenu {
                                        Button {
                                            viewStore.send(
                                                .createLayer(layerIndex: layerIndex - 1)
                                            )
                                        } label: {
                                            Text("왼쪽에 layer 삽입")
                                        }
                                        Button {
                                            viewStore.send(
                                                .createLayer(layerIndex: layerIndex)
                                            )
                                        } label: {
                                            Text("오른쪽에 layer 삽입")
                                        }
                                    }
                                    
                                    // MARK: - ListItemSection
                                    if viewStore.map.count > 0 {
                                        ForEach(0..<viewStore.map[String(layer)]!.count) { rowIndex in
                                            ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex)
                                        }
                                    }
                                    
                                    // TODO: - 16 -> maxLineAreaRow로 변경. 현재는 0으로 초기화 되어있고 값이 바뀔 때마다 할당이되어서 처음에 항상 0개.
                                    // TODO: - map에 들어있는 것들 count를 빼는게 아니라 map에 들어있는 plan이 들고있는 lane 개수로 변경
                                    ForEach(0..<(16 - viewStore.map[String(layer)]!.count)) { rowIndex in
                                        ListItemEmptyView(store: store)
                                    }
                                }
                                .frame(width: viewStore.listColumnWidth[viewStore.showingLayers.count-1][forIndex])
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
