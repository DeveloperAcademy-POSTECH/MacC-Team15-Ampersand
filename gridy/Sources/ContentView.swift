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
            SplashView()
//            AuthenticationView() /// 일단 주석처리 해놨습니다.
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
