//
//  BinarySearchStrategyTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 29/08/2025.
//

import Testing
@testable import UalaCities
import Foundation

struct BinarySearchStrategyTests {

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
        let strategy = BinarySearchStrategy()
        
        #expect(strategy.indexedCityCount == 0)
    }
    
    @Test func testClear() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        #expect(strategy.indexedCityCount == 10)
        
        strategy.clear()
        
        #expect(strategy.indexedCityCount == 0)
        await #expect(strategy.search(query: "Buenos").isEmpty)
    }
    
    // MARK: - Indexing Tests
    
    @Test func testIndexing() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        #expect(strategy.indexedCityCount == 10)
    }
    
    @Test func testReindexing() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        #expect(strategy.indexedCityCount == 10)
        
        let newCities = [City(id: 11, name: "Moscow", country: "Russia", coord: City.Coordinate(lon: 37.6173, lat: 55.7558))]
        strategy.index(cities: newCities)
        
        #expect(strategy.indexedCityCount == 1)
        await #expect(strategy.search(query: "Buenos").isEmpty)
        await #expect(strategy.search(query: "Moscow").count == 1)
    }
    
    // MARK: - Search Tests
    
    @Test func testEmptyQuery() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "")
        
        #expect(results.isEmpty)
    }
    
    @Test func testWhitespaceQuery() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "   ")
        
        #expect(results.isEmpty)
    }
    
    @Test func testCityNamePrefixSearch() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "Buenos")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
    }
    
    @Test func testCityNameCaseInsensitive() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results1 = await strategy.search(query: "buenos")
        let results2 = await strategy.search(query: "BUENOS")
        let results3 = await strategy.search(query: "Buenos")
        
        #expect(results1.count == 1)
        #expect(results2.count == 1)
        #expect(results3.count == 1)
        #expect(results1.first?.name == "Buenos Aires")
        #expect(results2.first?.name == "Buenos Aires")
        #expect(results3.first?.name == "Buenos Aires")
    }
    
    @Test func testCountryNameSearch() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "Argentina")
        
        #expect(results.count == 1)
        #expect(results.first?.country == "Argentina")
    }
    
    @Test func testDisplayNameSearch() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "Buenos Aires, Argentina")
        
        #expect(results.count == 1)
        #expect(results.first?.displayName == "Buenos Aires, Argentina")
    }
    
    @Test func testPartialDisplayNameSearch() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "Buenos Aires,")
        
        #expect(results.count == 1)
        #expect(results.first?.displayName == "Buenos Aires, Argentina")
    }
    
    @Test func testSpecialCharacters() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "São")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "São Paulo")
    }
    
    @Test func testNoMatch() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "NonExistentCity")
        
        #expect(results.isEmpty)
    }
    
    // MARK: - Binary Search Specific Tests
    
    @Test func testBinarySearchWithMultipleMatches() async throws {
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511)),
            City(id: 3, name: "Newark", country: "USA", coord: City.Coordinate(lon: -74.1724, lat: 40.7357)),
            City(id: 4, name: "Newcastle", country: "UK", coord: City.Coordinate(lon: -1.6178, lat: 54.9783))
        ]
        
        let strategy = BinarySearchStrategy()
        strategy.index(cities: cities)
        
        let results = await strategy.search(query: "New")
        
        #expect(results.count == 4)
        #expect(results.allSatisfy { $0.name.hasPrefix("New") })
    }
    
    @Test func testBinarySearchOrdering() async throws {
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511)),
            City(id: 3, name: "Newark", country: "USA", coord: City.Coordinate(lon: -74.1724, lat: 40.7357))
        ]
        
        let strategy = BinarySearchStrategy()
        strategy.index(cities: cities)
        
        let results = await strategy.search(query: "New")
        
        #expect(results.count == 3)
        #expect(results[0].name == "Newark")
        #expect(results[1].name == "New York")
        #expect(results[2].name == "New Orleans")
    }
    
    @Test func testBinarySearchSingleCharacter() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "B")
        
        #expect(results.count > 0)
        #expect(results.allSatisfy { $0.name.hasPrefix("B") || $0.country.hasPrefix("B") })
    }
    
    @Test func testBinarySearchExactMatch() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: testCities)
        
        let results = await strategy.search(query: "Buenos Aires")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
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
        
        let strategy = BinarySearchStrategy()
        strategy.index(cities: largeCities)
        
        #expect(strategy.indexedCityCount == 1000)
        
        let results = await strategy.search(query: "City1")
        
        #expect(results.count > 0)
        #expect(results.allSatisfy { $0.name.hasPrefix("City1") })
    }
    
    @Test func testBinarySearchPerformance() async throws {
        let cities = (1...10000).map { id in
            City(
                id: id,
                name: "City\(String(format: "%05d", id))",
                country: "Country\(id % 100)",
                coord: City.Coordinate(lon: Double(id), lat: Double(id))
            )
        }
        
        let strategy = BinarySearchStrategy()
        strategy.index(cities: cities)
        
        // Measure search performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let results = await strategy.search(query: "City1")
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let searchTime = endTime - startTime
        
        #expect(results.count > 0)
        #expect(searchTime < 0.1) // Should be very fast with binary search
    }
    
    // MARK: - Edge Cases
    
    @Test func testDuplicateCities() async throws {
        let duplicateCities = [
            City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
            City(id: 2, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        
        let strategy = BinarySearchStrategy()
        strategy.index(cities: duplicateCities)
        
        let results = await strategy.search(query: "Buenos")
        
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.name == "Buenos Aires" })
    }
    
    @Test func testEmptyCitiesArray() async throws {
        let strategy = BinarySearchStrategy()
        strategy.index(cities: [])
        
        #expect(strategy.indexedCityCount == 0)
        await #expect(strategy.search(query: "anything").isEmpty)
    }
    
    @Test func testSingleCity() async throws {
        let singleCity = [City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037))]
        
        let strategy = BinarySearchStrategy()
        strategy.index(cities: singleCity)
        
        let results = await strategy.search(query: "Buenos")
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Buenos Aires")
    }
    
    @Test func testBinarySearchBoundaryConditions() async throws {
        let cities = [
            City(id: 1, name: "A", country: "CountryA", coord: City.Coordinate(lon: 0, lat: 0)),
            City(id: 2, name: "B", country: "CountryB", coord: City.Coordinate(lon: 0, lat: 0)),
            City(id: 3, name: "C", country: "CountryC", coord: City.Coordinate(lon: 0, lat: 0))
        ]
        
        let strategy = BinarySearchStrategy()
        strategy.index(cities: cities)
        
        // Test boundary conditions
        let resultsA = await strategy.search(query: "A")
        let resultsB = await strategy.search(query: "B")
        let resultsC = await strategy.search(query: "C")
        
        #expect(resultsA.count == 1)
        #expect(resultsB.count == 1)
        #expect(resultsC.count == 3) // Every city in the data set contains C letter
        #expect(resultsA.first?.name == "A")
        #expect(resultsB.first?.name == "B")
        #expect(resultsC.first?.name == "C")
    }
}

