//
//  NotificationView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleAndFeedbackArea
            notifications
        }
        .frame(width: 275, height: 424)
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
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.blackWhite)
    }
}

extension NotificationView {
    var notifications: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 8) {
                ForEach(0..<5) { index in
                    Notifications(id: index)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private struct Notifications: View {
        var id: Int
        
        var body: some View {
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
        }
    }
}

#Preview {
    NotificationView()
}
