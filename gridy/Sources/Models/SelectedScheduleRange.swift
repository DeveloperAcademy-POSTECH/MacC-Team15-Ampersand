//
//  SelectedScheduleRange.swift
//  gridy
//
//  Created by xnoag on 11/20/23.
//

import SwiftUI

struct SelectedScheduleRange: Identifiable, Hashable {
    let id = UUID()
    var startCol: Int
    var endCol: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SelectedScheduleRange, rhs: SelectedScheduleRange) -> Bool {
        return lhs.id == rhs.id
    }
}
