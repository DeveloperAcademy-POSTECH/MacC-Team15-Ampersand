//
//  ListElementView.swift
//  gridy
//
//  Created by xnoag on 10/5/23.
//

import SwiftUI

struct ListElementView: View {
    @State private var isHovering = false
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.white)
            .frame(width: 266, height: 48)
            .border(Color.gray, width: 0.3)
            .overlay {
                if isHovering {
                    Button(action: {
                        print("gaon")
                    }) {
                        Text("Add a new Task")
                            .foregroundColor(.gray)
                            .font(.custom("Pretendard-Bold", size: 16))
                    }
                    .frame(width: 264, height: 44)
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                }
            }
            .onHover { phase in
                isHovering = phase
            }
    }
}

#Preview {
    ListElementView()
}
