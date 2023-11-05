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
    @State var textFieldHover = false
    @State var textFieldText = ""
    @State var textFieldSubmit = false
    @FocusState var textFieldFocus: Bool
    @State var exitButtonHover = false
    
    var jobOptions = ["개발자", "디자이너", "기획자", "부자"]
    @State private var selectionOption = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            profileImage
            nameForm
            jobForm.padding(.bottom, 16)
            exit
        }
        .padding(16)
        .background(.white)
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

extension SettingsView {
    var nameForm: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Name")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundStyle(Color.title)
            Spacer()
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(textFieldHover ? Color.itemHovered : Color.item)
                .foregroundStyle(textFieldHover ? Color.item : .clear)
                .frame(width: 160, height: 24)
                .overlay(alignment: .leading) {
                    if textFieldSubmit {
                        Text(textFieldText)
                            .font(.title3)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.title)
                            .padding(.leading, 8)
                    } else {
                        TextField(textFieldText, text: $textFieldText)
                            .onSubmit {
                                textFieldSubmit = true
                            }
                            .focused($textFieldFocus)
                            .font(.title3)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.title)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 8)
                    }
                }
                .onHover { proxy in
                    textFieldHover = proxy
                }
                .onTapGesture {
                    textFieldSubmit = false
                    textFieldFocus = true
                }
        }
    }
}

extension SettingsView {
    var jobForm: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Job")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundStyle(Color.title)
            Spacer()
            Picker("", selection: $selectionOption) {
                ForEach(0..<jobOptions.count, id: \.self) {
                    Text(jobOptions[$0])
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.title)
                }
            }
            .frame(width: 168)
        }
    }
}

extension SettingsView {
    var exit: some View {
        HStack {
            Button {
                // TODO: - 탈퇴 Button
            } label: {
                Text("탈퇴하기")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.title)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(exitButtonHover ? Color.itemHovered : Color.item)
                            .frame(width: 64, height: 24)
                    )
            }
            .buttonStyle(.link)
            .onHover { proxy in
                exitButtonHover = proxy
            }
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
