//
//  Schedule.swift
//  gridy
//
//  Created by SY AN on 11/19/23.
//

import Foundation

enum ScheduleCategory: String, Decodable {
    case none
    case apple
    case google
}

struct Schedule: Identifiable, Decodable, Equatable {
    var id: String
    var title: String?
    var startDate: Date
    var endDate: Date
    var colorCode: UInt
    var category: String
    
    static let mock = Schedule(id: "", title: "", startDate: Date(), endDate: Date(), colorCode: 0x000000, category: ScheduleCategory.none.rawValue)
}
