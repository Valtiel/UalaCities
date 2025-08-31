//
//  CityDataServiceTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
@testable import UalaCities

@MainActor
final class CityDataServiceTests: XCTestCase {
    
    func testMockProviderLoadsCities() async {
        // Given
        let mockCities = [
            City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0))
        ]
        let service = CityDataService.withMockProvider(cities: mockCities, delay: 0.1)
        
        // When
        let expectation = XCTestExpectation(description: "Cities loaded")
        var loadedCities: [City] = []
        
        // Observe cities changes
        let observation = service.$cities.sink { cities in
            if !cities.isEmpty {
                loadedCities = cities
                expectation.fulfill()
            }
        }
        
        service.loadCities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        observation.cancel()
        
        XCTAssertEqual(loadedCities.count, 1)
        XCTAssertEqual(loadedCities.first?.name, "Test City")
    }
    
    func testLoadingState() async {
        // Given
        let service = CityDataService.withMockProvider(delay: 0.1)
        var loadingStates: [Bool] = []
        
        // When
        let expectation = XCTestExpectation(description: "Loading state changes received")
        
        let observation = service.$isLoading.sink { isLoading in
            loadingStates.append(isLoading)
            if !isLoading && loadingStates.count > 1 {
                expectation.fulfill()
            }
        }
        
        service.loadCities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        observation.cancel()
        
        XCTAssertGreaterThan(loadingStates.count, 1)
        XCTAssertTrue(loadingStates.first == true) // Should start with loading true
        XCTAssertTrue(loadingStates.last == false) // Should end with loading false
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
        
        let observation = service.$cities.sink { cities in
            if !cities.isEmpty {
                expectation.fulfill()
            }
        }
        
        service.loadCities()
        await fulfillment(of: [expectation], timeout: 2.0)
        observation.cancel()
        
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
        
        let observation = service.$cities.sink { cities in
            if !cities.isEmpty {
                expectation.fulfill()
            }
        }
        
        service.loadCities()
        await fulfillment(of: [expectation], timeout: 2.0)
        observation.cancel()
        
        // Then
        let foundCity = service.city(withId: 1)
        XCTAssertNotNil(foundCity)
        XCTAssertEqual(foundCity?.name, "Test City")
        
        let notFoundCity = service.city(withId: 999)
        XCTAssertNil(notFoundCity)
    }
    
    func testErrorHandling() async {
        // Given
        let service = CityDataService.withMockProvider(cities: [], delay: 0.1)
        
        // When
        let expectation = XCTestExpectation(description: "Error handling test")
        var receivedError: Error?
        
        let errorObservation = service.$error.sink { error in
            receivedError = error
            if error != nil {
                expectation.fulfill()
            }
        }
        
        service.loadCities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        errorObservation.cancel()
        
        // Note: This test might not always pass depending on the mock implementation
        // It's here to test the error handling infrastructure
    }
}
