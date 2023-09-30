//
//  gridyApp.swift
//  gridy
//
//  Created by 제나 on 2023/09/21.
//

import SwiftUI
import ComposableArchitecture

@main
struct GridyApp: App {
    static let store = Store(initialState: Authentication.State()) {
        Authentication()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
//            ContentView()
            AuthenticationView(store: GridyApp.store)
        }
    }
}
