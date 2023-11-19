//
//  Plan.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import Foundation

struct Plan: Identifiable, Equatable, Codable, Hashable {
    var id: String
    var planTypeID: String
    var childPlanIDs: [String: [String]]
    var periods: [String: [Date]]? /// [index: [startDate, endDate]
    var totalPeriod: [Date]? /// computed period for [minimum start date, maximum end date]
    var description: String?
    
    static let mock = Plan(id: "", planTypeID: PlanType.emptyPlanType.id, childPlanIDs: [:])
}
