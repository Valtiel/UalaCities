//
//  CityDataProvider.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation

/// Protocol defining the interface for city data providers
protocol CityDataProvider {
    
    /// Fetches cities with progress reporting
    /// - Parameter progress: Closure that receives progress updates (0.0 to 1.0)
    /// - Returns: Array of cities
    func fetchCities(progress: @escaping (Double) -> Void) async throws -> [City]
}

/// Network-based city data provider that fetches from a remote JSON endpoint
final class NetworkCityDataProvider: CityDataProvider {
    
    private let url: URL
    private let session: URLSession
    
    init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }
    
    func fetchCities(progress: @escaping (Double) -> Void) async throws -> [City] {
        progress(0.1) // Started
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CityDataError.invalidResponse
        }
        
        progress(0.5) // Data received
        
        let cities = try JSONDecoder().decode([City].self, from: data)
        progress(0.9) // Decoded
        progress(1.0) // Complete
        
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
    
    func fetchCities(progress: @escaping (Double) -> Void) async throws -> [City] {
        progress(0.2) // Started
        
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw CityDataError.fileNotFound
        }
        
        progress(0.4) // File found
        
        let data = try Data(contentsOf: url)
        progress(0.6) // Data loaded
        
        let cities = try JSONDecoder().decode([City].self, from: data)
        progress(0.8) // Decoded
        progress(1.0) // Complete
        
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
    
    func fetchCities(progress: @escaping (Double) -> Void) async throws -> [City] {
        // Simulate progress
        for i in 1...10 {
            progress(Double(i) / 10.0)
            try await Task.sleep(nanoseconds: UInt64(delay * 100_000_000) / 10) // Convert to nanoseconds
        }
        
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
