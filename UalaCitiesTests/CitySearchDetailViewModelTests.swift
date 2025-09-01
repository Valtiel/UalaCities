//
//  CitySearchDetailViewModelTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
import Combine
@testable import UalaCities

final class CitySearchDetailViewModelTests: XCTestCase {
    
    var viewModel: CitySearchDetailViewModel!
    var searchService: MockCitySearchService!
    var cityDataService: MockCityDataService!
    var favoritesService: MockFavoritesService!
    var coordinator: MockCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        searchService = MockCitySearchService()
        cityDataService = MockCityDataService()
        favoritesService = MockFavoritesService()
        coordinator = MockCoordinator()
        cancellables = Set<AnyCancellable>()
        
        viewModel = CitySearchDetailViewModel(
            searchService: searchService,
            cityDataService: cityDataService,
            favoritesService: favoritesService,
            coordinator: coordinator
        )
    }
    
    override func tearDown() {
        viewModel = nil
        searchService = nil
        cityDataService = nil
        favoritesService = nil
        coordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(viewModel.cityList.count, 0)
        XCTAssertEqual(viewModel.filteredCityList.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertFalse(viewModel.isLoadingMore)
        XCTAssertEqual(viewModel.favoritesCount, 0)
        XCTAssertNil(viewModel.selectedCity)
        XCTAssertFalse(viewModel.isDetailFavorite)
    }
    
    // MARK: - Search Tests
    
    func testSearchQuery_EmptyQuery_ShowsAllCities() {
        // Given
        let cities = [mockCity1, mockCity2, mockCity3]
        cityDataService.mockCities = cities
        
        // When
        viewModel.perform(.searchQuery(""))
        
        // Then
        XCTAssertEqual(viewModel.filteredCityList.count, 3)
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func testSearchQuery_WithQuery_FiltersCities() {
        // Given
        let cities = [mockCity1, mockCity2, mockCity3]
        cityDataService.mockCities = cities
        searchService.mockSearchResults = [mockCity1]
        
        // When
        viewModel.perform(.searchQuery("Buenos"))
        
        // Then
        XCTAssertEqual(viewModel.filteredCityList.count, 1)
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    // MARK: - City Selection Tests
    
    func testSelectCity_UpdatesSelectedCity() {
        // Given
        let city = mockCity1
        
        // When
        viewModel.perform(.selectCity(city))
        
        // Then
        XCTAssertEqual(viewModel.selectedCity?.id, city.id)
        XCTAssertEqual(viewModel.selectedCity?.name, city.name)
    }
    
    // MARK: - Favorite Tests
    
    func testToggleFavorite_CallsFavoritesService() {
        // Given
        let city = mockCity1
        
        // When
        viewModel.perform(.toggleFavorite(city))
        
        // Then
        XCTAssertTrue(favoritesService.toggleFavoriteCalled)
        XCTAssertEqual(favoritesService.lastToggledCity?.id, city.id)
    }
    
    func testToggleDetailFavorite_CallsFavoritesService() {
        // Given
        let city = mockCity1
        viewModel.perform(.selectCity(city))
        
        // When
        viewModel.perform(.toggleDetailFavorite)
        
        // Then
        XCTAssertTrue(favoritesService.toggleFavoriteCalled)
        XCTAssertEqual(favoritesService.lastToggledCity?.id, city.id)
    }
    
    func testIsFavorite_ReturnsCorrectValue() {
        // Given
        let city = mockCity1
        favoritesService.mockFavoriteCities = [city]
        
        // When
        let result = viewModel.isFavorite(city)
        
        // Then
        XCTAssertTrue(result)
    }
    
    // MARK: - Load More Tests
    
    func testLoadMore_IncrementsPage() {
        // Given
        let cities = Array(1...25).map { City(id: $0, name: "City \($0)", country: "Country", coord: .init(lon: 0, lat: 0)) }
        cityDataService.mockCities = cities
        viewModel.perform(.searchQuery(""))
        
        // When
        viewModel.perform(.loadMore)
        
        // Then
        XCTAssertEqual(viewModel.currentPage, 2)
    }
    
    // MARK: - Show Favorites Tests
    
    func testShowFavorites_CallsCoordinator() {
        // When
        viewModel.perform(.showFavorites)
        
        // Then
        XCTAssertTrue(coordinator.presentSheetCalled)
        XCTAssertEqual(coordinator.lastPresentedSheet, .favorites)
    }
    
    // MARK: - Bindings Tests
    
    func testCityDataServiceBinding_UpdatesCityList() {
        // Given
        let cities = [mockCity1, mockCity2]
        
        // When
        cityDataService.mockCities = cities
        
        // Then
        XCTAssertEqual(viewModel.cityList.count, 2)
    }
    
    func testFavoritesServiceBinding_UpdatesFavoritesCount() {
        // Given
        let cities = [mockCity1, mockCity2]
        
        // When
        favoritesService.mockFavoriteCities = cities
        
        // Then
        XCTAssertEqual(viewModel.favoritesCount, 2)
    }
    
    func testSelectedCityFavoriteBinding_UpdatesDetailFavorite() {
        // Given
        let city = mockCity1
        favoritesService.mockFavoriteCities = [city]
        viewModel.perform(.selectCity(city))
        
        // Then
        XCTAssertTrue(viewModel.isDetailFavorite)
    }
    
    // MARK: - Helper Methods
    
    private var mockCity1: City {
        City(id: 1, name: "Buenos Aires", country: "Argentina", coord: .init(lon: -58.3816, lat: -34.6037))
    }
    
    private var mockCity2: City {
        City(id: 2, name: "New York", country: "USA", coord: .init(lon: -74.0060, lat: 40.7128))
    }
    
    private var mockCity3: City {
        City(id: 3, name: "London", country: "UK", coord: .init(lon: -0.1276, lat: 51.5074))
    }
}

// MARK: - Mock Classes

private class MockCitySearchService: CitySearchService {
    var mockSearchResults: [City] = []
    var isIndexed: Bool = false
    
    override func search(query: String) async -> [City] {
        return mockSearchResults
    }
    
    override func index(cities: [City]) {
        isIndexed = true
    }
}

private class MockCityDataService: CityDataService {
    var mockCities: [City] = [] {
        didSet {
            cities = mockCities
        }
    }
    
    override var cities: [City] {
        get { mockCities }
        set { mockCities = newValue }
    }
    
    override var isDataLoaded: Bool {
        return !mockCities.isEmpty
    }
}

private class MockFavoritesService: FavoritesService {
    var mockFavoriteCities: [City] = []
    var toggleFavoriteCalled = false
    var lastToggledCity: City?
    
    override var favoriteCities: [City] {
        get { mockFavoriteCities }
        set { mockFavoriteCities = newValue }
    }
    
    override func toggleFavorite(_ city: City) {
        toggleFavoriteCalled = true
        lastToggledCity = city
    }
    
    override func isFavorite(_ city: City) -> Bool {
        return mockFavoriteCities.contains { $0.id == city.id }
    }
}

private class MockCoordinator: Coordinator {
    var presentSheetCalled = false
    var lastPresentedSheet: SheetDestination?
    
    func navigate(to destination: NavigationDestination) {}
    func presentSheet(_ destination: SheetDestination) {
        presentSheetCalled = true
        lastPresentedSheet = destination
    }
    func dismissSheet() {}
    func popToRoot() {}
    func pop() {}
}
