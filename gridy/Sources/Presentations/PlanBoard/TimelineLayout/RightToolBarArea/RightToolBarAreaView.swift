//
//  RightToolBarAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct RightToolBarAreaView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                // TODO: Detail UI (하위코드삭제)
                ForEach(1..<10) { detailNumber in
                    Rectangle()
                        .opacity(0.1)
                        .frame(height: 60)
                        .cornerRadius(8)
                        .overlay(Text("Think \(detailNumber)"))
                }
                
                ScrollDatePickerView()
            }
            .padding(.horizontal, 16)
//            .frame(width: geo.size.width)
        }
    }
}

struct RightToolBarAreaView_Previews: PreviewProvider {
    static var previews: some View {
        RightToolBarAreaView()
    }
}
