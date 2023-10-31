//
//  ScheduleModel.swift
//  YorkURec
//
//  Created by Aayush Pokharel on 2023-10-31.
//

import Foundation

// https://innosoftfusiongo.com/schools/school4/schedule.json

// MARK: - Main CategoriesModel

struct ScheduleModel: Codable {
    let lastUpdateUTCDateTime: String
    let lastUpdateSource: String
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case lastUpdateUTCDateTime = "lastUpdateUtcDateTime"
        case lastUpdateSource
        case categories
    }

    static let example: ScheduleModel? = exampleModel(forName: "schedule")
}

// MARK: - Category

struct Category: Codable {
    let category: String
    let id: ActivityCategory
    let days: [Day]

    enum CodingKeys: String, CodingKey {
        case category
        case id
        case days
    }
}

// MARK: - Day

struct Day: Codable {
    let date: String
    let dayOfTheWeek: String
    let scheduledActivities: [ScheduledActivity]

    enum CodingKeys: String, CodingKey {
        case date
        case dayOfTheWeek
        case scheduledActivities = "scheduled_activities"
    }
}

// MARK: - ScheduledActivity

struct ScheduledActivity: Codable, Identifiable {
    var id: String { startTime }
    let activity: String
    let location: String
    let startTime: String
    let endTime: String
    let description: String
    let isCancelled: String
    let detailURL: String
    let activityID: String
    let availableSpots: Int

    enum CodingKeys: String, CodingKey {
        case activity
        case location
        case startTime
        case endTime
        case description
        case isCancelled
        case detailURL = "detailUrl"
        case activityID
        case availableSpots
    }
}

// MARK: - Date extensions

extension ScheduleModel {
    var formattedLastUpdateDate: String? {
        return lastUpdateUTCDateTime.toDate(withFormat: "yyyy-MM-dd'T'HH:mm:ss")?.formatted(as: "MMMM dd, yyyy")
    }
}

extension Day {
    var toDate: Date {
        return date.toDate(withFormat: "yyyy-MM-dd") ?? Date()
    }

    var formattedDate: String? {
        return date.toDate(withFormat: "yyyy-MM-dd")?.formatted(as: "MMMM dd, yyyy")
    }

    var formattedDayOfTheWeek: String {
        return dayOfTheWeek.capitalized
    }
}

extension ScheduledActivity {
    var formattedStartTime: String? {
        return startTime.toDate(withFormat: "HH:mm:ss")?.formatted(as: "hh:mm a")
    }

    var formattedEndTime: String? {
        return endTime.toDate(withFormat: "HH:mm:ss")?.formatted(as: "hh:mm a")
    }
}

enum ActivityCategory: String, Codable, CaseIterable, Identifiable {
    case dropInRecreation = "10"
    case groupClasses = "831"
    case groupFitness = "9"
    case recreationBookings = "830"
    case swimSchedule = "11"
    case varsitySchedule = "461"
    case womensOnly1 = "12"
    case womensOnly2 = "832"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dropInRecreation: return "Drop-In Recreation"
        case .groupClasses: return "Group Classes"
        case .groupFitness: return "Group Fitness"
        case .recreationBookings: return "Recreation Bookings"
        case .swimSchedule: return "Swim Schedule"
        case .varsitySchedule: return "Varsity Schedule"
        case .womensOnly1, .womensOnly2: return "Women's Only"
        }
    }
}

extension ScheduleModel {
    static let fetchURL = URL(string: "https://innosoftfusiongo.com/schools/school4/schedule.json")!

    static func fetch(completion: @escaping (Result<ScheduleModel, Error>) -> Void) {
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
                    let decoded = try JSONDecoder().decode(ScheduleModel.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
