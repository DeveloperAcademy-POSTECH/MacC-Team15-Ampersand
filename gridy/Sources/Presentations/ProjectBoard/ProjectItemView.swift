//
//  ProjectItemView.swift
//  gridy
//
//  Created by xnoag on 10/17/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectItemView: View {
    let store: StoreOf<ProjectItem>
    @State var tag: Int?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                // TODO: NavigationLink 방식은 Store 이용하기
                NavigationLink(destination: TimelineLayoutView(), tag: 2, selection: self.$tag) {
                    EmptyView()
                }
                RoundedRectangle(cornerRadius: 6)
                    .frame(height: 108)
                    .foregroundStyle(.white)
                RoundedRectangle(cornerRadius: 6)
                    .stroke(viewStore.isTapped ? .blue : .clear)
                    .frame(height: 108)
                    .overlay {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .center, spacing: 0) {
                                Text("Last updated on **\(viewStore.project.lastModifiedDate.formattedDate)**")
                                    .font(.custom("Pretendard-Regular", size: 12))
                                    .foregroundStyle(.gray)
                                    .padding(.leading, 10)
                                    .padding(.trailing, 4)
                                Spacer()
                            }
                            .frame(height: 28)
                            .background(.gray.opacity(0.1))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 6,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 6,
                                    style: .continuous
                                )
                            )
                            
                            HStack {
                                Text(viewStore.project.title)
                                    .font(.custom("Pretendard-Bold", size: 20))
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 12)
                                    .padding(.top, 12)
                                    .padding(.bottom, 11)
                                Spacer()
                            }
                            
                            HStack(alignment: .center, spacing: 0) {
                                Text("2023.10.01 ~ 2023.11.14")
                                    .font(.custom("Pretendard-SemiBold", size: 12))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 8)
                                    .frame(height: 24)
                                    .background(.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .padding(.trailing, 6)
                                Text("45 Days")
                                    .font(.custom("Pretendard-SemiBold", size: 12))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 8)
                                    .frame(height: 24)
                                    .background(.gray.opacity(0.3))
                                    .cornerRadius(6)
                            }
                            .padding(.leading, 12)
                            .padding(.bottom, 9)
                        }
                    }
            }
            .contextMenu {
                Button {
                    viewStore.$showSheet.wrappedValue = true
                } label: {
                    Text("Edit")
                }
                Button {
                    viewStore.$delete.wrappedValue.toggle()
                } label: {
                    Text("Delete")
                }
            }
            .onHover { proxy in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        let taskResult = viewStore.send(
                            .isHovering(hovered: proxy)
                        )
                    }
                }
            }
            .onTapGesture {
                viewStore.$isTapped.wrappedValue = true
            }
            .highPriorityGesture(TapGesture(count: 2).onEnded({
                viewStore.$isTapped.wrappedValue = true
                DispatchQueue.main.async {
                    withAnimation(.easeIn(duration: 0.1)) {
                        self.tag = 2
                    }
                }
            }))
            .scaleEffect(viewStore.isHovering ? 1.03 : 1)
        }
    }
}
