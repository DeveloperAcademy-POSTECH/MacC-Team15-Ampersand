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
    var updateProjectTitle: @Sendable (_ pid: String, _ newTitle: String) async throws -> Void
    var delete: @Sendable (_ pid: String) async throws -> Void
    
    init(
        create: @escaping () async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        delete: @escaping @Sendable (String) async throws -> Void
    ) {
        self.create = create
        self.readAllProjects = readAllProjects
        self.updateProjectTitle = updateProjectTitle
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
        }, updateProjectTitle: { pid, newTitle in
            guard let uid = Auth.auth().currentUser?.uid else { throw APIError.noAuthenticatedUser }
            let firestorePath = firestore.document(uid).collection("Projects").document(pid)
            firestorePath.updateData(["title": newTitle])
        }, delete: { pid in
            // TODO: - 구현
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
        updateProjectTitle: { _, title in
            
        }, delete: { _ in
        }
    )
    static let mockValue = Self(
        create: {
        },
        readAllProjects: {
            [Project.mock]
        },
        updateProjectTitle: { _, title in
            
        }, delete: { _ in
        }
    )
}
