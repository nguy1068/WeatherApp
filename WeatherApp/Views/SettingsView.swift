//
//  SettingsView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval: Int = 15
    let intervals = [1, 2, 5, 10, 15, 30, 60]

    var body: some View {
        VStack {
            Text("Settings View")
                .font(.largeTitle)
                .padding()

            Picker("Time Refresh Interval", selection: $refreshInterval) {
                ForEach(intervals, id: \.self) { interval in
                    Text("\(interval) minutes").tag(interval)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Text("Current Refresh Interval: \(refreshInterval) minutes")
                .padding()

            Spacer()
        }
        .padding()
    }
}
