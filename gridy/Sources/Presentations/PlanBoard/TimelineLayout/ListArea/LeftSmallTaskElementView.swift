//
//  LeftSmallTaskElementView.swift
//  gridy
//
//  Created by xnoag on 10/9/23.
//

import SwiftUI

struct LeftSmallTaskElementView: View {
    @State private var isTaskElementHovering = false
    @State private var isPressedReturnKey = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var leftSmallTaskElementTextField = ""
    @State private var isEditing = false
    @Binding var numbersOfGroupCell: Int
    
    var body: some View {
        var leftSmallTaskElementText: String {
            if isPressedReturnKey {
                return leftSmallTaskElementTextField
            } else {
                return ""
            }
        }
        
        Rectangle()
            .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
            .frame(height: 48 * CGFloat(numbersOfGroupCell))
            .foregroundStyle(.white)
            .border(.gray, width: 0.2)
            .overlay {
                if !isEditing {
                    Text(leftSmallTaskElementText)
                        .lineLimit(2 * numbersOfGroupCell)
                        .foregroundStyle(.black)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .padding(.horizontal, 8)
                }
            }
            .overlay {
                if isTaskElementHovering && leftSmallTaskElementText.isEmpty {
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
                } else if isTaskElementHovering && !leftSmallTaskElementText.isEmpty {
                        Button(action: {
                            isEditing = true
                            isTextFieldFocused = true
                            isTaskElementHovering = false
                        }) {
                            Rectangle()
                                .foregroundStyle(.white.opacity(0.1))
                                .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
                                .frame(height: 48 * CGFloat(numbersOfGroupCell))
                        }
                        .buttonStyle(PlainButtonStyle())
                    .border(isTaskElementHovering ? .blue : .clear)
                }
            }
            .overlay {
                if isEditing {
                    TextField("Editing", text: $leftSmallTaskElementTextField, onCommit: {
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
                        leftSmallTaskElementTextField = ""
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
    LeftSmallTaskElementView(numbersOfGroupCell: .constant(2))
}
