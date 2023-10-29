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
                            viewStore.send(
                                .showLowerLayer
                            )
                        } label: {
                            Image(systemName: "arrow.forward")
                                .font(.custom("Pretendard-Medium", size: 12))
                        }
                        .disabled(viewStore.showingLayers.isEmpty)
                        .padding(.leading, 4)
                        
                        // MARK: - Layer Index
                        let numberOfShowingLayers = viewStore.showingLayers.count
                        
                        if viewStore.showingLayers.isEmpty {
                            LayerControlButton(componentWidth: viewStore.listColumnWidth[numberOfShowingLayers]![0]) {
                                Text("Add a layer")
                                    .font(.custom("Pretendard-Medium", size: 12))
                                    .foregroundStyle(.gray)
                            }
                        } else {
                            ForEach(viewStore.showingLayers.indices, id: \.self) { forIndex in
                                let layer = viewStore.showingLayers[forIndex]
                                let showingAtFirst = (numberOfShowingLayers == 3 && forIndex == 0)
                                
                                LayerControlButton(componentWidth: viewStore.listColumnWidth[numberOfShowingLayers]![forIndex]) {
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
                        }
                        
                        LayerControlButton(componentWidth: geometry.size.width - 336) {
                            let lastShowingLayer = viewStore.showingLayers.isEmpty ? -1 : viewStore.showingLayers.last!
                            let totalLayers = viewStore.map.count
                            let haveMoreLayer = lastShowingLayer < (totalLayers - 1)
                            
                            Text(haveMoreLayer ? "Layer \(lastShowingLayer + 1)" : "Add a layer")
                                .font(.custom("Pretendard-Medium", size: 12))
                                .foregroundStyle(haveMoreLayer ? .black : .gray)
                        }
                        
                        // MARK: - < 엎기
                        LayerControlButton(componentWidth: 28) {
                            viewStore.send(
                                .showUpperLayer
                            )
                        } label: {
                            Image(systemName: "arrow.backward")
                                .font(.custom("Pretendard-Medium", size: 12))
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
    var action: (() -> Void)?
    var label: () -> Label

    init(componentWidth: CGFloat, action: (() -> Void)? = nil, @ViewBuilder label: @escaping () -> Label) {
        self.componentWidth = componentWidth
        self.action = action
        self.label = label
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
                self.label()
            )
        }
        .buttonStyle(.plain)
        .frame(width: max(componentWidth, 0), height: 26)
    }
}
