//
//  BlackPinkInYourAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI
import ComposableArchitecture

struct BlackPinkInYourAreaView: View {
    
    let store: StoreOf<PlanBoard>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundStyle(.white)
                    .border(.black)
                Text(viewStore.rootProject.title)
            }
        }
    }
}
