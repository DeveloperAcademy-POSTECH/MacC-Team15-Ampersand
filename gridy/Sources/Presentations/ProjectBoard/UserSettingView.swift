//
//  UserSettingView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct UserSettingView: View {
    @State var themeHover = false
    @State var themeClicked = false
    @State var settingsHover = false
    @State var settingsClicked = false
    @State var logOutHover = false
    @State var logOutClicked = false
    @State var automaticHover = false
    @State var automaticClicked = false
    @State var lightHover = false
    @State var lightClicked = false
    @State var darkHover = false
    @State var darkClicked = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.blackWhite.opacity(0.5))
            VStack(alignment: .center, spacing: 8) {
                profile.padding(.bottom, 24)
                theme
                settings
                logOut
            }
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
                    .font(.title3)
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
                .font(.title3)
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
                .font(.title3)
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

extension UserSettingView {
    var themeSelect: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 0) {
                Text("Automatic")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.title)
                Spacer()
                Image(systemName: "checkmark").foregroundStyle(automaticClicked ? Color.title : .clear)
            }
            .frame(height: 40)
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(automaticClicked ? Color.blackWhite : automaticHover ? Color.blackWhite : .clear)
            )
            .onHover { proxy in
                automaticHover = proxy
            }
            .onTapGesture {
                automaticClicked = true
                lightClicked = false
                darkClicked = false
            }
            
            HStack(alignment: .center, spacing: 0) {
                Text("Light")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.title)
                Spacer()
                Image(systemName: "checkmark").foregroundStyle(lightClicked ? Color.title : .clear)
            }
            .frame(height: 40)
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(lightClicked ? Color.blackWhite : lightHover ? Color.blackWhite : .clear)
            )
            .onHover { proxy in
                lightHover = proxy
            }
            .onTapGesture {
                automaticClicked = false
                lightClicked = true
                darkClicked = false
            }
            
            HStack(alignment: .center, spacing: 0) {
                Text("Dark")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.title)
                Spacer()
                Image(systemName: "checkmark").foregroundStyle(darkClicked ? Color.title : .clear)
            }
            .frame(height: 40)
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(darkClicked ? Color.blackWhite : darkHover ? Color.blackWhite : .clear)
            )
            .onHover { proxy in
                darkHover = proxy
            }
            .onTapGesture {
                automaticClicked = false
                lightClicked = false
                darkClicked = true
            }
        }
        .padding(16)
        .frame(width: 170, height: 168)
    }
}

#Preview {
    UserSettingView()
}
