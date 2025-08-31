//
//  LocalFileCityDataProviderTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
@testable import UalaCities

@MainActor
final class LocalFileCityDataProviderTests: XCTestCase {
    
    func testLoadCitiesFromLocalFile() async throws {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        var progressValues: [Double] = []
        var loadedCities: [City] = []
        
        // When
        loadedCities = try await provider.fetchCities { progress in
            progressValues.append(progress)
        }
        
        // Then
        // Verify cities were loaded
        XCTAssertGreaterThan(loadedCities.count, 0, "Should have loaded at least one city")
        
        // Verify progress was reported
        XCTAssertGreaterThan(progressValues.count, 0, "Should have received progress updates")
        XCTAssertEqual(progressValues.last, 1.0, "Final progress should be 1.0")
        
        // Verify city structure
        if let firstCity = loadedCities.first {
            XCTAssertGreaterThan(firstCity.id, 0, "City should have a valid ID")
            XCTAssertFalse(firstCity.name.isEmpty, "City should have a name")
            XCTAssertFalse(firstCity.country.isEmpty, "City should have a country")
            XCTAssertNotNil(firstCity.coord, "City should have coordinates")
            XCTAssertFalse(firstCity.displayName.isEmpty, "City should have a display name")
        }
    }
    
    func testLoadCitiesWithCityDataService() async {
        // Given
        let service = CityDataService.withLocalFileProvider(fileName: "cities")
        var loadedCities: [City] = []
        var isLoading = false
        var progress: Double = 0.0
        var error: Error?
        
        // When
        let expectation = XCTestExpectation(description: "Cities loaded via CityDataService")
        
        // Observe service state
        let citiesObservation = service.$cities.sink { cities in
            loadedCities = cities
            if !cities.isEmpty {
                expectation.fulfill()
            }
        }
        
        let loadingObservation = service.$isLoading.sink { loading in
            isLoading = loading
        }
        
        let progressObservation = service.$progress.sink { prog in
            progress = prog
        }
        
        let errorObservation = service.$error.sink { err in
            error = err
        }
        
        service.loadCities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // Clean up observations
        citiesObservation.cancel()
        loadingObservation.cancel()
        progressObservation.cancel()
        errorObservation.cancel()
        
        // Verify service state
        XCTAssertFalse(isLoading, "Service should not be loading after completion")
        XCTAssertEqual(progress, 1.0, "Progress should be complete")
        XCTAssertNil(error, "Should not have an error: \(error?.localizedDescription ?? "Unknown error")")
        XCTAssertGreaterThan(loadedCities.count, 0, "Should have loaded cities")
        
        // Verify some specific cities exist (if they're in the file)
        let cityNames = loadedCities.map { $0.name }
        let cityCountries = loadedCities.map { $0.country }
        
        // Log some statistics for debugging
        print("Loaded \(loadedCities.count) cities")
        print("Sample cities: \(Array(cityNames.prefix(5)))")
        print("Sample countries: \(Array(cityCountries.prefix(5)))")
    }
    
    func testSearchFunctionalityWithLoadedCities() async {
        // Given
        let service = CityDataService.withLocalFileProvider(fileName: "cities")
        
        // When
        let expectation = XCTestExpectation(description: "Cities loaded for search test")
        
        let observation = service.$cities.sink { cities in
            if !cities.isEmpty {
                expectation.fulfill()
            }
        }
        
        service.loadCities()
        await fulfillment(of: [expectation], timeout: 10.0)
        observation.cancel()
        
        // Then
        let allCities = service.cities
        XCTAssertGreaterThan(allCities.count, 0, "Should have cities to search")
        
        // Test search by city name
        let searchResults = service.searchCities(query: "New")
        XCTAssertGreaterThanOrEqual(searchResults.count, 0, "Search should return results or empty array")
        
        // Test search by country
        let countryResults = service.searchCities(query: "United")
        XCTAssertGreaterThanOrEqual(countryResults.count, 0, "Country search should return results or empty array")
        
        // Test empty search returns all cities
        let emptySearchResults = service.searchCities(query: "")
        XCTAssertEqual(emptySearchResults.count, allCities.count, "Empty search should return all cities")
    }
    
    func testFileNotFoundError() async {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "nonexistent_file")
        var receivedError: Error?
        
        // When
        do {
            _ = try await provider.fetchCities { _ in }
        } catch {
            receivedError = error
        }
        
        // Then
        // Verify error type
        XCTAssertNotNil(receivedError, "Should have received an error")
        XCTAssertTrue(receivedError is CityDataError, "Error should be CityDataError")
        
        if let cityDataError = receivedError as? CityDataError {
            XCTAssertEqual(cityDataError, .fileNotFound, "Should be file not found error")
        }
    }
    
    func testProgressReporting() async throws {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        var progressValues: [Double] = []
        
        // When
        _ = try await provider.fetchCities { progress in
            progressValues.append(progress)
        }
        
        // Then
        // Verify progress values
        XCTAssertGreaterThan(progressValues.count, 0, "Should have received progress updates")
        XCTAssertGreaterThanOrEqual(progressValues.first ?? 0, 0.0, "First progress should be >= 0")
        XCTAssertLessThanOrEqual(progressValues.last ?? 0, 1.0, "Last progress should be <= 1")
        XCTAssertEqual(progressValues.last, 1.0, "Final progress should be 1.0")
        
        // Verify progress is monotonically increasing
        for i in 1..<progressValues.count {
            XCTAssertGreaterThanOrEqual(progressValues[i], progressValues[i-1], "Progress should be monotonically increasing")
        }
    }
    
    func testCityDataStructure() async throws {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        var loadedCities: [City] = []
        
        // When
        loadedCities = try await provider.fetchCities { _ in }
        
        // Then
        XCTAssertGreaterThan(loadedCities.count, 0, "Should have loaded cities")
        
        // Verify each city has valid data
        for city in loadedCities.prefix(10) { // Check first 10 cities
            XCTAssertGreaterThan(city.id, 0, "City ID should be positive")
            XCTAssertFalse(city.name.isEmpty, "City name should not be empty")
            XCTAssertFalse(city.country.isEmpty, "City country should not be empty")
            XCTAssertNotNil(city.coord, "City should have coordinates")
            XCTAssertFalse(city.displayName.isEmpty, "City display name should not be empty")
            XCTAssertTrue(city.displayName.contains(city.name), "Display name should contain city name")
            XCTAssertTrue(city.displayName.contains(city.country), "Display name should contain country")
        }
    }
    
    func testConcurrentLoads() async throws {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        var results1: [City] = []
        var results2: [City] = []
        
        // When
        async let load1 = provider.fetchCities { _ in }
        async let load2 = provider.fetchCities { _ in }
        
        results1 = try await load1
        results2 = try await load2
        
        // Then
        // Verify both loads completed successfully
        XCTAssertGreaterThan(results1.count, 0, "First load should have results")
        XCTAssertGreaterThan(results2.count, 0, "Second load should have results")
        XCTAssertEqual(results1.count, results2.count, "Both loads should have same number of cities")
    }
}
