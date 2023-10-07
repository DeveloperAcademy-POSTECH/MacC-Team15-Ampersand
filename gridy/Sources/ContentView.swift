//
//  ContentView.swift
//  gridy
//
//  Created by 제나 on 2023/09/21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    let store = Store(initialState: Authentication.State()) {
        Authentication()
            ._printChanges()
    }
    var body: some View {
        ZStack {
            GeometryReader { _ in
                ZStack {
                    colorScheme == .dark ? Color.black.opacity(0.2) : Color.white
                    Image(.gridBackground)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(Color.gray)
                        .opacity(colorScheme == .dark ? 0.3 : 0.3)
                }
            }
            
            WithViewStore(store, observe: { $0 }) { viewStore in
                if viewStore.successToSignIn {
                    ProjectBoardView(
                        store: Store(
                            initialState: ProjectBoard.State(projects: []),
                            reducer: { ProjectBoard()._printChanges() }
                        )
                    )
                } else {
                    ZStack {
                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 16) {
                                    Image(.gridGreetingLogo)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60)
                                    Text("Alpha Version")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .foregroundColor(.gray.opacity(0.5))
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .foregroundColor(.gray.opacity(0.1))
                                        )
                                }
                                .padding(.vertical)
                                .padding(.top)
                                Spacer()
                            }
                            .background {
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.1))
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 30,
                                            bottomLeadingRadius: 0,
                                            bottomTrailingRadius: 0,
                                            topTrailingRadius: 30,
                                            style: .continuous
                                        )
                                    )
                            }
                            Spacer()
                            AuthenticationView(store: store)
                            Spacer()
                        }
                        .frame(width: 350, height: 350)
                        .padding(.bottom)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 24)
                        )
                        if viewStore.isProceeding {
                            Color.black.opacity(0.7)
                            ProgressView()
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
