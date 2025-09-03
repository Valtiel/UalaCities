//
//  FavoritesViewModel.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation
import Combine

final class FavoritesViewModel: ObservableObject, FavoritesViewState {
    
    // MARK: - Published Properties
    
    @Published var favoriteCities: [City] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let favoritesService: any FavoritesService
    private weak var coordinator: (any Coordinator)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(favoritesService: any FavoritesService, coordinator: (any Coordinator)? = nil) {
        self.favoritesService = favoritesService
        self.coordinator = coordinator
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    func perform(_ action: FavoritesViewAction) {
        switch action {
        case .selectCity(let city):
            Task { @MainActor in
                coordinator?.navigate(to: .cityDetail(city))
                coordinator?.dismissSheet()
            }
        case .toggleFavorite(let city):
            favoritesService.toggleFavorite(city)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        favoritesService.favoriteCitiesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.favoriteCities, on: self)
            .store(in: &cancellables)
    }
}
