//
//  SettingsView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval: Int = 15 // Default to 15 minutes
    let intervals = [1, 2, 5, 10, 15, 30, 60] // Available intervals in minutes

    var body: some View {
        VStack {
            Text("Settings View")
                .font(.largeTitle)
                .padding()

            // Picker for refresh interval
            Picker("Time Refresh Interval", selection: $refreshInterval) {
                ForEach(intervals, id: \.self) { interval in
                    Text("\(interval) minutes").tag(interval)
                }
            }
            .pickerStyle(MenuPickerStyle()) // You can change the style as needed
            .padding()

            // Display the selected interval
            Text("Current Refresh Interval: \(refreshInterval) minutes")
                .padding()

            Spacer()
        }
        .padding()
    }
}

// TODO: Implement settings options:

// TODO: Use Picker to allow users to set the refresh interval.

// TODO: Add a button to navigate to the About screen.

// TODO: Use @AppStorage to persist user settings.
