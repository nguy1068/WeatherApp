//
//  AddCityView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-05.
//

import SwiftUI

struct AddCityView: View {
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var matchedCities: Set<String> = []
    @State private var cachedCities: Set<String> = []
    @Environment(\.presentationMode) var presentationMode

    let weatherService = WeatherService()
    let dataStorage = DataStorage()
    var onAddCity: (String, Double, Double) -> Void

    var body: some View {
        VStack {
            Text("Add City")
                .font(.headline)
                .padding()

            VStack {
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

                if !cachedCities.isEmpty {
                    HStack {
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.gray)
                        Button(action: {
                            clearHistory()
                        }) {
                            Text("Clear history")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }

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
                            if !cachedCities.isEmpty {
                                Section(header: Text("Recent")) {
                                    ForEach(Array(cachedCities), id: \.self) { cityName in
                                        Button(action: {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }) {
                                            Text(cityName)
                                        }
                                    }
                                }
                            }
                            Section(header: Text("Suggestions")) {
                                ForEach(filteredCities, id: \.self) { cityName in
                                    Button(action: {
                                        searchCity(cityName: cityName)
                                        self.presentationMode.wrappedValue.dismiss()
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
            cachedCities = dataStorage.loadCityNames()
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
            return Array(matchedCities)
        } else {
            return matchedCities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }

    private func searchCity(cityName: String? = nil) {
        let cityToSearch = cityName ?? searchText
        guard !cityToSearch.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        matchedCities = []

        print("Searching for city: \(cityToSearch)")

        weatherService.getCoordinates(for: cityToSearch) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let geoResponses):
                    print("Received geo responses: \(geoResponses)")
                    if let firstGeoResponse = geoResponses.first {
                        let storedCityName = cityToSearch

                        if !self.cachedCities.contains(storedCityName) {
                            self.matchedCities.insert(storedCityName)
                            self.cachedCities.insert(storedCityName)
                            var cityCoordinates = self.dataStorage.loadCityCoordinates()
                            cityCoordinates[storedCityName] = (firstGeoResponse.lat, firstGeoResponse.lon)
                            self.dataStorage.saveCityCoordinates(cityCoordinates)
                            print("CachedCities: \(self.cachedCities)")
                            self.onAddCity(storedCityName, firstGeoResponse.lat, firstGeoResponse.lon)
                        } else {
                            print("City \(storedCityName) is already in the cache.")
                        }
                        self.searchText = ""
                    }
                case .failure(let error):
                    print("Failed to fetch coordinates for city: \(cityToSearch), error: \(error)")
                    self.errorMessage = "Failed to fetch coordinates for city: \(cityToSearch)"
                }
            }
        }
    }

    private func clearHistory() {
        dataStorage.deleteAllCityNames()
        cachedCities.removeAll()
    }

    private func refreshView() {
        matchedCities = dataStorage.loadCityNames()
        cachedCities = dataStorage.loadCityNames()
    }
}