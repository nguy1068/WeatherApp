//
//  CityDetailView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import MapKit
import SwiftUI

struct CityDetailView: View {
    let city: City
    @State private var region: MKCoordinateRegion

    init(city: City) {
        self.city = city
        _region = State(
            initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: city.cityInfo.coord.lat, longitude: city.cityInfo.coord.lon),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("City: \(city.name)")
                        .font(.largeTitle)
                        .padding(.bottom, 10)

                    // Current Local Time
                    let currentLocalTime = formatLocalTimeToHHmmss(
                        timezoneOffset: city.cityInfo.timezone)
                    Text("Current Local Time: \(currentLocalTime)")
                        .font(.title2)
                        .padding(.bottom, 10)

                    // NOW Section
                    Text("NOW")
                        .font(.title)
                        .padding(.top, 10)

                    if let currentForecast = getCurrentForecast(
                        for: city, currentLocalTime: currentLocalTime)
                    {
                        Text(
                            "Temperature: \(currentForecast.main.temp - 273.15, specifier: "%.1f")°C"
                        )
                        .font(.title2)
                        Text("Weather: \(currentForecast.weather.first?.description ?? "N/A")")
                            .font(.title2)
                        Text("Wind Speed: \(currentForecast.wind.speed) m/s")
                            .font(.title2)
                        Text("Humidity: \(currentForecast.main.humidity)%")
                            .font(.title2)
                    } else {
                        Text("No current forecast available.")
                            .font(.title2)
                    }

                    // Forecast Section
                    Text("Forecast")
                        .font(.title)
                        .padding(.top, 10)

                    ForEach(
                        getForecastsExcludingCurrent(for: city, currentLocalTime: currentLocalTime)
                    ) { forecast in
                        VStack(alignment: .leading) {
                            let localTime =
                                convertUTCToLocal(
                                    utcDateString: forecast.dt_txt,
                                    timezoneOffset: TimeInterval(city.cityInfo.timezone)
                                ) ?? "N/A"
                            Text("Time: \(localTime)")
                            Text("Temperature: \(forecast.main.temp - 273.15, specifier: "%.1f")°C")
                            Text("Weather: \(forecast.weather.first?.description ?? "N/A")")
                        }
                        .padding(.vertical, 5)
                        Divider()
                    }
                }
                .padding()
                .background(Color.white.opacity(0.6))  // Adjusted background opacity
                .cornerRadius(10)
                .padding()
            }
        }
        .navigationTitle(city.name)
    }

    private func getCurrentForecast(for city: City, currentLocalTime: String) -> WeatherForecast? {
        var closestForecast: WeatherForecast?
        var smallestTimeDifference: TimeInterval = .greatestFiniteMagnitude

        for forecast in city.forecast {
            let forecastLocalTime = convertUTCToLocal(
                utcDateString: forecast.dt_txt, timezoneOffset: TimeInterval(city.cityInfo.timezone)
            )
            if let forecastLocalTime = forecastLocalTime {
                let timeDifference = abs(
                    timeIntervalBetween(
                        timeString1: currentLocalTime, timeString2: forecastLocalTime))
                if timeDifference < smallestTimeDifference {
                    smallestTimeDifference = timeDifference
                    closestForecast = forecast
                }
            }
        }

        return closestForecast
    }

    private func getForecastsExcludingCurrent(for city: City, currentLocalTime: String)
        -> [WeatherForecast]
    {
        var forecasts: [WeatherForecast] = []
        var foundCurrent = false

        for forecast in city.forecast {
            let forecastLocalTime = convertUTCToLocal(
                utcDateString: forecast.dt_txt, timezoneOffset: TimeInterval(city.cityInfo.timezone)
            )
            if let forecastLocalTime = forecastLocalTime {
                if forecastLocalTime > currentLocalTime {
                    forecasts.append(forecast)
                } else if !foundCurrent {
                    foundCurrent = true
                }
            }
        }

        return forecasts
    }

    private func convertUTCToLocal(utcDateString: String, timezoneOffset: TimeInterval) -> String? {
        // Define the date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Parse the UTC date string into a Date object
        guard let utcDate = dateFormatter.date(from: utcDateString) else {
            return nil  // Return nil if parsing fails
        }

        // Create a new date by adding the timezone offset
        let localDate = utcDate.addingTimeInterval(timezoneOffset)

        // Convert the local date back to a string
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current  // Set to local timezone
        let localDateString = dateFormatter.string(from: localDate)

        return localDateString
    }

    private func formatLocalTime(timezoneOffset: Int) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return dateFormatter.string(from: date)
    }

    private func formatLocalTimeToHHmmss(timezoneOffset: Int) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return dateFormatter.string(from: date)
    }

    private func timeIntervalBetween(timeString1: String, timeString2: String) -> TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        guard let date1 = dateFormatter.date(from: timeString1),
            let date2 = dateFormatter.date(from: timeString2)
        else {
            return .greatestFiniteMagnitude
        }
        return date1.timeIntervalSince(date2)
    }
}

struct CityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CityDetailView(
            city: City(
                name: "Sample City",
                temperature: "25°C",
                weather: "Clear",
                icon: "01d",
                localTime: "12:00 PM",
                forecast: [
                    WeatherForecast(
                        dt: 1_661_875_200,
                        main: WeatherForecast.Main(
                            temp: 296.34,
                            feels_like: 296.02,
                            temp_min: 296.34,
                            temp_max: 298.24,
                            pressure: 1015,
                            sea_level: 1015,
                            grnd_level: 933,
                            humidity: 50,
                            temp_kf: -1.9
                        ),
                        weather: [
                            WeatherForecast.Weather(
                                id: 500,
                                main: "Rain",
                                description: "light rain",
                                icon: "10d"
                            )
                        ],
                        clouds: WeatherForecast.Clouds(all: 97),
                        wind: WeatherForecast.Wind(speed: 1.06, deg: 66, gust: 2.16),
                        visibility: 10000,
                        pop: 0.32,
                        rain: WeatherForecast.Rain(oneHour: 0.13),
                        sys: WeatherForecast.Sys(pod: "d"),
                        dt_txt: "2022-08-30 16:00:00"
                    )
                ],
                cityInfo: City.CityInfo(
                    id: 3_163_858,
                    name: "Zocca",
                    coord: City.CityInfo.Coord(lat: 44.34, lon: 10.99),
                    country: "IT",
                    population: 4593,
                    timezone: 7200,
                    sunrise: 1_661_834_187,
                    sunset: 1_661_882_248
                )
            ))
    }
}
