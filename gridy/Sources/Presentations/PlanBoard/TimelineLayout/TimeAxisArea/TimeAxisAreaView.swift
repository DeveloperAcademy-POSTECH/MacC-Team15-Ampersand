//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimeAxisAreaView: View {
    var body: some View {
        // TODO: TimeAxisArea (하위코드삭제)
        HStack(spacing: 0) {
            ForEach(1..<70) { _ in
                Rectangle()
                    .foregroundColor(.blue)
                    .border(.green)
                    .frame(width: 28, height: 28)
            }
        }
    }
}

struct TimeAxisAreaView_Previews: PreviewProvider {
    static var previews: some View {
        TimeAxisAreaView()
    }
}
