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
            VStack {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(viewStore.showingLayers, id: \.self) { layerIndex in
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(0..<viewStore.sampleMap[layerIndex].count) { rowIndex in
                                ListItemView(store: store, layerIndex: layerIndex, rowIndex: rowIndex)
                            }
                            // TODO: - 삭제
                            Text("\(layerIndex)")
                                .frame(width: 266 / CGFloat(viewStore.showingLayers.count))
                            
                            HStack {
                                Button("< +") {
                                    // TODO: - 내 index에 layer 추가
                                    
                                }
                                Button("+ >") {
                                    // TODO: - 내 index + 1 에 layer 추가
                                    
                                }
                            }
                            .frame(width: 266 / CGFloat(viewStore.showingLayers.count))
                        }
                        .border(.red)
                        .frame(width: 266 / CGFloat(viewStore.showingLayers.count))
                    }
                }
                HStack {
                    Button("<< 엎기") {
                        viewStore.send(
                            .showLowerLayer
                        )
                    }
                    .disabled(viewStore.showingLayers[0] == 0)
                    Button("엎기 >>") {
                        viewStore.send(
                            .showUpperLayer
                        )
                    }
                    .disabled(viewStore.showingLayers.last == viewStore.sampleMap.count - 1)
                }
                .frame(width: 266)
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
