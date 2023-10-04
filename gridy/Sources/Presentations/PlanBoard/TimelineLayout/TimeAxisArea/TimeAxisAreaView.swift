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
        ScrollView(.horizontal) {
            HStack {
                ForEach(1..<60) { _ in
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: 35, height: 35)
                }
            }
        }
    }
}

struct TimeAxisAreaView_Previews: PreviewProvider {
    static var previews: some View {
        TimeAxisAreaView()
    }
}
