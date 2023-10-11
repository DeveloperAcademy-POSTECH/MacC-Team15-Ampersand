//
//  GridView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct GridItemView: View {
    let width: CGFloat
    let height: CGFloat
    let item: Item

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Text("\(item.name)")
        }.frame(width: width, height: height)
    }
}
//
//struct GridItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        GridItemView(width: 50, height: 50, item: Item(name: "hello", start: Date(), end: Date(), items: []))
//    }
//}
