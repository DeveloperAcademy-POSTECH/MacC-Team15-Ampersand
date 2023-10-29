//
//  LayerControlAreaView.swift
//  gridy
//
//  Created by SY AN on 10/28/23.
//

import SwiftUI
import ComposableArchitecture

struct LayerControlAreaView: View {
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                VStack {
                    Spacer()
                        .frame(height: 3)
                    HStack(spacing: 2) {
                        // MARK: - 엎기 >
                        LayerControlButton(componentWidth: 28) {
                            Image(systemName: "arrow.forward")
                                .font(.custom("Pretendard-Medium", size: 12))
                        } action: {
                            viewStore.send(
                                .showLowerLayer
                            )
                        }
                        .disabled(viewStore.showingLayers[0] == 0 && viewStore.showingLayers.count == 1)
                        .padding(.leading, 4)
                        
                        // MARK: - Layer Index
                        ForEach(viewStore.showingLayers.indices, id: \.self) { forIndex in
                            let layer = viewStore.showingLayers[forIndex]
                            let showingAtFirst = (viewStore.showingLayers.count == 3 && forIndex == 0)
                            
                            LayerControlButton(componentWidth: viewStore.listColumnWidth[viewStore.showingLayers.count-1][forIndex]) {
                                Text(showingAtFirst ? "L\(layer)": "Layer\(layer)")
                                    .font(.custom("Pretendard-Medium", size: 12))
                            }
                            .contextMenu {
                                Button {
                                    viewStore.send(
                                        .createLayer(layerIndex: layer - 1)
                                    )
                                } label: {
                                    Text("Add a lower layer")
                                }
                                Button {
                                    viewStore.send(
                                        .createLayer(layerIndex: layer)
                                    )
                                } label: {
                                    Text("Add a upper layer")
                                }
                            }
                        }
                        
                        LayerControlButton(componentWidth: geometry.size.width - 336) {
                            let lastShowingLayer = viewStore.showingLayers.last!
                            let totalLayers = viewStore.map.count
                            let haveMoreLayer = lastShowingLayer < (totalLayers - 1)
        
                            Text(haveMoreLayer ? "Layer \(lastShowingLayer + 1)" : "Add a layer")
                                .font(.custom("Pretendard-Medium", size: 12))
                                .foregroundStyle(haveMoreLayer ? .black : .gray)
                        }
                        
                        // MARK: - < 엎기
                        LayerControlButton(componentWidth: 28) {
                            Image(systemName: "arrow.backward")
                                .font(.custom("Pretendard-Medium", size: 12))
                        } action: {
                            viewStore.send(
                                .showUpperLayer
                            )
                        }
                        .disabled(viewStore.showingLayers.last == viewStore.map.count - 1)
                        .padding(.trailing, 4)
                    }
                }
            }
        }
    }
}

#Preview {
    LayerControlAreaView(store: Store(initialState: PlanBoard.State(rootProject: Project.mock, map: Project.mock.map)) {
        PlanBoard()
    })
}

struct LayerControlButton<Label: View>: View {
    var componentWidth: CGFloat
        var content: () -> Label
        var action: (() -> Void)?

    init(componentWidth: CGFloat, @ViewBuilder content: @escaping () -> Label, action: (() -> Void)? = nil) {
        self.componentWidth = componentWidth
        self.content = content
        self.action = action
    }

    var body: some View {
        Button(action: {
            self.action?()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.white)
                
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.gray, lineWidth: 0.5)
            }
            .overlay(
                self.content()
            )
        }
        .buttonStyle(.plain)
        .frame(width: max(componentWidth, 0), height: 26)
    }
}
