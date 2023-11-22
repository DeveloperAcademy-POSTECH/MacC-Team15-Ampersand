//
//  PlanItem.swift
//  gridy
//
//  Created by 제나 on 11/22/23.
//

import ComposableArchitecture

struct PlanItem: Reducer {
    struct State: Equatable, Identifiable {
        var plan: Plan
        var id: String { plan.id }
//        var isDragging: Bool
        @BindingState var isFloating = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
}
