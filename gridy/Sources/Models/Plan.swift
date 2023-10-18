//
//  Plan.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import Foundation

struct Plan: Identifiable, Equatable, Decodable {
    var id: String
    var planTypeID: String?
    
    /// If parentLaneID is nil, this plan data must be on root layer
    var parentLaneID: String?
    var periods: [[Date]]?
    var description: String?
    var laneIDs: [Int: [String]]?
    
    static let mock = Plan(id: "", planTypeID: "", parentLaneID: "", description: "", laneIDs: [0: [""]])
}
