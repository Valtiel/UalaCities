//
//  CityDataProvider.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation

/// Protocol defining the interface for city data providers
protocol CityDataProvider {
    
    /// Fetches cities
    /// - Returns: Array of cities
    func fetchCities() async throws -> [City]
}

/// Network-based city data provider that fetches from a remote JSON endpoint
final class NetworkCityDataProvider: CityDataProvider {
    
    private let url: URL
    private let session: URLSession
    
    init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }
    
    func fetchCities() async throws -> [City] {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CityDataError.invalidResponse
        }
        
        let cities = try JSONDecoder().decode([City].self, from: data)
        
        return cities
    }
}

/// Local file-based city data provider that reads from a JSON file
final class LocalFileCityDataProvider: CityDataProvider {
    
    private let fileName: String
    private let bundle: Bundle
    
    init(fileName: String, bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }
    
    func fetchCities() async throws -> [City] {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw CityDataError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let cities = try JSONDecoder().decode([City].self, from: data)
        
        return cities
    }
}

/// Mock city data provider for testing
final class MockCityDataProvider: CityDataProvider {
    
    private let cities: [City]
    private let delay: TimeInterval
    
    init(cities: [City] = [], delay: TimeInterval = 1.0) {
        self.cities = cities
        self.delay = delay
    }
    
    func fetchCities() async throws -> [City] {
        // Simulate delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) // Convert to nanoseconds
        
        return cities
    }
}

// MARK: - Errors

enum CityDataError: LocalizedError {
    case invalidResponse
    case fileNotFound
    case providerDeallocated
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .fileNotFound:
            return "Cities file not found"
        case .providerDeallocated:
            return "Data provider was deallocated"
        case .decodingError:
            return "Failed to decode cities data"
        }
    }
}
