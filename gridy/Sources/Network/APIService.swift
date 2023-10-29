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
    var readAllPlanTypes: (String) async throws -> [PlanType]
    var searchPlanTypes: @Sendable (String, String) async throws -> [PlanType]
    var createPlanType: @Sendable (PlanType, String, String) async throws -> String
    var deletePlanType: @Sendable (String, String) async throws -> Void
    
    /// Plan
    var createPlan: @Sendable (Plan, Int, String) async throws -> [String: [String]]
    var deletePlan: @Sendable (String, Int, Bool, String) async throws -> [String: [String]]
    var updatePlan: @Sendable (String, String, String) async throws -> Plan
    var readAllPlans: @Sendable (String) async throws -> [String: Plan]
    
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
        
        readAllPlanTypes: @escaping (String) async throws -> [PlanType],
        searchPlanTypes: @escaping @Sendable (String, String) async throws -> [PlanType],
        createPlanType: @escaping @Sendable (PlanType, String, String) async throws -> String,
        deletePlanType: @escaping @Sendable (String, String) async throws -> Void,
        
        createPlan: @escaping @Sendable (Plan, Int, String) async throws -> [String: [String]],
        deletePlan: @escaping @Sendable (String, Int, Bool, String) async throws -> [String: [String]],
        updatePlan: @escaping @Sendable (String, String, String) async throws -> Plan,
        readAllPlans: @escaping @Sendable (String) async throws -> [String: Plan],
        
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
        self.updatePlan = updatePlan
        self.readAllPlans = readAllPlans
        
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
    
    static func planCollectionPath(_ projectID: String) throws -> CollectionReference {
        return try projectCollectionPath.document(projectID).collection("Plans")
    }
    
    static func planTypeCollectionPath(_ projectID: String) throws -> CollectionReference {
        return try projectCollectionPath.document(projectID).collection("PlanTypes")
    }
    
    static func laneCollectionPath(_ projectID: String) throws -> CollectionReference {
        return try projectCollectionPath.document(projectID).collection("Lanes")
    }
    
    /// 비우기만
    static func emptyOutPlanWithAllChild(
        currentPlan: Plan,
        currentLayerIndex: Int,
        _ projectMap: inout [String: [String]],
        projectID: String
    ) async throws {
        for laneID in currentPlan.laneIDs {
            /// plan이 가진 lane들에 속한 plan을 먼저 삭제, 재귀적으로 최하위까지 비움
            let currentLane = try await laneCollectionPath(projectID).document(laneID).getDocument(as: Lane.self)
            if let childIDs = currentLane.childIDs {
                for planID in childIDs {
                    let nextPlan = try await planCollectionPath(projectID).document(planID).getDocument(as: Plan.self)
                    try await emptyOutPlanWithAllChild(
                        currentPlan: nextPlan,
                        currentLayerIndex: currentLayerIndex + 1,
                        &projectMap,
                        projectID: projectID
                    )
                    if laneID == currentPlan.laneIDs.first,
                       planID == childIDs.first {
                        let emptyData = [
                            "periods": nil,
                            "planTypeID": nil
                        ] as [String: Any?]
                        try await planCollectionPath(projectID).document(planID).updateData(emptyData as [String: Any])
                    } else {
                        try await planCollectionPath(projectID).document(planID).delete()
                        projectMap["\(currentLayerIndex)"]!.remove(at: projectMap["\(currentLayerIndex)"]!.firstIndex(of: currentPlan.id)!)
                    }
                }
            }
            /// 하나의 lane(첫 lane)은 제외하고 나머지 lane들은 삭제
            if laneID == currentPlan.laneIDs.first! { continue }
            try await laneCollectionPath(projectID).document(laneID).delete()
        }
    }
    
    /// 싹 삭제
    static func deletePlanWithAllChild(
        currentPlan: Plan,
        currentLayerIndex: Int,
        _ projectMap: inout [String: [String]],
        projectID: String
    ) async throws {
        for laneID in currentPlan.laneIDs {
            /// plan이 가진 lane들에 속한 plan을 먼저 삭제, 재귀적으로 최하위까지 삭제
            let currentLane = try await laneCollectionPath(projectID).document(laneID).getDocument(as: Lane.self)
            if let childIDs = currentLane.childIDs {
                for planID in childIDs {
                    let nextPlan = try await planCollectionPath(projectID).document(planID).getDocument(as: Plan.self)
                    try await deletePlanWithAllChild(
                        currentPlan: nextPlan,
                        currentLayerIndex: currentLayerIndex + 1,
                        &projectMap,
                        projectID: projectID
                    )
                    try await planCollectionPath(projectID).document(planID).delete()
                    projectMap["\(currentLayerIndex)"]!.remove(at: projectMap["\(currentLayerIndex)"]!.firstIndex(of: currentPlan.id)!)
                }
            }
            /// 하나의 lane(첫 lane)은 제외하고 나머지 lane들은 삭제
            if laneID == currentPlan.laneIDs.first { continue }
            try await laneCollectionPath(projectID).document(laneID).delete()
        }
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
        readAllPlanTypes: { projectID in
            return try await planTypeCollectionPath(projectID)
                .getDocuments()
                .documents
                .map { try $0.data(as: PlanType.self) }
            
        },
        searchPlanTypes: { keyword, projectID in
            do {
                return try await planTypeCollectionPath(projectID)
                    .getDocuments()
                    .documents
                    .map { try $0.data(as: PlanType.self) }
                    .filter { $0.title.contains(keyword) }
            } catch {
                throw APIError.noResponseResult
            }
            
        },
        createPlanType: { target, planID, projectID in
            let id = try planTypeCollectionPath(projectID).document().documentID
            let data = ["id": id,
                        "title": target.title,
                        "colorCode": target.colorCode] as [String: Any]
            try planTypeCollectionPath(projectID).document(id).setData(data)
            try planCollectionPath(projectID).document(planID).updateData(["planTypeID": id])
            return id
            
        },
        deletePlanType: { typeID, projectID in
            try planTypeCollectionPath(projectID).document(typeID).delete()
        },
        
        // MARK: - Plan
        createPlan: { target, layerIndex, projectID in
            let targetID = try planCollectionPath(projectID).document().documentID
            /// plan에 대한  lane 생성
            let newLaneID = try laneCollectionPath(projectID).document().documentID
            var data = ["id": newLaneID,
                        "childIDs": [],
                        "ownerID": targetID,
                        "periods": []] as [String: Any?]
            try await laneCollectionPath(projectID).document(newLaneID).setData(data as [String: Any])
            
            /// parentPlanID를 조회
            var parentPlanID: String?
            if let parentLaneID = target.parentLaneID {
                parentPlanID = try await laneCollectionPath(projectID).document(parentLaneID).getDocument(as: Lane.self).ownerID
            }
            
            /// map 업데이트
            var map = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            /// 레이어를 생성해야 하는 경우인지 확인
            let currentLayerCount = map.count
            if layerIndex >= currentLayerCount {
                var upperLaneID: String?
                var rowIndex = -1
                for newLayerIndex in currentLayerCount...layerIndex {
                    map["\(newLayerIndex)"] = []
                    /// 생겨난 레이어에도 이전 최하위 레어어의 플랜만큼 만들어줌
                    if let prevLayer = map["\(newLayerIndex-1)"] {
                        for index in 0..<prevLayer.count {
                            if let parentPlanID = parentPlanID,
                               newLayerIndex == currentLayerCount,
                               prevLayer[index] == parentPlanID {
                                // 첫 순회때 새 플랜이 생성될 row 인덱스 조회
                                rowIndex = index
                            }
                            let prevLayerPlanID = prevLayer[index]
                            
                            let newPlanID = (layerIndex == newLayerIndex && rowIndex == index) ? targetID : try planCollectionPath(projectID).document().documentID
                            var dummyPlan = Plan(id: newPlanID, periods: [:], laneIDs: [newLaneID])
                            
                            if prevLayerPlanID == parentPlanID,
                               newLayerIndex == layerIndex {
                                dummyPlan = target
                                dummyPlan.laneIDs = [newLaneID]
                            }
                            let newLaneID = try laneCollectionPath(projectID).document().documentID
                            
                            data = ["id": dummyPlan.id,
                                    "planTypeID": dummyPlan.planTypeID,
                                    "parentLaneID": dummyPlan.parentLaneID,
                                    "periods": dummyPlan.periods.count == 0 ? [:] : ["0": dummyPlan.periods[0]],
                                    "description": dummyPlan.description,
                                    "laneIDs": [newLaneID]] as [String: Any?]
                            
                            try await planCollectionPath(projectID).document(dummyPlan.id).setData(data as [String: Any])
                            try await laneCollectionPath(projectID).document(newLaneID).setData(["id": newLaneID, "ownerID": dummyPlan.id])
                            if let upperLaneID = upperLaneID {
                                try await laneCollectionPath(projectID).document(upperLaneID).updateData(["childIDs": dummyPlan.id])
                            }
                            map["\(newLayerIndex)"]![index] = dummyPlan.id
                            
                            if prevLayerPlanID == parentPlanID {
                                parentPlanID = prevLayerPlanID
                            }
                            upperLaneID = newLaneID
                        }
                    }
                }
                try await projectCollectionPath.document(projectID).updateData(["map": map])
                return map
            }
            
            /// 새로운 레인을 생성하는 경우 == parentLane이 없는 경우
            if parentPlanID == nil {
                if layerIndex == 0 { /// root인 경우
                    map["0"]!.append(targetID)
                    data = ["id": targetID,
                            "planTypeID": target.planTypeID,
                            "parentLaneID": target.parentLaneID,
                            "periods": target.periods.count == 0 ? [:] : ["0": target.periods[0]],
                            "description": target.description,
                            "laneIDs": [newLaneID]] as [String: Any?]
                    
                    try await planCollectionPath(projectID).document(targetID).setData(data as [String: Any])
                } else { /// root가 아니고 parentLane이 없는 경우
                    var prevLayerLaneID: String?
                    for currentLayerIndex in 0...layerIndex {
                        let newLaneID = try laneCollectionPath(projectID).document().documentID
                        var dummyPlan = Plan(id: try planCollectionPath(projectID).document().documentID, periods: [:], laneIDs: [newLaneID])
                        if currentLayerIndex == layerIndex {
                            dummyPlan = target
                            dummyPlan.id = targetID
                            dummyPlan.laneIDs = [newLaneID]
                        }
                        try await laneCollectionPath(projectID).document(newLaneID).setData(["id": newLaneID, "ownerID": dummyPlan.id])
                        if let prevLayerLaneID = prevLayerLaneID {
                            try await laneCollectionPath(projectID).document(prevLayerLaneID).updateData(["childIDs": FieldValue.arrayUnion([dummyPlan.id])])
                        }
                        data = ["id": targetID,
                                "planTypeID": dummyPlan.planTypeID,
                                "parentLaneID": dummyPlan.parentLaneID,
                                "periods": dummyPlan.periods.count == 0 ? [:] : ["0": dummyPlan.periods[0]],
                                "description": dummyPlan.description,
                                "laneIDs": [newLaneID]] as [String: Any?]
                        try await planCollectionPath(projectID).document(targetID).setData(data as [String: Any])
                        prevLayerLaneID = newLaneID
                        map["\(currentLayerIndex)"]!.append(dummyPlan.id)
                    }
                }
            }
            try await projectCollectionPath.document(projectID).updateData(["map": map])
            return map
        },
        deletePlan: { planID, layerIndex, deleteAll, projectID in
            let currentPlan = try await planCollectionPath(projectID).document(planID).getDocument(as: Plan.self)
            var projectMap = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            if deleteAll {
                /// plan이 속해있던 parent의 childPlan의 개수가 2이상이라면 아예 삭제
                /// childPlan의 개수를 알아보자 ..;;
                var parentsChildsID = Set<String>()
                if let parentLaneID = currentPlan.parentLaneID {
                    let parentPlanID = try await laneCollectionPath(projectID).document(parentLaneID).getDocument(as: Lane.self).ownerID
                    let parentsLaneIDs = try await planCollectionPath(projectID).document(parentPlanID).getDocument(as: Plan.self).laneIDs
                    for parentsLaneID in parentsLaneIDs {
                        if let currentLanesChildIDs = try await laneCollectionPath(projectID).document(parentsLaneID).getDocument(as: Lane.self).childIDs {
                            for currentLanesChildID in currentLanesChildIDs {
                                parentsChildsID.insert(currentLanesChildID)
                            }
                        }
                        if parentsChildsID.count > 1 { break }
                    }
                }
                
                if parentsChildsID.count > 1 {
                    /// 하위 레이어의 자식 plan들을 모두 삭제하는 경우
                    try await APIService.deletePlanWithAllChild(
                        currentPlan: currentPlan,
                        currentLayerIndex: layerIndex,
                        &projectMap,
                        projectID: projectID
                    )
                    try await planCollectionPath(projectID).document(planID).delete()
                    projectMap["\(layerIndex)"]!.remove(at: projectMap["\(layerIndex)"]!.firstIndex(of: planID)!)
                } else {
                    /// parent plan이 가진 plan이 이것 하나뿐이기 때문에 타겟 플랜은 비우기만 하는데 ... 자식들은 싹 다 하나만 남겨야되네
                    try await APIService.emptyOutPlanWithAllChild(
                        currentPlan: currentPlan,
                        currentLayerIndex: layerIndex,
                        &projectMap,
                        projectID: projectID
                    )
                     let emptyData = [
                         "periods": nil,
                         "planTypeID": nil
                     ] as [String: Any?]
                     try await planCollectionPath(projectID).document(planID).updateData(emptyData as [String: Any])
                }
            } else {
                /// 하위 레이어는 남겨두는 경우 == periods, type만 삭제
                let emptyData = ["periods": nil, "planTypeID": nil] as [String: Any?]
                try await planCollectionPath(projectID).document(planID).updateData(emptyData as [String: Any])
            }
            try await projectCollectionPath.document(projectID).updateData(["map": projectMap])
            return projectMap
        },
        updatePlan: { planID, planTypeID, projectID in
            /// planTypeID를 업데이트하는 updatePlan
            /// periods를 업데이트하는 updatePlan도 필요함
            try await planCollectionPath(projectID).document(planID).updateData(["planTypeID": planTypeID])
            let result = try await planCollectionPath(projectID).document(planID).getDocument(as: Plan.self)
            return result
        },
        readAllPlans: { projectID in
            let plans = try await planCollectionPath(projectID).getDocuments().documents.map { try $0.data(as: Plan.self) }
            var result = [String: Plan]()
            for plan in plans {
                result[plan.id] = plan
            }
            return result
        },
        createLane: { layerIndex, laneIndex, createOnTop, planID, projectID in
            var projectMap = try await projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            let maximumDepth = projectMap.count
            var targetPlanID = planID
            /// 최하위 레이어까지 해당 위치에 새 레인 생성
            for currentLayerIndex in layerIndex..<maximumDepth {
                let planData = try await planCollectionPath(projectID).document(targetPlanID).getDocument(as: Plan.self)
                if var parentLaneID = planData.parentLaneID {
                    let parentLane = try await laneCollectionPath(projectID).document(parentLaneID).getDocument(as: Lane.self)
                    if var childIDsInLane = parentLane.childIDs {
                        let newPlanID = UUID().uuidString
                        let newLaneID = try laneCollectionPath(projectID).document().documentID
                        try await laneCollectionPath(projectID).document(newLaneID).setData(["id": newLaneID, "ownerID": newPlanID])
                        try await planCollectionPath(projectID).document(newPlanID).setData(["id": newPlanID, "periods": [], "laneIDs": [newLaneID]])
                        let newChildIndex = childIDsInLane.firstIndex(of: targetPlanID)! + (createOnTop ? 0 : 1)
                        childIDsInLane.insert(
                            newPlanID,
                            at: newChildIndex
                        )
                        try await laneCollectionPath(projectID).document(parentLaneID).updateData(["childIDs": childIDsInLane])
                        /// update project map
                        projectMap[currentLayerIndex.description]?.insert(targetPlanID, at: newChildIndex)
                        /// 다음 레이어에서 lane을 추가해줄 child plan으로 값 업데이트
                        targetPlanID = planData.laneIDs[createOnTop ? 0 : planData.laneIDs.count - 1]
                    }
                } else {
                    /// 레인이 아무것도 없는데 레인을 나누는 경우
                    /// map 업데이트
                    projectMap[layerIndex.description] = []
                    for dummy in 0...laneIndex {
                        let dummyPlan = Plan(id: UUID().uuidString, periods: [:], laneIDs: [])
                        try await planCollectionPath(projectID).document(dummyPlan.id).setData(["id": dummyPlan.id, "periods": [], "laneIDs": []])
                        projectMap[layerIndex.description]!.append(dummyPlan.id)
                    }
                }
            }
            return projectMap
        },
        deleteLane: { laneID, deleteAll, projectID in
            // TODO: -
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
                /// 0번째에 생성하는 경우
                var newFirstLayer = [String]()
                if layerIndex == -1 {
                    if projectMap.count == 0 {
                        projectMap["0"] = []
                    } else {
                        if let previousFirstLayer = projectMap["0"] {
                            for planID in previousFirstLayer {
                                /// 기존 0번째 레이어에 있던 플랜의 수만큼 parent로 쓸 플랜을 생성하고 연결
                                let newLaneID = try laneCollectionPath(projectID).document().documentID
                                let newPlan = Plan(id: UUID().uuidString, periods: [:], laneIDs: [newLaneID])
                                let newLane = Lane(id: newLaneID, childIDs: [planID], ownerID: newPlan.id)
                                newFirstLayer.append(newPlan.id)
                                try await planCollectionPath(projectID).document(newPlan.id).setData(["id": newPlan.id, "periods": [], "laneIDs": []])
                                try await laneCollectionPath(projectID).document(newLaneID).setData(["id": newLaneID, "ownerID": newPlan.id])
                            }
                        }
                        for currentLayerIndex in stride(from: projectMap.count-1, through: -1, by: -1) {
                            projectMap["\(currentLayerIndex + 1)"] = projectMap["\(currentLayerIndex)"]
                        }
                        projectMap["0"] = newFirstLayer
                    }
                } else {
                    for currentLayerIndex in stride(from: currentProjectMapLayerSize - 1, to: layerIndex, by: -1) {
                        projectMap["\(currentLayerIndex + 1)"] = projectMap.removeValue(forKey: currentLayerIndex.description)
                    }
                    projectMap["\(layerIndex + 1)"] = []
                    
                    /// 생성된 레이어에, layerIndex(상위레이어)에 위치한 plan이
                    for planIDInUpperLayer in projectMap[layerIndex.description]! {
                        let upperPlan = try await planCollectionPath(projectID).document(planIDInUpperLayer).getDocument(as: Plan.self)
                        var newUpperPlansLanes = []
                        /// 가지는 lane만큼
                        for laneIndex in 0..<upperPlan.laneIDs.count {
                            /// 빈 플랜을 생성해
                            var newPlan = Plan(id: UUID().uuidString, periods: [:], laneIDs: [])
                            newUpperPlansLanes.append(newPlan.id)
                            projectMap[layerIndex.description]!.append(newPlan.id)
                            
                            /// upper plan의 lane을 새로 생성된 빈 플랜으로 옮겨주고,
                            newPlan.laneIDs.insert(upperPlan.laneIDs[laneIndex], at: laneIndex)
                            try await planCollectionPath(projectID).document(newPlan.id).setData(["id": newPlan.id, "periods": [], "laneIDs": newPlan.laneIDs as Any])
                            
                            /// 그 child plan의 lane들이 가리키는 planID를 생성된 plan으로 변경
                            for laneID in upperPlan.laneIDs {
                                try await laneCollectionPath(projectID).document(laneID).updateData(["planIDs": newPlan.id])
                            }
                        }
                        /// 부모 플랜이 가지는 laneIDs도 업데이트
                        try await planCollectionPath(projectID).document(upperPlan.id).updateData(["laneIDs": newUpperPlansLanes])
                    }
                }
            }
            /// 수정된 map을 다시 해당 프로젝트에 업데이트
            try await projectCollectionPath.document(projectID).updateData(["map": projectMap])
            return projectMap
        }
    )
}
