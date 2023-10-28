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
        WithViewStore (store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                VStack {
                    Spacer()
                        .frame(height: 3)
                    HStack(spacing: 4) {
                        LayerControlComponent(componentWidth: 28)
                            .overlay(
                                Image(systemName: "arrow.forward")
                                    .font(.custom("Pretendard-Medium", size: 12))
                            )
                            .onTapGesture {
                                // TODO: - 엎기
                            }
                            .padding(.leading, 4)
                        
                        // TODO: - width showingColumns에 따라 조절
                        LayerControlComponent(componentWidth: 264)
                            .overlay(
                                Text("Layer")
                                    .font(.custom("Pretendard-Medium", size: 12))
                            )
                            .contextMenu {
                                Button {
                                    
                                } label: {
                                    Text("Add a lower layer")
                                }
                                Button {
                                    
                                } label: {
                                    Text("Add a upper layer")
                                }
                            }
                        
                        // TODO: - width 조절
                        LayerControlComponent(componentWidth: geometry.size.width - 340)
                            .overlay(
                                Text("Layer")
                                    .font(.custom("Pretendard-Medium", size: 12))
                            )
                            .contextMenu {
                                Button {
                                    
                                } label: {
                                    Text("Add a lower layer")
                                }
                                Button {
                                    
                                } label: {
                                    Text("Add a upper layer")
                                }
                            }
                        
                        LayerControlComponent(componentWidth: 28)
                            .overlay(
                                Image(systemName: "arrow.backward")
                                    .font(.custom("Pretendard-Medium", size: 12))
                            )
                            .onTapGesture {
                                // TODO: - 엎기
                            }
                            .padding(.trailing, 4)
                    }
                }
            }
        }
    }
}

#Preview {
    LayerControlAreaView(store: Store(initialState: PlanBoard.State(rootProject: Project.mock), reducer: { PlanBoard() }))
}

struct LayerControlComponent: View {
    var componentWidth: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.white)
            
            RoundedRectangle(cornerRadius: 4)
                .stroke(.gray, lineWidth: 0.5)
        }
        .frame(width: max(componentWidth, 0), height: 26)
    }
}
