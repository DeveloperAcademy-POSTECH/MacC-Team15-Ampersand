//
//  AuthenticationView.swift
//  gridy
//
//  Created by 제나 on 2023/09/29.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import ComposableArchitecture

struct AuthenticationView: View {
    
    let store: StoreOf<Authentication>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("Glad to meet you :)")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                    Text("Some Text Message ...")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewStore.encrytedNonce
                } onCompletion: { result in
                    switch result {
                    case let .success(authorization):
                        // TODO: completion handler도 Reducer에서 처리해야 할까요? -ZEN
                        switch authorization.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            guard let appleIDToken = appleIDCredential.identityToken else { return }
                            guard let idTokenToString = String(data: appleIDToken, encoding: .utf8) else { return }
                            
                            let credential = OAuthProvider.credential(
                                withProviderID: "apple.com",
                                idToken: idTokenToString,
                                rawNonce: viewStore.rawNonce
                            )
                            
                            guard let email = appleIDCredential.email else {
                                /// Already signed up
                                viewStore.send(.signInSuccessfully(credential))
                                return
                            }
                            
                            /// Not yet signed up
                            let fullName = appleIDCredential.fullName
                            let username = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")"
                            viewStore.send(.notYetRegistered(email, username, credential))
                        default:
                            break
                        }
                    case let .failure(error):
                        print("\(error.localizedDescription)")
                    }
                }
                .frame(width: 220)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(store: Store(initialState: Authentication.State(), reducer: {
            Authentication()
        }))
    }
}
