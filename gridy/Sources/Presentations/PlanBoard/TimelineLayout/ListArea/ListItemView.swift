//
//  ListItemView.swift
//  gridy
//
//  Created by SY AN on 10/19/23.
//

import SwiftUI
import ComposableArchitecture

struct ListItemView: View {
    
    let store: StoreOf<PlanBoard>
    @EnvironmentObject var viewModel: TimelineLayoutViewModel

    // TODO: 아래의 sample 변수 다 삭제
    var layerIndex: Int
    var rowIndex: Int
    let fontSize: CGFloat = 30
    
    /// 여기서부터 진짜 필요한 변수
    @FocusState var isTextFieldFocused: Bool
    @State var isHovering = false
    @State var isSelected = false
    @State var isEditing = false
    @State var editingText = ""
    @State var prevText = ""
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundStyle(isHovering ? Color.gray.opacity(0.4) : Color.clear)
                    .overlay(
                        Text(editingText)
                            .lineLimit(2)
                            .foregroundStyle(.black)
                            .font(.custom("Pretendard-Regular", size: fontSize))
                            .padding(.horizontal, 8)
                    )
                // TODO: border지우고 아래에 grid 깔기
                    .border(.gray)
                    .onHover { phase in
                        if !isSelected && !isEditing {
                            isHovering = phase
                        }
                    }
                    .onTapGesture(count: 1) {
                        isHovering = false
                        isSelected = true
                    }
                
                if isSelected {
                    Rectangle()
                        .strokeBorder(Color.blue)
                        .foregroundStyle(Color.yellow)
                        .overlay(
                            Text(editingText)
                                .lineLimit(2)
                                .foregroundStyle(.black)
                                .font(.custom("Pretendard-Regular", size: fontSize))
                                .padding(.horizontal, 8)
                        )
                        .onTapGesture(count: 2) {
                            isSelected = false
                            isEditing = true
                            isTextFieldFocused = true
                            prevText = editingText
                        }
                }
                
                if isEditing {
                    Rectangle()
                        .strokeBorder(Color.blue)
                        .foregroundStyle(Color.clear)
                        .overlay {
                            TextField("Editing", text: $editingText, axis: .vertical )
                                .disabled(true)
                                .onSubmit {
                                    isEditing = false
                                    isTextFieldFocused = false
                                }
                                .multilineTextAlignment(.center)
                                .font(.custom("Pretendard-Regular", size: fontSize))
                                .textFieldStyle(.plain)
                                .foregroundStyle(.clear)
                                .padding(.horizontal, 1)
                                .padding(.vertical, 2)
                            // TODO: 로이스 focus 적용
                                .focused($isTextFieldFocused)
                                .onExitCommand {
                                    editingText = prevText
                                    isEditing = false
                                    isTextFieldFocused = false
                                }
                        }
                }
            }
            // TODO: width: geo, unitHeight * 내가 가진 lane 개수
            .frame(height: viewModel.lineAreaGridHeight * CGFloat(viewStore.sampleMap[layerIndex][rowIndex]))
            .onAppear {
                editingText = String(viewStore.sampleMap[layerIndex][rowIndex])
            }
        }
    }
}

#Preview {
    ListItemView(
        store: Store(initialState: PlanBoard.State(rootProject: Project(id: "", title: "", ownerUid: "", createdDate: Date(), lastModifiedDate: Date(), map: ["0": [""], "1":[""], "2":[""]]))) {
            PlanBoard()
        }
    )
}
