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
    var createProject: (String, [Date]) async throws -> Project
    var readProjects: () async throws -> [Project]
    var updateProjects: @Sendable ([Project]) async throws -> Void
    var deleteProjects: @Sendable ([String]) async throws -> Void
    var deleteProjectsCompletely: @Sendable ([String]) async throws -> Void
    
    /// Plan Type
    var createPlanType: @Sendable (PlanType, String, String) async throws -> Void
    var readPlanTypes: @Sendable (String) async throws -> [PlanType]
    var updatePlanTypes: @Sendable ([PlanType], String) async throws -> Void
    var deletePlanTypes: @Sendable ([PlanType], String) async throws -> Void
    var deletePlanTypesCompletely: @Sendable ([String], String) async throws -> Void
    
    /// Plan
    var createPlans: @Sendable ([Plan], String) async throws -> Void
    var createPlanOnListArea: @Sendable ([Plan], Int, String) async throws -> Void
    var createPlanOnLineArea: @Sendable ([Plan], [Plan], String) async throws -> Void
    var readPlans: @Sendable (String) async throws -> [Plan]
    var updatePlans: @Sendable ([Plan], String) async throws -> Void
    var deletePlans: @Sendable ([Plan], String) async throws -> Void
    var deletePlansCompletely: @Sendable ([String], String) async throws -> Void
    
    /// Feedback
    var sendFeedback: @Sendable (String) async throws -> Void
    
    /// Notice
    var readAllNotices: @Sendable () async throws -> [Notice]
    
    init(
        createProject: @escaping (String, [Date]) async throws -> Project,
        readProjects: @escaping () async throws -> [Project],
        updateProjects: @escaping @Sendable ([Project]) async throws -> Void,
        deleteProjects: @escaping @Sendable ([String]) async throws -> Void,
        deleteProjectsCompletely: @escaping @Sendable ([String]) async throws -> Void,
        
        createPlanType: @escaping @Sendable (PlanType, String, String) async throws -> Void,
        readPlanTypes: @escaping @Sendable (String) async throws -> [PlanType],
        updatePlanTypes: @escaping @Sendable ([PlanType], String) async throws -> Void,
        deletePlanTypes: @escaping @Sendable ([PlanType], String) async throws -> Void,
        deletePlanTypesCompletely: @escaping @Sendable ([String], String) async throws -> Void,
        
        createPlans: @escaping @Sendable ([Plan], String) async throws -> Void,
        createPlanOnListArea: @escaping @Sendable ([Plan], Int, String) async throws -> Void,
        createPlanOnLineArea: @escaping @Sendable ([Plan], [Plan], String) async throws -> Void,
        readPlans: @escaping @Sendable (String) async throws -> [Plan],
        updatePlans: @escaping @Sendable ([Plan], String) async throws -> Void,
        deletePlans: @escaping @Sendable ([Plan], String) async throws -> Void,
        deletePlansCompletely: @escaping @Sendable ([String], String) async throws -> Void,
        
        sendFeedback: @escaping @Sendable (String) async throws -> Void,
        
        readAllNotices: @escaping @Sendable () async throws -> [Notice]
    ) {
        self.createProject = createProject
        self.readProjects = readProjects
        self.updateProjects = updateProjects
        self.deleteProjects = deleteProjects
        self.deleteProjectsCompletely = deleteProjectsCompletely
        
        self.createPlanType = createPlanType
        self.readPlanTypes = readPlanTypes
        self.updatePlanTypes = updatePlanTypes
        self.deletePlanTypes = deletePlanTypes
        self.deletePlanTypesCompletely = deletePlansCompletely
        
        self.createPlans = createPlans
        self.createPlanOnListArea = createPlanOnListArea
        self.createPlanOnLineArea = createPlanOnLineArea
        self.readPlans = readPlans
        self.updatePlans = updatePlans
        self.deletePlans = deletePlans
        self.deletePlansCompletely = deletePlansCompletely
        
        self.sendFeedback = sendFeedback
        
        self.readAllNotices = readAllNotices
    }
}

extension APIService {
    static let liveValue = Self(
        // MARK: - Project
        createProject: { title, period in
            let id = try FirestoreService.projectCollectionPath.document().documentID
            let rootPlan = Plan(id: UUID().uuidString, planTypeID: PlanType.emptyPlanType.id, childPlanIDs: ["0": []])
            let project = Project(
                id: id,
                title: title,
                ownerUid: try FirestoreService.uid,
                period: [period[0], period[1]],
                createdDate: Date(),
                lastModifiedDate: Date(),
                rootPlanID: rootPlan.id
            )
            let data = [
                "id": project.id,
                "title": title,
                "ownerUid": project.ownerUid,
                "period": project.period,
                "createdDate": Date(),
                "lastModifiedDate": Date(),
                "rootPlanID": rootPlan.id
            ] as [String: Any?]
            try await FirestoreService.projectCollectionPath.document(id).setData(data as [String: Any])
            try await FirestoreService.setDocumentData(id, .plans, rootPlan.id, planToDictionary(rootPlan))
            let planTypeData = [
                "id": PlanType.emptyPlanType.id,
                "title": PlanType.emptyPlanType.title,
                "colorCode": PlanType.emptyPlanType.colorCode
            ] as [String: Any]
            try await FirestoreService.setDocumentData(id, .planTypes, PlanType.emptyPlanType.id, planTypeData)
            return project
        },
        readProjects: {
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
        updateProjects: { projects in
            for project in projects {
                try FirestoreService
                    .projectCollectionPath
                    .document(project.id)
                    .updateData(
                        ["title": project.title,
                         "period": project.period,
                         "lastModifiedDate": Date()
                        ]
                    )
            }
        },
        deleteProjects: { ids in
            for id in ids {
                let data = try await FirestoreService.projectCollectionPath.document(id).getDocument().data()
                try await FirestoreService.projectCollectionPath.document(id).delete()
                if let data = data {
                    try await  FirestoreService.deletedProjectCollectionPath.document(id).setData(data)
                }
            }
        },
        deleteProjectsCompletely: { ids in
            for id in ids {
                try await FirestoreService.projectCollectionPath.document(id).delete()
            }
        },
        // MARK: - Plan type
        createPlanType: { target, planID, projectID in
            let data = [
                "id": target.id,
                "title": target.title,
                "colorCode": target.colorCode
            ]
            try await FirestoreService.setDocumentData(projectID, .planTypes, target.id, data)
            try await FirestoreService.updateDocumentData(projectID, .plans, planID, ["planTypeID": target.id])
        },
        readPlanTypes: { projectID in
            return try await FirestoreService.getDocuments(projectID, .planTypes, PlanType.self) as! [PlanType]
        },
        updatePlanTypes: { types, projectID in
            for type in types {
                try await FirestoreService
                    .updateDocumentData(
                        projectID,
                        .planTypes,
                        type.id,
                        [
                            "title": type.title,
                            "colorCode": type.colorCode
                        ]
                    )
            }
        },
        deletePlanTypes: { types, projectID in
            for type in types {
                try await FirestoreService.setDocumentData(
                    projectID,
                    .deletedPlanTypes,
                    type.id,
                    [
                        "title": type.title,
                        "colorCode": type.colorCode
                    ]
                )
                try await FirestoreService.deleteDocument(projectID, .planTypes, type.id)
            }
        },
        deletePlanTypesCompletely: { typeIDs, projectID in
            for typeID in typeIDs {
                try await FirestoreService.deleteDocument(projectID, .planTypes, typeID)
            }
        },
        // MARK: - Plan
        createPlans: { plansToCreate, projectID in
            for plan in plansToCreate {
                try await FirestoreService.setDocumentData(projectID, .plans, plan.id, planToDictionary(plan))
            }
        },
        createPlanOnListArea: { plansToCreate, layerCount, projectID in
            let rootPlanID = try await FirestoreService.projectCollectionPath.document(projectID).getDocument(as: Project.self).rootPlanID
            var rootPlan = try await FirestoreService.getDocument(projectID, .plans, rootPlanID, Plan.self) as! Plan
            for (index, plan) in plansToCreate.enumerated() {
                try await FirestoreService.setDocumentData(projectID, .plans, plan.id, planToDictionary(plan))
                
                /// must be root child
                if index % layerCount == 0 {
                    rootPlan.childPlanIDs["0"]![index / layerCount] = plan.id
                }
            }
            try await FirestoreService.setDocumentData(projectID, .plans, rootPlanID, ["childPlanIDs": rootPlan.childPlanIDs as Any])
        },
        createPlanOnLineArea: { plansToCreate, plansToUpdate, projectID in
            for plan in plansToCreate {
                try await FirestoreService.setDocumentData(projectID, .plans, plan.id, planToDictionary(plan))
            }
            for plan in plansToUpdate {
                try await FirestoreService.updateDocumentData(projectID, .plans, plan.id, planToDictionary(plan))
            }
        },
        readPlans: { projectID in
            return try await FirestoreService.getDocuments(projectID, .plans, Plan.self) as! [Plan]
        },
        updatePlans: { plansToUpdate, projectID in
            for plan in plansToUpdate {
                try await FirestoreService.updateDocumentData(projectID, .plans, plan.id, planToDictionary(plan))
            }
        },
        deletePlans: { plansToMove, projectID in
            for plan in plansToMove {
                try await FirestoreService.deleteDocument(projectID, .plans, plan.id)
                try await FirestoreService.setDocumentData(projectID, .deletedPlans, plan.id, planToDictionary(plan))
            }
        },
        deletePlansCompletely: { planIDs, projectID in
            for planID in planIDs {
                try await FirestoreService.deleteDocument(projectID, .plans, planID)
            }
        },
        sendFeedback: { contents in
            if let uid = Auth.auth().currentUser?.uid {
                try await FirestoreService.independentPath(.feedback).document(Date().description).setData(["uid": uid, "contents": contents])
            } else {
                try await FirestoreService.independentPath(.feedback).document(Date().description).setData(["uid": "???", "contents": contents])
            }
        },
        readAllNotices: {
            return try await FirestoreService
                .independentPath(.notice)
                .getDocuments()
                .documents
                .map { try $0.data(as: Notice.self) }
        }
    )
    
    static func planToDictionary(_ plan: Plan) -> [String: Any] {
        [
            "id": plan.id,
            "planTypeID": plan.planTypeID,
            "childPlanID": plan.childPlanIDs,
            "periods": plan.periods as Any,
            "totalPeriod": plan.totalPeriod as Any,
            "description": plan.description as Any
        ]
    }
}
