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
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    }

    var body: some View {
        let currentLocalTime = formatLocalTimeToHHmm(timezoneOffset: city.cityInfo.timezone)

        ZStack {
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.bottom)
                .foregroundColor(.blue)
                .opacity(0.3)

            VStack {
                VStack {
                    if let currentForecast = getCurrentForecast(
                        for: city, currentLocalTime: currentLocalTime)
                    {
                        displayCurrentWeather(currentForecast: currentForecast)
                    }
                }
                .padding()

                HStack(spacing: 32) {
                    displayCurrentForecast(currentLocalTime: currentLocalTime)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .padding()

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "bolt.badge.clock")
                            .foregroundColor(.gray)
                        Text("Forecast for today per 3 hour")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }

                    // Forecast Section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 32) {
                            ForEach(getForecast(for: city, currentLocalTime: currentLocalTime)) { forecast in
                                displayForecast(forecast: forecast)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(10)
                .padding()
            }
        }
        .navigationBarTitle(city.name, displayMode: .inline)
    }

    // Function to display current weather
    private func displayCurrentWeather(currentForecast: WeatherForecast) -> some View {
        VStack {
            Image(imageName(for: city.weather))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
            Text("\(currentForecast.weather.first?.description ?? "N/A")")
            Text("\(city.name)")
                .font(.title)
                .fontWeight(.semibold)
            Text("\(city.localTime)")
                .font(.title2)
        }
    }

    // Function to display current forecast section
    private func displayCurrentForecast(currentLocalTime: String) -> some View {
        if let currentForecast = getCurrentForecast(for: city, currentLocalTime: currentLocalTime) {
            print("\(currentForecast.main.temperatureCelsius)")

            return AnyView(
                HStack(spacing: 32) {
                    VStack {
                        Image("temp")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                        Text("\(currentForecast.main.temperatureCelsius, specifier: "%.1f")°C")
                    }
                    VStack {
                        Image("wind")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                        Text("\(String(format: "%.2f", currentForecast.wind.speed)) m/s")
                    }
                    VStack {
                        Image("humidity")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                        Text("\(currentForecast.main.humidity)%")
                    }
                })
        } else {
            return AnyView(Text("No current forecast available.").font(.title2))
        }
    }

    // Function to display each forecast
    private func displayForecast(forecast: WeatherForecast) -> some View {
        let localTime =
            convertUTCToLocal(
                utcDateString: forecast.dt_txt,
                timezoneOffset: TimeInterval(city.cityInfo.timezone)) ?? "N/A"

        var iconUrl = ""
        if let weather = forecast.weather.first {
            print("Icon: \(weather.icon)")
            iconUrl = "https://openweathermap.org/img/wn/\(weather.icon).png"
            print("Icon URL: \(iconUrl)")
        }

        return VStack {
            AsyncImage(url: URL(string: iconUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } placeholder: {
                ProgressView()
            }
            Text("\(localTime)")
            Text("\(forecast.main.temperatureCelsius, specifier: "%.1f")°C")
        }
        .padding(.vertical, 5)
    }
}

// Function to determine the image name
private func imageName(for weather: String) -> String {
    let validWeatherNames = [
        "broken clouds", "clear sky", "few clouds", "haze", "light shower snow",
        "overcast clouds", "smoke", "sunny",
    ]
    return validWeatherNames.contains(weather) ? weather : "default"
}

private func getCurrentForecast(for city: City, currentLocalTime: String) -> WeatherForecast? {
    return city.forecast.min(by: {
        abs(
            timeIntervalBetween(
                timeString1: currentLocalTime,
                timeString2: convertUTCToLocal(
                    utcDateString: $0.dt_txt,
                    timezoneOffset: TimeInterval(city.cityInfo.timezone)) ?? ""))
            < abs(
                timeIntervalBetween(
                    timeString1: currentLocalTime,
                    timeString2: convertUTCToLocal(
                        utcDateString: $1.dt_txt,
                        timezoneOffset: TimeInterval(city.cityInfo.timezone)) ?? ""))
    })
}

private func getForecast(for city: City, currentLocalTime: String)
    -> [WeatherForecast]
{
    return city.forecast.filter {
        let forecastLocalTime = convertUTCToLocal(
            utcDateString: $0.dt_txt, timezoneOffset: TimeInterval(city.cityInfo.timezone))
        return forecastLocalTime != nil && forecastLocalTime! > currentLocalTime
    }
}

private func convertUTCToLocal(utcDateString: String, timezoneOffset: TimeInterval) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

    guard let utcDate = dateFormatter.date(from: utcDateString) else {
        return nil
    }

    let localDate = utcDate.addingTimeInterval(timezoneOffset)
    dateFormatter.dateFormat = "HH:mm" 
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.string(from: localDate)
}

private func formatLocalTimeToHHmm(timezoneOffset: Int) -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
    return dateFormatter.string(from: date)
}

private func timeIntervalBetween(timeString1: String, timeString2: String) -> TimeInterval {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    guard let date1 = dateFormatter.date(from: timeString1),
          let date2 = dateFormatter.date(from: timeString2)
    else {
        return .greatestFiniteMagnitude
    }
    return date1.timeIntervalSince(date2)
}
