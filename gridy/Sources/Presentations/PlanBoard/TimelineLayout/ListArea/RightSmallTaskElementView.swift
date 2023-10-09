//
//  RightSmallTaskElementView.swift
//  gridy
//
//  Created by xnoag on 10/9/23.
//

import SwiftUI

struct RightSmallTaskElementView: View {
    @State private var isTaskElementHovering = false
    @State private var isTopButtonHovering = false
    @State private var isBottomButtonHovering = false
    @Binding var isTopButtonClicked: Bool
    @Binding var isBottomButtonClicked: Bool
    @State private var isPressedReturnKey = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var rightSmallTaskElementTextField = ""
    @State private var isEditing = false
    
    var body: some View {
        var rightSmallTaskElementText: String {
            if isPressedReturnKey {
                return rightSmallTaskElementTextField
            } else {
                return ""
            }
        }
        
        Rectangle()
            .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
            .frame(height: 48)
            .foregroundStyle(.white)
            .border(.gray, width: 0.2)
            .overlay {
                if !isEditing {
                    Text(rightSmallTaskElementText)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .padding(.horizontal, 8)
                }
            }
            .overlay {
                if isTaskElementHovering && rightSmallTaskElementText.isEmpty {
                    Button(action: {
                        isEditing = true
                        isTaskElementHovering = false
                        isTextFieldFocused = true
                    }) {
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
                } else if isTaskElementHovering && !rightSmallTaskElementText.isEmpty {
                    VStack(spacing: 0) {
                        Button(action: {
                            isTopButtonClicked = true
                        }) {
                            Rectangle()
                                .foregroundStyle(isTopButtonHovering ? .pink : .clear)
                                .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
                                .frame(height: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isTopButtonHovering = proxy
                        }
                        Button(action: {
                            isEditing = true
                            isTextFieldFocused = true
                            isTaskElementHovering = false
                        }) {
                            Rectangle()
                                .foregroundStyle(.white.opacity(0.1))
                                .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
                                .frame(height: 48-8-8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {
                            isBottomButtonClicked = true
                        }) {
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
                    TextField("Editing", text: $rightSmallTaskElementTextField, onCommit: {
                        isEditing = false
                        isPressedReturnKey = true
                    })
                    .multilineTextAlignment(.center)
                    .font(.custom("Pretendard-Regular", size: 16))
                    .textFieldStyle(.plain)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 1)
                    .padding(.vertical, 2)
                    .cornerRadius(6)
                    .focused($isTextFieldFocused)
                    .onExitCommand(perform: {
                        rightSmallTaskElementTextField = ""
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

#Preview {
    RightSmallTaskElementView(isTopButtonClicked: .constant(false), isBottomButtonClicked: .constant(false))
}
