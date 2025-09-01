//
//  ViewBuilder.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

/// ViewFactory responsible for creating views based on navigation destinations
@MainActor
final class ViewFactory {
    
    // MARK: - Dependencies
    
    private let viewModelFactory: ViewModelFactory
    
    // MARK: - Initialization
    
    init(viewModelFactory: ViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - View Creation Methods
    
    /// Creates a view based on the navigation destination
    @ViewBuilder
    func makeView(for destination: NavigationDestination, coordinator: any Coordinator) -> some View {
        switch destination {
        case .citySearch:
            let viewModel = viewModelFactory.makeCitySearchViewModel(coordinator: coordinator)
            CitySearchView(viewState: viewModel)
        case .cityDetail(let city):
            let viewModel = viewModelFactory.makeCityDetailViewModel(city: city, coordinator: coordinator)
            CityDetailView(viewState: viewModel)
        case .citySearchDetail:
            let viewModel = viewModelFactory.makeCitySearchDetailViewModel(coordinator: coordinator)
            CitySearchDetailView(viewState: viewModel)
        }
    }
    
    /// Creates a view based on the sheet destination
    @ViewBuilder
    func makeSheetView(for destination: SheetDestination, coordinator: any Coordinator) -> some View {
        switch destination {
        case .favorites:
            let viewModel = viewModelFactory.makeFavoritesViewModel(coordinator: coordinator)
            FavoritesView(viewState: viewModel)
        }
    }
}
