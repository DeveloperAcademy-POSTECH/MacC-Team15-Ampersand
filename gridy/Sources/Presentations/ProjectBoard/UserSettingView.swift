//
//  UserSettingView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct UserSettingView: View {
    @State var themeHover = false
    @State var settingsHover = false
    @State var settingsClicked = false
    @State var logOutHover = false
    @State var logOutClicked = false
    @Binding var themeClicked: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            profile.padding(.bottom, 24)
            theme
            settings
            logOut
        }
        .frame(width: 264, height: 300)
    }
}

extension UserSettingView {
    var profile: some View {
        VStack(alignment: .center, spacing: 16) {
            Circle()
                .frame(width: 48, height: 48)
            Text("한가온")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.title)
        }
    }
}

extension UserSettingView {
    var theme: some View {
        ZStack {
            if themeClicked {
                Rectangle()
                    .foregroundStyle(Color.blackWhite)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 8,
                            bottomLeadingRadius: 8,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0,
                            style: .continuous
                        )
                    )
                    .padding(.leading, 16)
                    .frame(height: 40)
            }
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "circle.lefthalf.filled")
                Text("Theme")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.title)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .frame(height: 40)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(themeHover ? Color.blackWhite : .clear)
            )
            .onHover { proxy in
                themeHover = proxy
            }
            .onTapGesture { themeClicked = true }
            .padding(.horizontal, 16)
        }
    }
}

extension UserSettingView {
    var settings: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "gear")
            Text("Settings")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color.title)
            Spacer()
        }
        .frame(height: 40)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(settingsClicked ? Color.blackWhite : settingsHover ? Color.blackWhite : .clear)
        )
        .onHover { proxy in
            settingsHover = proxy
        }
        .onTapGesture {
            themeClicked = false
            settingsClicked = true
        }
        .padding(.horizontal, 16)
    }
}

extension UserSettingView {
    var logOut: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
            Text("Logout")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color.title)
            Spacer()
        }
        .frame(height: 40)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(logOutClicked ? Color.blackWhite : logOutHover ? Color.blackWhite : .clear)
        )
        .onHover { proxy in
            logOutHover = proxy
        }
        .onTapGesture {
            settingsClicked = false
            logOutClicked = true
        }
        .padding(.horizontal, 16)
    }
}
