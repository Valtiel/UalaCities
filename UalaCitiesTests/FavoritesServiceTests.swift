//
//  FavoritesServiceTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import Testing
@testable import UalaCities
import Foundation
import Combine

struct FavoritesServiceTests {
    
    // MARK: - Test Setup and Cleanup
    
    private let favoritesKey = "favorite_cities"
    
    init() {
        // Clear UserDefaults before running any tests
        UserDefaults.standard.removeObject(forKey: favoritesKey)
    }
    
    private func createTestCity(id: Int, name: String, country: String) -> City {
        let coordinate = City.Coordinate(lon: Double(id), lat: Double(id))
        return City(id: id, name: name, country: country, coord: coordinate)
    }
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() {
        let service = UserDefaultsFavoritesService()
        
        #expect(service.favoriteCities.isEmpty)
        #expect(service.favoritesCount == 0)
    }
    
    // MARK: - Add to Favorites Tests
    
    @Test func testAddToFavorites() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.addToFavorites(city)
        
        #expect(service.favoriteCities.count == 1)
        #expect(service.favoritesCount == 1)
        #expect(service.favoriteCities.first?.id == city.id)
        #expect(service.isFavorite(city))
    }
    
    @Test func testAddToFavoritesDuplicate() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.addToFavorites(city)
        service.addToFavorites(city) // Try to add the same city again
        
        #expect(service.favoriteCities.count == 1)
        #expect(service.favoritesCount == 1)
        #expect(service.favoriteCities.first?.id == city.id)
    }
    
    @Test func testAddMultipleCities() {
        let service = UserDefaultsFavoritesService()
        let city1 = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let city2 = createTestCity(id: 2, name: "New York", country: "USA")
        let city3 = createTestCity(id: 3, name: "London", country: "UK")
        
        service.addToFavorites(city1)
        service.addToFavorites(city2)
        service.addToFavorites(city3)
        
        #expect(service.favoriteCities.count == 3)
        #expect(service.favoritesCount == 3)
        #expect(service.isFavorite(city1))
        #expect(service.isFavorite(city2))
        #expect(service.isFavorite(city3))
    }
    
    // MARK: - Remove from Favorites Tests
    
    @Test func testRemoveFromFavorites() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.addToFavorites(city)
        #expect(service.favoritesCount == 1)
        
        service.removeFromFavorites(city)
        
        #expect(service.favoriteCities.isEmpty)
        #expect(service.favoritesCount == 0)
        #expect(!service.isFavorite(city))
    }
    
    @Test func testRemoveFromFavoritesNotInList() {
        let service = UserDefaultsFavoritesService()
        let city1 = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let city2 = createTestCity(id: 2, name: "New York", country: "USA")
        
        service.addToFavorites(city1)
        #expect(service.favoritesCount == 1)
        
        service.removeFromFavorites(city2) // Try to remove a city that's not in favorites
        
        #expect(service.favoritesCount == 1)
        #expect(service.isFavorite(city1))
        #expect(!service.isFavorite(city2))
    }
    
    @Test func testRemoveFromFavoritesEmptyList() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.removeFromFavorites(city) // Try to remove from empty list
        
        #expect(service.favoriteCities.isEmpty)
        #expect(service.favoritesCount == 0)
    }
    
    // MARK: - Toggle Favorite Tests
    
    @Test func testToggleFavoriteAdd() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.toggleFavorite(city)
        
        #expect(service.favoritesCount == 1)
        #expect(service.isFavorite(city))
    }
    
    @Test func testToggleFavoriteRemove() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.addToFavorites(city)
        #expect(service.favoritesCount == 1)
        
        service.toggleFavorite(city)
        
        #expect(service.favoritesCount == 0)
        #expect(!service.isFavorite(city))
    }
    
    @Test func testToggleFavoriteMultipleTimes() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        // Toggle multiple times
        service.toggleFavorite(city) // Add
        service.toggleFavorite(city) // Remove
        service.toggleFavorite(city) // Add again
        
        #expect(service.favoritesCount == 1)
        #expect(service.isFavorite(city))
    }
    
    // MARK: - Is Favorite Tests
    
    @Test func testIsFavoriteTrue() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.addToFavorites(city)
        
        #expect(service.isFavorite(city))
    }
    
    @Test func testIsFavoriteFalse() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        #expect(!service.isFavorite(city))
    }
    
    @Test func testIsFavoriteAfterRemoval() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        service.addToFavorites(city)
        #expect(service.isFavorite(city))
        
        service.removeFromFavorites(city)
        #expect(!service.isFavorite(city))
    }
    
    // MARK: - Favorites Count Tests
    
    @Test func testFavoritesCountEmpty() {
        let service = UserDefaultsFavoritesService()
        
        #expect(service.favoritesCount == 0)
    }
    
    @Test func testFavoritesCountAfterAdding() {
        let service = UserDefaultsFavoritesService()
        let city1 = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let city2 = createTestCity(id: 2, name: "New York", country: "USA")
        
        #expect(service.favoritesCount == 0)
        
        service.addToFavorites(city1)
        #expect(service.favoritesCount == 1)
        
        service.addToFavorites(city2)
        #expect(service.favoritesCount == 2)
    }
    
    @Test func testFavoritesCountAfterRemoving() {
        let service = UserDefaultsFavoritesService()
        let city1 = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let city2 = createTestCity(id: 2, name: "New York", country: "USA")
        
        service.addToFavorites(city1)
        service.addToFavorites(city2)
        #expect(service.favoritesCount == 2)
        
        service.removeFromFavorites(city1)
        #expect(service.favoritesCount == 1)
        
        service.removeFromFavorites(city2)
        #expect(service.favoritesCount == 0)
    }
    
    // MARK: - Publisher Tests
    
    @Test func testFavoriteCitiesPublisher() {
        let service = UserDefaultsFavoritesService()
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        var receivedCities: [City] = []
        let cancellable = service.favoriteCitiesPublisher
            .sink { cities in
                receivedCities = cities
            }
        
        // The publisher should emit the initial empty state
        #expect(receivedCities.isEmpty)
        
        service.addToFavorites(city)
        
        // The publisher should emit the updated state with the city
        #expect(receivedCities.count == 1)
        #expect(receivedCities.first?.id == city.id)
        
        cancellable.cancel()
    }
    
    // MARK: - Persistence Tests
    
    @Test func testPersistenceAcrossInstances() {
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        // Create first instance and add a city
        let service1 = UserDefaultsFavoritesService()
        service1.addToFavorites(city)
        #expect(service1.favoritesCount == 1)
        
        // Create second instance and verify the city is still there
        let service2 = UserDefaultsFavoritesService()
        #expect(service2.favoritesCount == 1)
        #expect(service2.isFavorite(city))
    }
    
    @Test func testPersistenceAfterRemoval() {
        let city = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        
        // Create first instance, add and then remove a city
        let service1 = UserDefaultsFavoritesService()
        service1.addToFavorites(city)
        service1.removeFromFavorites(city)
        #expect(service1.favoritesCount == 0)
        
        // Create second instance and verify the city is not there
        let service2 = UserDefaultsFavoritesService()
        #expect(service2.favoritesCount == 0)
        #expect(!service2.isFavorite(city))
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func testMultipleCitiesWithSameNameDifferentIds() {
        let service = UserDefaultsFavoritesService()
        let city1 = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let city2 = createTestCity(id: 2, name: "Buenos Aires", country: "USA")
        
        service.addToFavorites(city1)
        service.addToFavorites(city2)
        
        #expect(service.favoritesCount == 2)
        #expect(service.isFavorite(city1))
        #expect(service.isFavorite(city2))
        
        service.removeFromFavorites(city1)
        #expect(service.favoritesCount == 1)
        #expect(!service.isFavorite(city1))
        #expect(service.isFavorite(city2))
    }
    
    @Test func testRemoveSpecificCityById() {
        let service = UserDefaultsFavoritesService()
        let city1 = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let city2 = createTestCity(id: 2, name: "New York", country: "USA")
        
        service.addToFavorites(city1)
        service.addToFavorites(city2)
        #expect(service.favoritesCount == 2)
        
        // Remove city1 specifically
        service.removeFromFavorites(city1)
        #expect(service.favoritesCount == 1)
        #expect(!service.isFavorite(city1))
        #expect(service.isFavorite(city2))
    }
    
    // MARK: - Cleanup Tests
    
    @Test func testCleanupAfterAllRemovals() {
        let service = UserDefaultsFavoritesService()
        let city1 = createTestCity(id: 1, name: "Buenos Aires", country: "Argentina")
        let city2 = createTestCity(id: 2, name: "New York", country: "USA")
        let city3 = createTestCity(id: 3, name: "London", country: "UK")
        
        service.addToFavorites(city1)
        service.addToFavorites(city2)
        service.addToFavorites(city3)
        #expect(service.favoritesCount == 3)
        
        service.removeFromFavorites(city1)
        service.removeFromFavorites(city2)
        service.removeFromFavorites(city3)
        
        #expect(service.favoritesCount == 0)
        #expect(service.favoriteCities.isEmpty)
    }
}
