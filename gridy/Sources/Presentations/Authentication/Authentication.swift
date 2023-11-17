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
        var isShowingProjectBoard = false
        
        /// Navigation
        var optionalProjectBoard = ProjectBoard.State(user: User.mock)
    }
    
    enum Action: Equatable, Sendable {
        case onAppear
        case createEncryptedNonce
        case notYetRegistered(User, AuthCredential) // Then sign up
        case signInSuccessfully(AuthCredential)
        case fetchUser
        case fetchUserResponse(TaskResult<User?>)
        case setProcessing(Bool)
        
        /// Navigation
        case goBtnClicked(clicked: Bool)
        case optionalProjectBoard(ProjectBoard.Action)
        case setNavigation(isActive: Bool)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.optionalProjectBoard, action: /Action.optionalProjectBoard) {
            ProjectBoard()
        }
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
                
            case let .notYetRegistered(user, credential):
                return .run { send in
                    await send(.setProcessing(true))
                    try await apiClient.signUp(user, credential)
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
                state.optionalProjectBoard.user = state.authenticatedUser
                state.successToSignIn = true
                return .none
                
            case .fetchUserResponse(.failure):
                state.successToSignIn = false
                return .none
                
            case let .setProcessing(isInProcess):
                state.isProceeding = isInProcess
                return .none
                
                /// Navigation
            case .setNavigation(isActive: true):
                return .run { _ in
                    try await continuousClock.sleep(for: .seconds(1))
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                return .cancel(id: CancelID.load)
                
            case let .goBtnClicked(clicked):
                state.isShowingProjectBoard = clicked
                return .none
                
            case .optionalProjectBoard:
                return .none
            }
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
