//
//  LeftToolBarAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct LeftToolBarAreaView: View {
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    ForEach(1..<30) { thinkNumber in
                        Rectangle()
                            .opacity(0.1)
                            .frame(height: 60)
                            .cornerRadius(8)
                            .overlay(Text("Think \(thinkNumber)"))
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(width: geo.size.width)
        }
    }
}

struct LeftToolBarAreaView_Previews: PreviewProvider {
    static var previews: some View {
        LeftToolBarAreaView()
    }
}
