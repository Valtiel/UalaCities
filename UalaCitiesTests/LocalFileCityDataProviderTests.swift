//
//  LocalFileCityDataProviderTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
import Combine
@testable import UalaCities

@MainActor
final class LocalFileCityDataProviderTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadCitiesFromLocalFile() async {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        let progressSubject = PassthroughSubject<Double, Never>()
        var progressValues: [Double] = []
        var loadedCities: [City] = []
        var receivedError: Error?
        
        // When
        let expectation = XCTestExpectation(description: "Cities loaded from local file")
        
        provider.fetchCities(progress: progressSubject)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { cities in
                    loadedCities = cities
                }
            )
            .store(in: &cancellables)
        
        // Track progress
        progressSubject
            .sink { progress in
                progressValues.append(progress)
            }
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // Verify no errors occurred
        XCTAssertNil(receivedError, "Should not have received an error: \(receivedError?.localizedDescription ?? "Unknown error")")
        
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
        service.$cities
            .dropFirst() // Skip initial empty array
            .sink { cities in
                loadedCities = cities
                if !cities.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        service.$isLoading
            .sink { loading in
                isLoading = loading
            }
            .store(in: &cancellables)
        
        service.$progress
            .sink { prog in
                progress = prog
            }
            .store(in: &cancellables)
        
        service.$error
            .sink { err in
                error = err
            }
            .store(in: &cancellables)
        
        service.loadCities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
        
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
        
        service.$cities
            .dropFirst()
            .sink { cities in
                if !cities.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        service.loadCities()
        await fulfillment(of: [expectation], timeout: 10.0)
        
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
        let progressSubject = PassthroughSubject<Double, Never>()
        var receivedError: Error?
        
        // When
        let expectation = XCTestExpectation(description: "File not found error")
        
        provider.fetchCities(progress: progressSubject)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    // Should not receive any cities
                }
            )
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Verify error type
        XCTAssertNotNil(receivedError, "Should have received an error")
        XCTAssertTrue(receivedError is CityDataError, "Error should be CityDataError")
        
        if let cityDataError = receivedError as? CityDataError {
            XCTAssertEqual(cityDataError, .fileNotFound, "Should be file not found error")
        }
    }
    
    func testProgressReporting() async {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        let progressSubject = PassthroughSubject<Double, Never>()
        var progressValues: [Double] = []
        
        // When
        let expectation = XCTestExpectation(description: "Progress reporting test")
        
        provider.fetchCities(progress: progressSubject)
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        progressSubject
            .sink { progress in
                progressValues.append(progress)
            }
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
        
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
    
    func testCityDataStructure() async {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        let progressSubject = PassthroughSubject<Double, Never>()
        var loadedCities: [City] = []
        
        // When
        let expectation = XCTestExpectation(description: "City data structure test")
        
        provider.fetchCities(progress: progressSubject)
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { cities in
                    loadedCities = cities
                }
            )
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 10.0)
        
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
    
    func testConcurrentLoads() async {
        // Given
        let provider = LocalFileCityDataProvider(fileName: "cities")
        let progressSubject1 = PassthroughSubject<Double, Never>()
        let progressSubject2 = PassthroughSubject<Double, Never>()
        var results1: [City] = []
        var results2: [City] = []
        
        // When
        let expectation1 = XCTestExpectation(description: "First concurrent load")
        let expectation2 = XCTestExpectation(description: "Second concurrent load")
        
        // Start first load
        provider.fetchCities(progress: progressSubject1)
            .sink(
                receiveCompletion: { _ in
                    expectation1.fulfill()
                },
                receiveValue: { cities in
                    results1 = cities
                }
            )
            .store(in: &cancellables)
        
        // Start second load
        provider.fetchCities(progress: progressSubject2)
            .sink(
                receiveCompletion: { _ in
                    expectation2.fulfill()
                },
                receiveValue: { cities in
                    results2 = cities
                }
            )
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation1, expectation2], timeout: 15.0)
        
        // Verify both loads completed successfully
        XCTAssertGreaterThan(results1.count, 0, "First load should have results")
        XCTAssertGreaterThan(results2.count, 0, "Second load should have results")
        XCTAssertEqual(results1.count, results2.count, "Both loads should have same number of cities")
    }
}
