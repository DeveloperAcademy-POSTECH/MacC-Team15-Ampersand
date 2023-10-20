//
//  MenuBar.swift
//  gridy
//
//  Created by Jin Sang woo on 10/20/23.
//

import SwiftUI

struct MenuBar: Commands {
    @ObservedObject var viewModel: TimelineLayoutViewModel
        
    var body: some Commands {
        CommandMenu("사용자 메뉴") {
            Section {
                Button("너비 확대", action: {
                    viewModel.gridWidth += 2
                })
                .keyboardShortcut("+", modifiers: [/*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/, .shift])
                
                Button("너비 축소", action: {
                    viewModel.gridWidth -= 2
                })
                .keyboardShortcut("-", modifiers: [/*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/, .shift])
            }
            Section {
                Button("전체 확대", action: {
                    viewModel.gridWidth += 2
                    viewModel.lineAreaGridHeight += 2
                })
                .keyboardShortcut("+", modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
                
                Button("전체 축소", action: {
                    viewModel.gridWidth -= 2
                    viewModel.lineAreaGridHeight -= 2
                })
                .keyboardShortcut("-", modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
                
                Button("셀 크기 초기화", action: {
                    viewModel.lineAreaGridHeight = 45
                    viewModel.gridWidth = 45
                    viewModel.horizontalMagnification = 1.0
                    viewModel.verticalMagnification = 1.0
                })
                .keyboardShortcut(.delete, modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
        }
    }
}
