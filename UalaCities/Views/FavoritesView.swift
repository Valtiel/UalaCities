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
    
    // MARK: - Constants
    
    private enum Constants {
        static var viewEntranceDuration: Double { 0.3 }
        static var emptyStateIconScale: Double { 0.8 }
        static var emptyStateIconOpacity: Double { 0.6 }
        static var emptyStateTitleOffset: Double { 10 }
        static var emptyStateDescriptionOffset: Double { 15 }
        static var emptyStateAnimationDuration: Double { 0.4 }
        static var emptyStateAnimationDelay: Double { 0.1 }
        static var listItemEntranceDuration: Double { 0.3 }
        static var listItemOffset: Double { -20 }
        static var listItemStaggerDelay: Double { 0.05 }
    }
    
    @ObservedObject var viewState: ViewState
    @State private var viewAppeared = false
    
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
            .opacity(viewAppeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: Constants.viewEntranceDuration)) {
                    viewAppeared = true
                }
            }
        }
    }
    
    // MARK: - Private Helper Views
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundColor(.gray)
                .scaleEffect(viewAppeared ? 1.0 : Constants.emptyStateIconScale)
                .opacity(viewAppeared ? 1.0 : Constants.emptyStateIconOpacity)
            
            Text("No Favorite Cities")
                .font(.title2)
                .fontWeight(.medium)
                .opacity(viewAppeared ? 1.0 : 0)
                .offset(y: viewAppeared ? 0 : Constants.emptyStateTitleOffset)
            
            Text("Add cities to your favorites by tapping the heart icon next to any city name.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(viewAppeared ? 1.0 : 0)
                .offset(y: viewAppeared ? 0 : Constants.emptyStateDescriptionOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
        .animation(.easeOut(duration: Constants.emptyStateAnimationDuration).delay(Constants.emptyStateAnimationDelay), value: viewAppeared)
    }
    
    private var favoriteCitiesList: some View {
        ForEach(Array(viewState.favoriteCities.enumerated()), id: \.element.id) { index, city in
            FavoriteCityRowView(
                city: city,
                onSelect: { viewState.perform(.selectCity(city)) },
                onToggleFavorite: { viewState.perform(.toggleFavorite(city)) }
            )
            .opacity(viewAppeared ? 1.0 : 0)
            .offset(x: viewAppeared ? 0 : Constants.listItemOffset)
            .animation(.easeOut(duration: Constants.listItemEntranceDuration).delay(Double(index) * Constants.listItemStaggerDelay), value: viewAppeared)
        }
    }
}

// MARK: - Favorite City Row View

private struct FavoriteCityRowView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static var favoriteButtonPressDuration: Double { 0.1 }
        static var favoriteButtonPressDelay: Double { 0.1 }
        static var favoriteButtonScale: Double { 0.8 }
    }
    
    let city: City
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var favoriteButtonPressed = false
    
    var body: some View {
        HStack {
            Button("\(city.name), \(city.country)") {
                onSelect()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                withAnimation(.easeInOut(duration: Constants.favoriteButtonPressDuration)) {
                    favoriteButtonPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.favoriteButtonPressDelay) {
                    withAnimation(.easeInOut(duration: Constants.favoriteButtonPressDuration)) {
                        favoriteButtonPressed = false
                    }
                }
                
                onToggleFavorite()
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .scaleEffect(favoriteButtonPressed ? Constants.favoriteButtonScale : 1.0)
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
