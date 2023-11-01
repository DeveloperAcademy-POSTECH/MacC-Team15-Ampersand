//
//  SignInWithAppleButtonView.swift
//  gridy
//
//  Created by 제나 on 10/11/23.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import ComposableArchitecture

struct SignInWithAppleButtonView: View {
    
    let store: StoreOf<Authentication>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
                request.nonce = viewStore.encryptedNonce
            } onCompletion: { result in
                switch result {
                case let .success(authorization):
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
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 200, height: 100)
        }
    }
}

#Preview {
    SignInWithAppleButtonView(
        store: Store(initialState: Authentication.State()) {
            Authentication()
                ._printChanges()
        }
    )
}
