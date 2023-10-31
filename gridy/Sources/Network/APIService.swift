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
    var searchPlanTypes: @Sendable (String, String) async throws -> [PlanType]
    var createPlanType: @Sendable (PlanType, String) async throws -> String
    var deletePlanType: @Sendable (String, String) async throws -> Void
    
    /// Plan
    var createPlan: @Sendable (Plan, Int, Int, String) async throws -> [String: [String]]
    var deletePlan: @Sendable (String, Int, Bool, String) async throws -> [String: [String]]
    var updatePlan: @Sendable (String, String, String) async throws -> Plan
    var readAllPlans: @Sendable (String) async throws -> [String: Plan]
    
    /// Lane
    var createLane: @Sendable (Bool, String, String) async throws -> [String: Plan]
    var deleteLane: @Sendable (String, Bool, String) async throws -> [String: [String]]
    var readAllLanes: @Sendable (String) async throws -> [String: Lane]
    
    /// Layer
    var createLayer: @Sendable (Int, String) async throws -> [String: [String]]
    
    init(
        createProject: @escaping (String) async throws -> Void,
        readAllProjects: @escaping () async throws -> [Project],
        updateProjectTitle: @escaping @Sendable (String, String) async throws -> Void,
        deleteProject: @escaping @Sendable (String) async throws -> Void,
        
        readAllPlanTypes: @escaping (String) async throws -> [PlanType],
        searchPlanTypes: @escaping @Sendable (String, String) async throws -> [PlanType],
        createPlanType: @escaping @Sendable (PlanType, String) async throws -> String,
        deletePlanType: @escaping @Sendable (String, String) async throws -> Void,
        
        createPlan: @escaping @Sendable (Plan, Int, Int, String) async throws -> [String: [String]],
        deletePlan: @escaping @Sendable (String, Int, Bool, String) async throws -> [String: [String]],
        updatePlan: @escaping @Sendable (String, String, String) async throws -> Plan,
        readAllPlans: @escaping @Sendable (String) async throws -> [String: Plan],
        
        createLane: @escaping @Sendable (Bool, String, String) async throws -> [String: Plan],
        deleteLane: @escaping @Sendable (String, Bool, String) async throws -> [String: [String]],
        readAllLanes: @escaping @Sendable (String) async throws -> [String: Lane],
        
        createLayer: @escaping @Sendable (Int, String) async throws -> [String: [String]]
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
        self.readAllLanes = readAllLanes
        
        self.createLayer = createLayer
    }
}

extension APIService {
    static let liveValue = Self(
        // MARK: - Project
        createProject: { title in
            let id = try FirestoreService.projectCollectionPath.document().documentID
            let data = ["id": id,
                        "title": title,
                        "ownerUid": try FirestoreService.uid,
                        "createdDate": Date(),
                        "lastModifiedDate": Date(),
                        "map": ["0": [],
                                "1": [],
                                "2": []]] as [String: Any?]
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
            try FirestoreService.projectCollectionPath.document(id).delete()
        },
        // MARK: - Plan type
        readAllPlanTypes: { projectID in
            return try await FirestoreService.getDocuments(projectID, .planTypes, PlanType.self) as! [PlanType]
        },
        searchPlanTypes: { keyword, projectID in
            let snapshots = try await FirestoreService.getDocuments(projectID, .planTypes, PlanType.self) as! [PlanType]
            return snapshots.filter { $0.title.contains(keyword) }
        },
        createPlanType: { target, projectID in
            let id = try FirestoreService.getNewDocumentID(projectID, .planTypes)
            // TODO: - id 변경
            let data = ["id": "0000",
                        "title": target.title,
                        "colorCode": target.colorCode] as [String: Any]
            try await FirestoreService.setDocumentData(projectID, .planTypes, id, data)
            return id
        },
        deletePlanType: { typeID, projectID in
            try await FirestoreService.deleteDocument(projectID, .planTypes, typeID)
        },
        // MARK: - Plan
        createPlan: { target, layerIndex, rowIndex, projectID in
            let targetID = try FirestoreService.getNewDocumentID(projectID, .plans)
            /// plan에 대한  lane 생성
            let newLaneID = try FirestoreService.getNewDocumentID(projectID, .lanes)
            var data = ["id": newLaneID,
                        "childIDs": [],
                        "ownerID": targetID,
                        "periods": []] as [String: Any?]
            try await FirestoreService.setDocumentData(projectID, .lanes, newLaneID, data as [String: Any])
            
            /// parentPlanID를 조회
            var parentPlanID: String?
            if let parentLaneID = target.parentLaneID {
                parentPlanID = (try await FirestoreService.getDocument(projectID, .lanes, parentLaneID, Lane.self) as! Lane).ownerID
            }
            
            /// map 업데이트
            var map = try await FirestoreService.projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            /// 레이어를 생성해야 하는 경우인지 확인
            let currentLayerCount = map.count
            let countRowToBeCreated = map["\(currentLayerCount)"]?.count ?? 0
            if layerIndex >= currentLayerCount {
                var upperLaneID: String?
                // TODO: - parameter랑 이름 겹침
                for newLayerIndex in currentLayerCount...layerIndex {
                    map["\(newLayerIndex)"] = []
                    for newRowIndex in 0...countRowToBeCreated {
                        var createTargetPlan = false
                        /// 생겨난 레이어에도 이전 최하위 레어어의 플랜만큼 만들어줌
                        if let prevLayer = map["\(newLayerIndex-1)"] {
                            if let parentPlanID = parentPlanID,
                               newLayerIndex == layerIndex,
                               prevLayer[newRowIndex] == parentPlanID {
                                // 첫 순회때 새 플랜이 생성될 row 인덱스 조회
                                createTargetPlan = true
                            }
                            let prevLayerPlanID = prevLayer[newRowIndex]
                            
                            let newPlanID = createTargetPlan ? targetID : try FirestoreService.getNewDocumentID(projectID, .plans)
                            var dummyPlan = Plan(id: newPlanID, periods: [:], laneIDs: [newLaneID])
                            
                            if prevLayerPlanID == parentPlanID,
                               newLayerIndex == layerIndex {
                                dummyPlan = target
                                dummyPlan.laneIDs = [newLaneID]
                            }
                            let newLaneID = try FirestoreService.getNewDocumentID(projectID, .lanes)
                            data = ["id": dummyPlan.id,
                                    "planTypeID": dummyPlan.planTypeID,
                                    "parentLaneID": dummyPlan.parentLaneID,
                                    "periods": dummyPlan.periods.count == 0 ? [:] : ["0": dummyPlan.periods["0"]],
                                    "description": dummyPlan.description,
                                    "laneIDs": [newLaneID]] as [String: Any?]
                            
                            try await FirestoreService.setDocumentData(projectID, .plans, dummyPlan.id, data as [String: Any])
                            try await FirestoreService.setDocumentData(projectID, .lanes, newLaneID, ["id": newLaneID, "ownerID": dummyPlan.id])
                            if let upperLaneID = upperLaneID {
                                try await FirestoreService.updateDocumentData(projectID, .lanes, upperLaneID, ["childIDs": dummyPlan.id])
                            }
                            map["\(newLayerIndex)"]![newRowIndex] = dummyPlan.id
                            
                            if prevLayerPlanID == parentPlanID {
                                parentPlanID = prevLayerPlanID
                            }
                            upperLaneID = newLaneID
                        }
                    }
                }
                try await FirestoreService.projectCollectionPath.document(projectID).updateData(["map": map])
                return map
            }
            
            /// 새로운 레인을 생성하는 경우 == parentLane이 없는 경우
            for currentLayerIndex in 0..<currentLayerCount {
                var prevLayerLaneID: String?
                let dummyLaneCountExceptTarget = rowIndex - (map["\(currentLayerIndex)"]!.count - 1)
                for currentLaneIndex in 0..<dummyLaneCountExceptTarget {
                    let newLaneID = try FirestoreService.getNewDocumentID(projectID, .lanes)
                    // TODO: - planTypeID 처리 좀 해 ...
                    var dummyPlan = Plan(id: try FirestoreService.getNewDocumentID(projectID, .plans), planTypeID: "0000", periods: [:], laneIDs: [newLaneID])
                    if currentLayerIndex == layerIndex,
                       currentLaneIndex == dummyLaneCountExceptTarget - 1 {
                        dummyPlan = target
                        dummyPlan.id = targetID
                        dummyPlan.laneIDs = [newLaneID]
                    }
                    try await FirestoreService.setDocumentData(projectID, .lanes, newLaneID, ["id": newLaneID, "ownerID": dummyPlan.id, "childIDs": [], "periods": [:]])
                    if let prevLayerLaneID = prevLayerLaneID {
                        try await FirestoreService.updateDocumentData(projectID, .lanes, prevLayerLaneID, ["childIDs": FieldValue.arrayUnion([dummyPlan.id])])
                    }
                    data = ["id": dummyPlan.id,
                            "planTypeID": dummyPlan.planTypeID,
                            "parentLaneID": dummyPlan.parentLaneID,
                            "periods": dummyPlan.periods.count == 0 ? [:] : ["0": dummyPlan.periods["0"]],
                            "description": dummyPlan.description,
                            "laneIDs": [newLaneID]] as [String: Any?]
                    try await FirestoreService.setDocumentData(projectID, .plans, dummyPlan.id, data as [String: Any])
                    prevLayerLaneID = newLaneID
                    map["\(currentLayerIndex)"]!.append(dummyPlan.id)
                }
            }
            try await FirestoreService.projectCollectionPath.document(projectID).updateData(["map": map])
            return map
        },
        deletePlan: { planID, layerIndex, deleteAll, projectID in
            let currentPlan = try await FirestoreService.getDocument(projectID, .plans, planID, Plan.self) as! Plan
            var projectMap = try await FirestoreService.projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            if deleteAll {
                /// plan이 속해있던 parent의 childPlan의 개수가 2이상이라면 아예 삭제
                /// childPlan의 개수를 알아보자 ..;;
                var parentsChildsID = Set<String>()
                if let parentLaneID = currentPlan.parentLaneID {
                    let parentPlanID = (try await FirestoreService.getDocument(projectID, .lanes, parentLaneID, Lane.self) as! Lane).ownerID
                    let parentsLaneIDs = (try await FirestoreService.getDocument(projectID, .plans, parentPlanID, Plan.self) as! Plan).laneIDs
                    for parentsLaneID in parentsLaneIDs {
                        if let currentLanesChildIDs = (try await FirestoreService.getDocument(projectID, .lanes, parentsLaneID, Lane.self) as! Lane).childIDs {
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
                    try await FirestoreService.deleteDocument(projectID, .plans, planID)
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
                    try await FirestoreService.updateDocumentData(projectID, .plans, planID, emptyData as [String: Any])
                }
            } else {
                /// 하위 레이어는 남겨두는 경우 == periods, type만 삭제
                let emptyData = ["periods": nil, "planTypeID": nil] as [String: Any?]
                try await FirestoreService.updateDocumentData(projectID, .plans, planID, emptyData as [String: Any])
            }
            try await FirestoreService.projectCollectionPath.document(projectID).updateData(["map": projectMap])
            return projectMap
        },
        updatePlan: { planID, planTypeID, projectID in
            try await FirestoreService.updateDocumentData(projectID, .plans, planID, ["planTypeID": planTypeID])
            return try await FirestoreService.getDocument(projectID, .plans, planID, Plan.self) as! Plan
        },
        readAllPlans: { projectID in
            let plans = try await FirestoreService.getDocuments(projectID, .plans, Plan.self) as! [Plan]
            var result = [String: Plan]()
            for plan in plans {
                result[plan.id] = plan
            }
            return result
        },
        createLane: { createOnTop, planID, projectID in
            let newLane = Lane(id: try FirestoreService.getNewDocumentID(projectID, .lanes), ownerID: planID)
            var currentLaneIDs = (try await FirestoreService.getDocument(projectID, .plans, planID, Plan.self) as! Plan).laneIDs
            try await FirestoreService.updateDocumentData(projectID, .plans, planID, ["laneIDs": createOnTop ? currentLaneIDs.insert(newLane.id, at: 0) : FieldValue.arrayUnion([newLane.id])])
            
            let plans = try await FirestoreService.getDocuments(projectID, .plans, Plan.self) as! [Plan]
            var result = [String: Plan]()
            for plan in plans {
                result[plan.id] = plan
            }
            return result
        },
        deleteLane: { laneID, deleteAll, projectID in
            // TODO: -
            return [:]
        },
        readAllLanes: { projectID in
            let snapshots = try await FirestoreService.getDocuments(projectID, .lanes, Lane.self) as! [Lane]
            var result = [String: Lane]()
            for snapshot in snapshots {
                result[snapshot.id] = snapshot
            }
            return result
        },
        createLayer: { layerIndex, projectID in
            /// projectMap에 새 레이어를 추가
            var projectMap = try await FirestoreService.projectCollectionPath.document(projectID).getDocument(as: Project.self).map
            let currentProjectMapLayerSize = projectMap.count
            
            if (currentProjectMapLayerSize - 1) < layerIndex + 1 {
                /// 이미 있는 레이어와 레이어 사이에 생성하는 것이 아닌, map에 아직 없는 레이어를 추가하는 경우: 레이어만 추가
                for currentLayerIndex in currentProjectMapLayerSize...layerIndex + 1 {
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
                                let newLaneID = try FirestoreService.getNewDocumentID(projectID, .lanes)
                                let newPlan = Plan(id: UUID().uuidString, periods: [:], laneIDs: [newLaneID])
                                let newLane = Lane(id: newLaneID, childIDs: [planID], ownerID: newPlan.id)
                                newFirstLayer.append(newPlan.id)
                                try await FirestoreService.setDocumentData(projectID, .plans, newPlan.id, ["id": newPlan.id, "periods": [], "laneIDs": []])
                                try await FirestoreService.setDocumentData(projectID, .lanes, newLaneID, ["id": newLaneID, "ownerID": newPlan.id])
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
                        let upperPlan = try await FirestoreService.getDocument(projectID, .plans, planIDInUpperLayer, Plan.self) as! Plan
                        var newUpperPlansLanes = []
                        /// 가지는 lane만큼
                        for laneIndex in 0..<upperPlan.laneIDs.count {
                            /// 빈 플랜을 생성해
                            var newPlan = Plan(id: UUID().uuidString, periods: [:], laneIDs: [])
                            newUpperPlansLanes.append(newPlan.id)
                            projectMap[layerIndex.description]!.append(newPlan.id)
                            
                            /// upper plan의 lane을 새로 생성된 빈 플랜으로 옮겨주고,
                            newPlan.laneIDs.insert(upperPlan.laneIDs[laneIndex], at: laneIndex)
                            try await FirestoreService.setDocumentData(projectID, .plans, newPlan.id, ["id": newPlan.id, "periods": [], "laneIDs": newPlan.laneIDs])
                            
                            /// 그 child plan의 lane들이 가리키는 planID를 생성된 plan으로 변경
                            for laneID in upperPlan.laneIDs {
                                try await FirestoreService.updateDocumentData(projectID, .lanes, laneID, ["planIDs": newPlan.id])
                            }
                        }
                        /// 부모 플랜이 가지는 laneIDs도 업데이트
                        try await FirestoreService.updateDocumentData(projectID, .plans, upperPlan.id, ["laneIDs": newUpperPlansLanes])
                    }
                }
            }
            /// 수정된 map을 다시 해당 프로젝트에 업데이트
            try await FirestoreService.projectCollectionPath.document(projectID).updateData(["map": projectMap])
            return projectMap
        }
    )
    
    /// 비우기만
    static func emptyOutPlanWithAllChild(
        currentPlan: Plan,
        currentLayerIndex: Int,
        _ projectMap: inout [String: [String]],
        projectID: String
    ) async throws {
        for laneID in currentPlan.laneIDs {
            /// plan이 가진 lane들에 속한 plan을 먼저 삭제, 재귀적으로 최하위까지 비움
            let currentLane = try await FirestoreService.getDocument(projectID, .lanes, laneID, Lane.self) as! Lane
            if let childIDs = currentLane.childIDs {
                for planID in childIDs {
                    let nextPlan = try await FirestoreService.getDocument(projectID, .plans, planID, Plan.self) as! Plan
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
                        try await FirestoreService.updateDocumentData(projectID, .plans, planID, emptyData as [String: Any])
                    } else {
                        try await FirestoreService.deleteDocument(projectID, .plans, planID)
                        projectMap["\(currentLayerIndex)"]!.remove(at: projectMap["\(currentLayerIndex)"]!.firstIndex(of: currentPlan.id)!)
                    }
                }
            }
            /// 하나의 lane(첫 lane)은 제외하고 나머지 lane들은 삭제
            if laneID == currentPlan.laneIDs.first! { continue }
            try await FirestoreService.deleteDocument(projectID, .lanes, laneID)
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
            let currentLane = try await FirestoreService.getDocument(projectID, .lanes, laneID, Lane.self) as! Lane
            if let childIDs = currentLane.childIDs {
                for planID in childIDs {
                    let nextPlan = try await FirestoreService.getDocument(projectID, .plans, planID, Plan.self) as! Plan
                    try await deletePlanWithAllChild(
                        currentPlan: nextPlan,
                        currentLayerIndex: currentLayerIndex + 1,
                        &projectMap,
                        projectID: projectID
                    )
                    try await FirestoreService.deleteDocument(projectID, .plans, planID)
                    projectMap["\(currentLayerIndex)"]!.remove(at: projectMap["\(currentLayerIndex)"]!.firstIndex(of: currentPlan.id)!)
                }
            }
            /// 하나의 lane(첫 lane)은 제외하고 나머지 lane들은 삭제
            if laneID == currentPlan.laneIDs.first { continue }
            try await FirestoreService.deleteDocument(projectID, .lanes, laneID)
        }
    }
}
