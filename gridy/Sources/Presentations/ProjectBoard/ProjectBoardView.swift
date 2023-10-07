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
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Button("create new project") {
                    viewStore.send(.createNewProjectButtonTapped)
                }
                Button("read all project") {
                    viewStore.send(.readAllProjectsButtonTapped)
                }
                
                ForEach(viewStore.projects) { project in
                    VStack {
                        Text(project.title)
                        Text(project.pid)
                        Text(project.ownerUid)
                    }
                    .padding()
                    .border(.white)
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
