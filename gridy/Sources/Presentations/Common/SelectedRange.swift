//
//  SelectedRange.swift
//  gridy
//
//  Created by 최민규 on 10/8/23.
//

import SwiftUI

struct SelectedRange: Identifiable, Hashable {
    let id = UUID()
    let start: (Int, Int)
    let end: (Int, Int)

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SelectedRange, rhs: SelectedRange) -> Bool {
        return lhs.id == rhs.id
    }
}
