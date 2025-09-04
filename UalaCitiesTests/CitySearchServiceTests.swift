//
//  CitySearchServiceTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 29/08/2025.
//

import Testing
import Foundation
@testable import UalaCities

@Suite("CitySearchService Tests")
struct CitySearchServiceTests {
    
    // MARK: - Test Data
    
    private let testCities = [
        City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
        City(id: 2, name: "Córdoba", country: "Argentina", coord: City.Coordinate(lon: -64.1888, lat: -31.4167)),
        City(id: 3, name: "Rosario", country: "Argentina", coord: City.Coordinate(lon: -60.6396, lat: -32.9468)),
        City(id: 4, name: "Barcelona", country: "Spain", coord: City.Coordinate(lon: 2.1734, lat: 41.3851)),
        City(id: 5, name: "Madrid", country: "Spain", coord: City.Coordinate(lon: -3.7038, lat: 40.4168)),
        City(id: 6, name: "Valencia", country: "Spain", coord: City.Coordinate(lon: -0.3763, lat: 39.4699)),
        City(id: 7, name: "New York", country: "United States", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
        City(id: 8, name: "Los Angeles", country: "United States", coord: City.Coordinate(lon: -118.2437, lat: 34.0522)),
        City(id: 9, name: "Chicago", country: "United States", coord: City.Coordinate(lon: -87.6298, lat: 41.8781)),
        City(id: 10, name: "Toronto", country: "Canada", coord: City.Coordinate(lon: -79.3832, lat: 43.6532))
    ]
    
    private var mockStrategy: MockCitySearchStrategy!
    private var service: CitySearchByStrategyService!
    
    // MARK: - Setup
    
    init() {
        mockStrategy = MockCitySearchStrategy()
        service = CitySearchByStrategyService(strategy: mockStrategy)
    }
    
    // MARK: - Index Tests
    
    @Test("Index should delegate to strategy")
    func testIndexDelegatesToStrategy() async throws {
        // When
        service.index(cities: testCities)
        
        // Then
        #expect(mockStrategy.indexedCities == testCities)
        #expect(mockStrategy.indexCallCount == 1)
    }
    
    @Test("Index should handle empty array")
    func testIndexHandlesEmptyArray() async throws {
        // When
        service.index(cities: [])
        
        // Then
        #expect(mockStrategy.indexedCities.isEmpty)
        #expect(mockStrategy.indexCallCount == 1)
    }
    
    // MARK: - Search Tests
    
    @Test("Search should delegate to strategy")
    func testSearchDelegatesToStrategy() async throws {
        // Given
        let query = "Buenos"
        let expectedResults = [testCities[0]]
        mockStrategy.searchResults = expectedResults
        
        // When
        let results = await service.search(query: query)
        
        // Then
        #expect(results == expectedResults)
        #expect(mockStrategy.lastSearchQuery == query)
        #expect(mockStrategy.searchCallCount == 1)
    }
    
    @Test("Search should handle empty query")
    func testSearchHandlesEmptyQuery() async throws {
        // Given
        let query = ""
        mockStrategy.searchResults = []
        
        // When
        let results = await service.search(query: query)
        
        // Then
        #expect(results.isEmpty)
        #expect(mockStrategy.lastSearchQuery == query)
    }
    
    @Test("Search should handle whitespace query")
    func testSearchHandlesWhitespaceQuery() async throws {
        // Given
        let query = "   "
        mockStrategy.searchResults = []
        
        // When
        let results = await service.search(query: query)
        
        // Then
        #expect(results.isEmpty)
        #expect(mockStrategy.lastSearchQuery == query)
    }
    
    // MARK: - Clear Tests
    
    @Test("Clear should delegate to strategy")
    func testClearDelegatesToStrategy() async throws {
        // When
        service.clear()
        
        // Then
        #expect(mockStrategy.clearCallCount == 1)
    }
    
    // MARK: - IndexedCityCount Tests
    
    @Test("IndexedCityCount should delegate to strategy")
    func testIndexedCityCountDelegatesToStrategy() async throws {
        // Given
        mockStrategy.mockIndexedCityCount = 5
        
        // When
        let count = service.indexedCityCount
        
        // Then
        #expect(count == 5)
    }
    
    @Test("IndexedCityCount should return zero when strategy has no cities")
    func testIndexedCityCountReturnsZeroWhenNoCities() async throws {
        // Given
        mockStrategy.mockIndexedCityCount = 0
        
        // When
        let count = service.indexedCityCount
        
        // Then
        #expect(count == 0)
    }
    
    // MARK: - IsIndexed Tests
    
    @Test("IsIndexed should return true when cities are indexed")
    func testIsIndexedReturnsTrueWhenCitiesIndexed() async throws {
        // Given
        mockStrategy.mockIndexedCityCount = 3
        
        // When
        let isIndexed = service.isIndexed
        
        // Then
        #expect(isIndexed == true)
    }
    
    @Test("IsIndexed should return false when no cities are indexed")
    func testIsIndexedReturnsFalseWhenNoCitiesIndexed() async throws {
        // Given
        mockStrategy.mockIndexedCityCount = 0
        
        // When
        let isIndexed = service.isIndexed
        
        // Then
        #expect(isIndexed == false)
    }
    
    // MARK: - Strategy Switching Tests
    
    @Test("SetStrategy should change the current strategy")
    func testSetStrategyChangesCurrentStrategy() async throws {
        // Given
        let newStrategy = MockCitySearchStrategy()
        newStrategy.searchResults = [testCities[0]]
        
        // When
        service.setStrategy(newStrategy)
        let results = await service.search(query: "test")
        
        // Then
        #expect(results == [testCities[0]])
        #expect(newStrategy.searchCallCount == 1)
    }
    
    @Test("SetStrategy should maintain state after switching")
    func testSetStrategyMaintainsStateAfterSwitching() async throws {
        // Given
        let newStrategy = MockCitySearchStrategy()
        newStrategy.mockIndexedCityCount = 7
        
        // When
        service.setStrategy(newStrategy)
        let count = service.indexedCityCount
        
        // Then
        #expect(count == 7)
    }
    
    // MARK: - Integration Tests
    
    @Test("Service should work with real BinarySearchStrategy")
    func testServiceWithRealBinarySearchStrategy() async throws {
        // Given
        let realStrategy = BinarySearchStrategy()
        let realService = CitySearchByStrategyService(strategy: realStrategy)
        
        // When
        realService.index(cities: testCities)
        let results = await realService.search(query: "Buenos")
        
        // Then
        #expect(realService.isIndexed == true)
        #expect(realService.indexedCityCount == 10)
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
    }
    
    @Test("Service should handle multiple search queries")
    func testServiceHandlesMultipleSearchQueries() async throws {
        // Given
        let realStrategy = BinarySearchStrategy()
        let realService = CitySearchByStrategyService(strategy: realStrategy)
        realService.index(cities: testCities)
        
        // When
        let argentinaResults = await realService.search(query: "Argentina")
        let spainResults = await realService.search(query: "Spain")
        let usaResults = await realService.search(query: "United States")
        
        // Then
        #expect(argentinaResults.count == 3)
        #expect(spainResults.count == 3)
        #expect(usaResults.count == 3)
    }
}

// MARK: - Mock Strategy

private class MockCitySearchStrategy: CitySearchStrategy {
    var indexedCities: [City] = []
    var searchResults: [City] = []
    var lastSearchQuery: String = ""
    
    var indexCallCount = 0
    var searchCallCount = 0
    var clearCallCount = 0
    
    // Mock property to control the return value
    var mockIndexedCityCount: Int = 0
    
    var indexedCityCount: Int {
        return mockIndexedCityCount
    }
    
    func index(cities: [City]) {
        indexedCities = cities
        mockIndexedCityCount = cities.count
        indexCallCount += 1
    }
    
    func search(query: String) async -> [City] {
        lastSearchQuery = query
        searchCallCount += 1
        return searchResults
    }
    
    func clear() {
        indexedCities.removeAll()
        mockIndexedCityCount = 0
        clearCallCount += 1
    }
}
