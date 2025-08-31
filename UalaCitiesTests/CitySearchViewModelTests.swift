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
    
    // MARK: - Pagination Tests
    
    func testPaginationInitialState() {
        // Then
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertFalse(viewModel.isLoadingMore)
    }
    
    func testPaginationWithLargeDataSet() {
        // Given - Create a large dataset
        let largeCityList = (1...50).map { index in
            City(id: index, name: "City \(index)", country: "Country \(index)", coord: City.Coordinate(lon: Double(index), lat: Double(index)))
        }
        
        // When - Set the large dataset
        viewModel.cityList = largeCityList
        viewModel.perform(.searchQuery(""))
        
        // Then - Should show first page (20 items) and have more pages
        XCTAssertEqual(viewModel.filteredCityList.count, 20)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func testLoadMoreIncreasesPageAndShowsMoreItems() {
        // Given - Create a large dataset
        let largeCityList = (1...50).map { index in
            City(id: index, name: "City \(index)", country: "Country \(index)", coord: City.Coordinate(lon: Double(index), lat: Double(index)))
        }
        viewModel.cityList = largeCityList
        viewModel.perform(.searchQuery(""))
        
        let initialCount = viewModel.filteredCityList.count
        let initialPage = viewModel.currentPage
        let initialFirstCity = viewModel.filteredCityList.first
        
        // When - Load more
        viewModel.perform(.loadMore)
        
        // Then - Should increase page and append more items
        XCTAssertEqual(viewModel.currentPage, initialPage + 1)
        XCTAssertEqual(viewModel.filteredCityList.count, initialCount + 20) // Should have 20 more items
        XCTAssertEqual(viewModel.filteredCityList.first, initialFirstCity) // First item should remain the same
        XCTAssertEqual(viewModel.filteredCityList[initialCount].name, "City 21") // First new item should be City 21
    }
    
    func testLoadMoreRespectsHasMorePagesFlag() {
        // Given - Create exactly 20 items (one page)
        let smallCityList = (1...20).map { index in
            City(id: index, name: "City \(index)", country: "Country \(index)", coord: City.Coordinate(lon: Double(index), lat: Double(index)))
        }
        viewModel.cityList = smallCityList
        viewModel.perform(.searchQuery(""))
        
        // Then - Should not have more pages
        XCTAssertFalse(viewModel.hasMorePages)
        
        // When - Try to load more
        viewModel.perform(.loadMore)
        
        // Then - Should not change page or add more items
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertEqual(viewModel.filteredCityList.count, 20)
    }
    
    func testSearchQueryResetsPagination() {
        // Given - Create a large dataset and load more
        let largeCityList = (1...50).map { index in
            City(id: index, name: "City \(index)", country: "Country \(index)", coord: City.Coordinate(lon: Double(index), lat: Double(index)))
        }
        viewModel.cityList = largeCityList
        viewModel.perform(.searchQuery(""))
        viewModel.perform(.loadMore)
        
        XCTAssertEqual(viewModel.currentPage, 2)
        
        // When - Perform a new search
        viewModel.perform(.searchQuery("City"))
        
        // Then - Should reset to page 1
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func testLoadMoreWhileLoadingDoesNothing() {
        // Given - Create a large dataset
        let largeCityList = (1...50).map { index in
            City(id: index, name: "City \(index)", country: "Country \(index)", coord: City.Coordinate(lon: Double(index), lat: Double(index)))
        }
        viewModel.cityList = largeCityList
        viewModel.perform(.searchQuery(""))
        
        // When - Start loading more
        viewModel.perform(.loadMore)
        XCTAssertTrue(viewModel.isLoadingMore)
        
        // And try to load more again while loading
        viewModel.perform(.loadMore)
        
        // Then - Should still be on the same page
        XCTAssertEqual(viewModel.currentPage, 2)
    }
    
    func testFirstPageReplacesListAndSubsequentPagesAppend() {
        // Given - Create a large dataset
        let largeCityList = (1...50).map { index in
            City(id: index, name: "City \(index)", country: "Country \(index)", coord: City.Coordinate(lon: Double(index), lat: Double(index)))
        }
        viewModel.cityList = largeCityList
        
        // When - Perform initial search (first page)
        viewModel.perform(.searchQuery(""))
        
        // Then - Should show first 20 items
        XCTAssertEqual(viewModel.filteredCityList.count, 20)
        XCTAssertEqual(viewModel.filteredCityList.first?.name, "City 1")
        XCTAssertEqual(viewModel.filteredCityList.last?.name, "City 20")
        
        // When - Load more (second page)
        viewModel.perform(.loadMore)
        
        // Then - Should have 40 items total (20 + 20)
        XCTAssertEqual(viewModel.filteredCityList.count, 40)
        XCTAssertEqual(viewModel.filteredCityList.first?.name, "City 1") // First item unchanged
        XCTAssertEqual(viewModel.filteredCityList[19].name, "City 20") // Last item from first page
        XCTAssertEqual(viewModel.filteredCityList[20].name, "City 21") // First item from second page
        XCTAssertEqual(viewModel.filteredCityList.last?.name, "City 40") // Last item from second page
        
        // When - Load more again (third page)
        viewModel.perform(.loadMore)
        
        // Then - Should have 50 items total (20 + 20 + 10)
        XCTAssertEqual(viewModel.filteredCityList.count, 50)
        XCTAssertEqual(viewModel.filteredCityList.first?.name, "City 1") // First item unchanged
        XCTAssertEqual(viewModel.filteredCityList.last?.name, "City 50") // Last item from third page
    }
}
