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
                Color.black.opacity(0.4)
                Text("hi this is planboard")
            }
        }
    }
}

#Preview {
    PlanBoardView(store: Store(initialState: PlanBoard.State(), reducer: { PlanBoard() }))
}
