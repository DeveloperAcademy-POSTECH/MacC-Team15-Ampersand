//
//  RightToolBarView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct RightToolBarView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            planBoardBorder(.vertical, 2)
            Color.rightToolBar
        }
    }
}

#Preview {
    RightToolBarView()
}
