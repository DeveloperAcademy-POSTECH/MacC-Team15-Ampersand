//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimeAxisAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    var body: some View {
        LazyHStack(alignment: .center, spacing: 0) {
            ForEach(0..<viewModel.numOfCol) { col in
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: viewModel.gridWidth, height: 30)
                    .overlay(
                        ZStack {
                            Text("\(col)")
                                .font(.body)
                            Rectangle()
                                .strokeBorder(lineWidth: 0.3)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
    }
}

struct TimeAxisAreaView_Previews: PreviewProvider {
    static var previews: some View {
        TimeAxisAreaView()
    }
}
