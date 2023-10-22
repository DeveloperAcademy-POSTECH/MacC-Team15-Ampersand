//
//  PlanType.swift
//  gridy
//
//  Created by 제나 on 10/12/23.
//

import Foundation

struct PlanType: Identifiable, Equatable, Decodable {
    var id: String
    var title: String
    var colorCode: UInt
    
    static let mock = PlanType(id: "", title: "", colorCode: 0x000000)
}
