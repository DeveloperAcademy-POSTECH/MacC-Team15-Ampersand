//
//  Project.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import Foundation

struct Project: Decodable {
    var pid: String
    var title: String
    var ownerUid: String
    let createdDate: Date
    var lastModifiedDate: Date
    
    static let mock = Project(
        pid: "",
        title: "",
        ownerUid: "",
        createdDate: Date(),
        lastModifiedDate: Date()
    )
}

extension Project: Identifiable {
    var id: String { pid }
}

extension Project: Equatable { }
