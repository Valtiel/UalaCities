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
    
    // MARK: - View Creation Methods
    
    /// Creates a view based on the navigation destination
    @ViewBuilder
    func makeView(for destination: NavigationDestination, coordinator: any Coordinator, servicesManager: ServicesManager) -> some View {
        switch destination {
        case .citySearch:
            let viewModel = servicesManager.makeCitySearchViewModel(coordinator: coordinator)
            CitySearchView(viewState: viewModel)
        case .cityDetail(let city):
            let viewModel = servicesManager.makeCityDetailViewModel(city: city, coordinator: coordinator)
            CityDetailView(viewState: viewModel)
        case .settings:
            VStack {
                Text("Settings")
                    .font(.title)
                Text("Settings view coming soon...")
            }
            .navigationTitle("Settings")
        }
    }
    
    /// Creates a view based on the sheet destination
    @ViewBuilder
    func makeSheetView(for destination: SheetDestination, coordinator: any Coordinator, servicesManager: ServicesManager) -> some View {
        switch destination {
        case .citySearch:
            let viewModel = servicesManager.makeCitySearchViewModel(coordinator: coordinator)
            CitySearchView(viewState: viewModel)
        case .cityDetail(let city):
            let viewModel = servicesManager.makeCityDetailViewModel(city: city, coordinator: coordinator)
            CityDetailView(viewState: viewModel)
        case .favorites:
            let viewModel = servicesManager.makeFavoritesViewModel(coordinator: coordinator)
            FavoritesView(viewState: viewModel)
        }
    }
    
    /// Creates a view based on the full screen destination
    @ViewBuilder
    func makeFullScreenView(for destination: FullScreenDestination, coordinator: any Coordinator, servicesManager: ServicesManager) -> some View {
        switch destination {
        case .citySearch:
            let viewModel = servicesManager.makeCitySearchViewModel(coordinator: coordinator)
            CitySearchView(viewState: viewModel)
        }
    }
}
