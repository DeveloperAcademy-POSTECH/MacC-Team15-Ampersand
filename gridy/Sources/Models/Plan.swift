//
//  Plan.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import Foundation

struct Plan: Identifiable, Equatable, Decodable {
    var id: String
    
    /// If planTypeID is nil, this plan data becomes a dummy.
    var planTypeID: String?
    
    /// If parentID is nil, this plan data must be on root layer
    var parentID: String?
    var periods: [[Date]]?
    var description: String?
    var laneIDs: [String]?
    
    static let mock = Plan(id: "", planTypeID: "", parentID: "", description: "", laneIDs: [""])
}
