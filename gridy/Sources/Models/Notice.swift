//
//  Notice.swift
//  gridy
//
//  Created by 제나 on 11/8/23.
//

import Foundation

struct Notice: Decodable, Equatable {
    let issuedDate: Date
    var contents: String
}
