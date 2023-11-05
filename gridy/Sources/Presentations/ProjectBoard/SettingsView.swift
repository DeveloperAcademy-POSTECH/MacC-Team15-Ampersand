//
//  SettingsView.swift
//  gridy
//
//  Created by xnoag on 11/5/23.
//

import SwiftUI

struct SettingsView: View {
    @State var profileHover = false
    @State var profileClicked = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            profileImage
        }
    }
}

extension SettingsView {
    var profileImage: some View {
        Image("LiLyProfile")
            .resizable()
            .frame(width: 96, height: 96)
            .overlay(alignment: .bottom) {
                if profileHover {
                    Text("편집")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.blackWhite)
                        .padding(.bottom, 6)
                        .background(
                            Rectangle()
                                .foregroundStyle(.black)
                                .frame(width: 96, height: 30)
                                .blur(radius: 12)
                        )
                }
            }
            .clipShape(Circle())
            .onHover { proxy in
                profileHover = proxy
            }
            .onTapGesture { profileClicked = true }
    }
}

#Preview {
    SettingsView()
}
