//
//  Authentication.swift
//  gridy
//
//  Created by 제나 on 2023/09/30.
//

import SwiftUI
import ComposableArchitecture
import CryptoKit
@preconcurrency import FirebaseAuth

struct Authentication: Reducer {
    
    @Dependency(\.apiClient) var apiClient
    
    struct State: Equatable {
        var rawNonce = ""
        var encrytedNonce = ""
        var successToSignIn = false
        var authenticatedUser = User.mock
        var isProceeding = false
    }
    
    enum Action: Equatable, Sendable, BindableAction {
        case onAppear
        case createEncrytedNonce
        case notYetRegistered(String, String, AuthCredential) // Then sign up
        case signInSuccessfully(AuthCredential)
        case fetchUser
        case fetchUserResponse(TaskResult<User?>)
        case binding(BindingAction<State>)
        case setProcessing(Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .run { send in
                await send(.fetchUser)
                await send(.createEncrytedNonce)
            }
            
        case .createEncrytedNonce:
            if !state.successToSignIn {
                state.rawNonce = randomNonceString()
                state.encrytedNonce = sha256(state.rawNonce)
            }
            return .none
            
        case let .notYetRegistered(email, username, credential):
            return .run { send in
                await send(.setProcessing(true))
                try await apiClient.signUp(email, username, credential)
                await send(.fetchUser)
            }
            
        case let .signInSuccessfully(credential):
            return .run { send in
                await send(.setProcessing(true))
                try await apiClient.signIn(credential)
                await send(.fetchUser)
            }
            
        case .fetchUser:
            return .run { send in
                await send(.setProcessing(true))
                await send(.fetchUserResponse(
                    TaskResult {
                        try await apiClient.fetchUser()
                    }
                ))
                await send(.setProcessing(false))
            }
            
        case let .fetchUserResponse(.success(response)):
            state.authenticatedUser = response ?? User.mock
            state.successToSignIn = true
            return .none
            
        case .fetchUserResponse(.failure):
            state.successToSignIn = false
            return .none
            
        case .binding:
            return .none
            
        case let .setProcessing(isInProcess):
            state.isProceeding = isInProcess
            return .none
        }
    }
    
    /// Create random nonce string
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(
            kSecRandomDefault,
            randomBytes.count,
            &randomBytes
        )
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { charset[Int($0) % charset.count] }
        
        return String(nonce)
    }
    
    /// Hashing function using CryptoKit
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
