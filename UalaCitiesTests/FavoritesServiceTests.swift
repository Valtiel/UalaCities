//
//  FavoritesServiceTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
@testable import UalaCities

@MainActor
final class FavoritesServiceTests: XCTestCase {
    
    var favoritesService: FavoritesService!
    
    override func setUp() {
        super.setUp()
        favoritesService = FavoritesService()
        // Clear UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "favorite_cities")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "favorite_cities")
        favoritesService = nil
        super.tearDown()
    }
    
    func testAddToFavorites() {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // When
        favoritesService.addToFavorites(city)
        
        // Then
        XCTAssertTrue(favoritesService.isFavorite(city))
        XCTAssertEqual(favoritesService.favoritesCount, 1)
        XCTAssertEqual(favoritesService.favoriteCities.count, 1)
        XCTAssertEqual(favoritesService.favoriteCities.first?.id, city.id)
    }
    
    func testRemoveFromFavorites() {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        favoritesService.addToFavorites(city)
        
        // When
        favoritesService.removeFromFavorites(city)
        
        // Then
        XCTAssertFalse(favoritesService.isFavorite(city))
        XCTAssertEqual(favoritesService.favoritesCount, 0)
        XCTAssertTrue(favoritesService.favoriteCities.isEmpty)
    }
    
    func testToggleFavorite() {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // When - Add to favorites
        favoritesService.toggleFavorite(city)
        
        // Then
        XCTAssertTrue(favoritesService.isFavorite(city))
        XCTAssertEqual(favoritesService.favoritesCount, 1)
        
        // When - Remove from favorites
        favoritesService.toggleFavorite(city)
        
        // Then
        XCTAssertFalse(favoritesService.isFavorite(city))
        XCTAssertEqual(favoritesService.favoritesCount, 0)
    }
    
    func testMultipleFavorites() {
        // Given
        let city1 = City(id: 1, name: "City 1", country: "Country 1", coord: City.Coordinate(lon: 0, lat: 0))
        let city2 = City(id: 2, name: "City 2", country: "Country 2", coord: City.Coordinate(lon: 1, lat: 1))
        let city3 = City(id: 3, name: "City 3", country: "Country 3", coord: City.Coordinate(lon: 2, lat: 2))
        
        // When
        favoritesService.addToFavorites(city1)
        favoritesService.addToFavorites(city2)
        favoritesService.addToFavorites(city3)
        
        // Then
        XCTAssertEqual(favoritesService.favoritesCount, 3)
        XCTAssertTrue(favoritesService.isFavorite(city1))
        XCTAssertTrue(favoritesService.isFavorite(city2))
        XCTAssertTrue(favoritesService.isFavorite(city3))
        
        // When - Remove one
        favoritesService.removeFromFavorites(city2)
        
        // Then
        XCTAssertEqual(favoritesService.favoritesCount, 2)
        XCTAssertTrue(favoritesService.isFavorite(city1))
        XCTAssertFalse(favoritesService.isFavorite(city2))
        XCTAssertTrue(favoritesService.isFavorite(city3))
    }
    
    func testDuplicateAddToFavorites() {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // When
        favoritesService.addToFavorites(city)
        favoritesService.addToFavorites(city) // Try to add again
        
        // Then
        XCTAssertEqual(favoritesService.favoritesCount, 1)
        XCTAssertEqual(favoritesService.favoriteCities.count, 1)
    }
    
    func testRemoveNonExistentFavorite() {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        
        // When
        favoritesService.removeFromFavorites(city)
        
        // Then
        XCTAssertEqual(favoritesService.favoritesCount, 0)
        XCTAssertTrue(favoritesService.favoriteCities.isEmpty)
    }
    
    func testPersistence() {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        favoritesService.addToFavorites(city)
        
        // When - Create a new service instance
        let newFavoritesService = FavoritesService()
        
        // Then
        XCTAssertTrue(newFavoritesService.isFavorite(city))
        XCTAssertEqual(newFavoritesService.favoritesCount, 1)
    }
}
