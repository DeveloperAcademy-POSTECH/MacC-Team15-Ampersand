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
    var fetchUser: () async throws -> User
    var signIn: @Sendable (_ credential: AuthCredential) async throws -> Void
    var signUp: @Sendable (
        _ user: User,
        _ crendential: AuthCredential
    ) async throws -> Void
    var signOut: () async throws -> Void
    var updateJob: (_ job: String) async throws -> Void
    var updateProfileImage: @Sendable (NSImage) async throws -> String
    
    init(
        fetchUser: @escaping () async throws -> User,
        signIn: @escaping @Sendable (AuthCredential) async throws -> Void,
        signUp: @escaping @Sendable (User, AuthCredential) async throws -> Void,
        signOut: @escaping () async throws -> Void,
        updateJob: @escaping (_ job: String) async throws -> Void,
        updateProfileImage: @escaping @Sendable (NSImage) async throws -> String
    ) {
        self.fetchUser = fetchUser
        self.signIn = signIn
        self.signUp = signUp
        self.signOut = signOut
        
        self.updateJob = updateJob
        self.updateProfileImage = updateProfileImage
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
            let data = try JSONSerialization.data(withJSONObject: result.data() as Any)
            let decoded = try JSONDecoder().decode(User.self, from: data)
            return decoded
        },
        
        signIn: { credential in
            do {
                _ = try await Auth.auth().signIn(with: credential)
            } catch {
                print("=== catch \(error)")
            }
        },
        
        signUp: { user, credential in
            do {
                let result = try await Auth.auth().signIn(with: credential)
                let data = [
                    "uid": result.user.uid,
                    "email": user.email,
                    "firstName": user.firstName,
                    "lastName": user.lastName
                ] as [String: Any]
                Task {
                    _ = try await APIClient.clientCollection.document(result.user.uid).setData(data)
                }
            } catch {
                print("=== catch \(error)")
            }
        },
        
        signOut: {
            try Auth.auth().signOut()
        },
        
        updateJob: { job in
            if let uid = Auth.auth().currentUser?.uid {
                try await APIClient.clientCollection.document(uid).updateData(["job": job])
            }
        },
        
        updateProfileImage: { nsImage in
            if let uid = Auth.auth().currentUser?.uid {
                let profileImageURL = await ImageUploader.uploadImage(uid: uid, image: nsImage)
                try await APIClient.clientCollection.document(uid).updateData(["profileImageURL": profileImageURL])
                return profileImageURL
            }
            return "⛔️ Upload ERROR"
        }
    )
}

// MARK: - test, mock
extension APIClient {
    static let testValue = Self(
        fetchUser: {
            User.mock
        }, signIn: { _ in
        }, signUp: { _, _ in
        }, signOut: {},
        updateJob: { _ in },
        updateProfileImage: { _ in "" }
    )
    static let mockValue = Self(
        fetchUser: {
            User.mock
        }, signIn: { _ in
        }, signUp: { _, _ in
        }, signOut: {},
        updateJob: { _ in },
        updateProfileImage: { _ in "" }
    )
}
