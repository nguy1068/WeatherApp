//
//  Cache.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-06.
//

import Foundation

class DataStorage {
    private let cityNamesKey = "cityNames"

    // Function to save a list of city names
    func saveCityNames(_ cityNames: [String]) {
        UserDefaults.standard.set(cityNames, forKey: cityNamesKey)
    }

    // Function to load the list of city names
    func loadCityNames() -> [String] {
        return UserDefaults.standard.stringArray(forKey: cityNamesKey) ?? []
    }

    // Function to delete all city names
    func deleteAllCityNames() {
        UserDefaults.standard.removeObject(forKey: cityNamesKey)
    }
}
