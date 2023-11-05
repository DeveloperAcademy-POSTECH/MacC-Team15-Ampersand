//
//  LogoutView.swift
//  gridy
//
//  Created by xnoag on 11/5/23.
//

import SwiftUI

struct LogoutView: View {
    @State var cancelHover = false
    @State var logoutHover = false
    
    var body: some View {
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
    }
}

extension LogoutView {
    var cancel: some View {
        Button {
            // TODO: - Logout Cancel Button
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(cancelHover ? Color.buttonHovered : Color.button)
                .frame(width: 110, height: 32)
                .overlay(
                    Text("Cancel")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.buttonText)
                )
        }
        .buttonStyle(.link)
        .onHover { proxy in
            cancelHover = proxy
        }
    }
}

extension LogoutView {
    var logout: some View {
        Button {
            // TODO: - Logout Button
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(logoutHover ? Color.buttonHovered : Color.button)
                .frame(width: 110, height: 32)
                .overlay(
                    Text("Logout")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.buttonText)
                )
        }
        .buttonStyle(.link)
        .onHover { proxy in
            logoutHover = proxy
        }
    }
}

#Preview {
    LogoutView()
}
