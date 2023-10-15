//
//  AuthenticationView.swift
//  gridy
//
//  Created by 제나 on 2023/09/29.
//

import SwiftUI
import ComposableArchitecture

struct AuthenticationView: View {
    
    let store = Store(initialState: Authentication.State()) {
        Authentication()
            ._printChanges()
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.isProceeding {
                    ProgressView()
                } else {
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 16) {
                                Image(.gridGreetingLogo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60)
                                Text("Alpha Version")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .foregroundStyle(.gray.opacity(0.5))
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundStyle(.gray.opacity(0.1))
                                    )
                            }
                            .padding(.vertical)
                            .padding(.top)
                            Spacer()
                        }
                        .background {
                            Rectangle()
                                .foregroundStyle(.gray.opacity(0.1))
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 30,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 30,
                                        style: .continuous
                                    )
                                )
                        }
                        
                        VStack(spacing: 20) {
                            Spacer()
                            Text("Glad to meet you :)")
                                .font(.title2.bold())
                                .foregroundStyle(.black)
                            if viewStore.successToSignIn {
                                Text("\(viewStore.authenticatedUser.username), Do gridy!")
                                    .font(.subheadline)
                                    .foregroundStyle(.black)
                                
                                /// Navige to Project Board View
                                NavigationLink("프로젝트 보드로 가기") {
                                    ProjectBoardView(
                                        store: store.scope(
                                            state: \.optionalProjectBoard,
                                            action: { .optionalProjectBoard($0) }
                                        )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.vertical, 10)
                                .padding(.horizontal, 50)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                Text("Some Text Message ...")
                                    .font(.callout)
                                    .foregroundStyle(.gray)
                                SignInWithAppleButtonView(store: store)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .frame(width: 350, height: 350)
            .padding(.bottom)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 24)
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
