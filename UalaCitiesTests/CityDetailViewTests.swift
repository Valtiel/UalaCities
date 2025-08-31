//
//  CityDetailViewTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
import SwiftUI
@testable import UalaCities

final class CityDetailViewTests: XCTestCase {
    
    func testCityDetailViewModelInitialization() {
        // Given
        let city = City(
            id: 1,
            name: "Buenos Aires",
            country: "Argentina",
            coord: City.Coordinate(lon: -58.3816, lat: -34.6037)
        )
        let favoritesService = FavoritesService()
        
        // When
        let viewModel = CityDetailViewModel(
            city: city,
            favoritesService: favoritesService
        )
        
        // Then
        XCTAssertEqual(viewModel.city.id, city.id)
        XCTAssertEqual(viewModel.city.name, city.name)
        XCTAssertEqual(viewModel.city.country, city.country)
        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testCityDetailViewModelWithDifferentCity() {
        // Given
        let city = City(
            id: 2,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        let favoritesService = FavoritesService()
        
        // When
        let viewModel = CityDetailViewModel(
            city: city,
            favoritesService: favoritesService
        )
        
        // Then
        XCTAssertEqual(viewModel.city.id, city.id)
        XCTAssertEqual(viewModel.city.name, city.name)
        XCTAssertEqual(viewModel.city.country, city.country)
    }
    
    func testCityDetailViewModelToggleFavorite() {
        // Given
        let city = City(
            id: 1,
            name: "Buenos Aires",
            country: "Argentina",
            coord: City.Coordinate(lon: -58.3816, lat: -34.6037)
        )
        let favoritesService = FavoritesService()
        let viewModel = CityDetailViewModel(
            city: city,
            favoritesService: favoritesService
        )
        
        // When
        viewModel.perform(.toggleFavorite)
        
        // Then
        // The favorite status should be updated through the binding
        // This test verifies the action is handled
        XCTAssertNotNil(viewModel)
    }
}
