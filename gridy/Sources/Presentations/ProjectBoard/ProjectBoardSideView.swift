//
//  ProjectBoardSideView.swift
//  gridy
//
//  Created by xnoag on 10/12/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardSideView: View {
    let store: StoreOf<ProjectBoard>
    @State var projectSearchText = ""
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { proxy in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 4) {
                        Circle()
                            .foregroundStyle(.gray)
                            .frame(width: 24, height: 24)
                            .padding(6)
                        Text("UserName")
                            .font(.custom("Pretendard-SemiBold", size: 14))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .background(Color.gray.opacity(0.2))
                    .frame(height: 36)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.gray.opacity(0.1))
                        .overlay {
                            TextField("Search..", text: $projectSearchText)
                                .textFieldStyle(.plain)
                                .font(.custom("Pretendard-Regular", size: 14))
                                .padding(.leading, 12)
                        }
                        .frame(height: 36)
                        .padding(.horizontal, 12)
                        .padding(.vertical)
                    
                    Button {
                        //TODO: New Folder Button
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.blue)
                            .overlay {
                                Text("New Folder")
                                    .foregroundStyle(.white)
                                    .font(.custom("Pretendard-Medium", size: 16))
                            }
                            .frame(height: 40)
                            .padding(.vertical)
                            .padding(.horizontal, 12)
                    }
                    HStack(alignment: .top, spacing: 4) {
                        Spacer()
                        Button {
                            // TODO: - 왼쪽 버튼
                            print("Button/1")
                        } label: {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(.black.opacity(0.7))
                                .frame(width: 24, height: 24)
                        }
                        Button {
                            // TODO: - 오른쪽 버튼
                            print("Button/2")
                        } label: {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(.black.opacity(0.7))
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(4)
                    .background(Color.gray.opacity(0.5))
                    HStack(spacing: 0) {
                        Text("Directory")
                            .font(.custom("Pretendard-Bold", size: 18))
                            .padding()
                        Spacer()
                    }
                    List {
                        ForEachStore(
                            store.scope(
                                state: \.projects,
                                action: { .deleteProjectButtonTapped(id: $0, action: $1) }
                            )
                        ) {
                            ProjectSideItemView(store: $0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: -16, bottom: 0, trailing: 0))
                                .border(.red)
                                .frame(width: proxy.size.width, height: 32)
                        }
                    }
                }
                .background(.white)
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 306)
            .onAppear {
                viewStore.send(
                    .onAppear
                )
            }
        }
    }
}
