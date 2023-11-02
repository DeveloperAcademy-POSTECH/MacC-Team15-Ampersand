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
    var createProject: (String) async throws -> Void
    var readAllProjects: () async throws -> [Project]
    var updateProjectTitle: @Sendable (String, String) async throws -> Void
    var deleteProject: @Sendable (String) async throws -> Void
    
    /// Plan Type
    var readAllPlanTypes: (String) async throws -> [PlanType]
    var createPlanType: @Sendable (PlanType, String, String) async throws -> Void
    var deletePlanType: @Sendable (String, String) async throws -> Void
    
    /// Plan
    var createPlanOnListArea: @Sendable ([Plan], Int, String) async throws -> Void
    var createPlanOnLineArea: @Sendable (Plan, Plan, String) async throws -> Void
    var readAllPlans: @Sendable (String) async throws -> [String: Plan]
    var updatePlanType: @Sendable (String, String, String) async throws -> Void
    var updatePlanPeriods: @Sendable (Plan, String) async throws -> Void
    var deletePlan: @Sendable (String, Int, Bool, String) async throws -> Void
    
    /// Layer
    var createLayer: @Sendable ([Plan], [Plan], String) async throws -> Void
    
    init(
        createProject: @escaping (String) async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        deleteProject: @escaping @Sendable (String) async throws -> Void,
        
        readAllPlanTypes: @escaping (String) async throws -> [PlanType],
        createPlanType: @escaping @Sendable (PlanType, String, String) async throws -> Void,
        deletePlanType: @escaping @Sendable (String, String) async throws -> Void,
        
        createPlanOnListArea: @escaping @Sendable ([Plan], Int, String) async throws -> Void,
        createPlanOnLineArea: @escaping @Sendable (Plan, Plan, String) async throws -> Void,
        readAllPlans: @escaping @Sendable (String) async throws -> [String: Plan],
        updatePlanType: @escaping @Sendable (String, String, String)  async throws -> Void,
        updatePlanPeriods: @escaping @Sendable (Plan, String) async throws -> Void,
        deletePlan: @escaping @Sendable (String, Int, Bool, String) async throws -> Void,
        
        createLayer: @escaping @Sendable ([Plan], [Plan], String) async throws -> Void
    ) {
        self.createProject = createProject
        self.readAllProjects = readAllProjects
        self.updateProjectTitle = updateProjectTitle
        self.deleteProject = deleteProject
        
        self.readAllPlanTypes = readAllPlanTypes
        self.createPlanType = createPlanType
        self.deletePlanType = deletePlanType
        
        self.createPlanOnListArea = createPlanOnListArea
        self.createPlanOnLineArea = createPlanOnLineArea
        self.readAllPlans = readAllPlans
        self.updatePlanType = updatePlanType
        self.updatePlanPeriods = updatePlanPeriods
        self.deletePlan = deletePlan
        
        self.createLayer = createLayer
    }
}

extension APIService {
    static let liveValue = Self(
        // MARK: - Project
        createProject: { title in
            let id = try FirestoreService.projectCollectionPath.document().documentID
            let data = [
                "id": id,
                "title": title,
                "ownerUid": try FirestoreService.uid,
                "createdDate": Date(),
                "lastModifiedDate": Date(),
                "map": [
                    "0": [],
                    "1": [],
                    "2": []
                ]
            ] as [String: Any?]
            try FirestoreService.projectCollectionPath.document(id).setData(data as [String: Any])
        },
        readAllProjects: {
            do {
                let snapshots = try await FirestoreService.projectCollectionPath
                    .getDocuments()
                    .documents
                    .map { try $0.data(as: Project.self) }
                    .sorted(by: { $0.lastModifiedDate > $1.lastModifiedDate })
                return snapshots
            } catch {
                throw APIError.noResponseResult
            }
        },
        updateProjectTitle: { id, newTitle in
            try FirestoreService.projectCollectionPath.document(id).updateData(["title": newTitle])
            try FirestoreService.projectCollectionPath.document(id).updateData(["lastModifiedDate": Date()])
        },
        deleteProject: { id in
            let data = try await FirestoreService.projectCollectionPath.document(id).getDocument().data()
            try await FirestoreService.projectCollectionPath.document(id).delete()
            if let data = data {
                try await  FirestoreService.deletedProjectCollectionPath.document(id).setData(data)
            }
        },
        // MARK: - Plan type
        readAllPlanTypes: { projectID in
            return try await FirestoreService.getDocuments(projectID, .planTypes, PlanType.self) as! [PlanType]
        },
        createPlanType: { target, planID, projectID in
            let id = try FirestoreService.getNewDocumentID(projectID, .planTypes)
            let data = [
                "id": id,
                "title": target.title,
                "colorCode": target.colorCode
            ] as [String: Any]
            try await FirestoreService.setDocumentData(projectID, .planTypes, id, data)
            try await FirestoreService.updateDocumentData(projectID, .plans, planID, ["planTypeID": id])
        },
        deletePlanType: { typeID, projectID in
            try await FirestoreService.deleteDocument(projectID, .planTypes, typeID)
        },
        // MARK: - Plan
        createPlanOnListArea: { plansToCreate, layerCount, projectID in
            let rootPlanID = try await FirestoreService.projectCollectionPath.document(projectID).getDocument(as: Project.self).rootPlanID
            var rootPlan = try await FirestoreService.getDocument(projectID, .plans, rootPlanID, Plan.self) as! Plan
            for (index, plan) in plansToCreate.enumerated() {
                try await FirestoreService.setDocumentData(projectID, .plans, plan.id, planToDictionary(plan) as [String: Any])
                
                /// must be root child
                if index % layerCount == 0 {
                    rootPlan.childPlanIDs["0"]![index / layerCount] = plan.id
                    try await FirestoreService.setDocumentData(projectID, .plans, rootPlanID, ["childPlanIDs": rootPlan.childPlanIDs as Any])
                }
            }
        },
        createPlanOnLineArea: { target, parent, projectID in
            try await FirestoreService.setDocumentData(projectID, .plans, target.id, planToDictionary(target) as [String: Any])
            try await FirestoreService.updateDocumentData(projectID, .plans, parent.id, planToDictionary(parent) as [String: Any])
        },
        readAllPlans: { projectID in
            let plans = try await FirestoreService.getDocuments(projectID, .plans, Plan.self) as! [Plan]
            var results = [String: Plan]()
            for plan in plans {
                results[plan.id] = plan
            }
            return results
        },
        updatePlanType: { targetPlanID, planTypeID, projectID in
            try await FirestoreService.updateDocumentData(projectID, .plans, targetPlanID, ["planTypeID": planTypeID])
        },
        updatePlanPeriods: { planToUpdate, projectID in
            try await FirestoreService.updateDocumentData(projectID, .plans, planToUpdate.id, ["periods": planToUpdate.periods as Any])
        },
        deletePlan: { planID, layerIndex, deleteAll, projectID in
        },
        createLayer: { plansToUpdate, plansToCreate, projectID in
            for plan in plansToUpdate {
                try await FirestoreService.updateDocumentData(projectID, .plans, plan.id, ["childPlanIDs": plan.childPlanIDs as Any])
            }
            for plan in plansToCreate {
                try await FirestoreService.setDocumentData(projectID, .plans, plan.id, planToDictionary(plan) as [String: Any])
            }
        }
    )
    
    static func planToDictionary(_ plan: Plan) -> [String: Any?] {
        [
            "id": plan.id,
            "planTypeID": plan.planTypeID,
            "childPlanID": plan.childPlanIDs,
            "periods": plan.periods,
            "totalPeriod": plan.totalPeriod,
            "description": plan.description
        ]
    }
}
