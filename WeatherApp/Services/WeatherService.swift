//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import Foundation

struct WeatherService {
    private let apiKey = "82cee47fde2a603c5aad6b9ea8cb8f11"
    private let refetchInterval: TimeInterval = 15 // 1 hour in seconds
    private let dataStorage = DataStorage()

    struct GeoResponse: Codable {
        let name: String
        let lat: Double
        let lon: Double
        let country: String?
        let state: String?
    }

    struct WeatherResponse: Codable {
        let cod: String
        let message: Int
        let cnt: Int
        let list: [WeatherForecast]
        let city: CityInfo

        struct CityInfo: Codable {
            let id: Int
            let name: String
            let coord: Coord
            let country: String
            let population: Int
            let timezone: Int
            let sunrise: Int
            let sunset: Int

            struct Coord: Codable {
                let lat: Double
                let lon: Double
            }
        }
    }

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

    func getWeather(
        lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void
    ) {
        let urlString =
            "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&cnt=10"
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
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                print("WeatherResponse: \(weatherResponse)")
                completion(.success(weatherResponse))
            } catch {
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

    func autoRefetchWeatherData(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let lastFetchTimeKey = "\(city)_lastFetchTime"
        let currentTime = Date().timeIntervalSince1970
        let lastFetchTime = UserDefaults.standard.double(forKey: lastFetchTimeKey)

        print("Checking if data needs to be refetched for city: \(city)")
        print("Current time: \(currentTime), Last fetch time: \(lastFetchTime)")

        if currentTime - lastFetchTime > refetchInterval {
            print("Refetching data for city: \(city)")
            getCoordinates(for: city) { result in
                switch result {
                case .success(let geoResponses):
                    guard let geoResponse = geoResponses.first else {
                        completion(.failure(NSError(domain: "No coordinates found", code: 0, userInfo: nil)))
                        return
                    }
                    self.getWeather(lat: geoResponse.lat, lon: geoResponse.lon) { weatherResult in
                        switch weatherResult {
                        case .success(let weatherResponse):
                            // Save the new data to cache
                            self.dataStorage.saveCityCoordinates([city: (geoResponse.lat, geoResponse.lon)])
                            UserDefaults.standard.set(currentTime, forKey: lastFetchTimeKey)
                            print("Successfully refetched and cached data for city: \(city)")
                            completion(.success(weatherResponse))
                        case .failure(let error):
                            print("Failed to fetch weather data for city: \(city), error: \(error)")
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print("Failed to fetch coordinates for city: \(city), error: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            print("Data is up-to-date for city: \(city), no need to refetch.")
            completion(.failure(NSError(domain: "Data is up-to-date", code: 0, userInfo: nil)))
        }
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

            if let codString = try? container.decode(String.self, forKey: .cod) {
                self.cod = codString
            } else {
                let codInt = try container.decode(Int.self, forKey: .cod)
                self.cod = String(codInt)
            }

            self.message = try container.decode(String.self, forKey: .message)
        }
    }
}
