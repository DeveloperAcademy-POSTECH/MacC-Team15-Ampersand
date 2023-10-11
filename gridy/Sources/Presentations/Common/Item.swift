//
//  Item.swift
//  gridy
//
//  Created by 최민규 on Date()0/8/23.
//

import SwiftUI

struct Item: Identifiable, Equatable {
    
    let id = UUID()
    let name: String
    let start: Date?
    let end: Date?
    var items: [String]
    
    init(name: String, start: Date?, end: Date?, items: [String]) {
        self.name = name
        self.start = start
        self.end = end
        self.items = items
    }
}

extension Item {
   static let sampleItems: [Item] = [
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: []),
        Item(name: "D", start: Date(), end: Date(), items: []),
        Item(name: "E", start: Date(), end: Date(), items: []),
        Item(name: "F", start: Date(), end: Date(), items: []),
        Item(name: "A", start: Date(), end: Date(), items: []),
        Item(name: "B", start: Date(), end: Date(), items: []),
        Item(name: "C", start: Date(), end: Date(), items: [])
    ]
}
