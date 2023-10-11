//
//  RightSmallTaskElementView.swift
//  gridy
//
//  Created by xnoag on 10/9/23.
//

import SwiftUI

struct RightSmallTaskElementView: View {
    @State private var isTaskElementHovering = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isEditing = false
    @State private var isTopButtonHovering = false
    @State private var isBottomButtonHovering = false
    @Binding var rightSmallTaskTuple: (Int, String)
    @Binding var isTopButtonClicked: Bool
    @Binding var isBottomButtonClicked: Bool
    @Binding var clickedIndex: Int
    var myIndex: Int
    
    //    @Binding var rightSmallTaskTuple.1: String
    
    var body: some View {
        Rectangle()
            .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
            .frame(height: 48)
            .foregroundStyle(.white)
            .border(.gray, width: 0.5)
            .overlay {
                if !isEditing {
                    Text(rightSmallTaskTuple.1)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .padding(.horizontal, 8)
                }
            }
            .overlay {
                if isTaskElementHovering && rightSmallTaskTuple.1.isEmpty {
                    Button {
                        isEditing = true
                        isTaskElementHovering = false
                        isTextFieldFocused = true
                    } label: {
                        Rectangle()
                            .foregroundStyle(.gray.opacity(0.2))
                            .cornerRadius(6)
                            .overlay {
                                Text("New Task")
                                    .foregroundStyle(.gray)
                                    .font(.custom("Pretendard-Regular", size: 16))
                            }
                            .padding(2)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if isTaskElementHovering && !rightSmallTaskTuple.1.isEmpty {
                    VStack(spacing: 0) {
                        Button {
                            isTopButtonClicked = true
                            clickedIndex = myIndex
                        } label: {
                            Rectangle()
                                .foregroundStyle(isTopButtonHovering ? .pink : .clear)
                                .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
                                .frame(height: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isTopButtonHovering = proxy
                        }
                        Button {
                            isEditing = true
                            isTextFieldFocused = true
                            isTaskElementHovering = false
                        } label: {
                            Rectangle()
                                .foregroundStyle(.white.opacity(0.1))
                                .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
                                .frame(height: 48-8-8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            isBottomButtonClicked = true
                            clickedIndex = myIndex
                        } label: {
                            Rectangle()
                                .foregroundStyle(isBottomButtonHovering ? .pink : .clear)
                                .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
                                .frame(height: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isBottomButtonHovering = proxy
                        }
                    }
                    .border(isTaskElementHovering && !isTopButtonHovering && !isBottomButtonHovering ? .blue : .clear)
                }
            }
            .overlay {
                if isEditing {
                    TextField("Editing", text: $rightSmallTaskTuple.1, axis: .vertical)
                        .onSubmit {
                            isEditing = false
                        }
                        .multilineTextAlignment(.center)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .textFieldStyle(.plain)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 1)
                        .padding(.vertical, 2)
                        .cornerRadius(6)
                        .focused($isTextFieldFocused)
                        .onExitCommand(perform: {
                            rightSmallTaskTuple.1 = ""
                            isEditing = false
                            isTextFieldFocused = false
                        })
                }
            }
            .onHover { phase in
                if !isEditing {
                    isTaskElementHovering = phase
                }
            }
    }
}
