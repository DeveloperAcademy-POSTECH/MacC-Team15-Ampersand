//
//  ContentView.swift
//  gridy
//
//  Created by 제나 on 2023/09/21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let windowManager: WindowManager
    let store = Store(initialState: Authentication.State()) {
        Authentication()
            ._printChanges()
    }
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if !viewStore.isShowingProjectBoard {
                    ZStack {
                        SplashView()
                        AuthenticationView(store: store)
                    }
                } else {
                    ProjectBoardView(
                        store: store.scope(
                            state: \.optionalProjectBoard,
                            action: { .optionalProjectBoard($0) }
                        ),
                        windowManager: windowManager
                    )
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let windowManager = WindowManager()
        ContentView(windowManager: windowManager)
    }
}
