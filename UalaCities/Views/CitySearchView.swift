//
//  CitySearchView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

protocol CitySearchViewState {
    var cityList: [City] { get }
    var filteredCityList: [City] { get }
    func perform(_ action: CitySearchViewAction)
}

enum CitySearchViewAction {
    case searchQuery(String)
    case selectCity(City)
}

struct CitySearchView<ViewState: ObservableObject & CitySearchViewState>: View {
    
    @ObservedObject var viewState: ViewState
    @State private var query: String = ""
    
    var body: some View {
        VStack {
            TextField("Search city...", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {
                    viewState.perform(.searchQuery(query))
                }
            
            List(viewState.filteredCityList, id: \.id) { city in
                Button(city.name) {
                    viewState.perform(.selectCity(city))
                }
            }
        }
        .navigationTitle("City Search")
        .onChange(of: query) { oldQuery, newQuery in
            viewState.perform(.searchQuery(newQuery))
        }
    }
}

//MARK: - Preview
final class CitySearchViewStatePreview: CitySearchViewState, ObservableObject {
    
    @Published var cityList: [City] =         [
        City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
        City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
        City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1276, lat: 51.5074)),
        City(id: 4, name: "São Paulo", country: "Brasil", coord: City.Coordinate(lon: -46.6333, lat: -23.5505)),
        City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566)),
        City(id: 6, name: "Tokyo", country: "Japan", coord: City.Coordinate(lon: 139.6917, lat: 35.6895)),
        City(id: 7, name: "Sydney", country: "Australia", coord: City.Coordinate(lon: 151.2093, lat: -33.8688)),
        City(id: 8, name: "Berlin", country: "Germany", coord: City.Coordinate(lon: 13.4050, lat: 52.5200)),
        City(id: 9, name: "Madrid", country: "Spain", coord: City.Coordinate(lon: -3.7038, lat: 40.4168)),
        City(id: 10, name: "Rome", country: "Italy", coord: City.Coordinate(lon: 12.4964, lat: 41.9028))
    ]
    
    @Published var filteredCityList: [City] = []
    
    func perform(_ action: CitySearchViewAction) {
        switch action {
        case .searchQuery(let query):
            filteredCityList = cityList.filter { $0.name.lowercased().contains(query.lowercased())
            }
        case .selectCity(let city):
            print("Selected City: \(city.name)")
        }
    }
}

#Preview {
    CitySearchView(viewState: CitySearchViewModel())
}
