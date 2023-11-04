//
//  LoginView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    
    let store = Store(initialState: Authentication.State()) {
        Authentication()
            ._printChanges()
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                ZStack {
                    lottie
                    VStack(alignment: .center, spacing: 8) {
                        gridyLogo
                        version
                    }
                    .padding(.bottom, 16)
                    .padding(.top, 32)
                }
                ZStack {
                    loginBack
                    VStack(alignment: .center, spacing: 0) {
                        Text("Hello Message")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.title)
                        Text("Some Message")
                            .font(.title3)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.subtitle)
                            .padding(.bottom, 50)
                        SignInWithAppleButtonView(store: store)
                    }
                }
            }
            .frame(width: 480, height: 400)
            .shadow(
                color: .black.opacity(0.25),
                radius: 32,
                y: 16
            )
        }
    }
}

extension LoginView {
    var lottie: some View {
        Rectangle()
            .clipShape(
                .rect(
                    topLeadingRadius: 32,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 32,
                    style: .continuous
                )
            )
            .frame(height: 136)
    }
}

extension LoginView {
    var gridyLogo: some View {
        Image("gridy-logo")
            .resizable()
            .scaledToFit()
            .frame(width: 120)
            .shadow(
                color: .black.opacity(0.25),
                radius: 8,
                y: 2
            )
    }
}

extension LoginView {
    var version: some View {
        Text("Pre-release")
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(Color.subtitle)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.item)
            .cornerRadius(8)
    }
}

extension LoginView {
    var loginBack: some View {
        Rectangle()
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 32,
                    bottomTrailingRadius: 32,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )
    }
}

#Preview {
    LoginView()
}
