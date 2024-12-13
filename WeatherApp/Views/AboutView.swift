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
                
                Image("app_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                
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

            
            VStack {
                Image("developer")
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
