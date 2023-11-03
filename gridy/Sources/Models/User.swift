//
//  User.swift
//  gridy
//
//  Created by 제나 on 2023/10/01.
//

import Foundation

struct User: Decodable {
    var uid: String
    var email: String
    var firstName: String
    var lastName: String

    var job: String?
    var profileImageURL: String?

    var username: String {
        "\(firstName) \(lastName)"
    }
    
    static let mock = User(
        uid: "",
        email: "dayo2n@gridy.do",
        firstName: "Dayeon",
        lastName: "Moon",
        job: "Developer"
    )
}

extension User: Identifiable {
    var id: String { uid }
}

extension User: Equatable { }
