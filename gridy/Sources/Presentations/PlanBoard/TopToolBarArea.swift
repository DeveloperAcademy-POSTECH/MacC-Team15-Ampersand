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
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .center, spacing: 0) {
                Text(viewStore.rootProject.title)
                    .font(.title)
                Spacer()
                planBoardBorder(.vertical)
                shareImageButton
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
    var shareImageButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isShareImagePresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isShareImagePresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .shareImageButton,
                            bool: newValue
                        ))
                    }
                )
            }
            Rectangle()
                .foregroundStyle(
                    viewStore.hoveredItem == .shareImageButton ||
                    viewStore.isShareImagePresented ?
                    Color.topToolItem : .clear
                )
                .overlay(
                    Image(systemName: "photo.fill")
                        .foregroundStyle(.black)
                )
                .frame(width: 48)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .shareImageButton : ""))
                }
                .onTapGesture {
                    viewStore.send(.popoverPresent(
                        button: .shareImageButton,
                        bool: true
                    ))
                }
                .sheet(isPresented: isShareImagePresented) {
                    ShareImageView()
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
