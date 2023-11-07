////
////  ProjectBoardView.swift
////  gridy
////
////  Created by 제나 on 10/7/23.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//struct ProjectBoardView: View {
//    let projectBoardStore: StoreOf<ProjectBoard>
//    @State var projectSearchText = ""
//    
//    var body: some View {
//        WithViewStore(projectBoardStore, observe: { $0 }) { viewStore in
//            GeometryReader { geometry in
//                ZStack {
//                    HStack(spacing: 0) {
//                        projectListArea
//                            .frame(width: 306)
//                        ProjectBoardMainView(store: projectBoardStore)
//                    }
//                    if viewStore.isCreationViewPresented {
//                        ZStack {
//                            Color.black.opacity(0.6)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                                .onTapGesture {
//                                    viewStore.send(
//                                        ProjectBoard.Action.setSheet(isPresented: false)
//                                    )
//                                }
//                            ProjectCreationView(store: projectBoardStore)
//                                .offset(y: viewStore.isCreationViewPresented ? 0 : -50)
//                        }
//                        .onExitCommand {
//                            viewStore.send(
//                                .setSheet(isPresented: false)
//                            )
//                        }
//                    }
//                    
//                    if viewStore.isEditViewPresented {
//                        ZStack {
//                            Color.black.opacity(0.6)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                                .onTapGesture {
//                                    viewStore.send(ProjectBoard.Action.setEditSheet(isPresented: false))
//                                }
//                            ProjectEditView(store: projectBoardStore)
//                                .offset(y: viewStore.isEditViewPresented ? 0 : -50)
//                        }
//                        .onExitCommand {
//                            viewStore.send(
//                                .setEditSheet(isPresented: false)
//                            )
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//extension ProjectBoardView {
//    var projectListArea: some View {
//        
//        WithViewStore(projectBoardStore, observe: { $0 }) { viewStore in
//            GeometryReader { proxy in
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack(alignment: .center, spacing: 4) {
//                        Circle()
//                            .foregroundStyle(.gray)
//                            .frame(width: 24, height: 24)
//                            .padding(6)
//                        Text("UserName")
//                            .font(.custom("Pretendard-SemiBold", size: 14))
//                            .multilineTextAlignment(.leading)
//                        Spacer()
//                    }
//                    .background(Color.gray.opacity(0.2))
//                    .frame(height: 36)
//                    
//                    RoundedRectangle(cornerRadius: 8)
//                        .foregroundStyle(.gray.opacity(0.1))
//                        .overlay {
//                            TextField("Search..", text: $projectSearchText)
//                                .textFieldStyle(.plain)
//                                .font(.custom("Pretendard-Regular", size: 14))
//                                .padding(.leading, 12)
//                        }
//                        .frame(height: 36)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical)
//                    
//                    Button {
//                        // TODO: - New Folder Button
//                    } label: {
//                        RoundedRectangle(cornerRadius: 12)
//                            .foregroundStyle(.blue)
//                            .overlay {
//                                Text("New Folder")
//                                    .foregroundStyle(.white)
//                                    .font(.custom("Pretendard-Medium", size: 16))
//                            }
//                            .frame(height: 40)
//                            .padding(.vertical)
//                            .padding(.horizontal, 12)
//                    }
//                    HStack(alignment: .top, spacing: 4) {
//                        Spacer()
//                        Button {
//                            // TODO: - 왼쪽 버튼
//                            print("Button/1")
//                        } label: {
//                            RoundedRectangle(cornerRadius: 6)
//                                .foregroundStyle(.black.opacity(0.7))
//                                .frame(width: 24, height: 24)
//                        }
//                        Button {
//                            // TODO: - 오른쪽 버튼
//                            print("Button/2")
//                        } label: {
//                            RoundedRectangle(cornerRadius: 6)
//                                .foregroundStyle(.black.opacity(0.7))
//                                .frame(width: 24, height: 24)
//                        }
//                    }
//                    .padding(4)
//                    .background(Color.gray.opacity(0.5))
//                    HStack(spacing: 0) {
//                        Text("Directory")
//                            .font(.custom("Pretendard-Bold", size: 18))
//                            .padding()
//                        Spacer()
//                    }
//                    List {
//                        ForEachStore(
//                            projectBoardStore.scope(
//                                state: \.projects,
//                                action: { .deleteProjectButtonTapped(id: $0, action: $1) }
//                            )
//                        ) {
//                            ProjectSideItemView(store: $0)
//                                .listRowSeparator(.hidden)
//                                .listRowInsets(EdgeInsets(top: 0, leading: -16, bottom: 0, trailing: 0))
//                                .frame(width: proxy.size.width, height: 32)
//                        }
//                    }
//                }
//                .background(.white)
//                .buttonStyle(PlainButtonStyle())
//            }
//            .frame(width: 306)
//            .onAppear {
//                viewStore.send(
//                    .onAppear
//                )
//            }
//        }
//    }
//}
//
//extension ProjectBoardView {
//    
//    var projectItem: some View {
//        WithViewStore(projectBoardStore, observe: { $0 }) { viewStore in
//            ZStack {
//                NavigationLink(
//                    isActive: viewStore.binding(
//                        get: \.isNavigationActive,
//                        send: { .setNavigation(isActive: $0) }
//                    )
//                ) {
//                    IfLetStore(
//                        self.projectBoardStore.scope(
//                            state: \.optionalPlanBoard,
//                            action: ProjectItem.Action.optionalPlanBoard
//                        )
//                    ) {
//                        TimelineLayoutView(store: $0)
//                    } else: {
//                        ProgressView()
//                    }
//                } label: {
//                    EmptyView()
//                }
//                RoundedRectangle(cornerRadius: 6)
//                    .foregroundStyle(.white)
//                    .frame(height: 108)
//                RoundedRectangle(cornerRadius: 6)
//                    .stroke(viewStore.isTapped ? .blue : .clear)
//                    .overlay {
//                        VStack(alignment: .leading, spacing: 0) {
//                            HStack(alignment: .center, spacing: 0) {
//                                Text("Last updated on **\(viewStore.project.lastModifiedDate.formattedDate)**")
//                                    .font(.custom("Pretendard-Regular", size: 12))
//                                    .foregroundStyle(.gray)
//                                    .padding(.leading, 10)
//                                    .padding(.trailing, 4)
//                                Spacer()
//                            }
//                            .frame(height: 28)
//                            .background(.gray.opacity(0.1))
//                            .clipShape(
//                                .rect(
//                                    topLeadingRadius: 6,
//                                    bottomLeadingRadius: 0,
//                                    bottomTrailingRadius: 0,
//                                    topTrailingRadius: 6,
//                                    style: .continuous
//                                )
//                            )
//                         
//                            HStack {
//                                Text(viewStore.project.title)
//                                    .font(.custom("Pretendard-Bold", size: 20))
//                                    .multilineTextAlignment(.leading)
//                                    .padding([.leading, .top], 12)
//                                    .padding(.bottom, 11)
//                                Spacer()
//                            }
//                            
//                            HStack(alignment: .center, spacing: 0) {
//                                Text("2023.10.01 ~ 2023.11.14")
//                                    .font(.custom("Pretendard-SemiBold", size: 12))
//                                    .multilineTextAlignment(.leading)
//                                    .padding(.horizontal, 8)
//                                    .frame(height: 24)
//                                    .background(.gray.opacity(0.3))
//                                    .cornerRadius(6)
//                                    .padding(.trailing, 6)
//                                Text("45 Days")
//                                    .font(.custom("Pretendard-SemiBold", size: 12))
//                                    .multilineTextAlignment(.leading)
//                                    .padding(.horizontal, 8)
//                                    .frame(height: 24)
//                                    .background(.gray.opacity(0.3))
//                                    .cornerRadius(6)
//                            }
//                            .padding(.leading, 12)
//                            .padding(.bottom, 9)
//                        }
//                    }
//                    .frame(height: 108)
//            }
//            .contextMenu {
//                Button {
//                    viewStore.$showSheet.wrappedValue = true
//                } label: {
//                    Text("Edit")
//                }
//                Button {
//                    viewStore.$delete.wrappedValue.toggle()
//                } label: {
//                    Text("Delete")
//                }
//            }
//            .onHover { isHovered in
//                DispatchQueue.main.async {
//                    withAnimation(.easeInOut(duration: 0.1)) {
//                        _ = viewStore.send(
//                            .isHovering(hovered: action)
//                        )
//                    }
//                }
//            }
//            .onTapGesture {
//                viewStore.$isTapped.wrappedValue = true
//            }
//            .highPriorityGesture(TapGesture(count: 2).onEnded({
//                viewStore.$isTapped.wrappedValue = true
//                viewStore.send(.setNavigation(isActive: true))
//            }))
//            .scaleEffect(viewStore.isHovering ? 1.03 : 1)
//        }
//    }
//}
