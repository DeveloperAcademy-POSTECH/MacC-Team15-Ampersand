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
                ZStack {
                    VStack {
                        HStack(alignment: .top, spacing: 2) {
                            ForEach(Array(zip(viewStore.showingLayers.indices, viewStore.showingLayers)), id: \.0) { forIndex, layerIndex in
                                VStack(alignment: .leading, spacing: 0) {
                                    // TODO: - map에 아무것도 없을 때 index 처리 해야 함
                                    //                            if viewStore.map[String(layerIndex)]!.count > 0 {
                                    //                                ForEach(0..<viewStore.map[String(layerIndex)]!.count) { rowIndex in
                                    //                                    ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex)
                                    //                                }
                                    //                            }
                                    
                                    //                            ForEach(0..<viewStore.maxLineAreaRow - viewStore.map[String(layerIndex)]!.count) { rowIndex in
                                    //                                ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex + viewStore.map[String(layerIndex)]!.count)
                                    //                            }
                                    
                                    HStack {
                                        Button {
                                            viewStore.send(
                                                .createLayer(layerIndex: layerIndex - 1)
                                            )
                                            print("=== layer added btw \(layerIndex - 1) and \(layerIndex)")
                                            print(viewStore.map)
                                        } label: {
                                            Text("+")
                                                .foregroundStyle(.black)
                                        }
                                        
                                        // TODO: - 삭제
                                        Text("\(layerIndex)")
                                        
                                        Button {
                                            viewStore.send(
                                                .createLayer(layerIndex: layerIndex)
                                            )
                                            print("=== layer added btw \(layerIndex) and \(layerIndex + 1)")
                                            print(viewStore.map)
                                            print(viewStore.rootProject.map)
                                        }label: {
                                            Text("+")
                                                .foregroundStyle(.black)
                                        }
                                    }
                                    .font(.caption)
                                    .frame(width: viewStore.listColumnWidth[viewStore.showingLayers.count-1][forIndex])
                                }
                                .frame(width: viewStore.listColumnWidth[viewStore.showingLayers.count-1][forIndex])
                            }
                        }
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
                    }
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
                        let xLocation = geometry.size.width - viewStore.columnStroke
                        path.move(to: CGPoint(x: xLocation, y: 0))
                        path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                    }
                    .stroke(Color.gray, lineWidth: viewStore.columnStroke)
                }
            }
        }
    }
}

#Preview {
    ListAreaView2(store: Store(initialState: PlanBoard.State(rootProject: Project.mock), reducer: { PlanBoard() }))
}
