//
//  ProjectSideItemView.swift
//  gridy
//
//  Created by xnoag on 10/19/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectSideItemView: View {
    let store: StoreOf<ProjectItem>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Rectangle()
                .frame(width: 306, height: 32)
                .foregroundStyle(.gray.opacity(0.1))
                .overlay {
                    Text(viewStore.project.title)
                        .font(.custom("Pretendard-Regular", size: 14))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.black)
                        .padding(.leading, 16)
                }
        }
    }
}

#Preview {
    ProjectSideItemView(store: StoreOf<ProjectItem>(initialState: ProjectItem.State(), reducer: { ProjectItem() }))
}
