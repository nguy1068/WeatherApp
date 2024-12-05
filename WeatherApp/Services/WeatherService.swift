//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import Foundation

struct WeatherService {
    private let apiKey = "82cee47fde2a603c5aad6b9ea8cb8f11"
    
    // Define the necessary data models
    struct GeoResponse: Codable {
        let name: String
        let lat: Double
        let lon: Double
    }
    
    struct WeatherResponse: Codable {
        let current: CurrentWeather
        let hourly: [HourlyWeather]
        let daily: [DailyWeather]
        
        struct CurrentWeather: Codable {
            let temp: Double
            let weather: [Weather]
        }
        
        struct HourlyWeather: Codable {
            let temp: Double
            let weather: [Weather]
        }
        
        struct DailyWeather: Codable {
            let temp: Temp
            let weather: [Weather]
            
            struct Temp: Codable {
                let day: Double
                let min: Double
                let max: Double
            }
        }
        
        struct Weather: Codable {
            let description: String
            let icon: String
        }
    }
    
    // Function to get coordinates by city name
    func getCoordinates(for city: String, completion: @escaping (Result<GeoResponse, Error>) -> Void) {
        let urlString = "http://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=1&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let geoResponse = try JSONDecoder().decode([GeoResponse].self, from: data)
                if let firstResult = geoResponse.first {
                    completion(.success(firstResult))
                } else {
                    completion(.failure(NSError(domain: "No results", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Function to get weather data by coordinates
    func getWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
