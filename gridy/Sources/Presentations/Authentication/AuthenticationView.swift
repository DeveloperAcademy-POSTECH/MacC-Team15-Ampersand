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
            VStack {
                Text("gridy")
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewStore.nonce
                } onCompletion: { result in
                    switch result {
                    case let .success(authorization):
                        switch authorization.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            let userIdentifier = appleIDCredential.user
                            let email = appleIDCredential.email
                            let fullName = appleIDCredential.fullName
                            
                            guard let appleIDToken = appleIDCredential.identityToken else {
                                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                            }
                            guard let idTokenToString = String(data: appleIDToken, encoding: .utf8) else {
                                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                return
                            }
                            
                            let credential = OAuthProvider.credential(
                                withProviderID: "apple.com",
                                idToken: idTokenToString,
                                rawNonce: viewStore.nonce)
                            
                            guard appleIDCredential.email != nil else {
                                print("Already Signed in")
                                // TODO: - Store Action when sign up
                                return
                            }
                            
                            // TODO: Store Action when sign in
                            
                        default:
                            break
                        }
                    case let .failure(error):
                        print("\(error.localizedDescription)")
                    }
                }
                .frame(width: 280, height: 60, alignment: .center)
                .onAppear {
                    viewStore.send(.createEncrytedNonce)
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
