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
    @State var isHovering = false
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 6)
                .frame(height: 108)
                .foregroundStyle(isHovering ? .gray.opacity(0.1) : .white)
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
                        .frame(height: 28)
                        
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
                    isHovering = proxy
                }
        }
    }
}
