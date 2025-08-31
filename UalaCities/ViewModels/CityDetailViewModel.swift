//
//  CityDetailViewModel.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation
import Combine

final class CityDetailViewModel: ObservableObject, CityDetailViewState {
    
    // MARK: - Published Properties
    
    @Published var city: City
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isFavorite: Bool = false
    
    // MARK: - Private Properties
    
    private let favoritesService: FavoritesService
    private let coordinator: (any Coordinator)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(city: City, favoritesService: FavoritesService, coordinator: (any Coordinator)? = nil) {
        self.city = city
        self.favoritesService = favoritesService
        self.coordinator = coordinator
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    func perform(_ action: CityDetailViewAction) {
        switch action {
        case .toggleFavorite:
            toggleFavorite()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Monitor favorite status changes
        favoritesService.$favoriteCities
            .receive(on: DispatchQueue.main)
            .map { [weak self] favoriteCities in
                guard let self = self else { return false }
                return favoriteCities.contains { $0.id == self.city.id }
            }
            .assign(to: \.isFavorite, on: self)
            .store(in: &cancellables)
    }
    
    private func toggleFavorite() {
        favoritesService.toggleFavorite(city)
    }
}
