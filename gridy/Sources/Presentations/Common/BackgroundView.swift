//
//  BackgroundView.swift
//  gridy
//
//  Created by 제나 on 10/11/23.
//

import SwiftUI

struct BackgroundView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { _ in
            colorScheme == .dark ? Color.black.opacity(0.2) : Color.white
            Image(.gridBackground)
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .foregroundStyle(Color.gray)
                .opacity(colorScheme == .dark ? 0.3 : 0.3)
        }
    }
}
