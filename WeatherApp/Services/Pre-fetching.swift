//
//  Pre-fetching.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-05.
//

import Foundation

class PrefetchingManager: ObservableObject {
    @Published var preFetchedCities: [WeatherService.GeoResponse] = []
    private let weatherService = WeatherService()

    func prefetchCities() {
        let cityNames = [
            "New York", "London", "Paris", "Tokyo", "Los Angeles",
        ]

        weatherService.prefetchCities(cityNames: cityNames) { result in
            switch result {
            case .success(let geoResponses):
                DispatchQueue.main.async {
                    self.preFetchedCities = geoResponses
                }
            case .failure(let error):
                print("Error prefetching cities: \(error)")
            }
        }
    }
}

