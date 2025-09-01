//
//  FavoritesView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI
import Combine

protocol FavoritesViewState {
    var favoriteCities: [City] { get }
    var isLoading: Bool { get }
    func perform(_ action: FavoritesViewAction)
}

enum FavoritesViewAction {
    case selectCity(City)
    case toggleFavorite(City)
}

struct FavoritesView<ViewState: ObservableObject & FavoritesViewState>: View {
    @ObservedObject var viewState: ViewState
    
    var body: some View {
        NavigationView {
            List {
                if viewState.favoriteCities.isEmpty {
                    emptyStateView
                } else {
                    favoriteCitiesList
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Private Helper Views
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Favorite Cities")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add cities to your favorites by tapping the heart icon next to any city name.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private var favoriteCitiesList: some View {
        ForEach(viewState.favoriteCities, id: \.id) { city in
            FavoriteCityRowView(
                city: city,
                onSelect: { viewState.perform(.selectCity(city)) },
                onToggleFavorite: { viewState.perform(.toggleFavorite(city)) }
            )
        }
    }
}

// MARK: - Favorite City Row View

private struct FavoriteCityRowView: View {
    let city: City
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            Button("\(city.name), \(city.country)") {
                onSelect()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onToggleFavorite) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Preview

final class FavoritesViewStatePreview: FavoritesViewState, ObservableObject {
    var isLoading: Bool = false
    
    @Published var favoriteCities: [City] = [
        City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
        City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
    ]
    
    func perform(_ action: FavoritesViewAction) {
        switch action {
        case .selectCity(let city):
            print("Selected: \(city.name)")
        case .toggleFavorite(let city):
            print("Toggle favorite: \(city.name)")
        }
    }
}

#Preview {
    FavoritesView(viewState: FavoritesViewStatePreview())
}
