//
//  Authentication.swift
//  gridy
//
//  Created by 제나 on 2023/09/30.
//

import SwiftUI
import ComposableArchitecture
import CryptoKit

struct Authentication: Reducer {
    struct State: Equatable {
        @BindingState var nonce = ""
    }
    
    enum Action: Equatable, Sendable {
        case createEncrytedNonce
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .createEncrytedNonce:
            state.nonce = encryptedNonce()
            return .none
        }
    }
    
    private func encryptedNonce() -> String {
        return sha256(randomNonceString())
    }
    
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
