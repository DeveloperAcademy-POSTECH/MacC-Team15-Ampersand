//
//  Task.swift
//  gridy
//
//  Created by 최민규 on 10/8/23.
//

import SwiftUI

struct Grid: Identifiable {

    let id = UUID()
    let item: Item
    let date: Date

}

extension Grid: Equatable {
    static func ==(lhs: Grid, rhs: Grid) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}
