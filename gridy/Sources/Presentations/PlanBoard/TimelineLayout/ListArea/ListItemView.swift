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

    // TODO: 아래의 sample 변수 삭제하기
    var layerIndex: Int
    var rowIndex: Int
    let fontSize: CGFloat = 30
    
    /// 여기서부터 진짜 필요한 변수.
    /// 각 뷰마다 Store를 가지게 해야 할 듯 합니다. 왜냐하면 각각의 listItemView마다 상태 체크를 해야해요.. IdentifiedArrayOf<ListItem>으로 PlanBoard Store에서 갖고있게 한 후 ForEachStore로 돌려도 괜찮을 듯 싶습니다.
    @FocusState var isTextFieldFocused: Bool
    @State var isHovering = false
    @State var isSelected = false
    @State var isEditing = false
    @State var editingText =  ""
    @State var prevText = ""
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            // TODO: - 실제 Plan 받아오기
//            let plan = viewStore.map[String(layerIndex)]![rowIndex]
            ZStack {
                // MARK: - 초기 상태.
                /// 빈 Text를 보여준다.  클릭, 더블클릭이 가능하고 호버링이 되면 배경이 회색으로 변경된다.
                Rectangle()
                    .foregroundStyle(isHovering ? Color.gray.opacity(0.2) : Color.clear)
                    .overlay(
                        Text(editingText)
                            .lineLimit(2)
                            .font(.custom("Pretendard-Regular", size: fontSize))
                            .padding(.horizontal, 8)
                    )
                    .onHover { phase in
                        if !isSelected && !isEditing {
                            isHovering = phase
                        }
                    }
                    .onTapGesture {
                        isHovering = false
                        isSelected = true
                    }
                    .highPriorityGesture(TapGesture(count: 2).onEnded({
                        isHovering = false
                        isSelected = false
                        isEditing = true
                        isTextFieldFocused = true
                        prevText = editingText
                    }))
                
                // MARK: - 한 번 클릭 된 상태.
                /// 호버링 상태를 추적하지 않는다. 흰 배경에 보더만 파란 상태. 더블 클릭이 가능하다.
                if isSelected {
                    Rectangle()
                        .strokeBorder(Color.blue)
                        .overlay(
                            Text(editingText)
                                .lineLimit(2)
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
                
                // MARK: - 더블 클릭 된 상태.
                /// 호버링 상태를 추적하지 않는다. 텍스트 필드가 활성화 된다. 엔터를 누르면 텍스트가 변경되고, esc를 누르면 이전 text를 보여주는 초기 상태로 돌아간다.
                if isEditing {
                    Rectangle()
                        .strokeBorder(Color.blue)
                        .overlay {
                            // TODO: Plan type 수정 -> 생성하는 flow
                            TextField("Editing", text: $editingText, axis: .vertical )
                                .onSubmit {
                                    isEditing = false
                                    isTextFieldFocused = false
                                }
                                .multilineTextAlignment(.center)
                                .font(.custom("Pretendard-Regular", size: fontSize))
                                .textFieldStyle(.plain)
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
            // TODO: unitHeight * 내가 가진 lane 개수
//            .frame(height: viewStore.lineAreaGridHeight * CGFloat(Int(viewStore.map[String(layerIndex)]![rowIndex])!))
            .frame(height: viewStore.lineAreaGridHeight)
        }
    }
}

#Preview {
    ListItemView(
        store: Store(initialState: PlanBoard.State(rootProject: Project.mock, map: Project.mock.map)) {
            PlanBoard()
        },
        layerIndex: 0,
        rowIndex: 0
    )
}
