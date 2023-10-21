//
//  SelectedGridRange.swift
//  gridy
//
//  Created by 최민규 on 10/8/23.
//

import SwiftUI

struct SelectedGridRange: Identifiable, Hashable {
    let id = UUID()
    var start: (row: Int, col: Int)
    var end: (row: Int, col: Int)

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SelectedGridRange, rhs: SelectedGridRange) -> Bool {
        return lhs.id == rhs.id
    }
}
