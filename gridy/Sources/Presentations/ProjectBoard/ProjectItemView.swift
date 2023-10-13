//
//  ProjectItemView.swift
//  gridy
//
//  Created by 제나 on 10/8/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectItemView: View {
    
    let store: StoreOf<ProjectItem>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationLink {
                PlanBoardView(
                    store: store.scope(
                        state: \.optionalPlanBoard,
                        action: { .optionalPlanBoard($0) }
                    )
                )
            } label: {
                VStack {
                    TextField(
                        viewStore.project.title,
                        text: viewStore.binding(
                            get: \.project.title,
                            send: ProjectItem.Action.titleChanged
                        )
                    )
                    Text(viewStore.project.pid)
                    Text(viewStore.project.ownerUid)
                    Button("프로젝트 삭제") {
                        viewStore.$delete.wrappedValue.toggle()
                    }
                    .keyboardShortcut(.delete)
                }
                .padding()
                .border(.white)
            }
        }
    }
}

#Preview {
    ProjectItemView(
        store: Store(
            initialState: ProjectItem.State(),
            reducer: { ProjectItem() }
        )
    )
}
