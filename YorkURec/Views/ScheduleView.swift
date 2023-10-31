//
//  ScheduleView.swift
//  YorkURec
//
//  Created by Aayush Pokharel on 2023-10-31.
//

import DynamicIsland
import EventKit
import EventKitUI
import SwiftUI

struct ScheduleView: View {
    @State private var model: ScheduleModel? = nil
    @State private var selectedCategoryID: ActivityCategory? = .swimSchedule

    var filteredCategories: [Category] {
        if let selected = selectedCategoryID {
            return model?.categories.filter { $0.id == selected } ?? []
        }
        return model?.categories ?? []
    }

    var body: some View {
        NavigationView {
            VStack {
                if model != nil {
                    ScrollView {
                        VStack {
                            ForEach(filteredCategories, id: \.id) { category in
                                ForEach(category.days, id: \.date) { day in
                                    DayView(day: day)
                                        .padding()
                                        .background(.thinMaterial)
                                        .clipShape(.rect(cornerRadius: 12))
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    ProgressView()
                        .task {
                            ScheduleModel.fetch { result in
                                switch result {
                                case .success(let schedule):
                                    model = schedule
                                case .failure(let error):
                                    print(error)
                                    model = .example
                                }
                            }
                        }
                }
            }
            .background(
                Image(.bg)
                    .scaledToFill()
                    .blur(radius: 32)
            )

            .toolbar(content: {
                CategoryPickerView(selectedCategoryID: $selectedCategoryID)
                    .buttonStyle(.bordered)

            })
            .navigationBarTitle("Schedule")
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
    }
}

struct DayView: View {
    @State private var activityToConfirm: ScheduledActivity? = nil

    @State private var showAlert: Bool = false
    @State private var added: Bool = false
    var day: Day

    var body: some View {
        if !day.scheduledActivities.isEmpty && day.toDate > Date().addingTimeInterval(-86400) {
            VStack(alignment: .leading, spacing: 10) {
                Text(day.formattedDayOfTheWeek + ", " + (day.formattedDate ?? ""))
                    .font(.headline)

                ForEach(day.scheduledActivities) { activity in
                    Button(action: {
                        activityToConfirm = activity
                        UIApplication.shared.inAppAlert {
                            DynamicAlert {
                                Text("")
                                    .padding()
                            } trailing: {
                                Text("")
                                    .padding()
                            } center: {
                                Text("Add \(activity.description)")
                                    .font(.caption2)
                                    .padding(.top)

                            } bottom: {
                                HStack {
                                    Button(action: {
                                        if let activity = self.activityToConfirm {
                                            self.proceedWithCalendarEventCreation(for: activity)
                                        } else {
                                            print("ERROR")
                                        }
                                    }, label: {
                                        HStack {
                                            Spacer()
                                            Label("Add", systemImage: "checkmark")
                                                .foregroundStyle(.black)
                                            Spacer()
                                        }
                                        .padding(6)
                                        .background(.green.opacity(0.75))
                                        .clipShape(.rect(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.green, lineWidth: 2)
                                        )
                                        .shadow(color: .green, radius: 12)
                                    })
                                    Button { showAlert.toggle(); added = false } label: {
                                        HStack {
                                            Spacer()
                                            Label("Nope", systemImage: "xmark")
                                                .foregroundStyle(.white)
                                            Spacer()
                                        }
                                        .padding(6)
                                        .background(.red.opacity(0.75))
                                        .clipShape(.rect(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.red, lineWidth: 2)
                                        )
                                        .shadow(color: .red, radius: 12)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding()
                            }
                        }
                    }, label: {
                        ActivityView(activity: activity)
                    })
                    .buttonStyle(.plain)
                }
            }
            .onChange(of: showAlert) { _, _ in

                UIApplication.shared.inAppAlert {
                    DynamicAlert {
                        Text("")
                            .padding()
                    } trailing: {
                        Text("")
                            .padding()
                    } center: {
                        HStack {
                            Spacer()
                            if added {
                                Text("Added Event to Calendar")
                                    .bold()
                                    .foregroundStyle(.green)
                                    .shadow(color: .green, radius: 24)
                            } else {
                                Text("Okay, Didn't Add")
                                    .foregroundStyle(.red)
                                    .shadow(color: .red, radius: 24)
                            }
                            Spacer()
                        }

                    } bottom: {
                        Text(activityToConfirm?.description ?? "New Activity")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            }
        }
    }

    func proceedWithCalendarEventCreation(for activity: ScheduledActivity) {
        let eventStore = EKEventStore()

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore, activity: activity)
        case .denied:
            print("Access denied")
        case .notDetermined:
            eventStore.requestFullAccessToEvents { granted, _ in
                if granted {
                    self.insertEvent(store: eventStore, activity: activity)
                } else {
                    print("Denied?!")
                }
            }
        default:
            print("Case Default")
            eventStore.requestFullAccessToEvents { granted, _ in
                if granted {
                    self.insertEvent(store: eventStore, activity: activity)
                } else {
                    print("Denied!!!")
                }
            }
        }
    }

    func insertEvent(store: EKEventStore, activity: ScheduledActivity) {
        print("Inserting Event")
        let event = EKEvent(eventStore: store)
        event.title = activity.activity
        event.location = activity.location

        guard let startDate = activity.startTime.toDate(withFormat: "HH:mm:ss"),
              let endDate = activity.endTime.toDate(withFormat: "HH:mm:ss")
        else {
            print("ERROR: Invalid start or end time")
            return
        }

        // Adjust the date component of startDate and endDate based on day.toDate
        let calendar = Calendar.current
        let adjustedStartDate = calendar.date(bySettingHour: calendar.component(.hour, from: startDate),
                                              minute: calendar.component(.minute, from: startDate),
                                              second: calendar.component(.second, from: startDate),
                                              of: day.toDate)
        let adjustedEndDate = calendar.date(bySettingHour: calendar.component(.hour, from: endDate),
                                            minute: calendar.component(.minute, from: endDate),
                                            second: calendar.component(.second, from: endDate),
                                            of: day.toDate)

        event.startDate = adjustedStartDate ?? startDate
        event.endDate = adjustedEndDate ?? endDate
        event.notes = activity.description
        event.calendar = store.defaultCalendarForNewEvents
        print(event)
        showAlert = true
        do {
            try store.save(event, span: .thisEvent)
            print("Event saved successfully")
            added = true
        } catch let e as NSError {
            print("ERROR SAVING")
            print("Error: \(e)")
            added = false
        }
    }
}

struct ActivityView: View {
    var activity: ScheduledActivity

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text(activity.activity).font(.subheadline)
                Text(activity.location).font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text((activity.formattedStartTime ?? "") + " - " + (activity.formattedEndTime ?? ""))
                    .font(.footnote)
                    .bold()
                if activity.availableSpots != 0 {
                    Text("Spots: \(activity.availableSpots)").font(.caption)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.ultraThinMaterial, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.25), radius: 12)
    }
}

#Preview("Schedule View") {
    ScheduleView()
}

struct CategoryPickerView: View {
    @Binding var selectedCategoryID: ActivityCategory?

    var body: some View {
        Picker("Choose Category", selection: $selectedCategoryID) {
            Text("All Categories").tag(ActivityCategory?.none)
            ForEach(ActivityCategory.allCases) { category in
                Text(category.displayName).tag(Optional(category))
            }
        }
    }
}
