//
//  Schedule.swift
//  gridy
//
//  Created by SY AN on 11/19/23.
//

import Foundation

struct Schedule: Identifiable, Equatable, Decodable {
    var id: String
    var title: String?
    var startDate: Date
    var endDate: Date
    var colorCode: UInt
    
    static let mock = Schedule(id: "", startDate: Date(), endDate: Date(), colorCode: 0x000000)
}
