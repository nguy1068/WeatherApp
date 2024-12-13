//
//  Weather.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

struct Weather: Codable {
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
    let uvIndex: Double
    let icon: String
    let description: String
    let forecast: [String]?
}

struct WeatherForecast: Identifiable, Codable {
    let id = UUID()
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let rain: Rain?
    let sys: Sys
    let dt_txt: String

    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Int
        let sea_level: Int?
        let grnd_level: Int?
        let humidity: Int
        let temp_kf: Double?
    }

    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String

        var iconURL: URL? {
            return URL(string: "http://openweathermap.org/img/wn/\(icon).png")
        }
    }

    struct Clouds: Codable {
        let all: Int
    }

    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double?
    }

    struct Rain: Codable {
        let oneHour: Double?

        enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
        }
    }

    struct Sys: Codable {
        let pod: String
    }
}
