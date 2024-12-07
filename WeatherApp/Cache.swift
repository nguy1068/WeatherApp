//
//  Cache.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-06.
//

import Foundation

class DataStorage {
    private let cityNamesKey = "cityNames"

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
}
