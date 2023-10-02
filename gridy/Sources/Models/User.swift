//
//  User.swift
//  gridy
//
//  Created by 제나 on 2023/10/01.
//

import Foundation

struct User: Decodable {
    var uid: String
    var username: String
    var email: String
    
    static let mock = User(
        uid: "",
        username: "ZENA",
        email: "dayo2n@gridy.do"
    )
}

extension User: Identifiable {
    var id: String { uid }
}

extension User: Equatable { }
