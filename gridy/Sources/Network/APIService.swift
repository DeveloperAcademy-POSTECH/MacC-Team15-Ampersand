//
//  APIService.swift
//  gridy
//
//  Created by 제나 on 2023/10/07.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Service CRUD
struct APIService {
    var create: () async throws -> Void
    var readAllProjects: () async throws -> [Project]
    var update: @Sendable (_ project: Project) async throws -> Void
    var delete: @Sendable (_ pid: String) async throws -> Void
    
    init(
        create: @escaping () async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        update: @escaping @Sendable (Project) async throws -> Void,
        delete: @escaping @Sendable (String) async throws -> Void
    ) {
        self.create = create
        self.readAllProjects = readAllProjects
        self.update = update
        self.delete = delete
    }
}

extension APIService {
    static let firestore = Firestore.firestore().collection("ProjectCollection")
    static let liveValue = Self(
        create: {
            guard let uid = Auth.auth().currentUser?.uid else { throw APIError.noAuthenticatedUser }
            let firestorePath = firestore.document(uid).collection("Projects")
            let pid = firestorePath.document().documentID
            let data = ["pid": pid,
                        "title": "제목 없음",
                        "ownerUid": uid] as [String: Any]
            firestorePath.document(pid).setData(data)
        }, readAllProjects: {
            guard let uid = Auth.auth().currentUser?.uid else { throw APIError.noAuthenticatedUser }
            let firestorePath = firestore.document(uid).collection("Projects")
            do {
                let snapshots = try await firestorePath.getDocuments().documents.map { try $0.data(as: Project.self) }
                return snapshots
            } catch {
                throw APIError.noResponse
            }
        }, update: { project in
            
        }, delete: { pid in
            
        }
    )
}

// MARK: - test, mock
extension APIService {
    static let testValue = Self(
        create: {
        },
        readAllProjects: {
            [Project.mock]
        },
        update: { _ in
            
        }, delete: { _ in
        }
    )
    static let mockValue = Self(
        create: {
        },
        readAllProjects: {
            [Project.mock]
        },
        update: { _ in
            
        }, delete: { _ in
        }
    )
}
