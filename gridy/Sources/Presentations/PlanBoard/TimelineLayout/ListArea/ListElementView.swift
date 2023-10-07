//
//  ListElementView.swift
//  gridy
//
//  Created by xnoag on 10/5/23.
//

import SwiftUI

struct ListElementView: View {
    @State private var isHovering = false
    @State private var isEditing = false
    @State private var listElementText = ""
    @State private var isEnterShorCut = false
    @State private var isLeftButtonOpening = false
    @State private var isRightButtonOpening = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.white)
            .border(Color.gray, width: 0.3)
            .overlay {
                if isEnterShorCut {
                    Text(listElementText)
                        .foregroundStyle(.black)
                        .font(.custom("Pretendard-Regular", size: 16))
                        .padding(.horizontal, 8)
                }
            }
            .overlay {
                if isHovering && listElementText.isEmpty {
                    Button(action: {
                        isEditing = true
                        isHovering = false
                        isTextFieldFocused = true
                        isEnterShorCut = false
                    }) {
                        Rectangle()
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .cornerRadius(6)
                            .frame(width: 264, height: 44)
                            .overlay {
                                Text("Add a new Task")
                                    .foregroundStyle(.gray)
                                    .font(.custom("Pretendard-Bold", size: 16))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if isHovering && !listElementText.isEmpty {
                    HStack(spacing: 0) {
                        Button(action: {}) {
                            Rectangle()
                                .foregroundStyle(isLeftButtonOpening ? .red : .clear)
                                .frame(width: 24, height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isLeftButtonOpening = proxy
                        }
                        Button(action: {
                            isEditing = true
                            isHovering = false
                            isTextFieldFocused = true
                            isEnterShorCut = false
                        }) {
                            Rectangle()
                                .foregroundColor(.white.opacity(0.1))
                                .frame(width: 216, height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {}) {
                            Rectangle()
                                .foregroundStyle(isRightButtonOpening ? .blue : .clear)
                                .frame(width: 24, height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isRightButtonOpening = proxy
                        }
                    }
                    .border(isHovering && !isLeftButtonOpening && !isRightButtonOpening ? .blue : .clear)
                } else if isEditing {
                    TextField("", text: $listElementText, onCommit: {
                        isEditing = false
                        isTextFieldFocused = false
                        isEnterShorCut = true
                    })
                    .multilineTextAlignment(.center)
                    .font(.custom("Pretendard-Regular", size: 16))
                    .textFieldStyle(.plain)
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .frame(width: 264, height: 44)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    .focused($isTextFieldFocused)
                    .overlay {
                        if listElementText.isEmpty {
                            Text("Editing")
                                .font(.custom("Pretendard-Bold", size: 16))
                                .foregroundStyle(.gray)
                        }
                    }
                    .onExitCommand(perform: {
                        listElementText = ""
                        isEditing = false
                        isTextFieldFocused = false
                    })
                }
            }
            .onHover { phase in
                if !isEditing {
                    isHovering = phase
                }
            }
    }
}

#Preview {
    ListElementView()
}
