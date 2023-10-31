//
//  NotificationView.swift
//  YorkURec
//
//  Created by Aayush Pokharel on 2023-10-31.
//

import SwiftUI

struct NotificationsView: View {
    @State var model: NotificationModel? = nil

    var body: some View {
        NavigationView {
            VStack {
                if let model {
                    List {
                        ForEach(model.notifications, id: \.id) { notification in
                            NotificationRow(notification: notification)
                        }
                    }
                } else {
                    ProgressView()
                        .task {
                            NotificationModel.fetch { result in
                                switch result {
                                case .success(let notifications):
                                    model = notifications
                                case .failure(let error):
                                    print("Failed to fetch notifications:", error)
                                }
                            }
                        }
                }
            }
            .navigationTitle("Notifications")
        }
    }
}

struct NotificationRow: View {
    var notification: Notification

    var body: some View {
        VStack(alignment: .leading) {
            Text(notification.notification)
                .font(.headline)
            Text(notification.formattedDate)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    NotificationsView()
}
