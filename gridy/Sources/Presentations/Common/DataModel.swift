//
//  DataModel.swift
//  gridy
//
//  Created by 최민규 on 10/8/23.
//

import Foundation

class DataModel: ObservableObject {
    
    @Published var items: [Item] = []
    
    init() {
        //TODO: 서버에서 Item배열 정보를 불러와서 items 변수에 부여한다.
    }
    
    func addItem(_ item: Item) {
        items.insert(item, at: 0)
    }
    
    func removeItem(_ item: Item) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            //TODO: 서버에서 해당 item을 찾아서 삭제한다.
        }
    }
}
