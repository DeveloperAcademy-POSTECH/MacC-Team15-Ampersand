//
//  ProjectBoardView.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardView: View {
    
    let store: StoreOf<ProjectBoard>
    @State private var onAppearProceeding = true
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Button("create new project") {
                    viewStore.send(.createNewProjectButtonTapped)
                }
                Button("read all projects") {
                    viewStore.send(.readAllButtonTapped)
                }
                ForEachStore(
                    store.scope(
                        state: \.projects,
                        action: { .deleteProjectButtonTapped(id: $0, action: $1) }
                    )
                ) {
                    ProjectItemView(store: $0)
                }
            }
        }
    }
}

#Preview {
    ProjectBoardView(
        store: Store(
            initialState: ProjectBoard.State(),
            reducer: { ProjectBoard() }
        )
    )
}
