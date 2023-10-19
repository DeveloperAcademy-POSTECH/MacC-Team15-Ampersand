//
//  SelectedDateRange.swift
//  gridy
//
//  Created by 최민규 on 10/18/23.
//

import SwiftUI

struct SelectedDateRange: Identifiable, Hashable {
    let id = UUID()
    var start: Date
    var end: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SelectedDateRange, rhs: SelectedDateRange) -> Bool {
        return lhs.id == rhs.id
    }
}
