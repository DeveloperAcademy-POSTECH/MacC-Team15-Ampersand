//
//  Project.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import Foundation

struct Project: Identifiable, Decodable {
    var id: String
    var title: String
    var ownerUid: String
    let createdDate: Date
    var lastModifiedDate: Date
    var planIDs: [String]?
    
    static let mock = Project(
        id: "",
        title: "",
        ownerUid: "",
        createdDate: Date(),
        lastModifiedDate: Date()
    )
}

extension Project: Equatable { }
