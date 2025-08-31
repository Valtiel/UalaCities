//
//  CitySearchStrategy.swift
//  UalaCities
//
//  Created by César Rosales on 29/08/2025.
//

import Foundation

/// Protocol defining the interface for city search strategies
/// This allows for different implementations of city filtering and autocomplete
protocol CitySearchStrategy {
    /// Adds cities to the search index
    /// - Parameter cities: Array of cities to index
    func index(cities: [City])
    
    /// Searches for cities that match the given query
    /// - Parameter query: The search query string
    /// - Returns: Array of matching cities, sorted by relevance
    func search(query: String) async -> [City]
    
    /// Clears all indexed cities
    func clear()
    
    /// Returns the total number of indexed cities
    var indexedCityCount: Int { get }
}
