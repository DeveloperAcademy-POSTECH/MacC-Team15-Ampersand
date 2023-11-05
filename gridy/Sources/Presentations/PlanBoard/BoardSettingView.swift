//
//  BoardSettingView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct BoardSettingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("BoardSettingView")
                .scenePadding()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Continue") {
                    dismiss()
                }
            }
        }
        .frame(width: 600, height: 350)
    }
}

#Preview {
    BoardSettingView()
}
