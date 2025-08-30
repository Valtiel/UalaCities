//
//  CitySearchViewModelTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
@testable import UalaCities

@MainActor
final class CitySearchViewModelTests: XCTestCase {
    
    var viewModel: CitySearchViewModel!
    var mockCoordinator: MockAppCoordinator!
    var mockSearchService: CitySearchService!
    
    override func setUp() {
        super.setUp()
        mockCoordinator = MockAppCoordinator()
        mockSearchService = CitySearchService(strategy: BinarySearchStrategy())
        viewModel = CitySearchViewModel(searchService: mockSearchService, coordinator: mockCoordinator)
    }
    
    override func tearDown() {
        viewModel = nil
        mockCoordinator = nil
        mockSearchService = nil
        super.tearDown()
    }
    
    func testCitySelectionTriggersNavigation() {
        // Given
        let testCity = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // When
        viewModel.perform(.selectCity(testCity))
        
        // Then
        XCTAssertEqual(mockCoordinator.navigatedDestinations.count, 1)
        XCTAssertEqual(mockCoordinator.navigatedDestinations.first, .cityDetail(testCity))
    }
    
    func testSearchQueryUpdatesFilteredList() {
        // Given
        let searchQuery = "Buenos"
        
        // When
        viewModel.perform(.searchQuery(searchQuery))
        
        // Then
        XCTAssertFalse(viewModel.filteredCityList.isEmpty)
        XCTAssertTrue(viewModel.filteredCityList.allSatisfy { city in
            city.name.lowercased().contains(searchQuery.lowercased()) ||
            city.country.lowercased().contains(searchQuery.lowercased()) ||
            city.displayName.lowercased().contains(searchQuery.lowercased())
        })
    }
    
    func testEmptySearchQueryShowsAllCities() {
        // Given
        let emptyQuery = ""
        
        // When
        viewModel.perform(.searchQuery(emptyQuery))
        
        // Then
        XCTAssertEqual(viewModel.filteredCityList.count, viewModel.cityList.count)
    }
    
    func testViewModelInitializationWithSampleData() {
        // Then
        XCTAssertFalse(viewModel.cityList.isEmpty)
        XCTAssertEqual(viewModel.filteredCityList.count, viewModel.cityList.count)
        XCTAssertTrue(viewModel.cityList.contains { $0.name == "Buenos Aires" })
        XCTAssertTrue(viewModel.cityList.contains { $0.name == "New York" })
    }
    
    func testViewModelWorksWithoutCoordinator() {
        // Given
        let viewModelWithoutCoordinator = CitySearchViewModel(coordinator: nil)
        let testCity = City(id: 999, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // When
        viewModelWithoutCoordinator.perform(.selectCity(testCity))
        
        // Then
        // Should not crash and should still filter cities
        XCTAssertFalse(viewModelWithoutCoordinator.cityList.isEmpty)
    }
}
