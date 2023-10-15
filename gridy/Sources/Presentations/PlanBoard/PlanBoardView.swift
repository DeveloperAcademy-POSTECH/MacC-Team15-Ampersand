//
//  PlanBoardView.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import SwiftUI
import ComposableArchitecture

struct PlanBoardView: View {
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack {
                        Text(viewStore.rootProject.title)
                        Text(viewStore.plans.count.description)
                        HStack {
                            TextField(
                                viewStore.keyword,
                                text: viewStore.binding(
                                    get: \.keyword,
                                    send: PlanBoard.Action.searchExistingPlanTypes
                                )
                            )
                            ColorPicker(
                                "",
                                selection: viewStore.binding(
                                    get: \.selectedColorCode,
                                    send: PlanBoard.Action.selectColorCode
                                )
                            )
                            Button("create new plan with new type") {
                                viewStore.send(.createPlanType(parentID: "", description: ""))
                            }
                        }
                        ZStack {
                            VStack {
                                ForEach(viewStore.searchPlanTypesResult) { result in
                                    Button {
                                        // TODO: - layer 위치 파악에서 parent id 찾아야 함
                                        // TODO: - description은 어디서 어떻게 보이는건지 확인, right tool bar에서만 보이는지? 피그마상 플랜보드에는 보이지 않음
                                        viewStore.send(.createPlan(
                                            selectedPlanTypeID: result.id,
                                            parentID: "",
                                            description: "")
                                        )
                                    } label: {
                                        HStack {
                                            Text(result.title)
                                            Rectangle()
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(Color(hex: result.colorCode))
                                        }
                                    }
                                }
                            }
                        }
                        HStack {
                            Text("PLAN 데이터")
                                .font(.headline)
                            Spacer()
                            Text("TYPE 데이터")
                                .font(.headline)
                        }
                        .frame(width: 500)
                        .padding()
                        ForEach(viewStore.plans) { plan in
                            HStack(spacing: 250) {
                                VStack {
                                    Text(plan.id)
                                    Text(plan.description)
                                    Text(plan.parentID)
                                    Text(plan.planTypeID)
                                    Text("\(plan.startDate ?? Date())")
                                    Text("\(plan.endDate ?? Date())")
                                }
                                VStack {
                                    if let typeData = viewStore.existingPlanTypes[plan.planTypeID] {
                                        Text(typeData.id)
                                        Text(typeData.title)
                                        Rectangle()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(Color(hex: typeData.colorCode))

                                    } else {
                                        Text("데이터 로딩 실패")
                                    }
                                }
                            }
                            .padding()
                            .frame(width: 800)
                            .border(.gray)
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

#Preview {
    PlanBoardView(
        store: Store(
            initialState: PlanBoard.State(rootProject: Project.mock),
            reducer: { PlanBoard() }
        )
    )
}
