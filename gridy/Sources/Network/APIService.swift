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
    var createProject: @Sendable (_ title: String, _ period: [Date]) async throws -> Project
    var readProject: @Sendable (_ projectID: String) async throws -> Project
    var readProjects: () async throws -> [Project]
    var updateProjects: @Sendable (_ projectToUpdate: [Project]) async throws -> Void
    var deleteProjects: @Sendable (_ projectIDs: [String]) async throws -> Void
    var deleteProjectsCompletely: @Sendable (_ projectIDs: [String]) async throws -> Void
    var emptyDeletedProjects: () async throws -> Void
    var deleteDeletedProjectsImmediately: @Sendable (_ projectIDs: [String]) async throws -> Void
    
    /// Plan Type
    var createPlanType: @Sendable (_ typeToCreate: PlanType, _ targetPlanID: String, _ projectID: String) async throws -> Void
    var readPlanTypes: @Sendable (_ projectID: String) async throws -> [PlanType]
    var updatePlanTypes: @Sendable (_ typesToUpdate: [PlanType], _ projectID: String) async throws -> Void
    var deletePlanTypes: @Sendable (_ typesToDelete: [PlanType], _ projectID: String) async throws -> Void
    var deletePlanTypesCompletely: @Sendable (_ typeIDsToDeleteCompletely: [String], _ projectID: String) async throws -> Void
    
    /// Plan
    var createPlans: @Sendable (_ plansToCreate: [Plan], _ projectID: String) async throws -> Void
    var readPlans: @Sendable (_ projectID: String) async throws -> [Plan]
    var updatePlans: @Sendable (_ plansToUpdate: [Plan], _ projectID: String) async throws -> Void
    var deletePlans: @Sendable (_ plansToDelete: [Plan], _ projectID: String) async throws -> Void
    var deletePlansCompletely: @Sendable (_ planIDsToDeleteCompletely: [String], _ projectID: String) async throws -> Void
    
    /// Schedule
    var createSchedule: @Sendable (Schedule, String) async throws -> Void
    var readSchedules: @Sendable (String) async throws -> [Schedule]
    var updateSchedule: @Sendable (Schedule, String) async throws -> Void
    var deleteSchedule: @Sendable (Schedule, String) async throws -> Void
    
    /// Feedback
    var sendFeedback: @Sendable (_ content: String) async throws -> Void
    
    /// Notice
    var readAllNotices: @Sendable () async throws -> [Notice]
    
    init(
        createProject: @escaping @Sendable (_ title: String, _ period: [Date]) async throws -> Project,
        readProject: @escaping @Sendable (_ projectID: String) async throws -> Project,
        readProjects: @escaping () async throws -> [Project],
        updateProjects: @escaping @Sendable (_ projectToUpdate: [Project]) async throws -> Void,
        deleteProjects: @escaping @Sendable (_ projectIDs: [String]) async throws -> Void,
        deleteProjectsCompletely: @escaping @Sendable (_ projectIDs: [String]) async throws -> Void,
        emptyDeletedProjects: @escaping () async throws -> Void,
        deleteDeletedProjectsImmediately: @escaping @Sendable (_ projectIDs: [String]) async throws -> Void,
        
        createPlanType: @escaping @Sendable (_ typeToCreate: PlanType, _ targetPlanID: String, _ projectID: String) async throws -> Void,
        readPlanTypes: @escaping @Sendable (_ projectID: String) async throws -> [PlanType],
        updatePlanTypes: @escaping @Sendable (_ typesToUpdate: [PlanType], _ projectID: String) async throws -> Void,
        deletePlanTypes: @escaping @Sendable (_ typesToDelete: [PlanType], _ projectID: String) async throws -> Void,
        deletePlanTypesCompletely: @escaping @Sendable (_ typeIDsToDeleteCompletely: [String], _ projectID: String) async throws -> Void,
        
        createPlans: @escaping @Sendable (_ plansToCreate: [Plan], _ projectID: String) async throws -> Void,
        readPlans: @escaping @Sendable (_ projectID: String) async throws -> [Plan],
        updatePlans: @escaping @Sendable (_ plansToUpdate: [Plan], _ projectID: String) async throws -> Void,
        deletePlans: @escaping @Sendable (_ plansToDelete: [Plan], _ projectID: String) async throws -> Void,
        deletePlansCompletely: @escaping @Sendable (_ planIDsToDeleteCompletely: [String], _ projectID: String) async throws -> Void,
        
        createSchedule: @escaping @Sendable (Schedule, String) async throws -> Void,
        readSchedules: @escaping @Sendable (String) async throws -> [Schedule],
        updateSchedule: @escaping @Sendable (Schedule, String) async throws -> Void,
        deleteSchedule: @escaping @Sendable (Schedule, String) async throws -> Void,
        
        sendFeedback: @escaping @Sendable (_ content: String) async throws -> Void,
        
        readAllNotices: @escaping @Sendable () async throws -> [Notice]
    ) {
        self.createProject = createProject
        self.readProject = readProject
        self.readProjects = readProjects
        self.updateProjects = updateProjects
        self.deleteProjects = deleteProjects
        self.deleteProjectsCompletely = deleteProjectsCompletely
        self.emptyDeletedProjects = emptyDeletedProjects
        self.deleteDeletedProjectsImmediately = deleteDeletedProjectsImmediately
        
        self.createPlanType = createPlanType
        self.readPlanTypes = readPlanTypes
        self.updatePlanTypes = updatePlanTypes
        self.deletePlanTypes = deletePlanTypes
        self.deletePlanTypesCompletely = deletePlansCompletely
        
        self.createPlans = createPlans
        self.readPlans = readPlans
        self.updatePlans = updatePlans
        self.deletePlans = deletePlans
        self.deletePlansCompletely = deletePlansCompletely
        
        self.createSchedule = createSchedule
        self.readSchedules = readSchedules
        self.updateSchedule = updateSchedule
        self.deleteSchedule = deleteSchedule
        
        self.sendFeedback = sendFeedback
        
        self.readAllNotices = readAllNotices
    }
}

extension APIService {
    static let liveValue = Self(
        // MARK: - Project
        createProject: { title, period in
            guard period.count == 2 else { throw APIError.wrongParameter }
            let projectID = try FirestoreService.projectCollectionPath.document().documentID
            let rootPlan = Plan(id: UUID().uuidString, planTypeID: PlanType.emptyPlanType.id, childPlanIDs: ["0": []])
            let startDate = min(period[0], period[1])
            let endDate = max(period[0], period[1])
            let project = Project(
                id: projectID,
                title: title,
                ownerUid: try FirestoreService.uid,
                period: [startDate, endDate],
                createdDate: Date(),
                lastModifiedDate: Date(),
                rootPlanID: rootPlan.id,
                countLayerInListArea: 1
            )
            let data = [
                "id": project.id,
                "title": title,
                "ownerUid": project.ownerUid,
                "period": project.period,
                "createdDate": Date(),
                "lastModifiedDate": Date(),
                "rootPlanID": rootPlan.id,
                "countLayerInListArea": 1
            ] as [String: Any?]
            try await FirestoreService.projectCollectionPath.document(projectID).setData(data as [String: Any])
            try await FirestoreService.setDocumentData(projectID, .plans, rootPlan.id, planToDictionary(rootPlan))
            let planTypeData = [
                "id": PlanType.emptyPlanType.id,
                "title": PlanType.emptyPlanType.title,
                "colorCode": PlanType.emptyPlanType.colorCode
            ] as [String: Any]
            try await FirestoreService.setDocumentData(
                projectID,
                .planTypes,
                PlanType.emptyPlanType.id,
                planTypeData
            )
            return project
        },
        readProject: { projectID in
            return try await FirestoreService.projectCollectionPath.document(projectID).getDocument(as: Project.self)
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
                         "lastModifiedDate": Date(),
                         "countLayerInListArea": project.countLayerInListArea
                        ]
                    )
            }
        },
        deleteProjects: { projectIDs in
            for projectID in projectIDs {
                let data = try await FirestoreService.projectCollectionPath.document(projectID).getDocument().data()
                try await FirestoreService.projectCollectionPath.document(projectID).delete()
                if let data = data {
                    try await  FirestoreService.deletedProjectCollectionPath.document(projectID).setData(data)
                }
            }
        },
        deleteProjectsCompletely: { projectIDs in
            for projectID in projectIDs {
                try await FirestoreService.projectCollectionPath.document(projectID).delete()
            }
        },
        emptyDeletedProjects: {
            let deletedProjectsIDs = try await FirestoreService
                .deletedProjectCollectionPath
                .getDocuments()
                .documents
                .map({ try $0.data(as: Project.self).id })
            for projectID in deletedProjectsIDs {
                try await FirestoreService.deletedProjectCollectionPath.document(projectID).delete()
            }
        },
        deleteDeletedProjectsImmediately: { projectIDs in
            for projectID in projectIDs {
                try await FirestoreService.deletedProjectCollectionPath.document(projectID).delete()
            }
        },
        // MARK: - Plan type
        createPlanType: { typeToCreate, targetPlanID, projectID in
            let data = [
                "id": typeToCreate.id,
                "title": typeToCreate.title,
                "colorCode": typeToCreate.colorCode
            ]
            try await FirestoreService.setDocumentData(projectID, .planTypes, typeToCreate.id, data)
            try await FirestoreService.updateDocumentData(projectID, .plans, targetPlanID, ["planTypeID": typeToCreate.id])
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
        // MARK: - Schedule
        createSchedule: { schedule, projectID in
            try await FirestoreService.setDocumentData(projectID, .schedules, schedule.id, scheduleToDictionary(schedule))
        },
        readSchedules: { projectID in
            return try await FirestoreService.getDocuments(projectID, .schedules, Schedule.self) as! [Schedule]
        },
        updateSchedule: { schedule, projectID in
            try await FirestoreService.updateDocumentData(projectID, .schedules, schedule.id, scheduleToDictionary(schedule))
        },
        deleteSchedule: { schedule, projectID in
            try await FirestoreService.setDocumentData(projectID, .deleteSchedules, schedule.id, scheduleToDictionary(schedule))
            try await FirestoreService.deleteDocument(projectID, .schedules, schedule.id)
        },
        sendFeedback: { content in
            if let uid = Auth.auth().currentUser?.uid {
                try await FirestoreService.independentPath(.feedback).document(Date().description).setData(["uid": uid, "contents": content])
            } else {
                try await FirestoreService.independentPath(.feedback).document(Date().description).setData(["uid": "???", "contents": content])
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
            "childPlanIDs": plan.childPlanIDs,
            "periods": plan.periods as Any,
            "totalPeriod": plan.totalPeriod as Any,
            "description": plan.description as Any
        ]
    }
    static func scheduleToDictionary(_ schedule: Schedule) -> [String: Any] {
            [
                "id": schedule.id,
                "startDate": schedule.startDate,
                "endDate": schedule.endDate,
                "title": schedule.title,
                "colorCode": schedule.colorCode,
                "category": schedule.category
            ]
        }
}

