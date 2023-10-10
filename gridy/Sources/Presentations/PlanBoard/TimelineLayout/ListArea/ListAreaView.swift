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
    @State var largeTaskTexts: [String] = Array(repeating: "", count: 20)
    @State var leftSmallTaskTexts: [String] = Array(repeating: "", count: 20)
    @State var rightSmallTaskTexts: [String] = Array(repeating: "", count: 20)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if !isRightButtonClicked && !isLeftButtonClicked {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<largeTaskTexts.count, id: \.self) { index in
                        LargeTaskElementView(isLeftButtonClicked: $isLeftButtonClicked, isRightButtonClicked: $isRightButtonClicked, largeTaskElementTextField: $largeTaskTexts[index])
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<leftSmallTaskTexts.count, id: \.self) { index in
                            LeftSmallTaskElementView(leftSmallTaskElementTextField: $leftSmallTaskTexts[index], numbersOfGroupCell: $numbersOfGroupCell)
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<rightSmallTaskTexts.count, id: \.self) { index in
                            RightSmallTaskElementView(isTopButtonClicked: $isTopButtonClicked, isBottomButtonClicked: $isBottomButtonClicked, rightSmallTaskElementTextField: $rightSmallTaskTexts[index])
                        }
                    }
                }
            }
        }
        .frame(width: 266)
        .onChange(of: isRightButtonClicked) { newValue in
            if newValue {
                leftSmallTaskTexts = largeTaskTexts
            }
        }
        .onChange(of: isLeftButtonClicked) { newValue in
            if newValue {
                rightSmallTaskTexts = largeTaskTexts
            }
        }
    }
}

struct ListAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ListAreaView()
    }
}
