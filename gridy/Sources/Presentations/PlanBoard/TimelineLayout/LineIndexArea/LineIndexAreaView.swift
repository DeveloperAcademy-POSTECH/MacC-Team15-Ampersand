//
//  LineIndexAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct LineIndexAreaView: View {
    var body: some View {
        // TODO: LineIndexArea (하위코드삭제)
        ZStack {
            Rectangle()
                .foregroundStyle(.white)
                .border(.gray)
            Text("LineIndexArea")
                .frame(maxHeight: .infinity)
        }
    }
}

struct LineIndexAreaView_Previews: PreviewProvider {
    static var previews: some View {
        LineIndexAreaView()
    }
}
