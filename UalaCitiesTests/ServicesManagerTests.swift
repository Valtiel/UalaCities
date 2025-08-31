//
//  ServicesManagerTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
@testable import UalaCities

final class ServicesManagerTests: XCTestCase {
    
    func testServicesManagerWithMockServices() {
        // Given
        let mockCityDataService = CityDataService.withMockProvider(cities: [
            City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        ])
        let mockSearchService = CitySearchService(strategy: TrieSearchStrategy())
        let mockFavoritesService = FavoritesService()
        
        // When
        let servicesManager = ServicesManager(
            cityDataService: mockCityDataService,
            searchService: mockSearchService,
            favoritesService: mockFavoritesService
        )
        
        // Then
        XCTAssertEqual(servicesManager.cityDataService.cities.count, 1)
        XCTAssertEqual(servicesManager.cityDataService.cities.first?.name, "Test City")
    }
    
    func testServicesManagerCreatesViewModelsWithCorrectServices() {
        // Given
        let servicesManager = ServicesManager()
        
        // When
        let searchViewModel = servicesManager.makeCitySearchViewModel()
        let favoritesViewModel = servicesManager.makeFavoritesViewModel()
        
        // Then
        XCTAssertNotNil(searchViewModel)
        XCTAssertNotNil(favoritesViewModel)
        // The view models should have access to the same service instances
        XCTAssertTrue(searchViewModel.favoritesService === favoritesViewModel.favoritesService)
    }
}
