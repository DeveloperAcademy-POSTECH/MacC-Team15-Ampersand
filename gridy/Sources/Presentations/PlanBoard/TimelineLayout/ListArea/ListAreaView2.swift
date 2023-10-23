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
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack(alignment: .top, spacing: 2) {
                    ForEach(viewStore.showingLayers, id: \.self) { layerIndex in
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(0..<viewStore.map[String(layerIndex)]!.count) { rowIndex in
                                ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex)
                            }
                            HStack {
                                Button {
                                    viewStore.send(
                                        .createLayer(layerIndex: layerIndex - 1)
                                    )
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
                                }label: {
                                    Text("+")
                                        .foregroundStyle(.black)
                                }
                            }
                            .font(.caption)
                            .frame(width: viewModel.listColumnWidth[viewStore.showingLayers.count-1][layerIndex])
                        }
                        .frame(width: viewModel.listColumnWidth[viewStore.showingLayers.count-1][layerIndex])
                        .onAppear {
                            print("layer : \(layerIndex)")
                            print("layercount: \(viewModel.listColumnWidth[viewStore.showingLayers.count-1])")
                            print(viewModel.listColumnWidth[viewStore.showingLayers.count-1][0])
                        }
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
         }
    }
}

#Preview {
    ListAreaView2(
        store: Store(initialState: PlanBoard.State(rootProject: Project.mock)) {
            PlanBoard()
        }
    )
}
