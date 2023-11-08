//
//  AuthenticationView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct AuthenticationView: View {
    
    let store: StoreOf<Authentication>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                ZStack {
                    lottie
                    VStack(alignment: .center, spacing: 8) {
                        gridyLogo
                        version
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 16)
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
                        if viewStore.successToSignIn {
                            Button("프로젝트 보드로 가기") {
                                viewStore.send(.goBtnClicked(clicked: true))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 392, height: 60)
                            .clipShape(
                                .rect(cornerRadius: 60)
                            )
                        } else {
                            SignInWithAppleButtonView(store: store)
                        }
                    }
                }
            }
            .frame(width: 480, height: 400)
            .shadow(
                color: .black.opacity(0.25),
                radius: 32,
                y: 16
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension AuthenticationView {
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

extension AuthenticationView {
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

extension AuthenticationView {
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

extension AuthenticationView {
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
    AuthenticationView(store: Store(initialState: Authentication.State()) {
        Authentication()
    })
}
