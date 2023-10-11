//
//  Plan.swift
//  gridy
//
//  Created by 최민규 on 10/11/23.
//

import SwiftUI

class Plan: Identifiable {
    
    let id: String
    let name: String
    let start: Date?
    let end: Date?
    var childs: [String]
    
    init(id: String, name: String, start: Date?, end: Date?, childs: [String]) {
        self.id = id
        self.name = name
        self.start = start
        self.end = end
        self.childs = childs
    }

}

struct ItemTreeView: View {
    
    @State private var ids: [String] = ["b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    @State private var sampleItems = [
        Plan(id: "henry", name: "Henry", start: nil, end: nil, childs: ["a"]),
        Plan(id: "a", name: "a", start: nil, end: nil, childs: [])
    ]
    
    var body: some View {
        HStack {
            let keyItem = sampleItems[0]
            Text(keyItem.name)
                .padding()
                .onTapGesture {
                    let newId = newId()
                    sampleItems.append(Plan(id: newId, name: newId, start: nil, end: nil, childs: []))
                    sampleItems.filter { $0.id == keyItem.id }[0].childs.append(newId)
                    print(keyItem.childs)
                    print(sampleItems)
                }
            VStack(alignment: .leading) {
                ForEach(keyItem.childs, id: \.self) { planId in
                    HStack {
                        Text(sampleItems.filter { $0.id == planId }[0].id)
                            .padding()
                            .onTapGesture {
                                let newId = newId()
                                sampleItems.append(Plan(id: newId, name: newId, start: nil, end: nil, childs: []))
                                sampleItems.filter { $0.id == planId }[0].childs.append(newId)
                                print(keyItem.childs)
                                print(sampleItems)
                            }
                        VStack(alignment: .leading) {
                            ForEach(sampleItems.filter { $0.id == planId }[0].childs, id: \.self) { planId in
                                Text(sampleItems.filter { $0.id == planId }[0].id)
                                    .padding()

                            }
                        }
                        .border(.red)
                    }
                    .border(.blue)
                }
            }
        }
    }
  
    func newId() -> String {
        let value = ids.first
        ids.removeFirst()
        return value!
    }
}
struct ItemTreeView_Previews: PreviewProvider {
    static var previews: some View {
        ItemTreeView().frame(width: 500, height: 500)
    }
}
