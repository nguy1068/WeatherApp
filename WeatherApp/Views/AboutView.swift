//
//  AboutView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            VStack {
                // Display the app logo
                Image("app_logo") // Replace with your actual image name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                // App information
                Text("Weather App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("version 1.0.0")
                    .font(.body)
                    .foregroundColor(.gray)

                Text("This app was developed to provide users with accurate weather data and a user-friendly experience.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .padding(.bottom, 40)

            // Creator information
            VStack {
                Image("developer") // Replace with your actual image name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Created by Dat Nguyen (Mike)")
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
    }
}

// TODO: Display information about the app and author:

// TODO: Show basic details about the app.

// TODO: Implement a hidden feature:

// TODO: Use a @State variable to track tap count.

// TODO: Display a childhood picture if tapped three times.
