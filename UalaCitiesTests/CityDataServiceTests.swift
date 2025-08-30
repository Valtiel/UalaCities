//
//  CityDataServiceTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
import Combine
@testable import UalaCities

@MainActor
final class CityDataServiceTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testMockProviderLoadsCities() async {
        // Given
        let mockCities = [
            City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        ]
        let service = CityDataService.withMockProvider(cities: mockCities, delay: 0.1)
        
        // When
        let expectation = XCTestExpectation(description: "Cities loaded")
        service.$cities
            .dropFirst() // Skip initial empty array
            .sink { cities in
                XCTAssertEqual(cities.count, 1)
                XCTAssertEqual(cities.first?.name, "Test City")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        service.loadCities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testProgressUpdates() async {
        // Given
        let service = CityDataService.withMockProvider(delay: 0.1)
        var progressValues: [Double] = []
        
        // When
        let expectation = XCTestExpectation(description: "Progress updates received")
        service.$progress
            .dropFirst() // Skip initial 0.0
            .sink { progress in
                progressValues.append(progress)
                if progress >= 1.0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        service.loadCities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertGreaterThan(progressValues.count, 1)
        XCTAssertEqual(progressValues.last, 1.0)
    }
    
    func testSearchCities() async {
        // Given
        let mockCities = [
            City(id: 1, name: "New York", country: "United States", coord: City.Coordinate(lon: -74, lat: 40)),
            City(id: 2, name: "London", country: "United Kingdom", coord: City.Coordinate(lon: 0, lat: 51)),
            City(id: 3, name: "Tokyo", country: "Japan", coord: City.Coordinate(lon: 139, lat: 35))
        ]
        let service = CityDataService.withMockProvider(cities: mockCities, delay: 0.1)
        
        // When
        let expectation = XCTestExpectation(description: "Cities loaded")
        service.$cities
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        service.loadCities()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        let searchResults = service.searchCities(query: "New")
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.name, "New York")
        
        let countryResults = service.searchCities(query: "United")
        XCTAssertEqual(countryResults.count, 2)
    }
    
    func testCityById() async {
        // Given
        let mockCities = [
            City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        ]
        let service = CityDataService.withMockProvider(cities: mockCities, delay: 0.1)
        
        // When
        let expectation = XCTestExpectation(description: "Cities loaded")
        service.$cities
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        service.loadCities()
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        let foundCity = service.city(withId: 1)
        XCTAssertNotNil(foundCity)
        XCTAssertEqual(foundCity?.name, "Test City")
        
        let notFoundCity = service.city(withId: 999)
        XCTAssertNil(notFoundCity)
    }
}
