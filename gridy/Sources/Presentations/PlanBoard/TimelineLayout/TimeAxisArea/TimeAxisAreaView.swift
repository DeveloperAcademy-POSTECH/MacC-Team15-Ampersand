//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimeAxisAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    var proxy: ScrollViewProxy
    
    var body: some View {
        LazyHStack(alignment: .top, spacing: 0) {
            ForEach(0..<viewModel.numOfCol) { col in
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: viewModel.gridWidth)
                    .overlay(
                        ZStack {
                            Text("\(col)")
                                .font(.body)
                            Rectangle()
                                .strokeBorder(lineWidth: 0.3)
                                .foregroundColor(.white)
                        }
                    )
                    .id(col)
                    .onTapGesture {
                        withAnimation {
                            proxy.scrollTo(col, anchor: .leading)
                        }
                    }
            }
        }
    }
}
//
//struct TimeAxisAreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeAxisAreaView()
//    }
//}
