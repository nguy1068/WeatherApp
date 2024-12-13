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
    let isEditing: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(city.name)")
                    .font(.system(size: 24))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 200, alignment: .leading)

                Text(city.temperature)
                    .font(.system(size: 32))
                Text("Local Time: \(city.localTime)")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
            }
            Spacer()
            if !isEditing {
                HStack {
                    Spacer() // This will push the content to the right
                    VStack(alignment: .trailing) {
                        Image(imageName(for: city.weather))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()

                        Text("\(city.weather)")
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }

    // Function to determine the image name
    private func imageName(for weather: String) -> String {
        let validWeatherNames = [
            "broken clouds", "clear sky", "few clouds", "haze", "light shower snow",
            "overcast clouds", "smoke", "sunny",
        ]
        return validWeatherNames.contains(weather) ? weather : "default"
    }
}

// Define the CityListView
struct CityListView: View {
    @State private var cities: [City] = []
    @State private var searchText: String = ""
    @State private var showingAddCityView: Bool = false
    @State private var isEditing: Bool = false
    @State private var timer: Timer?

    let dataStorage = DataStorage()
    let weatherService = WeatherService()

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                List {
                    ForEach(filteredCities) { city in
                        NavigationLink(destination: CityDetailView(city: city)) {
                            CityRow(city: city, isEditing: isEditing)
                        }
                    }
                    .onDelete(perform: deleteCity)
                    .onMove(perform: moveCity)
                }
                .navigationTitle("Cities")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
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
                .searchable(
                    text: $searchText, placement: .navigationBarDrawer(displayMode: .always)
                )
                .sheet(isPresented: $showingAddCityView) {
                    AddCityView { cityName, lat, lon in
                        getCityData(cityName: cityName, lat: lat, lon: lon)
                    }
                }
                .environment(
                    \.editMode,
                    Binding(
                        get: { isEditing ? .active : .inactive },
                        set: { isEditing = $0 == .active }
                    )
                )
            }
        }
        .onAppear {
            if cities.isEmpty {
                loadCitiesFromCache()
            }
            startRefetchTimer()
        }
        .onDisappear {
            stopRefetchTimer()
        }
    }

    private var filteredCities: [City] {
        if searchText.isEmpty {
            return cities
        } else {
            return cities.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    private func deleteCity(at offsets: IndexSet) {
        for index in offsets {
            let city = cities[index]
            dataStorage.removeCityName(city.name)
            dataStorage.removeCityCoordinates(city.name)
            cities.remove(at: index)
        }
        dataStorage.saveCityNames(Set(cities.map { $0.name }))
        saveCitiesToCache()
    }

    private func moveCity(from source: IndexSet, to destination: Int) {
        cities.move(fromOffsets: source, toOffset: destination)
        saveCitiesToCache()
    }

    private func saveCitiesToCache() {
        let cityNames = Set(cities.map { $0.name })
        dataStorage.saveCityNames(cityNames)
    }

    private func loadCitiesFromCache() {
        let cityCoordinates = dataStorage.loadCityCoordinates()
        print("Loaded city coordinates from cache: \(cityCoordinates)")
        var uniqueCities = Set<String>()
        for (cityName, coordinates) in cityCoordinates {
            if !uniqueCities.contains(cityName) {
                uniqueCities.insert(cityName)
                getCityData(cityName: cityName, lat: coordinates.0, lon: coordinates.1)
            }
        }
    }

    private func getCoordinatesForCity(cityName: String) -> (Double, Double)? {
        let cityCoordinates = dataStorage.loadCityCoordinates()
        return cityCoordinates[cityName]
    }

    private func getCityData(cityName: String, lat: Double, lon: Double) {
        weatherService.getWeather(lat: lat, lon: lon) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherResponse):
                    print("Successfully fetched weather data for city: \(cityName)")
                    let localTime = formatLocalTime(timezoneOffset: weatherResponse.city.timezone)
                    let temperatureCelsius = weatherResponse.list.first?.main.temp ?? 0 - 273.15
                    let cityInfo = City.CityInfo(
                        id: weatherResponse.city.id,
                        name: weatherResponse.city.name,
                        coord: City.CityInfo.Coord(
                            lat: weatherResponse.city.coord.lat,
                            lon: weatherResponse.city.coord.lon
                        ),
                        country: weatherResponse.city.country,
                        population: weatherResponse.city.population,
                        timezone: weatherResponse.city.timezone,
                        sunrise: weatherResponse.city.sunrise,
                        sunset: weatherResponse.city.sunset
                    )
                    let newCity = City(
                        name: cityName,
                        temperature: String(format: "%.1f°C", temperatureCelsius),
                        weather: weatherResponse.list.first?.weather.first?.description ?? "N/A",
                        icon: weatherResponse.list.first?.weather.first?.icon ?? "cloud.fill",
                        localTime: localTime,
                        forecast: weatherResponse.list,
                        cityInfo: cityInfo
                    )
                    if !self.cities.contains(where: { $0.name == newCity.name }) {
                        self.cities.append(newCity)
                        self.saveCitiesToCache()
                    }
                case .failure(let error):
                    print("Error fetching weather data: \(error)")
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

    private func startRefetchTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            refetchWeatherDataForAllCities()
        }
    }

    private func stopRefetchTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func refetchWeatherDataForAllCities() {
        for city in cities {
            weatherService.autoRefetchWeatherData(for: city.name) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weatherResponse):
                        print("Refetched weather data for city: \(city.name)")
                        
                        // Find the index of the city to update
                        if let index = self.cities.firstIndex(where: { $0.name == city.name }) {
                            // Update the city with new weather data
                            let updatedCity = City(
                                name: city.name,
                                temperature: String(format: "%.1f°C", weatherResponse.list.first?.main.temp ?? 0 - 273.15),
                                weather: weatherResponse.list.first?.weather.first?.description ?? "N/A",
                                icon: weatherResponse.list.first?.weather.first?.icon ?? "cloud.fill",
                                localTime: self.formatLocalTime(timezoneOffset: weatherResponse.city.timezone),
                                forecast: weatherResponse.list,
                                cityInfo: city.cityInfo
                            )
                            self.cities[index] = updatedCity
                        }
                        
                    case .failure(let error):
                        print("Failed to refetch weather data for city: \(city.name), error: \(error)")
                    }
                }
            }
        }
    }
}
