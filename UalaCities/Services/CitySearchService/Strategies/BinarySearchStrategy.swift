//
//  BinarySearchStrategy.swift
//  UalaCities
//
//  Created by César Rosales on 29/08/2025.
//

import Foundation

/// Binary search strategy for city autocomplete
/// Uses sorted arrays and binary search for efficient prefix-based searching
class BinarySearchStrategy: CitySearchStrategy {
    
    // MARK: - Properties
    
    private var citiesByName: [City] = []
    private var citiesByCountry: [City] = []
    private var citiesByDisplayName: [City] = []
    
    var indexedCityCount: Int {
        return citiesByName.count
    }
    
    // MARK: - CitySearchStrategy Implementation
    
    func index(cities: [City]) {
        clear()
        
        // Create sorted arrays for different search fields
        citiesByName = cities.sorted { $0.name.lowercased() < $1.name.lowercased() }
        citiesByCountry = cities.sorted { $0.country.lowercased() < $1.country.lowercased() }
        citiesByDisplayName = cities.sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }
    }
    
    func search(query: String) -> [City] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalizedQuery.isEmpty {
            return []
        }
        
        var results: Set<City> = []
        
        // Search by city name
        let nameResults = binarySearchPrefix(array: citiesByName, query: normalizedQuery, field: { $0.name.lowercased() })
        results.formUnion(nameResults)
        
        // Search by country name
        let countryResults = binarySearchPrefix(array: citiesByCountry, query: normalizedQuery, field: { $0.country.lowercased() })
        results.formUnion(countryResults)
        
        // Search by display name
        let displayResults = binarySearchPrefix(array: citiesByDisplayName, query: normalizedQuery, field: { $0.displayName.lowercased() })
        results.formUnion(displayResults)
        
        // Convert to array and sort by relevance
        let sortedResults = Array(results).sorted { city1, city2 in
            let score1 = calculateRelevanceScore(city: city1, query: normalizedQuery)
            let score2 = calculateRelevanceScore(city: city2, query: normalizedQuery)
            
            if score1 != score2 {
                return score1 > score2
            }
            
            // If scores are equal, sort alphabetically by display name
            return city1.displayName < city2.displayName
        }
        
        return sortedResults
    }
    
    func clear() {
        citiesByName.removeAll()
        citiesByCountry.removeAll()
        citiesByDisplayName.removeAll()
    }
    
    // MARK: - Binary Search Methods
    
    private func binarySearchPrefix<T>(array: [T], query: String, field: (T) -> String) -> [T] {
        guard !array.isEmpty else { return [] }
        
        // Find the first occurrence of the prefix
        let firstIndex = findFirstOccurrence(array: array, query: query, field: field)
        
        // Find the last occurrence of the prefix
        let lastIndex = findLastOccurrence(array: array, query: query, field: field)
        
        // Return the range of results
        if firstIndex <= lastIndex {
            return Array(array[firstIndex...lastIndex])
        }
        
        return []
    }
    
    private func findFirstOccurrence<T>(array: [T], query: String, field: (T) -> String) -> Int {
        var left = 0
        var right = array.count - 1
        var result = array.count // Default to not found
        
        while left <= right {
            let mid = left + (right - left) / 2
            let midValue = field(array[mid])
            
            if midValue.hasPrefix(query) {
                result = mid
                right = mid - 1 // Continue searching left for earlier occurrence
            } else if midValue < query {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return result
    }
    
    private func findLastOccurrence<T>(array: [T], query: String, field: (T) -> String) -> Int {
        var left = 0
        var right = array.count - 1
        var result = -1 // Default to not found
        
        while left <= right {
            let mid = left + (right - left) / 2
            let midValue = field(array[mid])
            
            if midValue.hasPrefix(query) {
                result = mid
                left = mid + 1 // Continue searching right for later occurrence
            } else if midValue < query {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return result
    }
    
    // MARK: - Relevance Scoring
    
    private func calculateRelevanceScore(city: City, query: String) -> Int {
        let cityName = city.name.lowercased()
        let countryName = city.country.lowercased()
        let displayName = city.displayName.lowercased()
        
        var score = 0
        
        // Exact prefix match on city name gets highest score
        if cityName.hasPrefix(query) {
            score += 100
        }
        
        // Exact prefix match on display name gets high score
        if displayName.hasPrefix(query) {
            score += 80
        }
        
        // Exact prefix match on country name gets medium score
        if countryName.hasPrefix(query) {
            score += 60
        }
        
        // Bonus for shorter city names (more specific)
        score += max(0, 50 - cityName.count)
        
        // Bonus for exact matches
        if cityName == query {
            score += 200
        }
        
        if countryName == query {
            score += 150
        }
        
        return score
    }
}
