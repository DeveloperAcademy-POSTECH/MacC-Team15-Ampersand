//
//  LogoutView.swift
//  gridy
//
//  Created by xnoag on 11/5/23.
//

import SwiftUI
import ComposableArchitecture

struct LogoutView: View {
    let store: StoreOf<ProjectBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .center, spacing: 8) {
                Text("Logout Message")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.title)
                Text("Logout Message")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.subtitle)
                    .padding(.bottom, 16)
                HStack(alignment: .center, spacing: 8) {
                    cancel
                    logout
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.blackWhite)
            )
            .frame(width: 300, height: 150)
        }
    }
}

extension LogoutView {
    var cancel: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.popoverPresent(
                    button: .logoutButton,
                    bool: false
                ))
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(viewStore.hoveredItem == .cancelButton ? Color.buttonHovered : .button)
                    .frame(height: 32)
                    .overlay(
                        Text("Cancel")
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.buttonText)
                    )
            }
            .buttonStyle(.link)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .cancelButton : ""))
            }
        }
    }
}

extension LogoutView {
    var logout: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                // TODO: - Logout Button
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(viewStore.hoveredItem == "logoutButton" ? Color.buttonHovered : .button)
                    .frame(height: 32)
                    .overlay(
                        Text("Logout")
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.buttonText)
                    )
            }
            .buttonStyle(.link)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? "logoutButton" : ""))
            }
        }
    }
}
