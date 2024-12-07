//
//  AddCityView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-05.
//

import SwiftUI

struct AddCityView: View {
    @Binding var cities: [City]
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var matchedCities: [String] = []
    @Environment(\.presentationMode) var presentationMode

    let weatherService = WeatherService()
    let dataStorage = DataStorage()

    var body: some View {
        VStack {
            Text("Add City")
                .font(.headline)
                .padding()

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for a city", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                Button(action: {
                    searchCity()
                }) {
                    Text("Add")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)

            Spacer()

            VStack {
                Spacer()
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if filteredMatchedCities.isEmpty && filteredCities.isEmpty {
                        Text("No result found, try to add new city")
                            .padding()
                    } else {
                        List {
                            if !filteredMatchedCities.isEmpty {
                                Section(header: Text("Your City")) {
                                    ForEach(filteredMatchedCities, id: \.self) { cityName in
                                        Button(action: {
                                            addCity(cityName)
                                        }) {
                                            Text(cityName)
                                        }
                                    }
                                }
                            }
                            Section(header: Text("Suggestions")) {
                                ForEach(filteredCities, id: \.self) { cityName in
                                    Button(action: {
                                        addCity(cityName)
                                    }) {
                                        Text(cityName)
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            matchedCities = dataStorage.loadCityNames()
        }
    }

    private var filteredCities: [String] {
        if searchText.isEmpty {
            return default_city
        } else {
            return default_city.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }

    private var filteredMatchedCities: [String] {
        if searchText.isEmpty {
            return matchedCities
        } else {
            return matchedCities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }

    private func searchCity() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        matchedCities = []

        print("Searching for city: \(searchText)")

        weatherService.getCoordinates(for: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let geoResponses):
                    print("Received geo responses: \(geoResponses)")
                    if let firstGeoResponse = geoResponses.first {
                        if searchText.lowercased() == firstGeoResponse.name.lowercased() {
                            matchedCities.append(firstGeoResponse.name)
                            dataStorage.saveCityNames(matchedCities)
                        } else {
                            errorMessage = "City not found. Please try again."
                        }
                    } else {
                        errorMessage = "City not found. Please try again."
                    }
                case .failure(let error):
                    print("Error fetching geo responses: \(error)")
                    errorMessage = "City not found. Please try again."
                }
            }
        }
    }

    private func addCity(_ cityName: String) {
        isLoading = true
        weatherService.getCoordinates(for: cityName) { result in
            switch result {
            case .success(let geoResponses):
                if let geoResponse = geoResponses.first {
                    self.weatherService.getWeather(lat: geoResponse.lat, lon: geoResponse.lon) {
                        result in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            switch result {
                            case .success(let weatherResponse):
                                let localTime = formatLocalTime(
                                    timezoneOffset: weatherResponse.timezone)
                                let temperatureCelsius = weatherResponse.main.temp - 273.15
                                let newCity = City(
                                    name: geoResponse.name,
                                    temperature: String(format: "%.1f°C", temperatureCelsius),
                                    weather: weatherResponse.weather.first?.description ?? "N/A",
                                    icon: weatherResponse.weather.first?.icon ?? "cloud.fill",
                                    localTime: localTime
                                )
                                self.cities.append(newCity)
                                self.presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                print("Error fetching weather data: \(error)")
                                self.errorMessage =
                                    "Failed to fetch weather data. Please try again."
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "City not found. Please try again."
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Error fetching geo responses: \(error)")
                    self.errorMessage = "City not found. Please try again."
                }
            }
        }
    }

    private func formatLocalTime(timezoneOffset: Int) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return dateFormatter.string(from: date)
    }
}

//struct AddCityView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddCityView(cities: .constant([]))
//    }
//}
