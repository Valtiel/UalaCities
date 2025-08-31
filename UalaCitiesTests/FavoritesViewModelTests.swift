//
//  FavoritesViewModelTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
import Combine
@testable import UalaCities

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    
    var favoritesService: FavoritesService!
    var coordinator: MockAppCoordinator!
    var viewModel: FavoritesViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        favoritesService = FavoritesService()
        coordinator = MockAppCoordinator()
        viewModel = FavoritesViewModel(favoritesService: favoritesService, coordinator: coordinator)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        favoritesService = nil
        coordinator = nil
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(viewModel.favoriteCities.count, 0)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Favorites Binding Tests
    
    func testFavoritesBinding() {
        let expectation = XCTestExpectation(description: "Favorites should be updated")
        
        viewModel.$favoriteCities
            .dropFirst() // Skip initial empty array
            .sink { cities in
                XCTAssertEqual(cities.count, 1)
                XCTAssertEqual(cities.first?.name, "Test City")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let testCity = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        favoritesService.addToFavorites(testCity)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Action Tests
    
    func testSelectCityAction() {
        let testCity = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        viewModel.perform(.selectCity(testCity))
        
        XCTAssertEqual(coordinator.navigationPath.count, 1)
        if case .cityDetail(let city) = coordinator.navigationPath.first {
            XCTAssertEqual(city.id, testCity.id)
            XCTAssertEqual(city.name, testCity.name)
        } else {
            XCTFail("Expected cityDetail navigation")
        }
        
        XCTAssertNil(coordinator.presentedSheet)
    }
    
    func testToggleFavoriteAction() {
        let testCity = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // Initially not favorite
        XCTAssertFalse(favoritesService.isFavorite(testCity))
        
        // Toggle to add to favorites
        viewModel.perform(.toggleFavorite(testCity))
        XCTAssertTrue(favoritesService.isFavorite(testCity))
        
        // Toggle to remove from favorites
        viewModel.perform(.toggleFavorite(testCity))
        XCTAssertFalse(favoritesService.isFavorite(testCity))
    }
    
    // MARK: - Multiple Favorites Tests
    
    func testMultipleFavorites() {
        let city1 = City(id: 1, name: "City 1", country: "Country 1", coord: City.Coordinate(lon: 0, lat: 0))
        let city2 = City(id: 2, name: "City 2", country: "Country 2", coord: City.Coordinate(lon: 1, lat: 1))
        
        favoritesService.addToFavorites(city1)
        favoritesService.addToFavorites(city2)
        
        XCTAssertEqual(viewModel.favoriteCities.count, 2)
        XCTAssertTrue(viewModel.favoriteCities.contains { $0.id == city1.id })
        XCTAssertTrue(viewModel.favoriteCities.contains { $0.id == city2.id })
    }
    
    // MARK: - Coordinator Integration Tests
    
    func testCoordinatorIntegration() {
        let testCity = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // Test that coordinator is properly used
        viewModel.perform(.selectCity(testCity))
        
        XCTAssertEqual(coordinator.navigationPath.count, 1)
        XCTAssertNil(coordinator.presentedSheet)
    }
    
    func testCoordinatorWithoutCoordinator() {
        // Test behavior when no coordinator is provided
        let viewModelWithoutCoordinator = FavoritesViewModel(favoritesService: favoritesService, coordinator: nil)
        let testCity = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // Should not crash
        viewModelWithoutCoordinator.perform(.selectCity(testCity))
        viewModelWithoutCoordinator.perform(.toggleFavorite(testCity))
        
        XCTAssertTrue(favoritesService.isFavorite(testCity))
    }
}
