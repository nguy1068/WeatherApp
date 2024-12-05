//
//  AddCityView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-05.
//

import SwiftUI

struct AddCityView: View {
    @Binding var cities: [City]
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    @ObservedObject var prefetchingManager = PrefetchingManager()
    
    let weatherService = WeatherService()
    
    var body: some View {
        VStack {
            Text("Add City")
                .font(.headline)
                .padding()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for a city", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                Button(action: {
                    searchCity()
                }) {
                    Text("Add")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
            
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                List(filteredCities, id: \.name) { result in
                    Button(action: {
                        addCity(result)
                    }) {
                        Text(result.name)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            prefetchingManager.prefetchCities()
        }
    }
    
    private var filteredCities: [WeatherService.GeoResponse] {
        if searchText.isEmpty {
            return uniqueCities(prefetchingManager.preFetchedCities)
        } else {
            return uniqueCities(prefetchingManager.preFetchedCities.filter { $0.name.lowercased().contains(searchText.lowercased()) })
        }
    }
    
    private func searchCity() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        print("Searching for city: \(searchText)")
        
        weatherService.getCoordinates(for: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let geoResponses):
                    print("Received geo responses: \(geoResponses)")
                    prefetchingManager.preFetchedCities.append(contentsOf: geoResponses)
                case .failure(let error):
                    print("Error fetching geo responses: \(error)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func addCity(_ geoResponse: WeatherService.GeoResponse) {
        let newCity = City(name: geoResponse.name, temperature: "N/A", weather: "N/A", icon: "cloud.fill", localTime: "N/A")
        cities.append(newCity)
    }
    
    private func uniqueCities(_ cities: [WeatherService.GeoResponse]) -> [WeatherService.GeoResponse] {
        var seen = Set<String>()
        return cities.filter { city in
            guard !seen.contains(city.name) else { return false }
            seen.insert(city.name)
            return true
        }
    }
}

struct AddCityView_Previews: PreviewProvider {
    static var previews: some View {
        AddCityView(cities: .constant([]))
    }
}
