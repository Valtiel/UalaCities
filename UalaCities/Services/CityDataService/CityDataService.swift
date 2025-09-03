//
//  CityDataService.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation
import Combine

/// Protocol defining the interface for city data services
protocol CityDataService: ObservableObject {
    
    // MARK: - Properties
    
    /// The list of cities
    var cities: [City] { get }
    
    /// Whether cities are currently being loaded
    var isLoading: Bool { get }
    
    // MARK: - Publishers
    
    /// Publisher for cities updates
    var citiesPublisher: Published<[City]>.Publisher { get }
    
    /// Publisher for loading state updates
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    /// Publisher for error updates
    var errorPublisher: Published<Error?>.Publisher { get }
    
    // MARK: - Computed Properties
    
    /// Returns true if cities have been loaded
    var isDataLoaded: Bool { get }
    
    // MARK: - Methods
    
    /// Loads cities from the data provider
    func loadCities()
    
    /// Reloads cities from the data provider
    func reloadCities()
    
    /// Returns a filtered list of cities based on search query
    func searchCities(query: String) -> [City]
    
    /// Returns a city by its ID
    func city(withId id: Int) -> City?
}

/// Service that manages city data loading and provides access to the city list
final class CityDataByProviderService: CityDataService {
    
    // MARK: - Published Properties
    
    @Published private(set) var cities: [City] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Publishers
    
    var citiesPublisher: Published<[City]>.Publisher {
        $cities
    }
    
    var isLoadingPublisher: Published<Bool>.Publisher {
        $isLoading
    }
    
    var errorPublisher: Published<Error?>.Publisher {
        $error
    }
    
    // MARK: - Private Properties
    
    private let dataProvider: CityDataProvider
    private var loadingTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(dataProvider: CityDataProvider) {
        self.dataProvider = dataProvider
    }
    
    // MARK: - Public Methods
    
    /// Returns true if cities have been loaded
    var isDataLoaded: Bool {
        return !cities.isEmpty
    }
    
    /// Loads cities from the data provider
    func loadCities() {
        guard !isLoading else { return }
        
        // If cities are already loaded, don't reload
        if !cities.isEmpty {
            return
        }
        
        // Cancel any existing loading task
        loadingTask?.cancel()
        
        isLoading = true
        error = nil
        
        loadingTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let cities = try await self.dataProvider.fetchCities()
                
                // Check if task was cancelled
                try Task.checkCancellation()
                
                await MainActor.run {
                    self.cities = cities.sorted { $0.name < $1.name }
                    self.isLoading = false
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

extension CityDataByProviderService {
    
    /// Creates a service with network data provider
    static func withNetworkProvider(url: URL) -> any CityDataService {
        let provider = NetworkCityDataProvider(url: url)
        return CityDataByProviderService(dataProvider: provider)
    }
    
    /// Creates a service with local file data provider
    static func withLocalFileProvider(fileName: String = "cities") -> any CityDataService {
        let provider = LocalFileCityDataProvider(fileName: fileName)
        return CityDataByProviderService(dataProvider: provider)
    }
    
    /// Creates a service with mock data provider for testing
    static func withMockProvider(cities: [City] = [], delay: TimeInterval = 1.0) -> any CityDataService {
        let provider = MockCityDataProvider(cities: cities, delay: delay)
        return CityDataByProviderService(dataProvider: provider)
    }
}
