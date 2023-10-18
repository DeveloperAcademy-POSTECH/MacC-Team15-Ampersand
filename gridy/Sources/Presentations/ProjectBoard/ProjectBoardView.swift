//
//  ProjectBoardView.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardView: View {
    @State var isCreateNewProjectSheet = false
    let store: StoreOf<ProjectBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
                HStack(spacing: 0) {
                    ProjectBoardSideView()
                        .frame(width: 306)
                    ProjectBoardMainView(store: store, isCreateNewProjectSheet: $isCreateNewProjectSheet)
                }
            .sheet(isPresented: viewStore.binding(
                get: \.isSheetPresented,
                send: ProjectBoard.Action.setSheet(isPresented:)
            )) {
                ProjectCreationView(store: store)
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
