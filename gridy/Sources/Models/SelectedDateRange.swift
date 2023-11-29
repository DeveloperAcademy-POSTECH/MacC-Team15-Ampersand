//
//  SelectedDateRange.swift
//  gridy
//
//  Created by 최민규 on 10/18/23.
//

import SwiftUI

struct SelectedDateRange: Hashable {
    var start: Date
    var end: Date
    
    static func == (lhs: SelectedDateRange, rhs: SelectedDateRange) -> Bool {
        return lhs.start == rhs.start
        && lhs.end == rhs.end
    }
}
