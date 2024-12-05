//
//  Pre-fetching.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-05.
//

import Foundation

class PrefetchingManager: ObservableObject {
    @Published var preFetchedCities: [WeatherService.GeoResponse] = []
    private let weatherService = WeatherService()

    func prefetchCities() {
        let cityNames = ["New York City", "Los Angeles", "Chicago", "Houston", "Phoenix","Hanoi"
                         
//                         "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville", "San Francisco", "Columbus", "Fort Worth", "Charlotte", "Detroit", "El Paso", "Seattle", "Denver", "Washington, D.C.", "Boston", "Baltimore", "Milwaukee", "Portland", "Las Vegas", "Omaha", "Atlanta", "Kansas City", "Miami", "Raleigh", "Virginia Beach", "Colorado Springs", "Tulsa", "Minneapolis", "New Orleans", "Arlington", "Wichita", "Bakersfield", "London", "Paris", "Berlin", "Madrid", "Rome", "Amsterdam", "Brussels", "Vienna", "Zurich", "Lisbon", "Copenhagen", "Stockholm", "Oslo", "Helsinki", "Dublin", "Prague", "Budapest", "Barcelona", "Athens", "Belgrade", "Sofia", "Bucharest", "Warsaw", "Zagreb", "Bratislava", "Tallinn", "Riga", "Vilnius", "Ljubljana", "Geneva", "Antwerp", "Porto", "Marseille", "Frankfurt", "Stuttgart", "Munich", "Amsterdam", "Basel", "Nuremberg", "Gothenburg", "Tokyo", "Beijing", "Shanghai", "Mumbai", "Delhi", "Seoul", "Bangkok", "Jakarta", "Manila", "Hong Kong", "Singapore", "Kuala Lumpur", "Taipei", "Ho Chi Minh City", "Chennai", "Guangzhou", "Shenzhen", "Wuhan", "Chengdu", "Hangzhou", "Osaka", "Nagoya", "Ahmedabad", "Lahore", "Karachi", "Dhaka", "Kathmandu", "Tashkent", "Baku", "Yerevan", "Tbilisi", "Almaty", "Astana", "Ulaanbaatar", "Dushanbe", "Bishkek", "Male", "Thimphu", "Vientiane", "Phnom Penh", "São Paulo", "Buenos Aires", "Rio de Janeiro", "Bogotá", "Lima", "Santiago", "Caracas", "Quito", "Salvador", "Fortaleza", "Medellín", "Brasília", "La Paz", "Asunción", "Montevideo", "Guayaquil", "Córdoba", "Rosario", "Cali", "Recife", "Cairo", "Lagos", "Nairobi", "Johannesburg", "Addis Ababa", "Dakar", "Accra", "Casablanca", "Tunis", "Algiers", "Kampala", "Harare", "Lusaka", "Khartoum", "Maputo", "Windhoek", "Gaborone", "Kigali", "Freetown", "Port Harcourt", "Sydney", "Melbourne", "Brisbane", "Perth", "Auckland", "Wellington", "Christchurch", "Adelaide", "Gold Coast", "Newcastle", "Hobart", "Cairns", "Darwin", "Dunedin"
        ]

        weatherService.prefetchCities(cityNames: cityNames) { result in
            switch result {
            case .success(let geoResponses):
                DispatchQueue.main.async {
                    self.preFetchedCities = geoResponses
                }
            case .failure(let error):
                print("Error prefetching cities: \(error)")
            }
        }
    }
}
