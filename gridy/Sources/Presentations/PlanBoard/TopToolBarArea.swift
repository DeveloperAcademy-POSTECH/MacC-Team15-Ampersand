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
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .center, spacing: 0) {
                Text(viewStore.rootProject.title)
                    .font(.title)
                Spacer()
                planBoardBorder(.vertical)
                exportImageButton
                planBoardBorder(.vertical)
                boardSettingButton
                planBoardBorder(.vertical)
                rightToolBarButton
            }
            .background(Color.topToolBar)
        }
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
            Rectangle()
                .foregroundStyle(
                    viewStore.hoveredItem == .exportButton ||
                    viewStore.isExportPresented ?
                    Color.topToolItem : .clear
                )
                .overlay(
                    Image(systemName: "photo.fill")
                        .foregroundStyle(.black)
                )
                .frame(width: 48)
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
            Rectangle()
                .foregroundStyle(
                    viewStore.hoveredItem == .boardSettingButton ||
                    viewStore.isBoardSettingPresented ?
                    Color.topToolItem : .clear
                )
                .overlay(
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(.black)
                )
                .frame(width: 48)
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
            Rectangle()
                .foregroundStyle(
                    viewStore.hoveredItem == .rightToolBarButton ?
                    Color.topToolItem : .clear
                )
                .overlay(
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                        .foregroundStyle(.black)
                )
                .frame(width: 48)
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
