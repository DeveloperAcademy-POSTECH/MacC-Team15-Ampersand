//
//  ProjectBoardMainView.swift
//  gridy
//
//  Created by xnoag on 10/12/23.
//

import SwiftUI

struct ProjectBoardMainView: View {
    let columnsFolders = [GridItem(.adaptive(minimum: 274), spacing: 20)]
    let columnsProjects = [GridItem(.adaptive(minimum: 274), spacing: 20)]
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // RightTopBarArea
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.1))
                        .frame(height: 36)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("Directory")
                            .font(.custom("Pretendard-Bold", size: 32))
                            .padding(.vertical, 16)
                        Spacer()
                        Button {
                            // Create a new project
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
                        .buttonStyle(PlainButtonStyle())
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
                            ForEach(1...8, id: \.self) { _ in
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
                                            .padding(.top, 12)
                                            .padding(.bottom, 11)
                                            .padding(.leading, 12)
                                            Spacer()
                                            Button {
                                                // 더보기 버튼
                                            } label: {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .frame(width: 20, height: 20)
                                                    .foregroundStyle(.gray.opacity(0.1))
                                                    .overlay {
                                                        Image(systemName: "ellipsis")
                                                            .foregroundStyle(.gray)
                                                    }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.top, 4)
                                            .padding(.trailing, 4)
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
                            ForEach(1...15, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(height: 108)
                                    .foregroundStyle(.white)
                                    .overlay {
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack(alignment: .center, spacing: 0) {
                                                Text("Last updated on")
                                                    .font(.custom("Pretendard-Regular", size: 12))
                                                    .foregroundStyle(.gray)
                                                    .padding(.leading, 10)
                                                    .padding(.trailing, 4)
                                                Text("2023.10.17")
                                                    .font(.custom("Pretendard-Bold", size: 12))
                                                    .foregroundStyle(.gray)
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                                Button {
                                                    // 더보기 버튼
                                                } label: {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .frame(width: 20, height: 20)
                                                        .foregroundStyle(.gray.opacity(0.1))
                                                        .overlay {
                                                            Image(systemName: "ellipsis")
                                                                .foregroundStyle(.gray)
                                                        }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .padding(.vertical, 4)
                                                .padding(.trailing, 4)
                                            }
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
                                            Text("Project Name")
                                                .font(.custom("Pretendard-Bold", size: 20))
                                                .multilineTextAlignment(.leading)
                                                .padding(.leading, 12)
                                                .padding(.top, 12)
                                                .padding(.bottom, 11)
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
                        }
                    }
                    
                    .padding(.top, 64)
                    .padding(.horizontal, 24)
                }
                .frame(width: proxy.size.width)
            }
        }
    }
}

#Preview {
    ProjectBoardMainView()
}
