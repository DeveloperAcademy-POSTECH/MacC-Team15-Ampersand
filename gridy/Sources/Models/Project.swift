//
//  Project.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import Foundation

struct Project: Identifiable, Decodable, Equatable {
    var id: String
    var title: String
    var ownerUid: String
    var period: [Date]
    var createdDate: Date
    var lastModifiedDate: Date
    let rootPlanID: String
    
    static let mock = Project(
        id: "",
        title: "",
        ownerUid: "",
        period: [Date(), Date()],
        createdDate: Date(),
        lastModifiedDate: Date(),
        rootPlanID: ""
    )
}
