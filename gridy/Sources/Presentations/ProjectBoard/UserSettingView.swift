//
//  UserSettingView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct UserSettingView: View {
    let store: StoreOf<ProjectBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .center, spacing: 8) {
                profile.padding(.bottom, 24)
                theme
                settings
                logOut
            }
            .frame(width: 264, height: 300)
        }
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
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.isThemeSettingPresented {
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
                        .foregroundStyle(viewStore.hoveredItem == .themeSettingButton ? Color.blackWhite : .clear)
                )
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .themeSettingButton : "")
                    )
                }
                .onTapGesture {
                    viewStore.send(.popoverPresent(
                        button: .themeSettingButton,
                        bool: true
                    ))
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

extension UserSettingView {
    var settings: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                    .foregroundStyle(viewStore.hoveredItem == .settingButton ? Color.blackWhite : .clear)
            )
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .settingButton : "")
                )
            }
            .onTapGesture {
                viewStore.send(.popoverPresent(
                    button: .settingButton,
                    bool: true
                ))
            }
            .padding(.horizontal, 16)
        }
    }
}

extension UserSettingView {
    var logOut: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                    .foregroundStyle(viewStore.hoveredItem == .logoutButton ? Color.blackWhite : .clear)
            )
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .logoutButton : "")
                )
            }
            .onTapGesture {
                viewStore.send(.popoverPresent(
                    button: .logoutButton,
                    bool: true
                ))
            }
            .padding(.horizontal, 16)
        }
    }
}
