//
//  Plan.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import Foundation

struct Plan: Identifiable {
    var id: String
    var planTypeID: String
    var parentID: String
    var startDate: Date?
    var endDate: Date?
    var description: String
}
