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
    var createPlan: @Sendable (_ target: Plan, _ layerIndex: Int, _ indexFromLane: Int, _ projectID: String) async throws -> [String: [String]]
    var deletePlan: @Sendable (_ planID: String) async throws -> Void
    var deletePlansByParent: @Sendable (_ parentLaneID: String) async throws -> Void
    
    /// Lane
    var newLaneCreated: @Sendable (_ layerIndex: Int, _ laneIndex: Int, _ createOnTop: Bool, _ planID: String, _ projectID: String) async throws -> [String: [String]]
    
    init(
        createProject: @escaping () async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        deleteProject: @escaping @Sendable (String) async throws -> Void,
        
        readAllPlanTypes: @escaping () async throws -> [PlanType],
        searchPlanTypes: @escaping @Sendable (String) async throws -> [PlanType],
        createPlanType: @escaping @Sendable (_ target: PlanType) async throws -> String,
        deletePlanType: @escaping @Sendable (_ typeID: String) async throws -> Void,
        
        createPlan: @escaping @Sendable (_ target: Plan, _ layerIndex: Int, _ indexFromLane: Int, _ projectID: String) async throws -> [String: [String]],
        deletePlan: @escaping @Sendable (_ typeID: String) async throws -> Void,
        deletePlansByParent: @escaping @Sendable (_ parentLaneID: String) async throws -> Void,
        
        newLaneCreated: @escaping @Sendable (_ layerIndex: Int, _ laneIndex: Int, _ createOnTop: Bool, _ planID: String, _ projectID: String) async throws -> [String: [String]]
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
        self.deletePlan = deletePlan
        self.deletePlansByParent = deletePlansByParent
        
        self.newLaneCreated = newLaneCreated
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
    
    static var laneCollectionPath: CollectionReference {
        get throws {
            return try basePath.collection("Lanes")
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
                        "map": ["0": [],
                                "1": [],
                                "2": []]] as [String: Any?]
            try projectCollectionPath.document(id).setData(data as [String: Any])
            
        },
        readAllProjects: {
            do {
                let snapshots = try await projectCollectionPath
                    .getDocuments()
                    .documents
                print(snapshots)
                let test = try snapshots
                    .map { try $0.data(as: Project.self) }
                    .sorted(by: { $0.lastModifiedDate > $1.lastModifiedDate })
                return test
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
            /// lane 생성
            let newLaneID = try laneCollectionPath.document().documentID
            var data = ["id": newLaneID,
                    "childIDs": [],
                    "ownerID": target.id,
                    "periods": nil] as [String: Any?]
            try await laneCollectionPath.document(newLaneID).setData(data as [String: Any])
            
            /// plan 생성
            data = ["id": target.id,
                        "planTypeID": target.planTypeID,
                        "parentLaneID": target.parentLaneID,
                        "periods": target.periods,
                        "description": target.description,
                        "laneIDs": [newLaneID]] as [String: Any?]
            try await planCollectionPath.document(target.id).setData(data as [String: Any])
            
            /// lane에 생성된 id를 추가
            if let parentLaneID = target.parentLaneID {
                try await laneCollectionPath.document(parentLaneID).updateData(["childIDs": FieldValue.arrayUnion([target.id])])
                /// lane은 이미 존재한다는 전제 하에: lane을 추가하려 했으면 lane 추가 액션에서 이미 생성되어 있어야 함
            }
            
            /// map 업데이트
            var map = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            /// 레이어를 생성해야 하는 경우인지 확인
            let currentLayerCount = map.count
            if layerIndex >= currentLayerCount {
                for newLayer in currentLayerCount..<layerIndex {
                    map["\(newLayer)"] = []
                }
            }
            
            if let layerLanes = map[layerIndex.description] {
                /// 빈 아이템을 생성해야 하는 경우인지 확인
                if indexFromLane >= layerLanes.count {
                    for dummy in layerLanes.count...indexFromLane {
                        let dummyPlan = Plan(id: UUID().uuidString)
                        try await planCollectionPath.document(dummyPlan.id).setData(["id": dummyPlan.id])
                        map[layerIndex.description]!.append(dummyPlan.id)
                    }
                }
                
                /// 생성된 플랜이 들어갈 위치에 이미 빈 아이템이 있는 상태
                try await planCollectionPath.document(map[layerIndex.description]![indexFromLane]).delete()
                map[layerIndex.description]![indexFromLane] = target.id
                try await projectCollectionPath.document(projectID).updateData(["map": map])
            }
            return map
        },
        deletePlan: { planID in
            try planCollectionPath.document(planID).updateData(["laneIDs": []])
            try planCollectionPath.document(planID).updateData(["periods": [[]]])
            
        }
        , deletePlansByParent: { planID in
            // TODO: -
            let laneIDs = try await planCollectionPath.document(planID).getDocument().data(as: Plan.self).laneIDs
            if let laneIDs = laneIDs {
                try laneIDs.forEach { laneID in
                    //                    try planCollectionPath.document(laneID).delete()
                }
            }
            //            try await planCollectionPath.document(planID).delete()
        },
        newLaneCreated: { layerIndex, laneIndex, createOnTop, planID, projectID in
            var projectMap = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            let maximumDepth = projectMap.count
            var targetPlanID = planID
            /// 최하위 레이어까지 해당 위치에 새 레인 생성
            for currentLayerIndex in layerIndex..<maximumDepth {
                let planData = try await planCollectionPath.document(targetPlanID).getDocument(as: Plan.self)
                if var parentLaneID = planData.parentLaneID {
                    let parentLane = try await laneCollectionPath.document(parentLaneID).getDocument(as: Lane.self)
                    if var childIDsInLane = parentLane.childIDs {
                        let newPlanID = UUID().uuidString
                        try await planCollectionPath.document(newPlanID).setData(["id": newPlanID])
                        let newChildIndex = childIDsInLane.firstIndex(of: targetPlanID)! + (createOnTop ? 0 : 1)
                        childIDsInLane.insert(
                            newPlanID,
                            at: newChildIndex
                        )
                        try await laneCollectionPath.document(parentLaneID).updateData(["childIDs": childIDsInLane])
                        /// update project map
                        projectMap[currentLayerIndex.description]?.insert(targetPlanID, at: newChildIndex)
                        targetPlanID = planData.laneIDs![createOnTop ? 0 : planData.laneIDs!.count - 1]![0]
                    }
                } else {
                    // TODO: - 레인에 아무것도 없는데 레인을 나누는 경우
                    /// map 업데이트
                    var projectMap = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
                    projectMap[layerIndex.description] = []
                    for dummy in 0...laneIndex {
                        let dummyPlan = Plan(id: UUID().uuidString)
                        try await planCollectionPath.document(dummyPlan.id).setData(["id": dummyPlan.id])
                        projectMap[layerIndex.description]!.append(dummyPlan.id)
                    }
                }
            }
            return projectMap
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
        createPlan: { _, _, _, _ in ["0": [""]] },
        deletePlan: { _ in },
        deletePlansByParent: { _ in },
        newLaneCreated: { _, _, _, _, _ in ["": [""]] }
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
        createPlan: { _, _, _, _ in ["0": [""]] },
        deletePlan: { _ in },
        deletePlansByParent: { _ in },
        newLaneCreated: { _, _, _, _, _ in ["": [""]] }
    )
}
