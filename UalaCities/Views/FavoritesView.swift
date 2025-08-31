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
                } else {
                    ForEach(viewState.favoriteCities, id: \.id) { city in
                        HStack {
                            Button("\(city.name), \(city.country)") {
                                viewState.perform(.selectCity(city))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                viewState.perform(.toggleFavorite(city))
                            }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
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
    FavoritesView(viewState: FavoritesViewModel(favoritesService: FavoritesService()))
}
