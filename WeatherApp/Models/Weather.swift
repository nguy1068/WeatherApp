//
//  Weather.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

struct Weather: Codable {
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
    let uvIndex: Double
    let icon: String
    let description: String
    let forecast: [String]?
}