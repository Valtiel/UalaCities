//
//  CitySearchView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

protocol CitySearchViewState {
    var cityList: [City] { get }
    var filteredCityList: [City] { get }
    var isLoading: Bool { get }
    var currentPage: Int { get }
    var hasMorePages: Bool { get }
    var isLoadingMore: Bool { get }
    var favoritesCount: Int { get }
    func perform(_ action: CitySearchViewAction)
    func isFavorite(_ city: City) -> Bool
    func onViewAppear()
}

enum CitySearchViewAction {
    case searchQuery(String)
    case selectCity(City)
    case loadMore
    case toggleFavorite(City)
    case showFavorites
}

struct CitySearchView<ViewState: ObservableObject & CitySearchViewState>: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static var searchFieldEntranceDuration: Double { 0.3 }
        static var favoritesButtonPressDuration: Double { 0.1 }
        static var favoritesButtonPressDelay: Double { 0.1 }
        static var cityRowEntranceDuration: Double { 0.6 }
        static var cityRowEntranceDelay: Double { 0.4 }
        static var cityRowStaggerDelay: Double { 0.05 }
        static var loadMoreEntranceDuration: Double { 0.7 }
        static var loadMoreEntranceDelay: Double { 0.6 }
        static var loadMoreStateTransitionDuration: Double { 0.3 }
        static var listUpdateDuration: Double { 0.2 }
    }
    
    @ObservedObject var viewState: ViewState
    @State private var query: String = ""
    @State private var searchFieldAppeared = false
    @State private var favoritesButtonPressed = false
    
    var body: some View {
        VStack {
            searchHeader
            contentSection
        }
        .navigationTitle("City Search")
        .onChange(of: query) { oldQuery, newQuery in
            viewState.perform(.searchQuery(newQuery))
        }
        .onAppear {
            viewState.onViewAppear()
            withAnimation(.easeOut(duration: Constants.searchFieldEntranceDuration)) {
                searchFieldAppeared = true
            }
        }
    }
    
    // MARK: - Private Helper Views
    
    private var searchHeader: some View {
        HStack {
            TextField("Search city...", text: $query)
                .textFieldStyle(.roundedBorder)
                .opacity(searchFieldAppeared ? 1 : 0)
                .offset(y: searchFieldAppeared ? 0 : -10)
            
            favoritesButton
        }
        .padding()
        .onSubmit {
            viewState.perform(.searchQuery(query))
        }
    }
    
    private var favoritesButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: Constants.favoritesButtonPressDuration)) {
                favoritesButtonPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.favoritesButtonPressDelay) {
                withAnimation(.easeInOut(duration: Constants.favoritesButtonPressDuration)) {
                    favoritesButtonPressed = false
                }
            }
            
            viewState.perform(.showFavorites)
        }) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .scaleEffect(favoritesButtonPressed ? 0.9 : 1.0)
                Text("\(viewState.favoritesCount)")
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var contentSection: some View {
        Group {
            if viewState.isLoading {
                loadingView
                Spacer()
            } else {
                cityListView
            }
        }
        .animation(.easeInOut(duration: Constants.listUpdateDuration), value: viewState.isLoading)
    }
    
    private var loadingView: some View {
        ProgressView()
            .padding()
    }
    
    private var cityListView: some View {
        List {
            ForEach(Array(viewState.filteredCityList.enumerated()), id: \.element.id) { index, city in
                CityRowView(
                    city: city,
                    isFavorite: viewState.isFavorite(city),
                    onSelect: { viewState.perform(.selectCity(city)) },
                    onToggleFavorite: { viewState.perform(.toggleFavorite(city)) }
                )
            }
            
            if viewState.hasMorePages {
                loadMoreSection
            }
        }
        .listStyle(PlainListStyle())
        .animation(.easeInOut(duration: Constants.listUpdateDuration), value: viewState.filteredCityList.count)
    }
    
    private var loadMoreSection: some View {
        HStack {
            Spacer()
            if viewState.isLoadingMore {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button("Load More") {
                    viewState.perform(.loadMore)
                }
                .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: Constants.loadMoreStateTransitionDuration), value: viewState.isLoadingMore)
    }
}

// MARK: - City Row View

private struct CityRowView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static var favoriteButtonPressDuration: Double { 0.1 }
        static var favoriteButtonPressDelay: Double { 0.1 }
        static var favoriteButtonScale: Double { 0.8 }
    }
    
    let city: City
    let isFavorite: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var favoriteButtonPressed = false
    
    var body: some View {
        HStack {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(city.name), \(city.country)")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("Lat: \(String(format: "%.4f", city.coord.lat)), Lon: \(String(format: "%.4f", city.coord.lon))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(PlainButtonStyle())
            
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
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .scaleEffect(favoriteButtonPressed ? Constants.favoriteButtonScale : 1.0)
                    .scaleEffect(isFavorite ? 1.1 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

//MARK: - Preview
final class CitySearchViewStatePreview: CitySearchViewState, ObservableObject {
    var isLoading: Bool = false
    var currentPage: Int = 1
    var hasMorePages: Bool = false
    var isLoadingMore: Bool = false
    var favoritesCount: Int = 2
    
    @Published var cityList: [City] =         [
        City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
        City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
        City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1276, lat: 51.5074)),
        City(id: 4, name: "São Paulo", country: "Brasil", coord: City.Coordinate(lon: -46.6333, lat: -23.5505)),
        City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566)),
        City(id: 6, name: "Tokyo", country: "Japan", coord: City.Coordinate(lon: 139.6917, lat: 35.6895)),
        City(id: 7, name: "Sydney", country: "Australia", coord: City.Coordinate(lon: 151.2093, lat: -33.8688)),
        City(id: 8, name: "Berlin", country: "Germany", coord: City.Coordinate(lon: 13.4050, lat: 52.5200)),
        City(id: 9, name: "Madrid", country: "Spain", coord: City.Coordinate(lon: -3.7038, lat: 40.4168)),
        City(id: 10, name: "Rome", country: "Italy", coord: City.Coordinate(lon: 12.4964, lat: 41.9028))
    ]
    
    @Published var filteredCityList: [City] = []
    
    func perform(_ action: CitySearchViewAction) {
        switch action {
        case .searchQuery(let query):
            if query.isEmpty {
                filteredCityList = cityList
            } else {
                filteredCityList = cityList.filter { $0.name.lowercased().contains(query.lowercased())
                }
            }
        case .selectCity(let city):
            print("Selected City: \(city.name)")
        case .loadMore:
            print("Load more requested")
        case .toggleFavorite(let city):
            print("Toggle favorite for: \(city.name)")
        case .showFavorites:
            print("Show favorites requested")
        }
    }
    
    func isFavorite(_ city: City) -> Bool {
        // Mock implementation for preview
        return city.id == 1 || city.id == 3
    }
    
    func onViewAppear() {
        // Mock implementation for preview
        filteredCityList = cityList
    }
}

#Preview {
    CitySearchView(viewState: CitySearchViewStatePreview())
}
