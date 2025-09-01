//
//  ViewModelFactory.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation

/// Factory responsible for creating view models with proper dependencies
@MainActor
final class ViewModelFactory {
    
    // MARK: - Dependencies
    
    private let servicesManager: ServicesManager
    
    // MARK: - Initialization
    
    init(servicesManager: ServicesManager) {
        self.servicesManager = servicesManager
    }
    
    // MARK: - Factory Methods
    
    /// Creates a CitySearchViewModel with the managed services
    func makeCitySearchViewModel(coordinator: (any Coordinator)? = nil) -> CitySearchViewModel {
        return CitySearchViewModel(
            searchService: servicesManager.searchService,
            cityDataService: servicesManager.cityDataService,
            favoritesService: servicesManager.favoritesService,
            coordinator: coordinator
        )
    }
    
    /// Creates a FavoritesViewModel with the managed services
    func makeFavoritesViewModel(coordinator: (any Coordinator)? = nil) -> FavoritesViewModel {
        return FavoritesViewModel(
            favoritesService: servicesManager.favoritesService,
            coordinator: coordinator
        )
    }
    
    /// Creates a CityDetailViewModel with the managed services
    func makeCityDetailViewModel(city: City, coordinator: (any Coordinator)? = nil) -> CityDetailViewModel {
        return CityDetailViewModel(
            city: city,
            favoritesService: servicesManager.favoritesService,
            coordinator: coordinator
        )
    }
}
