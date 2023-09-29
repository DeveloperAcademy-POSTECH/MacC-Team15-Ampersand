//
//  TimelineLayoutContentView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutContentView: View {
    var body: some View {
        ScrollView(.vertical) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(1..<10) { _ in
                        VStack {
                            ForEach(1..<10) { _ in
                                Rectangle()
                                    .frame(width: 200, height: 200)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TimelineLayoutContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutContentView()
    }
}
