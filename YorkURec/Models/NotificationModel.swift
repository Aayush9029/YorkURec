//
//  NotificationModel.swift
//  YorkURec
//
//  Created by Aayush Pokharel on 2023-10-31.
//

// https://innosoftfusiongo.com/schools/download.php?schoolid=4&version=268&device=iPhone&file=Notifications

import Foundation

// MARK: - Main NotificationModel

struct NotificationModel: Codable {
    let notifications: [Notification]

    enum CodingKeys: String, CodingKey {
        case notifications
    }

    static let example: NotificationModel? = exampleModel(forName: "notification")
}

// MARK: - Notification

struct Notification: Codable {
    let id: String
    let notification: String
    let datetimeSent: String

    enum CodingKeys: String, CodingKey {
        case id
        case notification
        case datetimeSent = "datetime_sent"
    }
}

extension Notification {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = formatter.date(from: datetimeSent) {
            formatter.dateFormat = "MM/dd/yyyy, HH:mm"
            return formatter.string(from: date)
        } else {
            return datetimeSent
        }
    }
}

extension NotificationModel {
    static let fetchURL = URL(string: "https://innosoftfusiongo.com/schools/download.php?schoolid=4&version=268&device=iPhone&file=Notifications")!

    static func fetch(completion: @escaping (Result<NotificationModel, Error>) -> Void) {
        URLSession.shared.dataTask(with: fetchURL) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "com.YorkURec", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(NotificationModel.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
