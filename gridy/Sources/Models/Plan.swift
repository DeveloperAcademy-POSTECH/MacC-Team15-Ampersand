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
    var periods: [Int: [Date]] /// [index: [startDate, endDate]]
    var description: String?
    var laneIDs: [String]
    
    static let mock = Plan(id: "", planTypeID: "", parentLaneID: "", periods: [:], description: "", laneIDs: [])
}
