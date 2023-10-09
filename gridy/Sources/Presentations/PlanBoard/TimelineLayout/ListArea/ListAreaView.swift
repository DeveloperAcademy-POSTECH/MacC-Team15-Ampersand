//
//  ListAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct ListAreaView: View {
    @State var isRightButtonClicking: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<30) { _ in
                        ListElementView(isRightButtonClicking: $isRightButtonClicking)
                            .frame(width: isRightButtonClicking ? 133 : 266, height: 48)
                    }
                }
                if isRightButtonClicking {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<30) { _ in
                            ListElementRightView()
                        }
                    }
                }
            }
        }
    }
}

struct ListAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ListAreaView()
    }
}
