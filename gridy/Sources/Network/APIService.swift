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
    var deletePlanType: @Sendable (_ typeID: String) async throws -> Void
    
    /// Plan
    var createPlan: @Sendable (_ target: Plan, _ layerIndex: Int, _ indexFromLane: Int, _ projectID: String) async throws -> Plan
    var readAllPlans: @Sendable (_ projectID: String) async throws -> [[Plan]]
    var deletePlan: @Sendable (_ planID: String) async throws -> Void
    var deletePlansByParent: @Sendable (_ parentID: String) async throws -> Void
    
    init(
        createProject: @escaping () async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        deleteProject: @escaping @Sendable (String) async throws -> Void,
        
        readAllPlanTypes: @escaping () async throws -> [PlanType],
        searchPlanTypes: @escaping @Sendable (String) async throws -> [PlanType],
        createPlanType: @escaping @Sendable (_ target: PlanType) async throws -> String,
        deletePlanType: @escaping @Sendable (_ typeID: String) async throws -> Void,
        
        createPlan: @escaping @Sendable (_ target: Plan, _ layerIndex: Int, _ indexFromLane: Int, _ projectID: String) async throws -> Plan,
        readAllPlans: @escaping @Sendable (String) async throws -> [[Plan]],
        deletePlan: @escaping @Sendable (_ typeID: String) async throws -> Void,
        deletePlansByParent: @escaping @Sendable (_ parentID: String) async throws -> Void
    ) {
        self.createProject = createProject
        self.readAllProjects = readAllProjects
        self.updateProjectTitle = updateProjectTitle
        self.deleteProject = deleteProject
        
        self.readAllPlanTypes = readAllPlanTypes
        self.searchPlanTypes = searchPlanTypes
        self.createPlanType = createPlanType
        self.deletePlanType = deletePlanType
        
        self.createPlan = createPlan
        self.readAllPlans = readAllPlans
        self.deletePlan = deletePlan
        self.deletePlansByParent = deletePlansByParent
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
                        "title": "제목없음",
                        "ownerUid": try uid,
                        "createdDate": Date(),
                        "lastModifiedDate": Date(),
                        "planIDs": nil] as [String: Any?]
            try projectCollectionPath.document(id).setData(data as [String: Any])
            
        },
        readAllProjects: {
            do {
                let snapshots = try await projectCollectionPath.getDocuments().documents.map { try $0.data(as: Project.self) }.sorted(by: { $0.lastModifiedDate > $1.lastModifiedDate })
                return snapshots
            } catch {
                throw APIError.noResponseResult
            }
            
        },
        updateProjectTitle: { id, newTitle in
            try projectCollectionPath.document(id).updateData(["title": newTitle])
            try projectCollectionPath.document(id).updateData(["lastModifiedDate": Date()])
            
        },
        deleteProject: { id in
            try projectCollectionPath.document(id).delete()
            
        },
        
        // MARK: - Plan type
        readAllPlanTypes: {
            return try await planTypeCollectionPath
                .getDocuments()
                .documents
                .map { try $0.data(as: PlanType.self) }
            
        },
        searchPlanTypes: { keyword in
            do {
                return try await planTypeCollectionPath
                    .getDocuments()
                    .documents
                    .map { try $0.data(as: PlanType.self) }
                    .filter { $0.title.contains(keyword) }
            } catch {
                throw APIError.noResponseResult
            }
            
        },
        createPlanType: { target in
            let id = try planTypeCollectionPath.document().documentID
            let data = ["id": id,
                        "title": target.title,
                        "colorCode": target.colorCode] as [String: Any]
            try planTypeCollectionPath.document(id).setData(data)
            return id
            
        },
        deletePlanType: { typeID in
            try planTypeCollectionPath.document(typeID).delete()
        },
        
        // MARK: - Plan
        createPlan: { target, layerIndex, indexFromLane, projectID in
            let data = ["id": target.id,
                        "planTypeID": target.planTypeID,
                        "parentID": target.parentID,
                        "periods": target.periods,
                        "description": target.description,
                        "laneIDs": target.laneIDs] as [String: Any?]
            try await planCollectionPath.document(target.id).setData(data as [String: Any])
            
            if let parentID = target.parentID {
                var newLaneIDs = try await planCollectionPath.document(parentID).getDocument(as: Plan.self).laneIDs
                if var newLaneIDs = newLaneIDs {
                    newLaneIDs.insert(target.id, at: indexFromLane)
                    try await planCollectionPath.document(parentID).setData(["laneIDs": newLaneIDs])
                }
                
                var newPlanIDs = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).planIDs
                if var newPlanIDs = newPlanIDs {
                    newPlanIDs[layerIndex].insert(target.id, at: indexFromLane)
                    try await projectCollectionPath.document(projectID).setData(["planIDs": newPlanIDs])
                }
            }
            return target
        },
        readAllPlans: { projectID in
            let planLayers = try await projectCollectionPath.document(projectID).getDocument().data(as: Project.self).planIDs
            var results = [[Plan]]()
            if let planLayers = planLayers {
                for layer in planLayers {
                    var layerResults = [Plan]()
                    for planID in layer {
                        let snapshot = try await planCollectionPath.document(planID).getDocument().data(as: Plan.self)
                        layerResults.append(snapshot)
                    }
                    results.append(layerResults)
                }
            } else {
                throw APIError.noResponseResult
            }
            return results
        }, deletePlan: { planID in
            try planCollectionPath.document(planID).updateData(["laneIDs": []])
            try planCollectionPath.document(planID).updateData(["periods": [[]]])
            
        }, deletePlansByParent: { planID in
            // TODO: -
            let laneIDs = try await planCollectionPath.document(planID).getDocument().data(as: Plan.self).laneIDs
            if let laneIDs = laneIDs {
                try laneIDs.forEach { laneID in
                    //                    try planCollectionPath.document(laneID).delete()
                }
            }
            //            try await planCollectionPath.document(planID).delete()
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
        deletePlanType: { _ in },
        createPlan: { _, _, _, _ in Plan.mock },
        readAllPlans: { _ in return [[Plan.mock]] },
        deletePlan: { _ in },
        deletePlansByParent: { _ in }
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
        deletePlanType: { _ in },
        createPlan: { _, _, _, _ in  Plan.mock },
        readAllPlans: { _ in return [[Plan.mock]] },
        deletePlan: { _ in },
        deletePlansByParent: { _ in }
    )
}

