//
//  ContentView.swift
//  gridy
//
//  Created by 제나 on 2023/09/21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store = Store(initialState: Authentication.State()) {
        Authentication()
            ._printChanges()
    }
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.successToSignIn {
                    Text("\(viewStore.authenticatedUser.username), Do gridy!")
                } else {
                    AuthenticationView(store: store)
                }
                if viewStore.isProceeding {
                    Color.black.opacity(0.7)
                    ProgressView()
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
