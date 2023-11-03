//
//  PlanBoard2.swift
//  gridy
//
//  Created by SY AN on 11/1/23.
//

import Foundation
import ComposableArchitecture

struct PlanBoard2: Reducer {
    
    @Dependency(\.apiService) var apiService
    
    struct State: Equatable {
        var rootProject: Project
        var rootPlan: Plan
        var map: [[String]] = [[]]
        var existingPlans = [String: Plan]()
        var existingPlanTypes = [PlanType.emptyPlanType]
        
        // MARK: - listArea
        var listLayers = [0]
    }
    
    enum Action: Equatable {
        
        case fetchMap
        case createLayerBtnClicked(layer: Int)
        case createPlanOnList(layer: Int, row: Int, text: String)
        case createPlanType(layer: Int, row: Int, text: String, colorCode: UInt)
        case updatePlanType(layer: Int, row: Int, text: String, colorCode: UInt)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case let .createPlanOnList(layer, row, text):
                if text.isEmpty {
                    return .none
                }
                
                let projectID = state.rootProject.id

                var createdPlans: [Plan] = []
                var createdPlanType = PlanType.mock
                
                var parentPlanID = state.rootPlan.id
                var newPlanID = UUID().uuidString
                var childPlanID = UUID().uuidString
                var newPlanTypeID = PlanType.emptyPlanType.id
                
                /// map에 dummy 생성
                for rowIndex in state.map[layer].count...row {
                    for layerIndex in 0...layer {
                        
                        /// 맨 마지막일 때는 text를 title로 하는 planType을 가지고 생성
                        if (rowIndex == row - 1) && (layerIndex == layer - 1) {
                            let newPlanType = PlanType(
                                id: UUID().uuidString,
                                title: text,
                                colorCode: PlanType.emptyPlanType.colorCode
                            )
                            state.existingPlanTypes.append(newPlanType)
                            createdPlanType = newPlanType
                            newPlanTypeID = newPlanType.id
                        }
                        
                        /// dummy로 넣어줄 plan 생성
                        let newPlan = Plan(
                            id: newPlanID,
                            planTypeID: newPlanTypeID,
                            childPlanIDs: ["0": layerIndex == layer ? [] : [childPlanID]]
                        )
                        state.existingPlans[newPlanID] = newPlan
                        createdPlans.append(newPlan)
                        
                        /// 부모의 childPlan을 대체
                        state.existingPlans[parentPlanID]!.childPlanIDs[String(rowIndex)] = [newPlanID]
                        
                        parentPlanID = newPlanID
                        newPlanID = childPlanID
                        childPlanID = UUID().uuidString
                    }
                    parentPlanID = state.rootPlan.id
                    newPlanID = UUID().uuidString
                    childPlanID = UUID().uuidString
                }
                
                let plansToCreate = createdPlans
                let layerIndex = layer
                let newPlanType = createdPlanType
                
                return .run { send in
                    await send(.fetchMap)
                    try await apiService.createPlanOnListArea(
                        plansToCreate,
                        layerIndex,
                        projectID
                    )
                    
                    try await apiService.createPlanType(
                        newPlanType,
                        projectID
                    )
                }
                
                
            case let .createPlanType(layer, row, text, colorCode):
                let projectID = state.rootProject.id
                let existingPlanID = state.map[layer][row]
                let existingPlan = state.existingPlans[existingPlanID]!
                
                let newPlanTypeID = UUID().uuidString
                let newPlanType = PlanType(
                    id: newPlanTypeID,
                    title: text,
                    colorCode: colorCode
                )
                
                state.existingPlanTypes.append(newPlanType)
                state.existingPlans[existingPlanID]!.planTypeID = newPlanTypeID
                
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.createPlanType(
                        newPlanType,
                        projectID
                    )
                    
                    try await apiService.updatePlanType(
                        existingPlanID,
                        newPlanTypeID,
                        projectID
                    )
                }
                
            case let .updatePlanType(layer, row, text, colorCode):
                let projectID = state.rootProject.id
                let existingPlanID = state.map[layer][row]
                let existingPlan = state.existingPlans[existingPlanID]!
                let existingPlanTypeID = existingPlan.planTypeID
                let existingPlanType = state.existingPlanTypes.first(where: {$0.id == existingPlanTypeID})!
                
                /// 똑같은게 들어온 경우 > 실행 안 함
                if existingPlanType.id == state.existingPlanTypes.first(where: { $0.title == text && $0.colorCode  == colorCode})?.id {
                    return .none
                }
                
                /// planType이 없는 경우
                if state.existingPlanTypes.first(where: { $0.title == text && $0.colorCode  == colorCode}) == nil {
                    return .run { send in
                        await send(
                            .createPlanType(layer: layer, row: row, text: text, colorCode: colorCode)
                        )
                    }
                }
                
                /// planType이 있는 경우
                let foundPlanTypeID = state.existingPlanTypes.first(where: { $0.title == text && $0.colorCode  == colorCode})!.id
                
                state.existingPlans[existingPlanID]!.planTypeID = foundPlanTypeID
                
                return .run { send in
                    await send(.fetchMap)
                    try await apiService.updatePlanType(
                        existingPlanID,
                        foundPlanTypeID,
                        projectID
                    )
                }
                
            case let .createLayerBtnClicked(layer):
                let projectID = state.rootProject.id
                var updatedPlans: [Plan] = []
                var createdPlans: [Plan] = []
                
                state.map.insert([], at: layer)
                
                let prevLayerPlanIDs = layer == 0 ? [state.rootPlan.id] : state.map[layer-1]
                
                for prevPlanID in prevLayerPlanIDs {
                    let prevPlan = state.existingPlans[prevPlanID]!
                    
                    for index in 0..<prevPlan.childPlanIDs.count {
                        let childPlanIDs = prevPlan.childPlanIDs[String(index)]!
                        
                        let newPlanID = UUID().uuidString
                        let newPlan = Plan(id: newPlanID, planTypeID: "", childPlanIDs: [String(index): childPlanIDs])
                        
                        state.existingPlans[newPlanID] = newPlan
                        createdPlans.append(newPlan)
                        
                        state.existingPlans[prevPlanID]!.childPlanIDs[String(index)] = [newPlanID]
                        
                        if prevPlanID != state.rootPlan.id {
                            updatedPlans.append(state.existingPlans[prevPlanID]!)
                        }
                    }
                    if prevPlanID == state.rootPlan.id && state.existingPlans[prevPlanID]!.childPlanIDs.isEmpty {
                        updatedPlans.append(state.existingPlans[prevPlanID]!)
                    }
                }
                
                let plansToUpdate = updatedPlans
                let plansToCreate = createdPlans
                
                return .run { send in
                    await send(.fetchMap)
                    
                    try await apiService.createLayer(
                        plansToUpdate,
                        plansToCreate,
                        projectID
                    )
                }
                
            case .fetchMap:
                /// map 업데이트
                var newMap: [[String]] = []
                var planIDsQ: [String] = [state.rootPlan.id]
                var tempLayer: [String] = []
                
                while !planIDsQ.isEmpty {
                    for planID in planIDsQ {
                        let plan = state.existingPlans[planID]!
                        
                        for index in 0..<plan.childPlanIDs.count {
                            tempLayer.append(contentsOf: plan.childPlanIDs[String(index)]!)
                        }
                    }
                    
                    if !tempLayer.isEmpty {
                        newMap.append(tempLayer)
                    }
                    planIDsQ.removeAll()
                    planIDsQ.append(contentsOf: tempLayer)
                    tempLayer = []
                }
                state.map = newMap
                return .none
                
            default:
                return .none
            }
        }
    }
}
