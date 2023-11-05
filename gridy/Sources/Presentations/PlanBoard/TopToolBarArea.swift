//
//  TopToolBarView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//

import SwiftUI

struct TopToolBarView: View {
    @EnvironmentObject var viewModel: PlanBoardViewModel
    @Binding var isNotificationPresented: Bool
    @Binding var isShareImagePresented: Bool
    @Binding var isBoardSettingPresented: Bool
    @Binding var isRightToolBarPresented: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            planBoardBorder(.vertical)
            shareImageButton
            planBoardBorder(.vertical)
            boardSettingButton
            planBoardBorder(.vertical)
            rightToolBarButton
        }
        .background(Color.topToolBar)
        .sheet(isPresented: $isBoardSettingPresented) {
            ShareImageView()
        }
        .sheet(isPresented: $isBoardSettingPresented) {
            BoardSettingView()
        }
    }
}

extension TopToolBarView {
    var shareImageButton: some View {
        Rectangle()
            .foregroundStyle(
                viewModel.hoveredItem == .shareImageButton || isShareImagePresented ? Color.topToolItem : .clear
            )
            .overlay(
                Image(systemName: "photo.fill")
                    .foregroundStyle(.black)
            )
            .frame(width: 48)
            .onHover { proxy in
                viewModel.hoveredItem = proxy ? .shareImageButton : ""
            }
            .onTapGesture {
                isBoardSettingPresented.toggle()
            }
    }
}

extension TopToolBarView {
    var boardSettingButton: some View {
        Rectangle()
            .foregroundStyle(
                viewModel.hoveredItem == .boardSettingButton || isBoardSettingPresented ? Color.topToolItem : .clear
            )
            .overlay(
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.black)
            )
            .frame(width: 48)
            .onHover { proxy in
                viewModel.hoveredItem = proxy ? .boardSettingButton : ""
            }
            .onTapGesture {
                isBoardSettingPresented.toggle()
            }
    }
}

extension TopToolBarView {
    var rightToolBarButton: some View {
        Rectangle()
            .foregroundStyle(
                viewModel.hoveredItem == .rightToolBarButton ? Color.topToolItem : .clear
            )
            .overlay(
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .foregroundStyle(.black)
            )
            .frame(width: 48)
            .onHover { proxy in
                viewModel.hoveredItem = proxy ? .rightToolBarButton : ""
            }
            .onTapGesture {
                isRightToolBarPresented.toggle()
            }
        
    }
}
