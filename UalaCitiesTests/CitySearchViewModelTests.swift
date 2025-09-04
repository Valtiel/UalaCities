//
//  CitySearchViewModelTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import Testing
@testable import UalaCities
import Foundation

struct CitySearchViewModelTests {
    
    // MARK: - Test Setup
    
    private func createMocks() -> (MockCitySearchService, MockCityDataService, MockFavoritesService, MockCoordinator) {
        let mockSearchService = MockCitySearchService()
        let mockCityDataService = MockCityDataService()
        let mockFavoritesService = MockFavoritesService()
        let mockCoordinator = MockCoordinator()
        return (mockSearchService, mockCityDataService, mockFavoritesService, mockCoordinator)
    }
    
    private func createViewModel(
        searchService: MockCitySearchService,
        cityDataService: MockCityDataService,
        favoritesService: MockFavoritesService,
        coordinator: MockCoordinator
    ) -> CitySearchViewModel {
        return CitySearchViewModel(
            searchService: searchService,
            cityDataService: cityDataService,
            favoritesService: favoritesService,
            coordinator: coordinator
        )
    }
    
    private func createTestCity(id: Int, name: String, country: String) -> City {
        let coordinate = City.Coordinate(lon: Double(id), lat: Double(id))
        return City(id: id, name: name, country: country, coord: coordinate)
    }
    
    private func createTestCities() -> [City] {
        [
            createTestCity(id: 1, name: "Buenos Aires", country: "Argentina"),
            createTestCity(id: 2, name: "New York", country: "USA"),
            createTestCity(id: 3, name: "London", country: "UK"),
            createTestCity(id: 4, name: "Paris", country: "France"),
            createTestCity(id: 5, name: "Tokyo", country: "Japan")
        ]
    }
    
    // MARK: - Initialization Tests
    
    @Test func testInitializationWithDefaultValues() {
        let (mockSearchService, mockCityDataService, mockFavoritesService, mockCoordinator) = createMocks()
        let viewModel = createViewModel(
            searchService: mockSearchService,
            cityDataService: mockCityDataService,
            favoritesService: mockFavoritesService,
            coordinator: mockCoordinator
        )
        #expect(viewModel.cityList.isEmpty)
        #expect(viewModel.filteredCityList.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.error == nil)
        #expect(viewModel.currentPage == 1)
        #expect(!viewModel.hasMorePages)
        #expect(!viewModel.isLoadingMore)
        #expect(viewModel.favoritesCount == 0)
    }
    
    @Test func testConvenienceInitializer() {
        let (_, _, _, mockCoordinator) = createMocks()
        let testFavoritesService = MockFavoritesService()
        let viewModel = CitySearchViewModel(
            coordinator: mockCoordinator,
            favoritesService: testFavoritesService
        )
        
        #expect(viewModel.favoritesService === testFavoritesService)
    }
    
    // MARK: - Data Loading Tests
    
    @Test func testDataLoadingWhenNotLoaded() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = createTestCities()
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = false
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        #expect(mockCityDataService.loadCitiesCalled)
    }
    
    @Test func testDataLoadingWhenAlreadyLoaded() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = createTestCities()
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        #expect(!mockCityDataService.loadCitiesCalled)
    }
    
    // MARK: - Search Functionality Tests
    
    @Test func testSearchWithEmptyQuery() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = createTestCities()
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        viewModel.perform(.searchQuery(""))
        
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.cityList == cities)
    }
        
    @Test func testSearchResetsPagination() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = createTestCities()
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        // Set to page 2
        viewModel.currentPage = 2
        viewModel.hasMorePages = true
        
        viewModel.perform(.searchQuery("test"))
        
        #expect(viewModel.currentPage == 1)
    }
    
    // MARK: - Pagination Tests
    
    @Test func testPaginationWithLessThanPageSize() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = Array(createTestCities().prefix(3)) // 3 cities, less than page size (20)
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        viewModel.perform(.searchQuery(""))
        
        #expect(viewModel.filteredCityList.count == 3)
        #expect(!viewModel.hasMorePages)
    }
    
    @Test func testPaginationWithMoreThanPageSize() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = Array(1...25).map { id in
            createTestCity(id: id, name: "City \(id)", country: "Country \(id)")
        }
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        viewModel.perform(.searchQuery(""))
        
        #expect(viewModel.filteredCityList.count == 20) // First page
        #expect(viewModel.hasMorePages)
    }
    
    @Test func testLoadMoreCities() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = Array(1...25).map { id in
            createTestCity(id: id, name: "City \(id)", country: "Country \(id)")
        }
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        viewModel.perform(.searchQuery(""))
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.hasMorePages)
        
        viewModel.perform(.loadMore)
        
        #expect(viewModel.currentPage == 2)
        #expect(viewModel.isLoadingMore)
    }
    
    @Test func testLoadMoreWhenNoMorePages() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = Array(createTestCities().prefix(3))
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        viewModel.perform(.searchQuery(""))
        #expect(!viewModel.hasMorePages)
        
        viewModel.perform(.loadMore)
        
        #expect(viewModel.currentPage == 1) // Should not change
    }
    
    @Test func testLoadMoreWhenAlreadyLoading() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = Array(1...25).map { id in
            createTestCity(id: id, name: "City \(id)", country: "Country \(id)")
        }
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        viewModel.perform(.searchQuery(""))
        viewModel.perform(.loadMore)
        
        let initialPage = viewModel.currentPage
        viewModel.perform(.loadMore) // Try to load more while already loading
        
        #expect(viewModel.currentPage == initialPage) // Should not change
    }
    
    // MARK: - Favorites Tests
    
    @Test func testToggleFavorite() {
        let (_, _, mockFavoritesService, _) = createMocks()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: MockCityDataService(),
            favoritesService: mockFavoritesService,
            coordinator: MockCoordinator()
        )
        
        viewModel.perform(.toggleFavorite(city))
        
        #expect(mockFavoritesService.toggleFavoriteCalled)
        #expect(mockFavoritesService.lastToggledCity?.id == city.id)
    }
    
    @Test func testIsFavorite() {
        var (_, _, mockFavoritesService, _) = createMocks()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        mockFavoritesService.mockIsFavorite = true
        mockFavoritesService.addToFavorites(city)
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: MockCityDataService(),
            favoritesService: mockFavoritesService,
            coordinator: MockCoordinator()
        )
        
        let result = viewModel.isFavorite(city)
        
        #expect(result)
        #expect(mockFavoritesService.isFavoriteCalled)
        #expect(mockFavoritesService.lastCheckedCity?.id == city.id)
    }
        
    // MARK: - View Lifecycle Tests
    
    @Test func testOnViewAppearWithLoadedData() {
        let (_, mockCityDataService, _, _) = createMocks()
        let cities = createTestCities()
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        // Clear filtered list to simulate empty state
        viewModel.filteredCityList = []
        
        viewModel.onViewAppear()
        
        #expect(!viewModel.filteredCityList.isEmpty)
        #expect(viewModel.cityList == cities)
        #expect(viewModel.currentPage == 1)
    }
    
    @Test func testOnViewAppearWithUnloadedData() {
        let (_, mockCityDataService, _, _) = createMocks()
        mockCityDataService.mockIsDataLoaded = false
        
        let viewModel = createViewModel(
            searchService: MockCitySearchService(),
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        viewModel.onViewAppear()
        
        #expect(viewModel.filteredCityList.isEmpty)
    }
    
    // MARK: - Search Service Integration Tests
    
    @Test func testSearchServiceIndexing() {
        let (mockSearchService, mockCityDataService, _, _) = createMocks()
        let cities = createTestCities()
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        
        let viewModel = createViewModel(
            searchService: mockSearchService,
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        #expect(mockSearchService.indexCalled)
        #expect(mockSearchService.lastIndexedCities == cities)
    }
    
    @Test func testSearchServiceNotIndexedTwice() {
        let (mockSearchService, mockCityDataService, _, _) = createMocks()
        let cities = createTestCities()
        mockCityDataService.mockCities = cities
        mockCityDataService.mockIsDataLoaded = true
        mockSearchService.mockIsIndexed = true
        
        let viewModel = createViewModel(
            searchService: mockSearchService,
            cityDataService: mockCityDataService,
            favoritesService: MockFavoritesService(),
            coordinator: MockCoordinator()
        )
        
        #expect(!mockSearchService.indexCalled)
    }
}

// MARK: - Mock Services

private class MockCitySearchService: CitySearchService {
    var mockSearchResults: [City] = []
    var mockIsIndexed = false
    var mockIndexedCityCount = 0
    
    var indexCalled = false
    var lastIndexedCities: [City]?
    var searchCalled = false
    var lastSearchQuery: String?
    var clearCalled = false
    
    func index(cities: [City]) {
        indexCalled = true
        lastIndexedCities = cities
        mockIndexedCityCount = cities.count
        mockIsIndexed = true
    }
    
    func search(query: String) async -> [City] {
        searchCalled = true
        lastSearchQuery = query
        return mockSearchResults
    }
    
    func clear() {
        clearCalled = true
        mockIsIndexed = false
        mockIndexedCityCount = 0
    }
    
    var indexedCityCount: Int { mockIndexedCityCount }
    var isIndexed: Bool { mockIsIndexed }
}

private class MockCityDataService: CityDataService, ObservableObject {
    @Published var mockCities: [City] = []
    @Published var mockIsLoading = false
    @Published var mockError: Error?
    var mockIsDataLoaded = false
    
    var loadCitiesCalled = false
    var reloadCitiesCalled = false
    var searchCitiesCalled = false
    var lastSearchQuery: String?
    
    var cities: [City] { mockCities }
    var isLoading: Bool { mockIsLoading }
    var isDataLoaded: Bool { mockIsDataLoaded }
    
    var citiesPublisher: Published<[City]>.Publisher {
        $mockCities
    }
    
    var isLoadingPublisher: Published<Bool>.Publisher {
        $mockIsLoading
    }
    
    var errorPublisher: Published<Error?>.Publisher {
        $mockError
    }
    
    func loadCities() {
        loadCitiesCalled = true
    }
    
    func reloadCities() {
        reloadCitiesCalled = true
    }
    
    func searchCities(query: String) -> [City] {
        searchCitiesCalled = true
        lastSearchQuery = query
        return mockCities.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func city(withId id: Int) -> City? {
        return mockCities.first { $0.id == id }
    }
}

private class MockFavoritesService: FavoritesService, ObservableObject {
    @Published var mockFavoriteCities: [City] = []
    var mockIsFavorite = false
    
    var toggleFavoriteCalled = false
    var lastToggledCity: City?
    var isFavoriteCalled = false
    var lastCheckedCity: City?
    
    var favoriteCities: [City] { mockFavoriteCities }
    var favoritesCount: Int { mockFavoriteCities.count }
    
    var favoriteCitiesPublisher: Published<[City]>.Publisher {
        $mockFavoriteCities
    }
    
    func addToFavorites(_ city: City) {
        if !mockFavoriteCities.contains(where: { $0.id == city.id }) {
            mockFavoriteCities.append(city)
        }
    }
    
    func removeFromFavorites(_ city: City) {
        mockFavoriteCities.removeAll { $0.id == city.id }
    }
    
    func toggleFavorite(_ city: City) {
        toggleFavoriteCalled = true
        lastToggledCity = city
        if isFavorite(city) {
            removeFromFavorites(city)
        } else {
            addToFavorites(city)
        }
    }
    
    func isFavorite(_ city: City) -> Bool {
        isFavoriteCalled = true
        lastCheckedCity = city
        return mockFavoriteCities.contains { $0.id == city.id }
    }
}

private class MockCoordinator: Coordinator, ObservableObject {
    var presentSheetCalled = false
    var lastSheetDestination: SheetDestination?
    var navigateCalled = false
    var lastNavigationDestination: NavigationDestination?
    var dismissSheetCalled = false
    var popToRootCalled = false
    var popCalled = false
    
    func navigate(to destination: NavigationDestination) {
        navigateCalled = true
        lastNavigationDestination = destination
    }
    
    func presentSheet(_ destination: SheetDestination) {
        presentSheetCalled = true
        lastSheetDestination = destination
    }
    
    func dismissSheet() {
        dismissSheetCalled = true
    }
    
    func popToRoot() {
        popToRootCalled = true
    }
    
    func pop() {
        popCalled = true
    }
}

private class MockAppCoordinator: MockCoordinator {
    var setSelectedCityCalled = false
    var lastSelectedCity: City?
    
    func setSelectedCity(_ city: City) {
        setSelectedCityCalled = true
        lastSelectedCity = city
    }
}
