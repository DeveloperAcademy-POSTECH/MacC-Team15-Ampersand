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
    @FocusState private var isTextFieldFocused: Bool
    @Binding var largeTaskElementTextField: String
    @State private var isEditing = false
    
    var body: some View {
        Rectangle()
            .frame(minWidth: 266, idealWidth: 266, maxWidth: 532)
            .frame(height: 48)
            .foregroundStyle(.white)
            .border(.gray, width: 0.5)
            .overlay {
                if !isEditing {
                    Text(largeTaskElementTextField)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .padding(.horizontal, 8)
                }
            }
            .overlay {
                if isTaskElementHovering && largeTaskElementTextField.isEmpty {
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
                } else if isTaskElementHovering && !largeTaskElementTextField.isEmpty {
                    HStack(spacing: 0) {
                        Button {
                            isLeftButtonClicked = true
                        } label: {
                            Rectangle()
                                .foregroundStyle(.red)
                                .frame(width: 24, height: 48)
                                .offset(x: isLeftButtonHovering ? 0 : -24)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            withAnimation {
                                isLeftButtonHovering = proxy
                            }
                        }
                        Button {
                            isEditing = true
                            isTextFieldFocused = true
                            isTaskElementHovering = false
                        } label: {
                            Rectangle()
                                .foregroundStyle(.white.opacity(0.1))
                                .frame(minWidth: 266-48, idealWidth: 266-48, maxWidth: 532-48)
                                .frame(height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            isRightButtonClicked = true
                        } label: {
                            Rectangle()
                                .foregroundStyle(.blue)
                                .frame(width: 24, height: 48)
                                .offset(x: isRightButtonHovering ? 0 : 24)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            withAnimation {
                                isRightButtonHovering = proxy
                            }
                        }
                    }
                    .border(isTaskElementHovering ? .blue : .clear)
                }
            }
            .overlay {
                if isEditing {
                    TextField("Editing", text: $largeTaskElementTextField, axis: .vertical)
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
                        .onExitCommand {
                            largeTaskElementTextField = ""
                            isEditing = false
                            isTextFieldFocused = false
                        }
                }
            }
            .onHover { phase in
                if !isEditing {
                    isTaskElementHovering = phase
                }
            }
    }
}
