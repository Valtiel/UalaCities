//
//  CityDetailViewModelTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import Testing
import Foundation
import Combine
@testable import UalaCities

final class CityDetailViewModelTests {
    
    // MARK: - Test Data
    
    private let testCity = City(
        id: 1,
        name: "Buenos Aires",
        country: "Argentina",
        coord: City.Coordinate(lon: -58.3816, lat: -34.6037)
    )
    
    private let anotherCity = City(
        id: 2,
        name: "Córdoba",
        country: "Argentina",
        coord: City.Coordinate(lon: -64.1811, lat: -31.4135)
    )
    
    // MARK: - Mock Objects
    
    private var mockFavoritesService: MockFavoritesService!
    private var mockCoordinator: MockCoordinator!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    
    init() {
        setupMocks()
        setupCancellables()
    }
    
    private func setupMocks() {
        mockFavoritesService = MockFavoritesService()
        mockCoordinator = MockCoordinator()
    }
    
    private func resetMocks() {
        mockFavoritesService.reset()
        mockCoordinator.reset()
    }
    
    private func setupCancellables() {
        cancellables = Set<AnyCancellable>()
    }
    
    // MARK: - Test Groups
    
    @Test("Initialization sets correct initial state")
    func testInitialization() throws {
        // Given & When
        let viewModel = CityDetailViewModel(
            city: testCity,
            favoritesService: mockFavoritesService,
            coordinator: mockCoordinator
        )
        
        // Then
        #expect(viewModel.city == testCity)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.isFavorite == false)
    }
    
    @Test("Initialization without coordinator works correctly")
    func testInitializationWithoutCoordinator() throws {
        // Given & When
        let viewModel = CityDetailViewModel(
            city: testCity,
            favoritesService: mockFavoritesService
        )
        
        // Then
        #expect(viewModel.city == testCity)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.isFavorite == false)
    }
    
    @Test("Toggle favorite action calls favorites service")
    func testToggleFavoriteAction() throws {
        // Given
        let viewModel = CityDetailViewModel(
            city: testCity,
            favoritesService: mockFavoritesService
        )
        
        // When
        viewModel.perform(.toggleFavorite)
        
        // Then
        #expect(mockFavoritesService.toggleFavoriteCalled == true)
        #expect(mockFavoritesService.lastToggledCity == testCity)
    }
    
    @Test("Favorite status remains false when other cities are in favorites")
    func testFavoriteStatusWithOtherCities() throws {
        resetMocks()
        
        // Given
        let viewModel = CityDetailViewModel(
            city: testCity,
            favoritesService: mockFavoritesService
        )
        
        // When - Add different city to favorites
        mockFavoritesService.addToFavorites(anotherCity)
        
        // Then
        #expect(viewModel.isFavorite == false)
    }
    
    @Test("Mock service publisher works correctly")
    func testMockServicePublisher() async throws {
        resetMocks()
        
        // Given
        var receivedCities: [City] = []
        var publisherEmitted = false
        
        mockFavoritesService.favoriteCitiesPublisher
            .sink { cities in
                receivedCities = cities
                publisherEmitted = true
            }
            .store(in: &cancellables)
        
        // When - Add a city to favorites
        mockFavoritesService.addToFavorites(testCity)
        
        // Wait for the publisher to emit
        var attempts = 0
        while !publisherEmitted && attempts < 50 {
            try await Task.sleep(nanoseconds: 50_000)
            attempts += 1
        }
        
        // Then - Verify the publisher worked
        #expect(publisherEmitted == true)
        #expect(receivedCities.count == 1)
        #expect(receivedCities.first?.id == testCity.id)
    }
    
    @Test("City property can be updated")
    func testCityPropertyUpdate() throws {
        // Given
        let viewModel = CityDetailViewModel(
            city: testCity,
            favoritesService: mockFavoritesService
        )
        
        // When
        viewModel.city = anotherCity
        
        // Then
        #expect(viewModel.city == anotherCity)
    }
    
    @Test("Loading state can be updated")
    func testLoadingStateUpdate() throws {
        // Given
        let viewModel = CityDetailViewModel(
            city: testCity,
            favoritesService: mockFavoritesService
        )
        
        // When
        viewModel.isLoading = true
        
        // Then
        #expect(viewModel.isLoading == true)
    }
    
    @Test("Error state can be updated")
    func testErrorStateUpdate() throws {
        // Given
        let viewModel = CityDetailViewModel(
            city: testCity,
            favoritesService: mockFavoritesService
        )
        let testError = NSError(domain: "TestDomain", code: 1, userInfo: nil)
        
        // When
        viewModel.error = testError
        
        // Then
        #expect(viewModel.error?.localizedDescription == testError.localizedDescription)
    }
}

// MARK: - Mock Favorites Service

private final class MockFavoritesService: FavoritesService, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var favoriteCities: [City] = []
    
    var favoriteCitiesPublisher: Published<[City]>.Publisher {
        $favoriteCities
    }
    
    // MARK: - Mock Properties
    
    var toggleFavoriteCalled = false
    var lastToggledCity: City?
    
    // MARK: - Mock Methods
    
    func addToFavorites(_ city: City) {
        if !isFavorite(city) {
            favoriteCities.append(city)
        }
    }
    
    func removeFromFavorites(_ city: City) {
        favoriteCities.removeAll { $0.id == city.id }
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
        favoriteCities.contains { $0.id == city.id }
    }
    
    var favoritesCount: Int {
        favoriteCities.count
    }
    
    // MARK: - Test Helper Methods
    
    func simulateFavoriteCitiesUpdate(_ cities: [City]) {
        favoriteCities.removeAll()
        favoriteCities.forEach { city in
            addToFavorites(city)
        }
    }
    
    func reset() {
        favoriteCities.removeAll()
        toggleFavoriteCalled = false
        lastToggledCity = nil
    }
    

}

// MARK: - Mock Coordinator

private final class MockCoordinator: Coordinator {
    
    // MARK: - Mock Properties
    
    var navigateCalled = false
    var presentSheetCalled = false
    var dismissSheetCalled = false
    var popToRootCalled = false
    var popCalled = false
    
    var lastNavigationDestination: NavigationDestination?
    var lastSheetDestination: SheetDestination?
    
    // MARK: - Mock Methods
    
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
    
    func reset() {
        navigateCalled = false
        presentSheetCalled = false
        dismissSheetCalled = false
        popToRootCalled = false
        popCalled = false
        lastNavigationDestination = nil
        lastSheetDestination = nil
    }
}
