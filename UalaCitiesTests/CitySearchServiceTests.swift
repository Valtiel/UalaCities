//
//  CitySearchServiceTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 29/08/2025.
//

import Testing
@testable import UalaCities
import Foundation

struct CitySearchServiceTests {

    // MARK: - Test Data
    
    private var testCities: [City] {
        [
            City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
            City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1276, lat: 51.5074))
        ]
    }
    
    // MARK: - Service Tests
    
    @Test func testServiceInitialization() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        #expect(service.indexedCityCount == 0)
    }
    
    @Test func testServiceIndexing() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        
        #expect(service.indexedCityCount == 3)
    }
    
    @Test func testServiceSearch() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        
        let results = service.search(query: "Buenos")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
    }
    
    @Test func testServiceClear() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        #expect(service.indexedCityCount == 3)
        
        service.clear()
        #expect(service.indexedCityCount == 0)
        #expect(service.search(query: "Buenos").isEmpty)
    }
    
    // MARK: - Strategy Switching Tests
    
    @Test func testStrategySwitching() async throws {
        let initialStrategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: initialStrategy)
        
        service.index(cities: testCities)
        #expect(service.indexedCityCount == 3)
        
        // Switch to a new strategy
        let newStrategy = TrieSearchStrategy()
        service.setStrategy(newStrategy)
        
        // The new strategy should be empty
        #expect(service.indexedCityCount == 0)
        #expect(service.search(query: "Buenos").isEmpty)
        
        // Index cities in the new strategy
        service.index(cities: testCities)
        #expect(service.indexedCityCount == 3)
        
        let results = service.search(query: "Buenos")
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
    }
    
    @Test func testStrategySwitchingWithData() async throws {
        let strategy1 = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy1)
        
        service.index(cities: testCities)
        
        let strategy2 = TrieSearchStrategy()
        strategy2.index(cities: [City(id: 4, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566))])
        
        service.setStrategy(strategy2)
        
        #expect(service.indexedCityCount == 1)
        #expect(service.search(query: "Paris").count == 1)
        #expect(service.search(query: "Buenos").isEmpty)
    }
    
    // MARK: - Integration Tests
    
    @Test func testServiceWithEmptyQuery() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        
        let results = service.search(query: "")
        
        #expect(results.isEmpty)
    }
    
    @Test func testServiceWithWhitespaceQuery() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        
        let results = service.search(query: "   ")
        
        #expect(results.isEmpty)
    }
    
    @Test func testServiceCaseInsensitive() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        
        let results1 = service.search(query: "buenos")
        let results2 = service.search(query: "BUENOS")
        let results3 = service.search(query: "Buenos")
        
        #expect(results1.count == 1)
        #expect(results2.count == 1)
        #expect(results3.count == 1)
        #expect(results1.first?.name == "Buenos Aires")
        #expect(results2.first?.name == "Buenos Aires")
        #expect(results3.first?.name == "Buenos Aires")
    }
    
    @Test func testServiceMultipleSearchFields() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        
        // Search by city name
        let cityResults = service.search(query: "Buenos")
        #expect(cityResults.count == 1)
        #expect(cityResults.first?.name == "Buenos Aires")
        
        // Search by country name
        let countryResults = service.search(query: "Argentina")
        #expect(countryResults.count == 1)
        #expect(countryResults.first?.country == "Argentina")
        
        // Search by display name
        let displayResults = service.search(query: "Buenos Aires, Argentina")
        #expect(displayResults.count == 1)
        #expect(displayResults.first?.displayName == "Buenos Aires, Argentina")
    }
    
    @Test func testServiceNoMatch() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        
        let results = service.search(query: "NonExistentCity")
        
        #expect(results.isEmpty)
    }
    
    @Test func testServiceReindexing() async throws {
        let strategy = TrieSearchStrategy()
        let service = CitySearchService(strategy: strategy)
        
        service.index(cities: testCities)
        #expect(service.indexedCityCount == 3)
        
        let newCities = [City(id: 4, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566))]
        service.index(cities: newCities)
        
        #expect(service.indexedCityCount == 1)
        #expect(service.search(query: "Buenos").isEmpty)
        #expect(service.search(query: "Paris").count == 1)
    }
}
