//
//  CitySearchViewModel.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject, @preconcurrency CitySearchViewState {
    
    // MARK: - Published Properties
    
    @Published var cityList: [City] = []
    @Published var filteredCityList: [City] = []
    
    // MARK: - Private Properties
    
    private let searchService: CitySearchService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(searchService: CitySearchService) {
        self.searchService = searchService
        setupInitialData()
    }
    
    /// Convenience initializer that creates a ViewModel with a default search strategy
    convenience init() {
        let searchService = CitySearchService(strategy: BinarySearchStrategy())
        self.init(searchService: searchService)
    }
    
    // MARK: - Public Methods
    
    func perform(_ action: CitySearchViewAction) {
        switch action {
        case .searchQuery(let query):
            handleSearchQuery(query)
        case .selectCity(let city):
            handleCitySelection(city)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialData() {
        // Load initial city data
        cityList = loadSampleCities()
        searchService.index(cities: cityList)
        filteredCityList = cityList
    }
    
    private func handleSearchQuery(_ query: String) {
        if query.isEmpty {
            filteredCityList = cityList
        } else {
            filteredCityList = searchService.search(query: query)
        }
    }
    
    private func handleCitySelection(_ city: City) {
        // Handle city selection - this could trigger navigation, show details, etc.
        print("Selected City: \(city.displayName)")
        // TODO: Implement navigation or detail view presentation
    }
    
    private func loadSampleCities() -> [City] {
        return [
            City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
            City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1276, lat: 51.5074)),
            City(id: 4, name: "São Paulo", country: "Brasil", coord: City.Coordinate(lon: -46.6333, lat: -23.5505)),
            City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566)),
            City(id: 6, name: "Tokyo", country: "Japan", coord: City.Coordinate(lon: 139.6917, lat: 35.6895)),
            City(id: 7, name: "Sydney", country: "Australia", coord: City.Coordinate(lon: 151.2093, lat: -33.8688)),
            City(id: 8, name: "Berlin", country: "Germany", coord: City.Coordinate(lon: 13.4050, lat: 52.5200)),
            City(id: 9, name: "Madrid", country: "Spain", coord: City.Coordinate(lon: -3.7038, lat: 40.4168)),
            City(id: 10, name: "Rome", country: "Italy", coord: City.Coordinate(lon: 12.4964, lat: 41.9028)),
            City(id: 11, name: "Barcelona", country: "Spain", coord: City.Coordinate(lon: 2.1734, lat: 41.3851)),
            City(id: 12, name: "Amsterdam", country: "Netherlands", coord: City.Coordinate(lon: 4.9041, lat: 52.3676)),
            City(id: 13, name: "Vienna", country: "Austria", coord: City.Coordinate(lon: 16.3738, lat: 48.2082)),
            City(id: 14, name: "Prague", country: "Czech Republic", coord: City.Coordinate(lon: 14.4378, lat: 50.0755)),
            City(id: 15, name: "Budapest", country: "Hungary", coord: City.Coordinate(lon: 19.0402, lat: 47.4979))
        ]
    }
}
