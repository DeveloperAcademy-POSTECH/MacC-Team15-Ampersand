//
//  User.swift
//  gridy
//
//  Created by 제나 on 2023/10/01.
//

import Foundation

struct User: Decodable, Equatable {
    var uid: String
    var email: String
    var firstName: String
    var lastName: String
    
    var job: String?
    var profileImageURL: String?
}

extension User: Identifiable {
    var id: String { uid }
}

extension User {
    var fullName: String {
        let personNameFormatter = PersonNameComponentsFormatter()
        var components = PersonNameComponents()
        components.givenName = firstName
        components.familyName = lastName
        return personNameFormatter.string(from: components)
    }
    
    static let mock = User(
        uid: "",
        email: "dayo2n@gridy.do",
        firstName: "Dayeon",
        lastName: "Moon",
        job: "Developer"
    )
}
