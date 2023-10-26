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
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: 0) {
                        ProjectBoardSideView(store: store)
                            .frame(width: 306)
                        ProjectBoardMainView(store: store)
                    }
                    if viewStore.isCreationViewPresented {
                        ZStack {
                            Color.black.opacity(0.6)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .onTapGesture {
                                    viewStore.send(ProjectBoard.Action.setSheet(isPresented: false))
                                }
                            ProjectCreationView(store: store)
                                .offset(y: viewStore.isCreationViewPresented ? 0 : -50)
                        }
                        .onExitCommand {
                            viewStore.send(ProjectBoard.Action.setSheet(isPresented: false))
                        }
                    }
                    
                    if viewStore.isEditViewPresented {
                        ZStack {
                            Color.black.opacity(0.6)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .onTapGesture {
                                    viewStore.send(ProjectBoard.Action.setEditSheet(isPresented: false))
                                }
                            ProjectEditView(store: store)
                                .offset(y: viewStore.isEditViewPresented ? 0 : -50)
                        }
                        .onExitCommand {
                            viewStore.send(ProjectBoard.Action.setEditSheet(isPresented: false))
                        }
                    }
                }
            }
        }
    }
}
