//
//  City.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

struct City: Identifiable {
    let id = UUID()
    let name: String
    let temperature: String
    let weather: String
    let icon: String
    let localTime: String
    let forecast: [WeatherForecast]
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

let default_city = [
    // Asia
    "Tokyo", "Beijing", "Shanghai", "Mumbai", "Delhi", "Seoul", "Bangkok", "Jakarta", "Manila", "Hong Kong", "Singapore", "Kuala Lumpur", "Taipei", "Ho Chi Minh City", "Chennai", "Guangzhou", "Shenzhen", "Wuhan", "Chengdu", "Hangzhou", "Osaka", "Nagoya", "Ahmedabad", "Lahore", "Karachi", "Dhaka", "Kathmandu", "Tashkent", "Baku", "Yerevan", "Tbilisi", "Almaty", "Astana", "Ulaanbaatar", "Dushanbe", "Bishkek", "Male", "Thimphu", "Vientiane", "Phnom Penh", "Hanoi", "Surabaya", "Riyadh", "Jeddah", "Doha", "Kuwait City", "Muscat", "Baghdad", "Damascus", "Tehran", "Ankara", "Istanbul", "Izmir", "Antalya", "Adana", "Moscow", "Saint Petersburg", "Novosibirsk", "Yekaterinburg", "Nizhny Novgorod", "Kazan", "Chelyabinsk", "Samara", "Omsk", "Rostov-on-Don", "Ufa", "Volgograd", "Krasnoyarsk", "Vladivostok", "Nizhny Tagil", "Irkutsk", "Khabarovsk", "Surgut", "Tver", "Tula", "Sochi", "Makhachkala", "Yakutsk", "Barnaul", "Kemerovo", "Tomsk", "Kaliningrad", "Saratov", "Lipetsk", "Voronezh", "Kursk", "Bryansk", "Orel", "Stavropol", "Krasnodar", "Vologda", "Kostroma", "Penza", "Astrakhan", "Ulyanovsk", "Chita", "Blagoveshchensk", "Cherepovets", "Petrozavodsk", "Syktyvkar", "Kirov", "Kurgan", "Cheboksary", "Ulan-Ude", "Arkhangelsk", "Yaroslavl", "Ivanovo", "Smolensk", "Vladimir", "Rybinsk", "Saratov", "Cherepovets", "Klin", "Zelenograd", "Khimki", "Podolsk", "Mytishchi", "Balashikha", "Krasnogorsk", "Serpukhov", "Kolomna", "Ramenskoye", "Dzerzhinsk", "Sergiyev Posad", "Voskresensk", "Zhukovsky", "New York City", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville", "San Francisco", "Columbus", "Fort Worth", "Charlotte", "Detroit", "El Paso", "Seattle", "Denver", "Washington, D.C.", "Boston", "Baltimore", "Milwaukee", "Portland", "Las Vegas", "Omaha", "Atlanta", "Kansas City", "Miami", "Raleigh", "Virginia Beach", "Colorado Springs", "Tulsa", "Minneapolis", "New Orleans", "Arlington", "Wichita", "Bakersfield", "Tampa", "Honolulu", "Anaheim", "Cincinnati", "Bakersfield", "St. Louis", "Pittsburgh", "Orlando", "Riverside", "Cleveland", "Newark", "Birmingham", "Buffalo", "St. Paul", "Jersey City", "Chula Vista", "Chandler", "Madison", "Lubbock", "Scottsdale", "Glendale", "Henderson", "Irvine", "Chesapeake", "Gilbert", "Boise", "Richmond", "Des Moines", "San Bernardino", "Spokane", "Santa Ana", "Oxnard", "Salt Lake City", "Stockton", "Baton Rouge", "Fort Wayne", "Montgomery", "Fremont", "Mobile", "Little Rock", "Grand Rapids", "Huntsville", "Salt Lake City", "Tallahassee", "Cape Coral", "Tempe", "Omaha", "Columbus", "Overland Park", "Knoxville", "Worcester", "Brownsville", "Newport News", "Santa Clarita", "Fort Lauderdale", "Chattanooga", "Cape Girardeau", "Vancouver", "Cedar Rapids", "Peoria", "Springfield", "Jackson", "Salem", "Lancaster", "Eugene", "Coral Springs", "Palm Bay", "Hayward", "Pomona", "Pasadena", "Torrance", "Fullerton", "Orange", "McKinney", "Killeen", "Frisco", "Cary", "Carrollton", "Waco", "South Bend", "Round Rock", "Waterbury", "Sandy Springs", "Visalia", "Bridgeport", "West Valley City", "Burbank", "Palm Coast", "Norwalk", "Bellingham", "Pompano Beach", "Wilmington", "Greeley", "Lakeland", "Daly City", "Sparks", "San Mateo", "Bend", "Macon", "Columbia", "Billings", "South Fulton", "Rochester", "Syracuse", "Chattanooga", "Grand Prairie", "Arlington", "Boulder", "Sandy Springs", "Denton", "Lakewood", "West Palm Beach", "Inglewood", "Wilmington", "Torrance", "Laredo", "Burbank", "San Angelo", "League City", "Peoria", "Waterloo", "Wichita Falls", "Gulfport", "Dothan", "Decatur", "Canton", "Wheeling", "Cleveland Heights", "Lawrence", "Mansfield", "Nampa", "Bismarck", "Yuma", "South Bend", "Haverhill", "Wausau", "Sioux City", "Marietta", "Hickory", "Bend", "Macon", "Cedar Rapids", "Myrtle Beach", "Mansfield", "Dothan", "Davenport", "Harrisonburg", "Huntington", "Richmond", "Fargo", "Grand Forks", "Billings", "London", "Paris", "Berlin", "Madrid", "Rome", "Amsterdam", "Brussels", "Vienna", "Zurich", "Lisbon", "Copenhagen", "Stockholm", "Oslo", "Helsinki", "Dublin", "Prague", "Budapest", "Barcelona", "Athens", "Belgrade", "Sofia", "Bucharest", "Warsaw", "Zagreb", "Bratislava", "Tallinn", "Riga", "Vilnius", "Ljubljana", "Geneva", "Antwerp", "Porto", "Marseille", "Frankfurt", "Stuttgart", "Munich", "Hamburg", "Düsseldorf", "Nuremberg", "Cologne", "Milan", "Turin", "Genoa", "Bologna", "Florence", "Venice", "Palermo", "Catania", "Naples", "Messina", "Bari", "Brescia", "Verona", "Trieste", "Lille", "Nice", "Strasbourg", "Toulouse", "Montpellier", "Lyon", "Grenoble", "Marseille", "Bordeaux", "Saint-Étienne", "Le Havre", "Rennes", "Angers", "Nantes", "Clermont-Ferrand", "Caen", "Amiens", "Reims", "Metz", "Nancy", "La Rochelle", "Saint-Denis", "Saint-Nazaire", "Lorient", "Avignon", "Antwerp", "Ghent", "Bruges", "Ostend", "Liège", "Namur", "Leuven", "Charleroi", "Mons", "Brussels", "Luxembourg City", "Amsterdam", "Rotterdam", "The Hague", "Utrecht", "Eindhoven", "Groningen", "Breda", "Nijmegen", "Tilburg", "Haarlem", "Leiden", "Delft", "Alkmaar", "Enschede", "Apeldoorn", "Amersfoort", "Arnhem", "Zwolle", "Groningen", "Bonn", "Cologne", "Dortmund", "Düsseldorf", "Essen", "Frankfurt", "Hamburg", "Leipzig", "Mannheim", "Nuremberg", "Stuttgart", "Wiesbaden", "Freiburg", "Karlsruhe", "Heidelberg", "Bremen", "Chemnitz", "Dresden", "Halle", "Magdeburg", "Mönchengladbach", "Kiel", "Aachen", "Kassel", "Potsdam", "Rostock", "Wolfsburg", "Bielefeld", "Bochum", "Gelsenkirchen", "Mülheim", "Oberhausen", "Duisburg", "Hagen", "Remscheid", "Solingen", "Leverkusen", "Lübeck", "Cottbus", "Reutlingen", "Tübingen", "Ulm", "Villingen-Schwenningen", "Friedrichshafen", "Konstanz", "Weimar", "Jena", "Erfurt", "Görlitz"
]