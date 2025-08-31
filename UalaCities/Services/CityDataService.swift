//
//  CityDataService.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation

/// Service that manages city data loading and provides access to the city list
final class CityDataService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var cities: [City] = []
    @Published private(set) var isLoading = false
    @Published private(set) var progress: Double = 0.0
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    
    private let dataProvider: CityDataProvider
    private var loadingTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(dataProvider: CityDataProvider) {
        self.dataProvider = dataProvider
    }
    
    // MARK: - Public Methods
    
    /// Loads cities from the data provider
    func loadCities() {
        guard !isLoading else { return }
        
        // Cancel any existing loading task
        loadingTask?.cancel()
        
        isLoading = true
        progress = 0.0
        error = nil
        
        loadingTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let cities = try await self.dataProvider.fetchCities { progress in
                    Task { @MainActor in
                        self.progress = progress
                    }
                }
                
                // Check if task was cancelled
                try Task.checkCancellation()
                
                await MainActor.run {
                    self.cities = cities
                    self.isLoading = false
                    self.progress = 1.0
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Reloads cities from the data provider
    func reloadCities() {
        loadingTask?.cancel()
        loadCities()
    }
    
    /// Returns a filtered list of cities based on search query
    func searchCities(query: String) -> [City] {
        guard !query.isEmpty else { return cities }
        
        let lowercasedQuery = query.lowercased()
        return cities.filter { city in
            city.name.lowercased().contains(lowercasedQuery) ||
            city.country.lowercased().contains(lowercasedQuery) ||
            city.displayName.lowercased().contains(lowercasedQuery)
        }
    }
    
    /// Returns a city by its ID
    func city(withId id: Int) -> City? {
        return cities.first { $0.id == id }
    }
    
    deinit {
        loadingTask?.cancel()
    }
}

// MARK: - Factory Methods

extension CityDataService {
    
    /// Creates a service with network data provider
    static func withNetworkProvider(url: URL) -> CityDataService {
        let provider = NetworkCityDataProvider(url: url)
        return CityDataService(dataProvider: provider)
    }
    
    /// Creates a service with local file data provider
    static func withLocalFileProvider(fileName: String = "cities") -> CityDataService {
        let provider = LocalFileCityDataProvider(fileName: fileName)
        return CityDataService(dataProvider: provider)
    }
    
    /// Creates a service with mock data provider for testing
    static func withMockProvider(cities: [City] = [], delay: TimeInterval = 1.0) -> CityDataService {
        let provider = MockCityDataProvider(cities: cities, delay: delay)
        return CityDataService(dataProvider: provider)
    }
}
