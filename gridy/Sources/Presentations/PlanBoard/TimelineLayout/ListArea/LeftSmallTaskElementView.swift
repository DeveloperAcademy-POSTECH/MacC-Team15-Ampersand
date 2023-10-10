//
//  LeftSmallTaskElementView.swift
//  gridy
//
//  Created by xnoag on 10/9/23.
//

import SwiftUI

struct LeftSmallTaskElementView: View {
    @State private var isTaskElementHovering = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isEditing = false
    
    @Binding var leftSmallTaskTuple: (Int, String)
    
    var body: some View {
        Rectangle()
            .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
            .frame(height: 48 * CGFloat(leftSmallTaskTuple.0))
            .foregroundStyle(.white)
            .border(.gray, width: 0.5)
            .overlay {
                if !isEditing {
                    Text(leftSmallTaskTuple.1)
                        .lineLimit(2 * leftSmallTaskTuple.0)
                        .foregroundStyle(.black)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .padding(.horizontal, 8)
                }
            }
            .overlay {
                if isTaskElementHovering && leftSmallTaskTuple.1.isEmpty {
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
                } else if isTaskElementHovering && !leftSmallTaskTuple.1.isEmpty {
                    Button(action: {
                        isEditing = true
                        isTextFieldFocused = true
                        isTaskElementHovering = false
                    }) {
                        Rectangle()
                            .foregroundStyle(.white.opacity(0.1))
                            .frame(minWidth: 133, idealWidth: 133, maxWidth: 266)
                            .frame(height: 48 * CGFloat(leftSmallTaskTuple.0))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .border(isTaskElementHovering ? .blue : .clear)
                }
            }
            .overlay {
                if isEditing {
                    TextField("Editing", text: $leftSmallTaskTuple.1, axis: .vertical)
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
                            leftSmallTaskTuple.1 = ""
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
