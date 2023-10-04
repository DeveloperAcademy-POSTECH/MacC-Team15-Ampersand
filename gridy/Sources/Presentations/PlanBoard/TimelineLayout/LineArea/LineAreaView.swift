//
//  LineAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct LineAreaView: View {
    var body: some View {
        // TODO: LineArea (하위코드삭제)
        ScrollView([.horizontal, .vertical]) {
            HStack {
                ForEach(1..<60) { _ in
                    VStack {
                        ForEach(1..<60) { _ in
                            Rectangle()
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
        }
    }
}

struct LineAreaView_Previews: PreviewProvider {
    static var previews: some View {
        LineAreaView()
    }
}
