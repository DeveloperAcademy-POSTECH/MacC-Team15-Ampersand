//
//  TopToolBarArea.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//

import SwiftUI

struct TopToolBarArea: View {
    
    @Binding var shareImageClicked: Bool
    @Binding var boardSettingClicked: Bool
    @Binding var rightToolBarClicked: Bool
    @State var shareImageHover = false
    @State var boardSettingHover = false
    @State var rightToolBarHover = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            borderSpacer(.vertical)
            imageButton
            borderSpacer(.vertical)
            rightToolBarButton
            borderSpacer(.vertical)
            boardSettingButton
        }
    }
}

extension TopToolBarArea {
    var imageButton: some View {
        Rectangle()
            .foregroundStyle(shareImageClicked ? .white : shareImageHover ? .gray : .clear)
            .overlay(
                Image(systemName: "photo.fill")
                    .foregroundStyle(.black)
            )
            .frame(width: 48)
            .onHover { proxy in
                shareImageHover = proxy
            }
            .onTapGesture {
                shareImageClicked = true
            }
    }
}

extension TopToolBarArea {
    var rightToolBarButton: some View {
        Rectangle()
            .foregroundStyle(boardSettingClicked ? .white : boardSettingHover ? .gray : .clear)
            .overlay(
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .foregroundStyle(.black)
            )
            .frame(width: 48)
            .onHover { proxy in
                boardSettingHover = proxy
            }
            .onTapGesture { boardSettingClicked = true }
    }
}

extension TopToolBarArea {
    var boardSettingButton: some View {
        Rectangle()
            .foregroundStyle(rightToolBarClicked ? .white : rightToolBarHover ? .gray : .clear)
            .overlay(
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.black)
            )
            .frame(width: 48)
            .onHover { proxy in
                rightToolBarHover = proxy
            }
            .onTapGesture { rightToolBarClicked = true }
    }
}
