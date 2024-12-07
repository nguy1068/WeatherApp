//
//  Cache.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-06.
//

import Foundation

class DataStorage {
    private let cityNamesKey = "cityNames"
    private let cityCoordinatesKey = "cityCoordinates"

    // Function to save a set of city names
    func saveCityNames(_ cityNames: Set<String>) {
        UserDefaults.standard.set(Array(cityNames), forKey: cityNamesKey)
    }

    // Function to load the set of city names
    func loadCityNames() -> Set<String> {
        let cityNamesArray = UserDefaults.standard.stringArray(forKey: cityNamesKey) ?? []
        return Set(cityNamesArray)
    }

    // Function to delete all city names
    func deleteAllCityNames() {
        UserDefaults.standard.removeObject(forKey: cityNamesKey)
    }

    // Function to save a dictionary of city names and their coordinates
    func saveCityCoordinates(_ cityCoordinates: [String: (Double, Double)]) {
        let encodedData = try? JSONEncoder().encode(cityCoordinates.mapValues { ["lat": $0.0, "lon": $0.1] })
        UserDefaults.standard.set(encodedData, forKey: cityCoordinatesKey)
    }

    // Function to load the dictionary of city names and their coordinates
    func loadCityCoordinates() -> [String: (Double, Double)] {
        guard let data = UserDefaults.standard.data(forKey: cityCoordinatesKey),
              let decodedData = try? JSONDecoder().decode([String: [String: Double]].self, from: data) else {
            return [:]
        }
        return decodedData.mapValues { ($0["lat"]!, $0["lon"]!) }
    }

    // Function to delete all city coordinates
    func deleteAllCityCoordinates() {
        UserDefaults.standard.removeObject(forKey: cityCoordinatesKey)
    }

    // Function to remove a city name from the cache
    func removeCityName(_ cityName: String) {
        var cityNames = loadCityNames()
        cityNames.remove(cityName)
        saveCityNames(cityNames)
    }

    // Function to remove city coordinates from the cache
    func removeCityCoordinates(_ cityName: String) {
        var cityCoordinates = loadCityCoordinates()
        cityCoordinates.removeValue(forKey: cityName)
        saveCityCoordinates(cityCoordinates)
    }
}
