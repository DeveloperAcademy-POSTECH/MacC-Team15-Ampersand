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
    
    var body: some View {
        Text("Hello")
    }
}

struct ListAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ListAreaView()
    }
}
