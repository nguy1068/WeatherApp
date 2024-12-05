//
//  CityListView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

// Define a CityRow view to display city details
struct CityRow: View {
    let city: City

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(city.name)")
                    .font(.system(size: 24))
                Text(city.temperature)
                    .font(.system(size: 32))
                    .fontWeight(.semibold)
                Text("Local Time: \(city.localTime)")
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack {
                Image("default_weather_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                Text("\(city.weather)")
                    .foregroundColor(.gray)
            }
        }
    }
}

// Define the CityListView
struct CityListView: View {
    @State private var cities: [City] = [
        City(name: "New York", temperature: "22°C", weather: "Sunny", icon: "sun.max.fill", localTime: "10:00 AM"),
        City(name: "London", temperature: "15°C", weather: "Cloudy", icon: "cloud.fill", localTime: "3:00 PM")
    ]
    @State private var newCityName: String = ""
    @State private var newCityTemperature: String = ""
    @State private var newCityWeather: String = ""
    @State private var newCityIcon: String = ""
    @State private var newCityLocalTime: String = ""
    @State private var searchText: String = ""
    @State private var showingAddCityView: Bool = false

    var body: some View {
        NavigationStack {
            List(filteredCities) { city in
                CityRow(city: city)
            }
            .navigationTitle("OhMyWeather")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCityView = true
                    }) {
                        Text("Add").font(.headline)
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .sheet(isPresented: $showingAddCityView) {
                VStack {
                    TextField("City Name", text: $newCityName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Temperature", text: $newCityTemperature)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Weather", text: $newCityWeather)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Icon", text: $newCityIcon)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Local Time", text: $newCityLocalTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        addCity()
                        showingAddCityView = false
                    }) {
                        Text("Add City")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }

    private var filteredCities: [City] {
        if searchText.isEmpty {
            return cities
        } else {
            return cities.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    private func addCity() {
        let newCity = City(name: newCityName, temperature: newCityTemperature, weather: newCityWeather, icon: newCityIcon, localTime: newCityLocalTime)
        cities.append(newCity)
        newCityName = ""
        newCityTemperature = ""
        newCityWeather = ""
        newCityIcon = ""
        newCityLocalTime = ""
    }
}

struct CityListView_Previews: PreviewProvider {
    static var previews: some View {
        CityListView()
    }
}
