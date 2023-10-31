//
//  ContentView.swift
//  YorkURec
//
//  Created by Aayush Pokharel on 2023-10-31.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ScheduleView()
                .tabItem { Label("Schedule", systemImage: "calendar") }
            NotificationsView()
                .tabItem { Label("Notifications", systemImage: "bell.badge") }
        }
    }
}

#Preview {
    ContentView()
}
