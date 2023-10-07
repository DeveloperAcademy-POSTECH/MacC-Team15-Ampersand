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
                if isHovering {
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
                                if listElementText == "" {
                                    Text("Add a new Task")
                                        .foregroundStyle(.gray)
                                        .font(.custom("Pretendard-Bold", size: 16))
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
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
