//
//  CityListView.swift
//  WeatherApp
//
//  Created by Dat Nguyen(Mike) on 2024-12-04.
//

import SwiftUI

// Define a CityRow view to display city details
struct CityRow: View {
    let city: City
    let isEditing: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(city.name)")
                    .font(.system(size: 24))
                Text(city.temperature)
                    .font(.system(size: 32))
                Text("Local Time: \(city.localTime)")
            }
            Spacer()
            if !isEditing {
                VStack {
                    Image(systemName: city.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                    Text("\(city.weather)")
                }
            }
        }
    }
}

// Define the CityListView
struct CityListView: View {
    @State private var cities: [City] = [
        City(name: "New York", temperature: "22°C", weather: "Sunny", icon: "sun.max.fill", localTime: "10:00 AM")
    ]
    @State private var searchText: String = ""
    @State private var showingAddCityView: Bool = false
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                List {
                    ForEach(filteredCities) { city in
                        CityRow(city: city, isEditing: isEditing)
                    }
                    .onDelete(perform: deleteCity)
                    .onMove(perform: moveCity)
                }
                .navigationTitle("Cities")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddCityView = true
                        }) {
                            Text("Add").font(.headline)
                            Image(systemName: "plus")
                                .font(.headline)
                        }
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .sheet(isPresented: $showingAddCityView) {
                    AddCityView(cities: $cities)
                }
                .environment(\.editMode, Binding(
                    get: { isEditing ? .active : .inactive },
                    set: { isEditing = $0 == .active }
                ))
            }
        }
    }

    private var filteredCities: [City] {
        if searchText.isEmpty {
            return cities
        } else {
            return cities.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    private func deleteCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }

    private func moveCity(from source: IndexSet, to destination: Int) {
        cities.move(fromOffsets: source, toOffset: destination)
    }
}

struct CityListView_Previews: PreviewProvider {
    static var previews: some View {
        CityListView()
    }
}
