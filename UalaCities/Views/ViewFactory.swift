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
    
    // MARK: - Shared Services
    
    private let sharedFavoritesService = FavoritesService()
    
    // MARK: - View Creation Methods
    
    /// Creates a view based on the navigation destination
    @ViewBuilder
    func makeView(for destination: NavigationDestination, coordinator: any Coordinator) -> some View {
        switch destination {
        case .citySearch:
            let viewModel = CitySearchViewModel(coordinator: coordinator, favoritesService: sharedFavoritesService)
            CitySearchView(viewState: viewModel)
        case .cityDetail(let city):
            VStack {
                Text("City Details")
                    .font(.title)
                Text(city.displayName)
                    .font(.headline)
                Text("Lat: \(city.coord.lat), Lon: \(city.coord.lon)")
                    .font(.caption)
            }
            .navigationTitle(city.name)
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
    func makeSheetView(for destination: SheetDestination, coordinator: any Coordinator) -> some View {
        switch destination {
        case .citySearch:
            let viewModel = CitySearchViewModel(coordinator: coordinator, favoritesService: sharedFavoritesService)
            CitySearchView(viewState: viewModel)
        case .cityDetail(let city):
            VStack {
                Text("City Details")
                    .font(.title)
                Text(city.displayName)
                    .font(.headline)
                Text("Lat: \(city.coord.lat), Lon: \(city.coord.lon)")
                    .font(.caption)
            }
            .navigationTitle(city.name)
        case .favorites:
            let viewModel = FavoritesViewModel(favoritesService: sharedFavoritesService, coordinator: coordinator)
            FavoritesView(viewState: viewModel)
        }
    }
    
    /// Creates a view based on the full screen destination
    @ViewBuilder
    func makeFullScreenView(for destination: FullScreenDestination, coordinator: any Coordinator) -> some View {
        switch destination {
        case .citySearch:
            let viewModel = CitySearchViewModel(coordinator: coordinator, favoritesService: sharedFavoritesService)
            CitySearchView(viewState: viewModel)
        }
    }
}
