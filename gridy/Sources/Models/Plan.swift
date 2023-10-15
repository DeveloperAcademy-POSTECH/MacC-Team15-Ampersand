//
//  Plan.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import Foundation

struct Plan: Identifiable, Equatable, Decodable {
    var id: String
    var planTypeID: String
    var parentID: String
    var startDate: Date?
    var endDate: Date?
    var description: String
    
    static let mock = Plan(id: "", planTypeID: "", parentID: "", description: "")
}
