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
        ScrollView {
            HStack(spacing: 0) {
                ForEach(1..<70) { _ in
                    VStack(spacing: 0) {
                        ForEach(1..<60) { _ in
                            Rectangle()
                                .border(.green)
                                .frame(width: 28, height: 28)
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
