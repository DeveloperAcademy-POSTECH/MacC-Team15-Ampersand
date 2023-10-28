//
//  LayerControlAreaView.swift
//  gridy
//
//  Created by SY AN on 10/28/23.
//

import SwiftUI
import ComposableArchitecture

struct LayerControlAreaView: View {
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        Rectangle()
    }
}

#Preview {
    LayerControlAreaView(store: Store(initialState: PlanBoard.State(rootProject: Project.mock), reducer: { PlanBoard() }))
}
