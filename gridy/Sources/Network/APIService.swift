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
    var updateProjectTitle: @Sendable (_ id: String, _ newTitle: String) async throws -> Void
    var delete: @Sendable (_ id: String) async throws -> Void
    var readAllPlans: @Sendable (_ planIDs: [String]?) async throws -> [Plan]
    
    init(
        create: @escaping () async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        delete: @escaping @Sendable (String) async throws -> Void,
        readAllPlans: @escaping @Sendable (_ planIDs: [String]?) async throws -> [Plan]
    ) {
        self.create = create
        self.readAllProjects = readAllProjects
        self.updateProjectTitle = updateProjectTitle
        self.delete = delete
        self.readAllPlans = readAllPlans
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
    static var basePath: DocumentReference {
        get throws {
            let firestore = Firestore.firestore().collection("ProjectCollection")
            return firestore.document(try uid)
        }
    }
    
    static var projectCollectionPath: CollectionReference {
        get throws {
            return try basePath.collection("Projects")
        }
    }
    
    static var planCollectionPath: CollectionReference {
        get throws {
            return try basePath.collection("Plans")
        }
    }
    
    static let liveValue = Self(
        create: {
            let id = try projectCollectionPath.document().documentID
            let data = ["id": id,
                        "title": "제목 없음",
                        "ownerUid": try uid,
                        "createdDate": Date(),
                        "lastModifiedDate": Date()] as [String: Any]
            try projectCollectionPath.document(id).setData(data)
            
        }, readAllProjects: {
            do {
                let snapshots = try await projectCollectionPath.getDocuments().documents.map { try $0.data(as: Project.self) }.sorted(by: { $0.lastModifiedDate > $1.lastModifiedDate })
                return snapshots
            } catch {
                throw APIError.noResponseResult
            }
            
        }, updateProjectTitle: { id, newTitle in
            try projectCollectionPath.document(id).updateData(["title": newTitle])
            try projectCollectionPath.document(id).updateData(["lastModifiedDate": Date()])
            
        }, delete: { id in
            try projectCollectionPath.document(id).delete()
            
        }, readAllPlans: { planIDs in
            var results = [Plan]()
            if let planIDs = planIDs {
                for planID in planIDs {
                    let snapshot = try await planCollectionPath.document(planID).getDocument().data(as: Plan.self)
                    results.append(snapshot)
                }
            } else {
                throw APIError.noResponseResult
            }
            return results
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
        delete: { _ in },
        readAllPlans: { _ in return [Plan.mock] }
    )
    static let mockValue = Self(
        create: { },
        readAllProjects: {
            [Project.mock] },
        updateProjectTitle: { _, _ in },
        delete: { _ in },
        readAllPlans: { _ in return [Plan.mock] }
    )
}
