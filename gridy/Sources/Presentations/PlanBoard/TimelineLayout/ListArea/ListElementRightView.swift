//
//  ListElementRightView.swift
//  gridy
//
//  Created by xnoag on 10/8/23.
//

import SwiftUI

struct ListElementRightView: View {
    @State private var isHovering = false
    @State private var isEditing = false
    @State private var listElementText = ""
    @State private var isEnterShorCut = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isTopButtonOpening = false
    @State private var isBottomButtonOpening = false
    @State private var isTopButtonClicking = false
    @State private var isBottomButtonClicking = false
    
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
                            .foregroundStyle(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                            .frame(width: 132, height: 44)
                            .overlay {
                                Text("New Task")
                                    .foregroundStyle(.gray)
                                    .font(.custom("Pretendard-Regular", size: 16))
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if isHovering && !listElementText.isEmpty {
                    VStack(spacing: 0) {
                        Button(action: {
                            isTopButtonClicking = true
                        }) {
                            Rectangle()
                                .foregroundStyle(isTopButtonOpening ? .pink : .clear)
                                .frame(width: 132, height: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isTopButtonOpening = proxy
                        }
                        Button(action: {
                            isEditing = true
                            isHovering = false
                            isTextFieldFocused = true
                            isEnterShorCut = false
                        }) {
                            Rectangle()
                                .foregroundColor(.white.opacity(0.1))
                                .frame(width: 132, height: 32)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {
                            isBottomButtonClicking = true
                        }) {
                            Rectangle()
                                .foregroundStyle(isBottomButtonOpening ? .pink : .clear)
                                .frame(width: 132, height: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { proxy in
                            isBottomButtonOpening = proxy
                        }
                    }
                    .border(isHovering && !isTopButtonOpening && !isBottomButtonOpening ? .blue : .clear)
                }else if isEditing {
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
                    .frame(width: 132, height: 44)
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
    ListElementRightView()
}
