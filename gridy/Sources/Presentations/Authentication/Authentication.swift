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
    @Dependency(\.continuousClock) var continuousClock
    
    private enum CancelID { case load }
    
    struct State: Equatable {
        var rawNonce = ""
        var encryptedNonce = ""
        var successToSignIn = false
        var authenticatedUser = User.mock
        var isProceeding = false
        
        /// Navigation
        var isNavigationActive = false
        var optionalProjectBoard: ProjectBoard.State?
    }
    
    enum Action: Equatable, Sendable {
        case onAppear
        case createEncryptedNonce
        case notYetRegistered(String, String, AuthCredential) // Then sign up
        case signInSuccessfully(AuthCredential)
        case fetchUser
        case fetchUserResponse(TaskResult<User?>)
        case setProcessing(Bool)
        
        /// Navigation
        case optionalProjectBoard(ProjectBoard.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.fetchUser)
                    await send(.createEncryptedNonce)
                }
                
            case .createEncryptedNonce:
                if !state.successToSignIn {
                    state.rawNonce = randomNonceString()
                    state.encryptedNonce = sha256(state.rawNonce)
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
                return .run { send in
                    await send(.setNavigation(isActive: true))
                }
                
            case .fetchUserResponse(.failure):
                state.successToSignIn = false
                return .none
                
            case let .setProcessing(isInProcess):
                state.isProceeding = isInProcess
                return .none
                
                /// Navigation
            case .setNavigation(isActive: true):
                state.isNavigationActive = true
                return .run { send in
                    try await continuousClock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.isNavigationActive = false
                state.optionalProjectBoard = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationIsActiveDelayCompleted:
                state.optionalProjectBoard = ProjectBoard.State()
                return .none
                
            case .optionalProjectBoard:
                return .none
            }
        }
        .ifLet(
            \.optionalProjectBoard,
             action: /Action.optionalProjectBoard
        ) {
            ProjectBoard()
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
