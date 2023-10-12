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
    @State var largeTaskTexts: [String] = Array(repeating: "", count: 20)
    @State var leftSmallTaskTuples: [(Int, String)] = []
    @State var rightSmallTaskTuples: [(Int, String)] = []
    @State var clickedIndex = -1
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if !isRightButtonClicked && !isLeftButtonClicked {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<largeTaskTexts.count, id: \.self) { index in
                        LargeTaskElementView(
                            isLeftButtonClicked: $isLeftButtonClicked,
                            isRightButtonClicked: $isRightButtonClicked,
                            largeTaskElementTextField: $largeTaskTexts[index]
                        )
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<leftSmallTaskTuples.count, id: \.self) { index in
                            LeftSmallTaskElementView(leftSmallTaskTuple: $leftSmallTaskTuples[index])
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<rightSmallTaskTuples.count, id: \.self) { index in
                            RightSmallTaskElementView(
                                rightSmallTaskTuple: $rightSmallTaskTuples[index],
                                isTopButtonClicked: $isTopButtonClicked,
                                isBottomButtonClicked: $isBottomButtonClicked,
                                clickedIndex: $clickedIndex,
                                myIndex: index
                            )
                        }
                    }
                }
            }
        }
        .frame(width: 266)
        .onAppear {
            leftSmallTaskTuples = Array(repeating: (1, ""), count: 20)
            rightSmallTaskTuples = (0..<20).map { ($0, "") }
        }
        .onChange(of: isRightButtonClicked) { newValue in
            if newValue {
                leftSmallTaskTuples = largeTaskTexts.enumerated().map { _, stringValues in
                    return(1, stringValues)
                }
            }
        }
        .onChange(of: isLeftButtonClicked) { newValue in
            if newValue {
                rightSmallTaskTuples = largeTaskTexts.enumerated().map { index, stringValues in
                    return(index, stringValues)
                }
            }
        }
        .onChange(of: isTopButtonClicked) { newValue in
            if newValue {
                rightSmallTaskTuples.insert((rightSmallTaskTuples[clickedIndex].0, ""), at: clickedIndex)
                leftSmallTaskTuples[rightSmallTaskTuples[clickedIndex].0].0 += 1
                isTopButtonClicked = false
            }
        }
        .onChange(of: isBottomButtonClicked) { newValue in
            if newValue {
                rightSmallTaskTuples.insert((rightSmallTaskTuples[clickedIndex].0, ""), at: clickedIndex + 1)
                leftSmallTaskTuples[rightSmallTaskTuples[clickedIndex].0].0 += 1
                isBottomButtonClicked = false
            }
        }
    }
}

struct ListAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ListAreaView()
    }
}
