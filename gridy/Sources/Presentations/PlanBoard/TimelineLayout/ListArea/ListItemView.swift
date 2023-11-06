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
    
    let fontSize: CGFloat = 14
    
    /// 호버, 클릭, 더블 클릭을 트래킹하는 변수들.
    @FocusState var isTextFieldFocused: Bool
    @State var isHovering = false
    @State var isSelected = false
    @State var isEditing = false
    @State var editingText =  ""
    @State var prevText = ""
    
    var layerIndex: Int
    var rowIndex: Int
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                // MARK: - 초기 상태.
                /// 빈 Text를 보여준다.  클릭, 더블클릭이 가능하고 호버링이 되면 배경이 회색으로 변경된다.
                if !isSelected && !isEditing {
                    Rectangle()
                        .foregroundStyle(isHovering ? Color.gray.opacity(0.2) : Color.clear)
                        .overlay(
                            Text(editingText)
                                .onAppear {
                                    if let plan = viewStore.existingAllPlans[viewStore.map[String(layerIndex)]![rowIndex]],
                                       let planTypeID = plan.planTypeID,
                                       let planType = viewStore.existingPlanTypes[planTypeID] {
                                        let title = planType.title
                                        editingText = title
                                    } else {
                                        // TODO: - 옵셔널 분기 없어야함. map에 있는 ID로 existingAllPlans에 접근하면 무조건 있어야 함.
                                        editingText = viewStore.map[String(layerIndex)]![rowIndex]
                                    }
                                }
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
                }
                
                // MARK: - 한 번 클릭 된 상태.
                /// 호버링 상태를 추적하지 않는다. 흰 배경에 보더만 파란 상태. 더블 클릭이 가능하다.
                if isSelected {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.white)
                        Rectangle()
                            .strokeBorder(Color.blue)
                            .overlay(
                                Text(editingText)
                                    .lineLimit(2)
                                    .font(.custom("Pretendard-Regular", size: fontSize))
                                    .padding(.horizontal, 8)
                            )
                    }
                    .onTapGesture(count: 2) {
                        isSelected = false
                        isEditing = true
                        isTextFieldFocused = true
                        prevText = editingText
                    }
                    .contextMenu {
                        Button {
                            // TODO: - createPlan, 인자 true
                        } label: {
                            Text("Add a lane above")
                        }
                        
                        Button {
                            // TODO: - createPlan, 인자 false
                        } label: {
                            Text("Add a lane below")
                        }
                    }
                }
                
                // MARK: - 더블 클릭 된 상태.
                /// 호버링 상태를 추적하지 않는다. 텍스트 필드가 활성화 된다. 엔터를 누르면 텍스트가 변경되고, esc를 누르면 이전 text를 보여주는 초기 상태로 돌아간다.
                if isEditing {
                    Rectangle()
                        .strokeBorder(Color.blue)
                        .overlay {
                            TextField("Editing", text: $editingText, axis: .vertical )
                                .onSubmit {
                                    isEditing = false
                                    isTextFieldFocused = false
                                    // TODO: - PlanType Title Change
                                }
                                .multilineTextAlignment(.center)
                                .font(.custom("Pretendard-Medium", size: fontSize))
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 1)
                                .padding(.vertical, 2)
                            // TODO: - 로이스 focus 적용
                                .focused($isTextFieldFocused)
                                .onExitCommand {
                                    editingText = prevText
                                    isEditing = false
                                    isTextFieldFocused = false
                                }
                        }
                }
            }
            // TODO: - unitHeight * 내가 가진 lane 개수
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
