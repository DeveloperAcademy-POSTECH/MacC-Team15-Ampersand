//
//  ListAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct ListAreaView: View {
    @State var isLeftButtonClicked = false
    @State var isRightButtonClicked = false
    @State var isTopButtonClicked = false
    @State var isBottomButtonClicked = false
    @State var numbersOfGroupCell = 1
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
        }
        .frame(width: 266)
    }
}

struct ListAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ListAreaView()
    }
}
