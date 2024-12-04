//
//  City.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

struct City: Identifiable {
    let id: UUID
    let name: String
    let coordinates: (latitude: Double, longitude: Double)
    var weather: Weather?
}
