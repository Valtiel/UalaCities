//
//  ServicesManager.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation

/// Central manager for all application services
/// Provides shared instances of services while avoiding singletons
final class ServicesManager: ObservableObject {
    
    // MARK: - Shared Services
    
    let cityDataService: CityDataService
    let searchService: CitySearchService
    let favoritesService: FavoritesService
    
    // MARK: - Initialization
    
    init() {
        // Initialize services
        self.cityDataService = CityDataService.withLocalFileProvider(fileName: "cities")
        self.searchService = CitySearchService(strategy: TrieSearchStrategy())
        self.favoritesService = FavoritesService()
        
        // Preload data for better performance
        self.cityDataService.loadCities()
    }
    
    /// Convenience initializer for testing with mock services
    init(cityDataService: CityDataService, searchService: CitySearchService, favoritesService: FavoritesService) {
        self.cityDataService = cityDataService
        self.searchService = searchService
        self.favoritesService = favoritesService
        
        // Preload data for better performance
        self.cityDataService.loadCities()
    }
}
