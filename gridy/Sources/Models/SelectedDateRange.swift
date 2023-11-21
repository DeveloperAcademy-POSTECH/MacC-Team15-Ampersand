//
//  SelectedDateRange.swift
//  gridy
//
//  Created by 최민규 on 10/18/23.
//

import SwiftUI

struct SelectedDateRange: Identifiable, Hashable, Codable {
    let id = UUID()
    var start: Date
    var end: Date
}
