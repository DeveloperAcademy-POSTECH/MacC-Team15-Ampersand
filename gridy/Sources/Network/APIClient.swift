//
//  APIClient.swift
//  gridy
//
//  Created by 제나 on 2023/10/01.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseAuthCombineSwift
import ComposableArchitecture

/// Client
struct APIClient {
    var fetchUser: () async throws -> User?
    var signIn: @Sendable (_ credential: AuthCredential) async throws -> Void
    var signUp: @Sendable (
        _ email: String,
        _ username: String,
        _ crendential: AuthCredential
    ) async throws -> Void
    var signOut: () async throws -> Void
    
    init(
        fetchUser: @escaping () async throws -> User?,
        signIn: @escaping @Sendable (AuthCredential) async throws -> Void,
        signUp: @escaping @Sendable (String, String, AuthCredential) async throws -> Void,
        signOut: @escaping () async throws -> Void
    ) {
        self.fetchUser = fetchUser
        self.signIn = signIn
        self.signUp = signUp
        self.signOut = signOut
    }
}

// MARK: - live
extension APIClient {
    static let clientCollectionPath = "ClientCollection"
    static let clientCollection = Firestore.firestore().collection(APIClient.clientCollectionPath)
    
    static let liveValue = Self(
        fetchUser: {
            let currentUser = Auth.auth().currentUser
            guard let currentUser = currentUser else { throw APIError.noResponseResult }
            let result = try await APIClient.clientCollection.document(currentUser.uid).getDocument()
            let data = try? JSONSerialization.data(withJSONObject: result.data() as Any)
            let decoded = try? JSONDecoder().decode(User.self, from: data!)
            return decoded
        },
        
        signIn: { credential in
            do {
                _ = try await Auth.auth().signIn(with: credential)
            } catch {
                print("=== catch \(error)")
            }
        },
        
        signUp: { email, username, credential in
            do {
                let result = try await Auth.auth().signIn(with: credential)
                let data = ["uid": result.user.uid,
                            "username": username,
                            "email": email] as [String: Any]
                Task {
                    _ = try await APIClient.clientCollection.document(result.user.uid).setData(data)
                }
            } catch {
                print("=== catch \(error)")
            }
        },
        
        signOut: {
            try Auth.auth().signOut()
        }
    )
}

// MARK: - test, mock
extension APIClient {
    static let testValue = Self(
        fetchUser: {
            return User.mock
        }, signIn: { _ in
        }, signUp: { _, _, _ in
        }, signOut: {}
    )
    static let mockValue = Self(
        fetchUser: {
            return nil
        }, signIn: { _ in
        }, signUp: { _, _, _ in
        }, signOut: {}
    )
}
