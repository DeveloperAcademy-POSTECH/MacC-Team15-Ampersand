//
//  RightToolBarAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct RightToolBarAreaView: View {
    @Binding var proxy: ScrollViewProxy?
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                // TODO: Detail UI (하위코드삭제)
                ForEach(1..<10) { detailNumber in
                    Rectangle()
                        .opacity(0.1)
                        .frame(height: 60)
                        .cornerRadius(8)
                        .overlay(Text("Think \(detailNumber)"))
                }
                
                ScrollDatePickerView(proxy: $proxy)
            }
            .padding(.horizontal, 16)
//            .frame(width: geo.size.width)
        }
    }
}
