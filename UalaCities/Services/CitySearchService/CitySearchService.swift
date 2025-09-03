//
//  CitySearchService.swift
//  UalaCities
//
//  Created by César Rosales on 29/08/2025.
//

import Foundation

/// Protocol defining the interface for city search services
protocol CitySearchService {
    /// Indexes cities for searching
    /// - Parameter cities: Array of cities to index
    func index(cities: [City])
    
    /// Searches for cities matching the query
    /// - Parameter query: The search query
    /// - Returns: Array of matching cities, sorted by relevance
    func search(query: String) async -> [City]
    
    /// Clears all indexed cities
    func clear()
    
    /// Returns the total number of indexed cities
    var indexedCityCount: Int { get }
    
    /// Returns true if cities have been indexed
    var isIndexed: Bool { get }
}

/// Service class that provides city search functionality using different strategies
/// This allows for easy switching between different search implementations
final class CitySearchByStrategyService: CitySearchService {
    
    // MARK: - Properties
    
    private var strategy: CitySearchStrategy
    
    // MARK: - Initialization
    
    /// Initializes the service with a specific search strategy
    /// - Parameter strategy: The search strategy to use
    init(strategy: CitySearchStrategy) {
        self.strategy = strategy
    }
    
    // MARK: - Public Methods
    
    /// Changes the search strategy
    /// - Parameter newStrategy: The new strategy to use
    func setStrategy(_ newStrategy: CitySearchStrategy) {
        self.strategy = newStrategy
    }
    
    // MARK: - CitySearchService Implementation
    
    /// Indexes cities for searching
    /// - Parameter cities: Array of cities to index
    func index(cities: [City]) {
        strategy.index(cities: cities)
    }
    
    /// Searches for cities matching the query
    /// - Parameter query: The search query
    /// - Returns: Array of matching cities, sorted by relevance
    func search(query: String) async -> [City] {
        return await strategy.search(query: query)
    }
    
    /// Clears all indexed cities
    func clear() {
        strategy.clear()
    }
    
    /// Returns the total number of indexed cities
    var indexedCityCount: Int {
        return strategy.indexedCityCount
    }
    
    /// Returns true if cities have been indexed
    var isIndexed: Bool {
        return indexedCityCount > 0
    }
}
