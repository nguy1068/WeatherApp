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
        let country: String?
        let state: String?
    }

    struct WeatherResponse: Codable {
        let coord: Coord
        let weather: [Weather]
        let main: Main
        let visibility: Int
        let wind: Wind
        let clouds: Clouds
        let dt: Int
        let sys: Sys
        let timezone: Int
        let id: Int
        let name: String
        let cod: Int

        struct Coord: Codable {
            let lon: Double
            let lat: Double
        }

        struct Weather: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }

        struct Main: Codable {
            let temp: Double
            let feels_like: Double
            let temp_min: Double
            let temp_max: Double
            let pressure: Int
            let humidity: Int
            let sea_level: Int?
            let grnd_level: Int?
        }

        struct Wind: Codable {
            let speed: Double
            let deg: Int
            let gust: Double?
        }

        struct Clouds: Codable {
            let all: Int
        }

        struct Sys: Codable {
            let type: Int?
            let id: Int?
            let country: String
            let sunrise: Int
            let sunset: Int
        }
    }

    // Function to get coordinates by city name
    func getCoordinates(
        for city: String, completion: @escaping (Result<[GeoResponse], Error>) -> Void
    ) {
        let urlString =
            "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=1&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        print("Fetching coordinates for URL: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
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
                print("GeoResponse: \(geoResponse)")
                completion(.success(geoResponse))
            } catch {
                print("Error decoding GeoResponse: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    struct ErrorResponse: Codable {
        let cod: String
        let message: String

        enum CodingKeys: String, CodingKey {
            case cod
            case message
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // Attempt to decode `cod` as a String
            if let codString = try? container.decode(String.self, forKey: .cod) {
                self.cod = codString
            } else {
                // If it fails, try to decode it as an Int and convert to String
                let codInt = try container.decode(Int.self, forKey: .cod)
                self.cod = String(codInt)
            }

            self.message = try container.decode(String.self, forKey: .message)
        }
    }

    // Function to get weather data by coordinates
    func getWeather(
        lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void
    ) {
        let urlString =
            "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        print("Fetching weather for URL: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                // Attempt to decode the WeatherResponse
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                print("WeatherResponse: \(weatherResponse)")
                completion(.success(weatherResponse))
            } catch {
                // Handle the case where the response is not in the expected format
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    print("ErrorResponse: \(errorResponse)")
                    completion(
                        .failure(NSError(domain: errorResponse.message, code: 0, userInfo: nil)))
                } catch {
                    print("Error decoding WeatherResponse: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
