//
//  ListAreaView2.swift
//  gridy
//
//  Created by SY AN on 10/20/23.
//

import SwiftUI
import ComposableArchitecture

struct ListAreaView2: View {
    
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
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.rowStroke)
                    Path { path in
                        let numOfShowingLayers = viewStore.showingLayers.count
                        
                        for colIndex in 0..<numOfShowingLayers {
                            var xLocation = CGFloat.zero
                            
                            for internalIndex in 0..<viewStore.listColumnWidth[numOfShowingLayers-1].count {
                                xLocation += (viewStore.listColumnWidth[numOfShowingLayers-1][internalIndex] + CGFloat((2 * internalIndex)) - viewStore.columnStroke)
                                
                                path.move(to: CGPoint(x: xLocation, y: 0))
                                path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                            }
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
                        .background(.red)
                        .frame(height: viewStore.lineAreaGridHeight / 2)
                        
                        // MARK: - ListItem Section
                        HStack(alignment: .top, spacing: 2) {
                            ForEach(Array(zip(viewStore.showingLayers.indices, viewStore.showingLayers)), id: \.0) { forIndex, layerIndex in
                                VStack(alignment: .leading, spacing: 0) {
                                    let layer = viewStore.showingLayers[forIndex]
                                    
                                    // TODO: map이 자꾸 빈걸로 들어옴 ;;;; 그래서 map 언래핑 할 수 없음
//                                    if viewStore.map[String(layer)]!.count > 0 {
//                                        ForEach(0..<viewStore.map[String(layer)]!.count) { rowIndex in
//                                            ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex)
//                                        }
//                                    }
                                    
                                    // TODO: scroll이 가능하게 되면 기본으로 보여줄 row 개수만큼으로 변경
//                                    ForEach(0..<viewStore.maxLineAreaRow - viewStore.map[String(layer)]!.count) { rowIndex in
//                                        ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex + viewStore.map[String(layerIndex)]!.count)
//                                    }
                                    
//                                    ForEach(0..<viewStore.maxLineAreaRow) { rowIndex in
//                                        ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex)
//                                    }
                                    
                                    // TODO: - LayerIndex Area 나오면 옮기기. 지금은 temp.
                                    HStack {
                                        Button {
                                            viewStore.send(
                                                .createLayer(layerIndex: layerIndex - 1)
                                            )
                                        } label: {
                                            Text("+")
                                                .foregroundStyle(.black)
                                        }
                                        
                                        Text("\(layerIndex)")
                                        
                                        Button {
                                            viewStore.send(
                                                .createLayer(layerIndex: layerIndex)
                                            )
                                        } label: {
                                            Text("+")
                                                .foregroundStyle(.black)
                                        }
                                    }
                                    .font(.caption)
                                    .frame(width: viewStore.listColumnWidth[viewStore.showingLayers.count-1][forIndex])
                                    .onAppear{print(viewStore.maxLineAreaRow)}
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
    ListAreaView2(store: Store(initialState: PlanBoard.State(rootProject: Project.mock), reducer: { PlanBoard() }))
}
