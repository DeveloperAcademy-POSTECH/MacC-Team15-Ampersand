//
//  ProjectBoardMainView.swift
//  gridy
//
//  Created by xnoag on 10/12/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardMainView: View {
    let columnsFolders = [GridItem(.adaptive(minimum: 274), spacing: 20)]
    let columnsProjects = [GridItem(.adaptive(minimum: 274), spacing: 20)]
    let store: StoreOf<ProjectBoard>
    @State var isTapped = false
    @State private var selectedIndex = 0
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Rectangle()
                            .foregroundStyle(.gray.opacity(0.1))
                            .frame(height: 36)
                        
                        HStack(alignment: .center, spacing: 0) {
                            Text("Directory")
                                .font(.custom("Pretendard-Bold", size: 32))
                                .padding(.vertical, 16)
                            Spacer()
                            Button {
                                viewStore.send(.setSheet(isPresented: true))
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
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 70, height: 20)
                                .foregroundStyle(.gray.opacity(0.2))
                                .overlay(
                                    Text("Folders")
                                        .font(.custom("Pretendard-Bold", size: 12))
                                )
                            LazyVGrid(columns: columnsFolders, alignment: .leading, spacing: 20) {
                                ForEach(1...2, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(height: 65)
                                        .foregroundStyle(.white)
                                        .overlay {
                                            HStack(alignment: .top, spacing: 0) {
                                                VStack(alignment: .leading, spacing: 0) {
                                                    Text("Folder Name")
                                                        .font(.custom("Pretendard-Bold", size: 16))
                                                        .multilineTextAlignment(.leading)
                                                        .padding(.bottom, 6)
                                                    Text("4 Projects")
                                                        .foregroundStyle(.gray)
                                                        .multilineTextAlignment(.leading)
                                                        .font(.custom("Pretendard-Medium", size: 14))
                                                }
                                                .padding([.top, .leading], 12)
                                                .padding(.bottom, 11)
                                                Spacer()
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.top, 6)
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 70, height: 20)
                                .foregroundStyle(.gray.opacity(0.2))
                                .overlay(
                                    Text("Projects")
                                        .font(.custom("Pretendard-Bold", size: 12))
                                )
                            LazyVGrid(columns: columnsProjects, alignment: .leading, spacing: 20) {
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
                        .padding(.top, 64)
                        .padding(.horizontal, 24)
                    }
                    .frame(width: proxy.size.width)
                }
                .onAppear {
                    viewStore.send(
                        .onAppear
                    )
                }
            }
        }
    }
}
