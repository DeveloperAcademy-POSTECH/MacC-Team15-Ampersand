//
//  CreateFolderView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct CreateFolderView: View {
    @State var folderName = ""
    @State var cancelHover = false
    @State var createHover = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            folderNameTextField
            HStack(alignment: .center, spacing: 8) {
                cancel
                create
            }
        }
        .padding(24)
        .frame(width: 480, height: 160)
    }
}

extension CreateFolderView {
    var folderNameTextField: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.item)
            .frame(height: 48)
            .overlay(
                TextField("Folder Name", text: $folderName)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
            )
    }
}

extension CreateFolderView {
    var cancel: some View {
        Button {
            // TODO: - Cancel Button
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(cancelHover ? Color.buttonHovered : Color.button)
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
            cancelHover = isHovered
        }
    }
}

extension CreateFolderView {
    var create: some View {
        Button {
            // TODO: - Create Button
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(createHover ? Color.buttonHovered : Color.button)
                .frame(height: 32)
                .overlay(
                    Text("Create")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.buttonText)
                )
        }
        .buttonStyle(.link)
        .onHover { isHovered in
            createHover = isHovered
        }
    }
}

#Preview {
    CreateFolderView()
}
