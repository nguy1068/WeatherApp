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
    @Environment(\.presentationMode) var presentationMode
    
    let weatherService = WeatherService()
    
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
            
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                List(filteredCities, id: \.self) { cityName in
                    Button(action: {
                        addCity(cityName)
                    }) {
                        Text(cityName)
                    }
                }
            }
        }
        .padding()
    }
    
    private var filteredCities: [String] {
        if searchText.isEmpty {
            return default_city
        } else {
            return default_city.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private func searchCity() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        print("Searching for city: \(searchText)")
        
        weatherService.getCoordinates(for: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let geoResponses):
                    print("Received geo responses: \(geoResponses)")
                    if let firstGeoResponse = geoResponses.first {
                        addCity(firstGeoResponse.name)
                    }
                case .failure(let error):
                    print("Error fetching geo responses: \(error)")
                    errorMessage = error.localizedDescription
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
                    self.weatherService.getWeather(lat: geoResponse.lat, lon: geoResponse.lon) { result in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            switch result {
                            case .success(let weatherResponse):
                                let localTime = formatLocalTime(timezoneOffset: weatherResponse.timezone)
                                let newCity = City(
                                    name: geoResponse.name,
                                    temperature: "\(weatherResponse.main.temp)°C",
                                    weather: weatherResponse.weather.first?.description ?? "N/A",
                                    icon: weatherResponse.weather.first?.icon ?? "cloud.fill",
                                    localTime: localTime
                                )
                                self.cities.append(newCity)
                                self.presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                print("Error fetching weather data: \(error)")
                                self.errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Error fetching geo responses: \(error)")
                    self.errorMessage = error.localizedDescription
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

struct AddCityView_Previews: PreviewProvider {
    static var previews: some View {
        AddCityView(cities: .constant([]))
    }
}
