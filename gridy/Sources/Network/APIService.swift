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
    /// Currently authenticated user
    static var uid: String {
        get throws {
            guard let uid = Auth.auth().currentUser?.uid else { throw APIError.noAuthenticatedUser }
            return uid
        }
    }
    
    /// Base firestore path for API Service
    static var basePath: CollectionReference {
        get throws {
            let firestore = Firestore.firestore().collection("ProjectCollection")
            return firestore.document(try uid).collection("Projects")
        }
    }
    
    static let liveValue = Self(
        create: {
            let pid = try basePath.document().documentID
            let data = ["pid": pid,
                        "title": "제목 없음",
                        "ownerUid": try uid] as [String: Any]
            try basePath.document(pid).setData(data)
            
        }, readAllProjects: {
            do {
                let snapshots = try await basePath.getDocuments().documents.map { try $0.data(as: Project.self) }
                return snapshots
            } catch {
                throw APIError.noResponseResult
            }
            
        }, updateProjectTitle: { pid, newTitle in
            try basePath.document(pid).updateData(["title": newTitle])
            
        }, delete: { pid in
            try basePath.document(pid).delete()
        }
    )
}

// MARK: - test, mock
extension APIService {
    static let testValue = Self(
        create: { },
        readAllProjects: {
            [Project.mock] },
        updateProjectTitle: { _, _ in },
        delete: { _ in }
    )
    static let mockValue = Self(
        create: { },
        readAllProjects: {
            [Project.mock] },
        updateProjectTitle: { _, _ in },
        delete: { _ in }
    )
}