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
                VStack {
                    Text(viewStore.rootProject.title)
                    Text(viewStore.plans.count.description)
                    HStack {
                        TextField(
                            viewStore.keyword,
                            text: viewStore.binding(
                                get: \.keyword,
                                send: PlanBoard.Action.fetchExistingPlanTypes
                            )
                        )
                        ColorPicker(
                            "color",
                            selection: viewStore.binding(
                                get: \.selectedColorCode,
                                send: PlanBoard.Action.selectColorCode
                            )
                        )
                        Button("create new type") {
                            viewStore.send(.createPlanType)
                        }
                    }
                    ZStack {
                        VStack {
                            ForEach(viewStore.existingPlanTypesResult) { result in
                                HStack {
                                    Text(result.title)
                                    Rectangle()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color(hex: result.colorCode))
                                }
                            }
                        }
                    }
                    ForEach(viewStore.plans) { plan in
                        VStack {
                            Text(plan.id)
                            Text(plan.description)
                            Text(plan.parentID)
                            Text(plan.planTypeID)
                            Text("\(plan.startDate ?? Date())")
                            Text("\(plan.endDate ?? Date())")
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
