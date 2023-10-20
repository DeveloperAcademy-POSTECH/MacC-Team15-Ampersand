//
//  ListItemView.swift
//  gridy
//
//  Created by SY AN on 10/19/23.
//

import SwiftUI
import ComposableArchitecture

struct ListItemView: View {
    // TODO: 아래의 sample 변수 다 삭제
    let unitWidth: CGFloat = 266
    let unitHeight: CGFloat = 45
    var showingLayerIndexs = [0]
    
    // 여기서부터 진짜 필요한 변수
    @FocusState var isTextFieldFocused: Bool
    @State var isHovering = false
    @State var isSelected = false
    @State var isEditing = false
    @State var editingText = ""
    var prevText = ""
    
    var body: some View {
        GeometryReader { geo in
            Rectangle()
            // TODO: width: geo, unitHeight * 내가 가진 lane 개수
                .frame(width: unitWidth / CGFloat(showingLayerIndexs.count), height: unitHeight)
                .border(isSelected ? .blue : .clear)
                .foregroundStyle(Color.clear)
                .overlay {
                    if isEditing {
                        TextField("Editing", text: $editingText, axis: .vertical )
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
                        
                        // TODO: 로이스 focus 적용
                            .focused($isTextFieldFocused)
                            .onExitCommand {
                                isEditing = false
                                isTextFieldFocused = false
                            }
                    }
                }
                .onHover { phase in
                    isHovering = phase
                }
        }
    }
}

#Preview {
    ListItemView()
}
