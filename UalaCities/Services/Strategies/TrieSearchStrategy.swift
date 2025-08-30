//
//  TrieSearchStrategy.swift
//  UalaCities
//
//  Created by César Rosales on 29/08/2025.
//

import Foundation

/// Trie-based search strategy for incremental autocomplete
/// Maintains search state for efficient character-by-character updates
class TrieSearchStrategy: CitySearchStrategy {
    
    // MARK: - Private Types
    
    private class TrieNode {
        var children: [Character: TrieNode] = [:]
        var cities: [City] = []
        var isEndOfWord = false
        
        init() {}
    }
    
    // MARK: - Properties
    
    private var root = TrieNode()
    private var allCities: [City] = []
    private var currentSearchState: SearchState?
    
    var indexedCityCount: Int {
        return allCities.count
    }
    
    // MARK: - Search State Management
    
    private struct SearchState {
        let currentNode: TrieNode
        let query: String
        let results: [City]
    }
    
    // MARK: - CitySearchStrategy Implementation
    
    func index(cities: [City]) {
        clear()
        allCities = cities
        
        for city in cities {
            insertCity(city)
        }
    }
    
    func search(query: String) -> [City] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalizedQuery.isEmpty {
            currentSearchState = nil
            return []
        }
        
        // Check if we can incrementally update from current state
        if let currentState = currentSearchState {
            if normalizedQuery.hasPrefix(currentState.query) {
                // Adding characters - incrementally update
                return incrementalSearchAdd(currentState: currentState, newQuery: normalizedQuery)
            } else if currentState.query.hasPrefix(normalizedQuery) {
                // Removing characters - incrementally update
                return incrementalSearchRemove(currentState: currentState, newQuery: normalizedQuery)
            }
        }
        
        // Full search from root
        return performFullSearch(query: normalizedQuery)
    }
    
    func clear() {
        root = TrieNode()
        allCities.removeAll()
        currentSearchState = nil
    }
    
    // MARK: - Incremental Search Methods
    
    private func incrementalSearchAdd(currentState: SearchState, newQuery: String) -> [City] {
        var currentNode = currentState.currentNode
        let additionalChars = String(newQuery.dropFirst(currentState.query.count))
        
        // Navigate from current node with additional characters
        for char in additionalChars {
            guard let nextNode = currentNode.children[char] else {
                // No path exists, clear state and return empty
                currentSearchState = nil
                return []
            }
            currentNode = nextNode
        }
        
        // Collect results from current node and descendants
        var results: [City] = []
        collectCities(from: currentNode, results: &results)
        
        // Remove duplicates and sort
        let uniqueResults = Array(Set(results)).sorted { city1, city2 in
            let score1 = calculateRelevanceScore(city: city1, query: newQuery)
            let score2 = calculateRelevanceScore(city: city2, query: newQuery)
            
            if score1 != score2 {
                return score1 > score2
            }
            return city1.displayName < city2.displayName
        }
        
        // Update search state
        currentSearchState = SearchState(
            currentNode: currentNode,
            query: newQuery,
            results: uniqueResults
        )
        
        return uniqueResults
    }
    
    private func incrementalSearchRemove(currentState: SearchState, newQuery: String) -> [City] {
        // Navigate back to the node for the shorter query
        var currentNode = root
        
        for char in newQuery {
            guard let nextNode = currentNode.children[char] else {
                // This shouldn't happen if we're removing characters
                currentSearchState = nil
                return []
            }
            currentNode = nextNode
        }
        
        // Collect results from current node and descendants
        var results: [City] = []
        collectCities(from: currentNode, results: &results)
        
        // Remove duplicates and sort
        let uniqueResults = Array(Set(results)).sorted { city1, city2 in
            let score1 = calculateRelevanceScore(city: city1, query: newQuery)
            let score2 = calculateRelevanceScore(city: city2, query: newQuery)
            
            if score1 != score2 {
                return score1 > score2
            }
            return city1.displayName < city2.displayName
        }
        
        // Update search state
        currentSearchState = SearchState(
            currentNode: currentNode,
            query: newQuery,
            results: uniqueResults
        )
        
        return uniqueResults
    }
    
    private func performFullSearch(query: String) -> [City] {
        var currentNode = root
        
        // Navigate to the node for the query
        for char in query {
            guard let nextNode = currentNode.children[char] else {
                currentSearchState = nil
                return []
            }
            currentNode = nextNode
        }
        
        // Collect results from current node and descendants
        var results: [City] = []
        collectCities(from: currentNode, results: &results)
        
        // Remove duplicates and sort
        let uniqueResults = Array(Set(results)).sorted { city1, city2 in
            let score1 = calculateRelevanceScore(city: city1, query: query)
            let score2 = calculateRelevanceScore(city: city2, query: query)
            
            if score1 != score2 {
                return score1 > score2
            }
            return city1.displayName < city2.displayName
        }
        
        // Update search state
        currentSearchState = SearchState(
            currentNode: currentNode,
            query: query,
            results: uniqueResults
        )
        
        return uniqueResults
    }
    
    // MARK: - Private Methods
    
    private func insertCity(_ city: City) {
        // Insert by city name
        insertString(city.name.lowercased(), city: city)
        
        // Insert by country name
        insertString(city.country.lowercased(), city: city)
        
        // Insert by display name
        insertString(city.displayName.lowercased(), city: city)
    }
    
    private func insertString(_ string: String, city: City) {
        var current = root
        
        for char in string {
            if current.children[char] == nil {
                current.children[char] = TrieNode()
            }
            current = current.children[char]!
        }
        
        current.isEndOfWord = true
        current.cities.append(city)
    }
    
    private func collectCities(from node: TrieNode, results: inout [City]) {
        results.append(contentsOf: node.cities)
        
        for child in node.children.values {
            collectCities(from: child, results: &results)
        }
    }
    
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
