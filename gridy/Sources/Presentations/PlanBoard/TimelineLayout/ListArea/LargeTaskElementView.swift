//
//  LargeTaskElementView.swift
//  gridy
//
//  Created by xnoag on 10/9/23.
//

import SwiftUI

struct LargeTaskElementView: View {
    @State private var isTaskElementHovering = false
    @State private var isLeftButtonHovering = false
    @State private var isRightButtonHovering = false
    @Binding var isLeftButtonClicked: Bool
    @Binding var isRightButtonClicked: Bool
    @State private var isPressedReturnKey = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var largeTaskElementTextField = ""
    @State private var isEditing = false
    
    var body: some View {
        var largeTaskElementText: String {
            if isPressedReturnKey {
                return largeTaskElementTextField
            } else {
                return ""
            }
        }
        
        Rectangle()
            .frame(minWidth: 266, idealWidth: 266, maxWidth: 532)
            .frame(height: 48)
            .foregroundStyle(.white)
            .border(.gray, width: 0.2)
            .overlay {
                if !isEditing {
                    Text(largeTaskElementText)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .padding(.horizontal, 8)
                }
            }
            .overlay {
                if isTaskElementHovering && largeTaskElementText.isEmpty {
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
                } else if isTaskElementHovering && !largeTaskElementText.isEmpty {
                    HStack(spacing: 0) {
                        Button(action: {
                            isLeftButtonClicked = true
                        }) {
                            Rectangle()
                                .foregroundStyle(isLeftButtonHovering ? .red : .clear)
                                .frame(width: 24, height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isLeftButtonHovering = proxy
                        }
                        Button(action: {
                            isEditing = true
                            isTextFieldFocused = true
                            isTaskElementHovering = false
                        }) {
                            Rectangle()
                                .foregroundStyle(.white.opacity(0.1))
                                .frame(minWidth: 266-48, idealWidth: 266-48, maxWidth: 532-48)
                                .frame(height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {
                            isRightButtonClicked = true
                        }) {
                            Rectangle()
                                .foregroundStyle(isRightButtonHovering ? .blue : .clear)
                                .frame(width: 24, height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isRightButtonHovering = proxy
                        }
                    }
                    .border(isTaskElementHovering && !isLeftButtonHovering && !isRightButtonHovering ? .blue : .clear)
                }
            }
            .overlay {
                if isEditing {
                    TextField("Editing", text: $largeTaskElementTextField, onCommit: {
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
                        largeTaskElementTextField = ""
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
    LargeTaskElementView(isLeftButtonClicked: .constant(false), isRightButtonClicked: .constant(false))
}
