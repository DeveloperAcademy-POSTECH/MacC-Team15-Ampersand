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
            NavigationLink(isActive: viewStore.binding(
                get: \.isNavigationActive,
                send: { .setNavigation(isActive: $0 ) }
            )) {
                IfLetStore(
                    store.scope(
                        state: \.optionalPlanBoard,
                        action: { .optionalPlanBoard($0) }
                    )
                ) {
                   PlanBoardView(store: $0)
                } else: {
                    ZStack {
                        BackgroundView()
                        ProgressView()
                    }
                }
            } label: {
                VStack {
                    TextField(
                        viewStore.project.title,
                        text: viewStore.binding(
                            get: \.project.title,
                            send: ProjectItem.Action.titleChanged
                        )
                    )
                    Text(viewStore.project.id)
                    Text(viewStore.project.ownerUid)
                    Text("생성일 \(viewStore.project.createdDate.description)")
                    Text("수정일 \(viewStore.project.lastModifiedDate.description)")
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

