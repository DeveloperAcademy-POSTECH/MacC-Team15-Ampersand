//
//  NotificationView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct NotificationView: View {
    let store: StoreOf<ProjectBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                titleAndFeedbackArea
                notifications
            }
            .frame(width: 275, height: 424)
        }
    }
}

extension NotificationView {
    var titleAndFeedbackArea: some View {
        HStack(alignment: .center) {
            Text("Notifications")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.title)
            Spacer()
            Button {
                // TODO: - Feedback Button
            } label: {
                Text("􀁞 Feedback")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.link)
        }
        .padding(16)
        .background(Color.blackWhite)
    }
}

extension NotificationView {
    var notifications: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<5) { index in
                    Notifications(id: index, store: store)
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    private struct Notifications: View {
        var id: Int
        let store: StoreOf<ProjectBoard>
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Button {
                    // TODO: - Notification Content Button
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Notification Content \(id)")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.title)
                            Text("Date")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.subtitle)
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .background(viewStore.hoveredItem == "NotificationContentButton \(id)" ? Color.item : Color.itemHovered)
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                .buttonStyle(.link)
                .scaleEffect(viewStore.hoveredItem == "NotificationContentButton \(id)" ? 1.02 : 1)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "NotificationContentButton \(id)" : ""))
                }
            }
        }
    }
}
