//
//  CityDataProvider.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation
import Combine

/// Protocol defining the interface for city data providers
protocol CityDataProvider {
    
    /// Fetches cities with progress reporting
    /// - Parameter progress: Publisher that emits progress updates (0.0 to 1.0)
    /// - Returns: Publisher that emits the array of cities
    func fetchCities(progress: PassthroughSubject<Double, Never>) -> AnyPublisher<[City], Error>
}

/// Network-based city data provider that fetches from a remote JSON endpoint
final class NetworkCityDataProvider: CityDataProvider {
    
    private let url: URL
    private let session: URLSession
    
    init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }
    
    func fetchCities(progress: PassthroughSubject<Double, Never>) -> AnyPublisher<[City], Error> {
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw CityDataError.invalidResponse
                }
                return data
            }
            .handleEvents(receiveSubscription: { _ in
                progress.send(0.1) // Started
            }, receiveOutput: { _ in
                progress.send(0.5) // Data received
            })
            .decode(type: [City].self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { _ in
                progress.send(0.9) // Decoded
            })
            .map { cities in
                progress.send(1.0) // Complete
                return cities
            }
            .eraseToAnyPublisher()
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
    
    func fetchCities(progress: PassthroughSubject<Double, Never>) -> AnyPublisher<[City], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(CityDataError.providerDeallocated))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    progress.send(0.2) // Started
                    
                    guard let url = self.bundle.url(forResource: self.fileName, withExtension: "json") else {
                        promise(.failure(CityDataError.fileNotFound))
                        return
                    }
                    
                    progress.send(0.4) // File found
                    
                    let data = try Data(contentsOf: url)
                    progress.send(0.6) // Data loaded
                    
                    let cities = try JSONDecoder().decode([City].self, from: data)
                    progress.send(0.8) // Decoded
                    
                    DispatchQueue.main.async {
                        progress.send(1.0) // Complete
                        promise(.success(cities))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
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
    
    func fetchCities(progress: PassthroughSubject<Double, Never>) -> AnyPublisher<[City], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(CityDataError.providerDeallocated))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                // Simulate progress
                for i in 1...10 {
                    DispatchQueue.main.async {
                        progress.send(Double(i) / 10.0)
                    }
                    Thread.sleep(forTimeInterval: self.delay / 10.0)
                }
                
                DispatchQueue.main.async {
                    promise(.success(self.cities))
                }
            }
        }
        .eraseToAnyPublisher()
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
