//
//  ProjectItemView.swift
//  gridy
//
//  Created by 제나 on 10/8/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectCreationView: View {
    let store: StoreOf<ProjectBoard>
    @FocusState private var isTextFieldFocused: Bool
    @State var tag: Int?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
                .frame(width: 368, height: 448)
                .overlay {
                    VStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .center, spacing: 73) {
                            Text("Create a new project")
                                .font(.custom("Pretendard-Bold", size: 16))
                            HStack(alignment: .center, spacing: 4) {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 30, height: 22)
                                    .foregroundStyle(.gray.opacity(0.8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 4)
                                            .frame(width: 28, height: 18)
                                            .foregroundStyle(.white)
                                            .overlay {
                                                Text("Esc")
                                                    .font(.custom("Pretendard-SemiBold", size: 12))
                                                    .foregroundStyle(.gray)
                                            }
                                            .offset(y: -1)
                                    }
                                Text("to Close tab")
                                    .font(.custom("Pretendard-Regular", size: 12))
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.gray.opacity(0.1))
                            .frame(width: 328, height: 36)
                            .overlay {
                                TextField(
                                    "Project Name",
                                    text: viewStore.binding(
                                        get: \.title,
                                        send: { .titleChanged($0) }
                                    )
                                )
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    if !viewStore.title.isEmpty {
                                        viewStore.send(.createNewProjectButtonTapped)
                                        self.tag = 1
                                    }
                                }
                                .font(.custom("Pretendard-Medium", size: 14))
                                .padding(.leading, 12)
                                .textFieldStyle(.plain)
                            }
                            .padding(.bottom, 16)
                        Divider()
                            .padding(.bottom, 14)
                        HStack(alignment: .center, spacing: 220) {
                            Text("Select Layout")
                                .font(.custom("Pretendard-SemiBold", size: 14))
                                .foregroundStyle(.opacity(0.8))
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.opacity(0.8))
                                .frame(width: 16, height: 16)
                        }
                        .padding(.bottom, 10)
                        HStack(alignment: .center, spacing: 14) {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.blue.opacity(0.1))
                                .frame(width: 100, height: 120)
                                .overlay {
                                    VStack(alignment: .center, spacing: 10) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundStyle(.blue.opacity(0.2))
                                            .frame(width: 64, height: 64)
                                            .overlay {
                                                Image(systemName: "chart.bar.doc.horizontal")
                                                    .resizable()
                                                    .foregroundStyle(.blue)
                                                    .frame(width: 32, height: 38)
                                            }
                                        Text("Timeline")
                                            .font(.custom("Pretendard-Medium", size: 14))
                                            .foregroundStyle(.blue)
                                    }
                                }
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.gray.opacity(0.1))
                                .frame(width: 100, height: 120)
                                .overlay {
                                    VStack(alignment: .center, spacing: 10) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundStyle(.gray.opacity(0.2))
                                            .frame(width: 64, height: 64)
                                            .overlay {
                                                Image(systemName: "calendar")
                                                    .resizable()
                                                    .foregroundStyle(.gray)
                                                    .frame(width: 36, height: 33)
                                            }
                                        Text("Calendar")
                                            .font(.custom("Pretendard-Medium", size: 14))
                                            .foregroundStyle(.gray)
                                    }
                                }
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.gray.opacity(0.1))
                                .frame(width: 100, height: 120)
                                .overlay {
                                    VStack(alignment: .center, spacing: 10) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundStyle(.gray.opacity(0.2))
                                            .frame(width: 64, height: 64)
                                            .overlay {
                                                Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                                                    .resizable()
                                                    .foregroundStyle(.gray)
                                                    .frame(width: 36, height: 30)
                                            }
                                        Text("Scheme")
                                            .font(.custom("Pretendard-Medium", size: 14))
                                            .foregroundStyle(.gray)
                                    }
                                }
                        }
                        .padding(.bottom, 16)
                        Text("We are currently offering the **Timeline Layout** in a \rclosed beta version. <Message>")
                            .font(.custom("Pretendard-Medium", size: 14))
                            .foregroundStyle(.gray)
                            .padding(.bottom, 24)
                        Divider()
                            .padding(.bottom, 20)
                        ZStack {
                            // TODO: NavigationLink 방식은 Store 이용하기
                            NavigationLink(destination: TimelineLayoutView(), tag: 1, selection: self.$tag) {
                                EmptyView()
                            }
                            Button {
                                viewStore.send(.createNewProjectButtonTapped)
                                self.tag = 1
                            } label: {
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(width: 328, height: 48)
                                    .foregroundStyle(viewStore.title.isEmpty ? .gray : .blue)
                                    .overlay {
                                        Text("Go Ahead !")
                                            .font(.custom("Pretendard-Medium", size: 16))
                                            .foregroundStyle(viewStore.title.isEmpty ? .black : .white)
                                    }
                            }
                            .disabled(viewStore.title.isEmpty)
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 9)
                        }
                        HStack(alignment: .center, spacing: 5) {
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 55, height: 22)
                                .foregroundStyle(.gray.opacity(0.8))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(width: 53, height: 18)
                                        .foregroundStyle(.white)
                                        .overlay {
                                            Text("↵ Enter")
                                                .font(.custom("Pretendard-SemiBold", size: 12))
                                                .foregroundStyle(.gray)
                                        }
                                        .offset(y: -1)
                                }
                            Text("to Create a proejct")
                                .font(.custom("Pretendard-Regular", size: 12))
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .onAppear {
                    isTextFieldFocused = true
                }
        }
    }
}
