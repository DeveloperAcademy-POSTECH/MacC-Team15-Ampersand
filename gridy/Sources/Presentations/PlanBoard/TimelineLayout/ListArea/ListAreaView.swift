//
//  ListAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct ListAreaView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<30) { _ in
                    ListElementView()
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
