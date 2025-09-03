//
//  FavoritesService.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation
import Combine

/// Protocol defining the interface for favorite cities management
protocol FavoritesService: ObservableObject {
    var favoriteCities: [City] { get }
    var favoriteCitiesPublisher: Published<[City]>.Publisher { get }
    func addToFavorites(_ city: City)
    func removeFromFavorites(_ city: City)
    func toggleFavorite(_ city: City)
    func isFavorite(_ city: City) -> Bool
    var favoritesCount: Int { get }
}

/// Service that manages favorite cities with persistence using UserDefaults
final class UserDefaultsFavoritesService: FavoritesService {
    
    // MARK: - Published Properties
    
    @Published private(set) var favoriteCities: [City] = []
    
    var favoriteCitiesPublisher: Published<[City]>.Publisher {
        $favoriteCities
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorite_cities"
    
    // MARK: - Initialization
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    /// Adds a city to favorites
    func addToFavorites(_ city: City) {
        guard !isFavorite(city) else { return }
        
        favoriteCities.append(city)
        saveFavorites()
    }
    
    /// Removes a city from favorites
    func removeFromFavorites(_ city: City) {
        favoriteCities.removeAll { $0.id == city.id }
        saveFavorites()
    }
    
    /// Toggles the favorite status of a city
    func toggleFavorite(_ city: City) {
        if isFavorite(city) {
            removeFromFavorites(city)
        } else {
            addToFavorites(city)
        }
    }
    
    /// Checks if a city is in favorites
    func isFavorite(_ city: City) -> Bool {
        favoriteCities.contains { $0.id == city.id }
    }
    
    /// Returns the number of favorite cities
    var favoritesCount: Int {
        favoriteCities.count
    }
    
    // MARK: - Private Methods
    
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favoriteCities)
            userDefaults.set(data, forKey: favoritesKey)
        } catch {
            print("Error saving favorites: \(error)")
        }
    }
    
    private func loadFavorites() {
        guard let data = userDefaults.data(forKey: favoritesKey) else { return }
        
        do {
            favoriteCities = try JSONDecoder().decode([City].self, from: data)
        } catch {
            print("Error loading favorites: \(error)")
            favoriteCities = []
        }
    }
}
