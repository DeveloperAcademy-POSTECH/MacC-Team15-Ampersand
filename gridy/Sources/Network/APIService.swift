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
    var updateProjectTitle: @Sendable (_ id: String, _ newTitle: String) async throws -> Void
    var deleteProject: @Sendable (_ id: String) async throws -> Void
    
    /// Plan Type
    var readAllPlanTypes: () async throws -> [PlanType]
    var searchPlanTypes: @Sendable (String) async throws -> [PlanType]
    var createPlanType: @Sendable (PlanType) async throws -> String
    var deletePlanType: @Sendable (String) async throws -> Void
    
    /// Plan
    var createPlan: @Sendable (Plan, Int, Int, String) async throws -> [String: [String]]
    var deletePlan: @Sendable (String, Int, Bool, String) async throws -> [String: [String]]
    
    /// Lane
    var createLane: @Sendable (Int, Int, Bool, String, String) async throws -> [String: [String]]
    var deleteLane: @Sendable (String, Bool, String) async throws -> [String: [String]]
    
    /// Layer
    var createLayer: @Sendable (Int, String) async throws -> [String: [String]]
    
    init(
        createProject: @escaping (String) async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        deleteProject: @escaping @Sendable (String) async throws -> Void,
        
        readAllPlanTypes: @escaping () async throws -> [PlanType],
        searchPlanTypes: @escaping @Sendable (String) async throws -> [PlanType],
        createPlanType: @escaping @Sendable (PlanType) async throws -> String,
        deletePlanType: @escaping @Sendable (String) async throws -> Void,
        
        createPlan: @escaping @Sendable (Plan, Int, Int, String) async throws -> [String: [String]],
        deletePlan: @escaping @Sendable (String, Int, Bool, String) async throws -> [String: [String]],
        
        createLane: @escaping @Sendable (Int, Int, Bool, String, String) async throws -> [String: [String]],
        deleteLane: @escaping @Sendable (String, Bool, String) async throws -> [String: [String]],
        
        createLayer: @escaping @Sendable (_ layerIndex: Int, _ projectID: String) async throws -> [String: [String]]
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
        
        self.createLane = createLane
        self.deleteLane = deleteLane
        
        self.createLayer = createLayer
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
    
    static func deletePlanWithAllChild(
        currentPlan: Plan,
        currentLayerIndex: Int,
        _ projectMap: inout [String: [String]]
    ) async throws {
        if let currentLaneIDs = currentPlan.laneIDs {
            for laneID in currentLaneIDs {
                /// plan이 가진 lane들에 속한 plan을 먼저 삭제, 재귀적으로 최하위까지 삭제
                let currentLane = try await laneCollectionPath.document(laneID).getDocument(as: Lane.self)
                if let childIDs = currentLane.childIDs {
                    for planID in childIDs {
                        let nextPlan = try await planCollectionPath.document(planID).getDocument(as: Plan.self)
                        try await deletePlanWithAllChild(
                            currentPlan: nextPlan,
                            currentLayerIndex: currentLayerIndex + 1,
                            &projectMap
                        )
                        try await planCollectionPath.document(planID).delete()
                    }
                }
                /// lane들을 삭제
                try await laneCollectionPath.document(laneID).delete()
            }
        }
        projectMap["\(currentLayerIndex)"]!.remove(at: projectMap["\(currentLayerIndex)"]!.firstIndex(of: currentPlan.id)!)
    }
    
    static let liveValue = Self(
        // MARK: - Project
        createProject: { title in
            let id = try projectCollectionPath.document().documentID
            let data = ["id": id,
                        "title": title,
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
                    .map { try $0.data(as: Project.self) }
                    .sorted(by: { $0.lastModifiedDate > $1.lastModifiedDate })
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
            let targetID = try planCollectionPath.document().documentID
            /// plane에 대한  lane 생성
            let newLaneID = try laneCollectionPath.document().documentID
            var data = ["id": newLaneID,
                        "childIDs": [],
                        "ownerID": targetID,
                        "periods": []] as [String: Any?]
            try await laneCollectionPath.document(newLaneID).setData(data as [String: Any])
            
            /// lane에 생성된 id를 추가
            /// 이 동작은 lane이 이미 존재한다는 전제 하에 있음: lane을 추가하려 했으면 lane 추가 액션에서 이미 생성되어 있어야 함
            var identicalTypeExist = false
            if let parentLaneID = target.parentLaneID {
                /// 이미 같은 lane에 동일한 type의 플랜이 존재하면 해당 플랜에 플랜을 따로 생성하지 않고 periods를 추가
                
                if let originLane = try await laneCollectionPath.document(parentLaneID).getDocument(as: Lane.self).childIDs {
                    for childID in originLane {
                        let childPlan = try await planCollectionPath.document(childID).getDocument(as: Plan.self)
                        if target.planTypeID == childPlan.planTypeID {
                            identicalTypeExist = true
                            try await planCollectionPath.document(childPlan.id).updateData(["periods": [childPlan.periods.count: [target.periods[0]![0], target.periods[0]![1]]]])
                        }
                    }
                    
                    /// lane 업데이트
                    try await laneCollectionPath.document(parentLaneID).updateData(
                        ["childIDs": FieldValue.arrayUnion([target.id]),
                         "periods": [
                            originLane.count: [
                                target.periods[0],
                                target.periods[1]]
                            ]
                        ]
                    )
                }
            }
            
            if !identicalTypeExist {
                /// lane에 동일한 type의 플랜이 존재하지 않으면 새로운 plan 생성
                data = ["id": targetID,
                        "planTypeID": target.planTypeID,
                        "parentLaneID": target.parentLaneID,
                        "periods": ["0": target.periods[0]],
                        "description": target.description,
                        "laneIDs": [newLaneID]] as [String: Any?]
                try await planCollectionPath.document(targetID).setData(data as [String: Any])
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
                        let dummyPlanID = try planCollectionPath.document().documentID
                        let dummyPlan = Plan(id: dummyPlanID, periods: [:])
                        try await planCollectionPath.document(dummyPlan.id).setData(["id": dummyPlan.id, "periods": [], "laneIDs": []])
                        map[layerIndex.description]!.append(dummyPlan.id)
                    }
                }
                
                /// 생성된 플랜이 들어갈 위치에 이미 빈 아이템이 있는 상태
                try await planCollectionPath.document(map[layerIndex.description]![indexFromLane]).delete()
                map[layerIndex.description]![indexFromLane] = targetID
                try await projectCollectionPath.document(projectID).updateData(["map": map])
            }
            return map
        },
        deletePlan: { planID, layerIndex, deleteAll, projectID in
            let currentPlan = try await planCollectionPath.document(planID).getDocument(as: Plan.self)
            var projectMap = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            if deleteAll {
                /// 하위 레이어의 자식 plan들을 모두 삭제하는 경우
                try await APIService.deletePlanWithAllChild(
                    currentPlan: currentPlan,
                    currentLayerIndex: layerIndex, &projectMap
                )
                
                /// plan이 속해있던 parentLane에서 삭제
                if let parentLaneID = currentPlan.parentLaneID {
                    if var parentLaneChildIDs = try await laneCollectionPath.document(parentLaneID).getDocument(as: Lane.self).childIDs {
                        let childIDsWithoutTargetPlanID = parentLaneChildIDs.remove(at: parentLaneChildIDs.firstIndex(of: planID)!)
                        try await laneCollectionPath.document(parentLaneID).updateData(["childIDs": childIDsWithoutTargetPlanID])
                    }
                }
                /// plan을 삭제
                try await planCollectionPath.document(planID).delete()
            } else {
                /// 하위 레이어는 남겨두는 경우 == periods만 삭제
                try await planCollectionPath.document(planID).updateData(["periods": [:]])
            }
            return projectMap
        },
        createLane: { layerIndex, laneIndex, createOnTop, planID, projectID in
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
                        let newLaneID = try laneCollectionPath.document().documentID
                        try await laneCollectionPath.document(newLaneID).setData(["id": newLaneID, "ownerID": newPlanID])
                        try await planCollectionPath.document(newPlanID).setData(["id": newPlanID, "periods": [], "laneIDs": [newLaneID]])
                        let newChildIndex = childIDsInLane.firstIndex(of: targetPlanID)! + (createOnTop ? 0 : 1)
                        childIDsInLane.insert(
                            newPlanID,
                            at: newChildIndex
                        )
                        try await laneCollectionPath.document(parentLaneID).updateData(["childIDs": childIDsInLane])
                        /// update project map
                        projectMap[currentLayerIndex.description]?.insert(targetPlanID, at: newChildIndex)
                        /// 다음 레이어에서 lane을 추가해줄 child plan으로 값 업데이트
                        if let laneIDs = planData.laneIDs {
                            targetPlanID = laneIDs[createOnTop ? 0 : laneIDs.count - 1]
                        } else {
                            // ???: laneIDs는 Plan이 무조건 하나 이상 갖고 있어야되는거 아닌가??
                        }
                    }
                } else {
                    /// 레인이 아무것도 없는데 레인을 나누는 경우
                    /// map 업데이트
                    projectMap[layerIndex.description] = []
                    for dummy in 0...laneIndex {
                        let dummyPlan = Plan(id: UUID().uuidString, periods: [:])
                        try await planCollectionPath.document(dummyPlan.id).setData(["id": dummyPlan.id, "periods": [], "laneIDs": []])
                        projectMap[layerIndex.description]!.append(dummyPlan.id)
                    }
                }
            }
            return projectMap
        },
        deleteLane: { laneID, deleteAll, projectID in
            
            return [:]
        },
        createLayer: { layerIndex, projectID in
            /// projectMap에 새 레이어를 추가
            var projectMap = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            let currentProjectMapLayerSize = projectMap.count
            
            if (currentProjectMapLayerSize - 1) < layerIndex {
                /// 이미 있는 레이어와 레이어 사이에 생성하는 것이 아닌, map에 아직 없는 레이어를 추가하는 경우: 레이어만 추가
                for currentLayerIndex in currentProjectMapLayerSize...layerIndex {
                    projectMap["\(currentLayerIndex)"] = []
                }
            } else {
                /// 이미 있는 레이어와 레이어 사이에 생성하는 경우
                for currentLayerIndex in stride(from: currentProjectMapLayerSize - 1, to: layerIndex - 1, by: -1) {
                    projectMap["\(currentLayerIndex + 1)"] = projectMap.removeValue(forKey: currentLayerIndex.description)
                }
                projectMap["\(layerIndex + 1)"] = []
                
                /// 생성된 레이어에, layerIndex(상위레이어)에 위치한 plan이
                for planIDInUpperLayer in projectMap[layerIndex.description]! {
                    let upperPlan = try await planCollectionPath.document(planIDInUpperLayer).getDocument(as: Plan.self)
                    if let laneIDs = upperPlan.laneIDs {
                        var newUpperPlansLanes = []
                        /// 가지는 lane만큼
                        for laneIndex in 0..<laneIDs.count {
                            /// 빈 플랜을 생성해
                            var newPlan = Plan(id: UUID().uuidString, periods: [:], laneIDs: [])
                            newUpperPlansLanes.append(newPlan.id)
                            projectMap[layerIndex.description]!.append(newPlan.id)
                            
                            /// upper plan의 lane을 새로 생성된 빈 플랜으로 옮겨주고,
                            newPlan.laneIDs?.insert(laneIDs[laneIndex], at: laneIndex)
                            try await planCollectionPath.document(newPlan.id).setData(["id": newPlan.id, "periods": [], "laneIDs": newPlan.laneIDs as Any])
                            
                            /// 그 child plan의 lane들이 가리키는 planID를 생성된 plan으로 변경
                            for laneID in laneIDs {
                                try await laneCollectionPath.document(laneID).updateData(["planIDs": newPlan.id])
                            }
                        }
                        /// 부모 플랜이 가지는 laneIDs도 업데이트
                        try await planCollectionPath.document(upperPlan.id).updateData(["laneIDs": newUpperPlansLanes])
                    }
                }
            }
            /// 수정된 map을 다시 해당 프로젝트에 업데이트
            try await projectCollectionPath.document(projectID).updateData(["map": projectMap])
            return projectMap
        }
    )
}
