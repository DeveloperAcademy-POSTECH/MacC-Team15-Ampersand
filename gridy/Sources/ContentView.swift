//
//  ContentView.swift
//  gridy
//
//  Created by 제나 on 2023/09/21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            AuthenticationView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
