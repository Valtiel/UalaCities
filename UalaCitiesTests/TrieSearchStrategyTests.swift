//
//  TrieSearchStrategyTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 29/08/2025.
//

import Testing
@testable import UalaCities
import Foundation

struct TrieSearchStrategyTests {

    // MARK: - Test Data
    
    private var testCities: [City] {
        [
            City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
            City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1276, lat: 51.5074)),
            City(id: 4, name: "São Paulo", country: "Brasil", coord: City.Coordinate(lon: -46.6333, lat: -23.5505)),
            City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566)),
            City(id: 6, name: "Tokyo", country: "Japan", coord: City.Coordinate(lon: 139.6917, lat: 35.6895)),
            City(id: 7, name: "Sydney", country: "Australia", coord: City.Coordinate(lon: 151.2093, lat: -33.8688)),
            City(id: 8, name: "Berlin", country: "Germany", coord: City.Coordinate(lon: 13.4050, lat: 52.5200)),
            City(id: 9, name: "Madrid", country: "Spain", coord: City.Coordinate(lon: -3.7038, lat: 40.4168)),
            City(id: 10, name: "Rome", country: "Italy", coord: City.Coordinate(lon: 12.4964, lat: 41.9028))
        ]
    }
    
    // MARK: - Setup and Teardown Tests
    
    @Test func testInitialization() async throws {
        let strategy = TrieSearchStrategy()
        
        #expect(strategy.indexedCityCount == 0)
    }
    
    @Test func testClear() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        #expect(strategy.indexedCityCount == 10)
        
        strategy.clear()
        
        #expect(strategy.indexedCityCount == 0)
        #expect(strategy.search(query: "Buenos").isEmpty)
    }
    
    // MARK: - Indexing Tests
    
    @Test func testIndexing() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        #expect(strategy.indexedCityCount == 10)
    }
    
    @Test func testReindexing() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        #expect(strategy.indexedCityCount == 10)
        
        let newCities = [City(id: 11, name: "Moscow", country: "Russia", coord: City.Coordinate(lon: 37.6173, lat: 55.7558))]
        strategy.index(cities: newCities)
        
        #expect(strategy.indexedCityCount == 1)
        #expect(strategy.search(query: "Buenos").isEmpty)
        #expect(strategy.search(query: "Moscow").count == 1)
    }
    
    // MARK: - Search Tests
    
    @Test func testEmptyQuery() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "")
        
        #expect(results.isEmpty)
    }
    
    @Test func testWhitespaceQuery() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "   ")
        
        #expect(results.isEmpty)
    }
    
    @Test func testCityNamePrefixSearch() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "Buenos")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
    }
    
    @Test func testIncrementalSearchAddCharacters() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        // Start with "B"
        let results1 = strategy.search(query: "B")
        #expect(results1.count > 0)
        #expect(results1.allSatisfy { $0.name.hasPrefix("B") || $0.country.hasPrefix("B") })
        
        // Add "u" -> "Bu"
        let results2 = strategy.search(query: "Bu")
        #expect(results2.count > 0)
        #expect(results2.allSatisfy { $0.name.hasPrefix("Bu") || $0.country.hasPrefix("Bu") })
        
        // Add "e" -> "Bue"
        let results3 = strategy.search(query: "Bue")
        #expect(results3.count > 0)
        #expect(results3.allSatisfy { $0.name.hasPrefix("Bue") || $0.country.hasPrefix("Bue") })
        
        // Add "n" -> "Buen"
        let results4 = strategy.search(query: "Buen")
        #expect(results4.count > 0)
        #expect(results4.allSatisfy { $0.name.hasPrefix("Buen") || $0.country.hasPrefix("Buen") })
        
        // Add "o" -> "Bueno"
        let results5 = strategy.search(query: "Bueno")
        #expect(results5.count > 0)
        #expect(results5.allSatisfy { $0.name.hasPrefix("Bueno") || $0.country.hasPrefix("Bueno") })
        
        // Add "s" -> "Buenos"
        let results6 = strategy.search(query: "Buenos")
        #expect(results6.count == 1)
        #expect(results6.first?.name == "Buenos Aires")
    }
    
    @Test func testIncrementalSearchRemoveCharacters() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        // Start with "Buenos"
        let results1 = strategy.search(query: "Buenos")
        #expect(results1.count == 1)
        #expect(results1.first?.name == "Buenos Aires")
        
        // Remove "s" -> "Bueno"
        let results2 = strategy.search(query: "Bueno")
        #expect(results2.count > 0)
        #expect(results2.allSatisfy { $0.name.hasPrefix("Bueno") || $0.country.hasPrefix("Bueno") })
        
        // Remove "o" -> "Buen"
        let results3 = strategy.search(query: "Buen")
        #expect(results3.count > 0)
        #expect(results3.allSatisfy { $0.name.hasPrefix("Buen") || $0.country.hasPrefix("Buen") })
        
        // Remove "n" -> "Bue"
        let results4 = strategy.search(query: "Bue")
        #expect(results4.count > 0)
        #expect(results4.allSatisfy { $0.name.hasPrefix("Bue") || $0.country.hasPrefix("Bue") })
        
        // Remove "e" -> "Bu"
        let results5 = strategy.search(query: "Bu")
        #expect(results5.count > 0)
        #expect(results5.allSatisfy { $0.name.hasPrefix("Bu") || $0.country.hasPrefix("Bu") })
        
        // Remove "u" -> "B"
        let results6 = strategy.search(query: "B")
        #expect(results6.count > 0)
        #expect(results6.allSatisfy { $0.name.hasPrefix("B") || $0.country.hasPrefix("B") })
    }
    
    @Test func testIncrementalSearchMixedOperations() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        // Start with "Buenos"
        let results1 = strategy.search(query: "Buenos")
        #expect(results1.count == 1)
        #expect(results1.first?.name == "Buenos Aires")
        
        // Remove to "Buen"
        let results2 = strategy.search(query: "Buen")
        #expect(results2.count > 0)
        
        // Add to "Buenos Aires"
        let results3 = strategy.search(query: "Buenos Aires")
        #expect(results3.count == 1)
        #expect(results3.first?.name == "Buenos Aires")
        
        // Remove to "Buenos"
        let results4 = strategy.search(query: "Buenos")
        #expect(results4.count == 1)
        #expect(results4.first?.name == "Buenos Aires")
    }
    
    @Test func testIncrementalSearchStateManagement() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        // First search should perform full search
        let results1 = strategy.search(query: "Buenos")
        #expect(results1.count == 1)
        
        // Second search with same query should use cached state
        let results2 = strategy.search(query: "Buenos")
        #expect(results2.count == 1)
        #expect(results2.first?.name == "Buenos Aires")
        
        // Clear should reset state
        strategy.clear()
        let results3 = strategy.search(query: "Buenos")
        #expect(results3.isEmpty)
    }
    
    @Test func testCityNameCaseInsensitive() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results1 = strategy.search(query: "buenos")
        let results2 = strategy.search(query: "BUENOS")
        let results3 = strategy.search(query: "Buenos")
        
        #expect(results1.count == 1)
        #expect(results2.count == 1)
        #expect(results3.count == 1)
        #expect(results1.first?.name == "Buenos Aires")
        #expect(results2.first?.name == "Buenos Aires")
        #expect(results3.first?.name == "Buenos Aires")
    }
    
    @Test func testCountryNameSearch() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "Argentina")
        
        #expect(results.count == 1)
        #expect(results.first?.country == "Argentina")
    }
    
    @Test func testDisplayNameSearch() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "Buenos Aires, Argentina")
        
        #expect(results.count == 1)
        #expect(results.first?.displayName == "Buenos Aires, Argentina")
    }
    
    @Test func testPartialDisplayNameSearch() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "Buenos Aires,")
        
        #expect(results.count == 1)
        #expect(results.first?.displayName == "Buenos Aires, Argentina")
    }
    
    @Test func testSpecialCharacters() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "São")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "São Paulo")
    }
    

    
    @Test func testNoMatch() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "NonExistentCity")
        
        #expect(results.isEmpty)
    }
    
    // MARK: - Relevance Scoring Tests
    
    @Test func testRelevanceScoring() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "Buenos")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
    }
    
    @Test func testMultipleMatchesOrdering() async throws {
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511)),
            City(id: 3, name: "Newark", country: "USA", coord: City.Coordinate(lon: -74.1724, lat: 40.7357))
        ]
        
        let strategy = TrieSearchStrategy()
        strategy.index(cities: cities)
        
        let results = strategy.search(query: "New")
        
        #expect(results.count == 3)
        // Newark should come first due to exact prefix match and shorter name
        #expect(results.first?.name == "Newark")
    }
    
    // MARK: - Performance Tests
    
    @Test func testLargeDataset() async throws {
        let largeCities = (1...1000).map { id in
            City(
                id: id,
                name: "City\(id)",
                country: "Country\(id % 10)",
                coord: City.Coordinate(lon: Double(id), lat: Double(id))
            )
        }
        
        let strategy = TrieSearchStrategy()
        strategy.index(cities: largeCities)
        
        #expect(strategy.indexedCityCount == 1000)
        
        let results = strategy.search(query: "City1")
        
        #expect(results.count > 0)
        #expect(results.allSatisfy { $0.name.hasPrefix("City1") })
    }
    
    // MARK: - Edge Cases
    
    @Test func testDuplicateCities() async throws {
        let duplicateCities = [
            City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
            City(id: 2, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        
        let strategy = TrieSearchStrategy()
        strategy.index(cities: duplicateCities)
        
        let results = strategy.search(query: "Buenos")
        
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.name == "Buenos Aires" })
    }
    
    @Test func testEmptyCitiesArray() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: [])
        
        #expect(strategy.indexedCityCount == 0)
        #expect(strategy.search(query: "anything").isEmpty)
    }
    
    @Test func testSingleCharacterQuery() async throws {
        let strategy = TrieSearchStrategy()
        strategy.index(cities: testCities)
        
        let results = strategy.search(query: "B")
        
        #expect(results.count > 0)
        #expect(results.allSatisfy { $0.name.hasPrefix("B") || $0.country.hasPrefix("B") })
    }
}
