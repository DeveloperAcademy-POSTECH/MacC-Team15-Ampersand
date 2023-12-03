//
//  TopToolBarView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//

import SwiftUI
import ComposableArchitecture

struct TopToolBarView: View {
    let store: StoreOf<PlanBoard>
    let selfView: PlanBoardView
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            boardSettingButton
            Spacer()
            exportImageButton
            Spacer().frame(width: 8)
            rightToolBarButton
        }
        .padding(.horizontal, 8)
    }
}

extension TopToolBarView {
    var exportImageButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isExportPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isExportPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .exportButton,
                            bool: newValue
                        ))
                    }
                )
            }
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(hex: 0x585858))
                .overlay(
                    Text("Export")
                        .font(.system(size: 12))
                )
                .frame(width: 61, height: 32)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .exportButton : ""))
                }
                .onTapGesture {
                    viewStore.send(.popoverPresent(
                        button: .exportButton,
                        bool: true
                    ))
                }
                .sheet(isPresented: isExportPresented) {
                    ExportView(store: store, selfView: selfView)
                }
        }
    }
}

extension TopToolBarView {
    var boardSettingButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isBoardSettingPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isBoardSettingPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .boardSettingButton,
                            bool: newValue
                        ))
                    }
                )
            }
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(hex: 0x585858))
                .overlay(
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(Color(hex: 0x8E8E8E))
                )
                .frame(width: 32, height: 32)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .boardSettingButton : ""))
                }
                .onTapGesture {
                    viewStore.send(.popoverPresent(
                        button: .boardSettingButton,
                        bool: true
                    ))
                }
                .sheet(isPresented: isBoardSettingPresented) {
                    BoardSettingView(store: store)
                }
        }
    }
}

extension TopToolBarView {
    var rightToolBarButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(hex: 0x585858))
                .overlay(
                    Image(systemName: "sidebar.squares.right")
                        .foregroundStyle(Color(hex: 0x8E8E8E))
                )
                .frame(width: 32, height: 32)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .rightToolBarButton : ""))
                }
                .onTapGesture {
                    viewStore.send(.popoverPresent(
                        button: .rightToolBarButton,
                        bool: !viewStore.isRightToolBarPresented
                    ))
                }
        }
    }
}
