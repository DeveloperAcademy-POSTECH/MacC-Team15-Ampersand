//
//  ProjectBoardMainView.swift
//  gridy
//
//  Created by xnoag on 10/12/23.
//

import SwiftUI

struct ProjectBoardMainView: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                // RightTopBarArea
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: proxy.size.width)
                    .frame(height: 36)
                HStack(alignment: .center, spacing: 0) {
                    Text("Directory")
                        .font(.custom("Pretendard-Bold", size: 32))
                    Spacer()
                    Button {
                        // Create a new project
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 119, height: 35)
                            .foregroundStyle(.blue)
                            .overlay {
                                Text("New Project")
                                    .foregroundStyle(.white)
                                    .font(.custom("Pretendard-SemiBold", size: 14))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(20)
            }
        }
    }
}

#Preview {
    ProjectBoardMainView()
}
