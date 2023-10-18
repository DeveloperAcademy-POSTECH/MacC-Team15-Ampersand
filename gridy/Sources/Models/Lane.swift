//
//  Lane.swift
//  gridy
//
//  Created by 제나 on 10/16/23.
//

import Foundation

struct Lane: Identifiable, Decodable {
    var id: String
    var childIDs: [String]?
    var ownerID: String
    
    /// Computed property by child's (minimum designated Date, maximum designated Date)
    var period: [[Date]]?
}
