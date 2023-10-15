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
    
    /// Project
    var createProject: () async throws -> Void
    var readAllProjects: () async throws -> [Project]
    var updateProjectTitle: @Sendable (_ id: String, _ newTitle: String) async throws -> Void
    var deleteProject: @Sendable (_ id: String) async throws -> Void
    
    /// Plan Type
    var readAllPlanTypes: () async throws -> [PlanType]
    var searchPlanTypes: @Sendable (_ with: String) async throws -> [PlanType]
    var createPlanType: @Sendable (_ target: PlanType) async throws -> String
    
    /// Plan
    var createPlan: @Sendable (_ target: Plan, _ projectID: String) async throws -> Plan
    var readAllPlans: @Sendable (_ projectID: String) async throws -> [Plan]
    
    init(
        createProject: @escaping () async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        deleteProject: @escaping @Sendable (String) async throws -> Void,
        
        readAllPlanTypes: @escaping () async throws -> [PlanType],
        searchPlanTypes: @escaping @Sendable (String) async throws -> [PlanType],
        createPlanType: @escaping @Sendable (_ target: PlanType) async throws -> String,
        
        createPlan: @escaping @Sendable (Plan, String) async throws -> Plan,
        readAllPlans: @escaping @Sendable (String) async throws -> [Plan]
    ) {
        self.createProject = createProject
        self.readAllProjects = readAllProjects
        self.updateProjectTitle = updateProjectTitle
        self.deleteProject = deleteProject
        
        self.readAllPlanTypes = readAllPlanTypes
        self.searchPlanTypes = searchPlanTypes
        self.createPlanType = createPlanType
        
        self.createPlan = createPlan
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
    
    static var planTypeCollectionPath: CollectionReference {
        get throws {
            return try basePath.collection("PlanTypes")
        }
    }
    
    static let liveValue = Self(
        // MARK: - Project
        createProject: {
            let id = try projectCollectionPath.document().documentID
            let data = ["id": id,
                        "title": "제목 없음",
                        "ownerUid": try uid,
                        "createdDate": Date(),
                        "lastModifiedDate": Date(),
                        "planIDs": nil] as [String: Any?]
            try projectCollectionPath.document(id).setData(data as [String: Any])
            
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
            
        }, deleteProject: { id in
            try projectCollectionPath.document(id).delete()
            
            // MARK: - Plan type
        }, readAllPlanTypes: {
            return try await planTypeCollectionPath
                .getDocuments()
                .documents
                .map { try $0.data(as: PlanType.self) }
            
        }, searchPlanTypes: { keyword in
            do {
                return try await planTypeCollectionPath
                    .getDocuments()
                    .documents
                    .map { try $0.data(as: PlanType.self) }
                    .filter { $0.title.contains(keyword) }
            } catch {
                throw APIError.noResponseResult
            }
            
        }, createPlanType: { target in
            let id = try planTypeCollectionPath.document().documentID
            let data = ["id": id,
                        "title": target.title,
                        "colorCode": target.colorCode] as [String: Any]
            try planTypeCollectionPath.document(id).setData(data)
            return id
            
            // MARK: - Plan
        }, createPlan: { target, projectID in
            let id = try planCollectionPath.document().documentID
            let data = ["id": id,
                        "planTypeID": target.planTypeID,
                        "parentID": target.parentID,
                        "startDate": target.startDate ?? nil,
                        "endDate": target.endDate ?? nil,
                        "description": ""] as [String: Any?]
            try planCollectionPath.document(id).setData(data as [String: Any])
            try projectCollectionPath.document(projectID).updateData(["planIDs": FieldValue.arrayUnion([id])]) { _ in }
            var createdPlan = target
            createdPlan.id = id
            return createdPlan
            
        }, readAllPlans: { projectID in
            let planIDs = try await projectCollectionPath.document(projectID).getDocument().data(as: Project.self).planIDs
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
        createProject: { },
        readAllProjects: {
            [Project.mock] },
        updateProjectTitle: { _, _ in },
        deleteProject: { _ in },
        readAllPlanTypes: { [PlanType.mock] },
        searchPlanTypes: { _ in [PlanType.mock] },
        createPlanType: { _ in ""},
        createPlan: { _, _ in Plan.mock },
        readAllPlans: { _ in return [Plan.mock] }
    )
    static let mockValue = Self(
        createProject: { },
        readAllProjects: {
            [Project.mock] },
        updateProjectTitle: { _, _ in },
        deleteProject: { _ in },
        readAllPlanTypes: { [PlanType.mock] },
        searchPlanTypes: { _ in [PlanType.mock] },
        createPlanType: { _ in ""},
        createPlan: { _, _ in Plan.mock },
        readAllPlans: { _ in return [Plan.mock] }
    )
}

