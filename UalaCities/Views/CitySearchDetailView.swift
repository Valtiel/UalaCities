//
//  CitySearchDetailView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

protocol CitySearchDetailViewState {
    var cityList: [City] { get }
    var filteredCityList: [City] { get }
    var isLoading: Bool { get }
    var currentPage: Int { get }
    var hasMorePages: Bool { get }
    var isLoadingMore: Bool { get }
    var favoritesCount: Int { get }
    var selectedCity: City? { get }
    var isDetailFavorite: Bool { get }
    func perform(_ action: CitySearchDetailViewAction)
    func isFavorite(_ city: City) -> Bool
    func onViewAppear()
}

enum CitySearchDetailViewAction {
    case searchQuery(String)
    case selectCity(City)
    case loadMore
    case toggleFavorite(City)
    case toggleDetailFavorite
    case showFavorites
}

struct CitySearchDetailView<ViewState: ObservableObject & CitySearchDetailViewState>: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static var viewEntranceDuration: Double { 0.3 }
        static var emptyStateScale: Double { 0.95 }
        static var emptyStateAnimationDuration: Double { 0.4 }
        static var emptyStateAnimationDelay: Double { 0.1 }
        static var citySelectionTransitionDuration: Double { 0.2 }
    }
    
    @ObservedObject var viewState: ViewState
    @State private var viewAppeared = false
    @State private var selectedCity: City? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            searchSection
                .frame(maxWidth: .infinity)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            detailSection
                .frame(maxWidth: .infinity)
        }
        .navigationTitle("City Search & Detail")
        .opacity(viewAppeared ? 1 : 0)
        .onAppear {
            viewState.onViewAppear()
            selectedCity = viewState.selectedCity
            withAnimation(.easeOut(duration: Constants.viewEntranceDuration)) {
                viewAppeared = true
            }
        }
        .onChange(of: viewState.selectedCity) {
            selectedCity = viewState.selectedCity
        }
    }
    
    // MARK: - Private Helper Views
    
    private var searchSection: some View {
        CitySearchView(viewState: SearchViewStateAdapter(
            detailViewState: viewState
        ))
    }
    
    private var detailSection: some View {
        Group {
            if let selectedCity {
                CityDetailView(viewState: DetailViewStateAdapter(
                    city: selectedCity,
                    isFavorite: viewState.isDetailFavorite,
                    onToggleFavorite: { viewState.perform(.toggleDetailFavorite) }
                ))
                .id(selectedCity.id) // Force view recreation when city changes
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                emptyDetailView
                    .opacity(viewAppeared ? 1 : 0)
                    .scaleEffect(viewAppeared ? 1.0 : Constants.emptyStateScale)
                    .animation(.easeOut(duration: Constants.emptyStateAnimationDuration).delay(Constants.emptyStateAnimationDelay), value: viewAppeared)
            }
        }
        .animation(.easeInOut(duration: Constants.citySelectionTransitionDuration), value: viewState.selectedCity)
    }
    
    private var emptyDetailView: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Select a City")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Choose a city from the list to view its details")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

// MARK: - Search View State Adapter

private class SearchViewStateAdapter: ObservableObject, CitySearchViewState {
    private let detailViewState: CitySearchDetailViewState
    
    init(detailViewState: CitySearchDetailViewState) {
        self.detailViewState = detailViewState
    }
    
    var cityList: [City] { detailViewState.cityList }
    var filteredCityList: [City] { detailViewState.filteredCityList }
    var isLoading: Bool { detailViewState.isLoading }
    var currentPage: Int { detailViewState.currentPage }
    var hasMorePages: Bool { detailViewState.hasMorePages }
    var isLoadingMore: Bool { detailViewState.isLoadingMore }
    var favoritesCount: Int { detailViewState.favoritesCount }
    
    func perform(_ action: CitySearchViewAction) {
        switch action {
        case .searchQuery(let query):
            detailViewState.perform(.searchQuery(query))
        case .selectCity(let city):
            detailViewState.perform(.selectCity(city))
        case .loadMore:
            detailViewState.perform(.loadMore)
        case .toggleFavorite(let city):
            detailViewState.perform(.toggleFavorite(city))
        case .showFavorites:
            detailViewState.perform(.showFavorites)
        }
    }
    
    func isFavorite(_ city: City) -> Bool {
        detailViewState.isFavorite(city)
    }
    
    func onViewAppear() {
        detailViewState.onViewAppear()
    }
}

// MARK: - Detail View State Adapter

private class DetailViewStateAdapter: ObservableObject, CityDetailViewState {
    let city: City
    let isFavorite: Bool
    private let onToggleFavorite: () -> Void
    var isLoading: Bool = false
    var error: Error? = nil
    
    init(city: City, isFavorite: Bool, onToggleFavorite: @escaping () -> Void) {
        self.city = city
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
    }
    
    func perform(_ action: CityDetailViewAction) {
        switch action {
        case .toggleFavorite:
            onToggleFavorite()
        }
    }
}

// MARK: - Preview

final class CitySearchDetailViewStatePreview: CitySearchDetailViewState, ObservableObject {
    var isLoading: Bool = false
    var currentPage: Int = 1
    var hasMorePages: Bool = false
    var isLoadingMore: Bool = false
    var favoritesCount: Int = 2
    @Published var isDetailFavorite: Bool = false
    
    @Published var cityList: [City] = [
        City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
        City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
        City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1276, lat: 51.5074)),
        City(id: 4, name: "São Paulo", country: "Brasil", coord: City.Coordinate(lon: -46.6333, lat: -23.5505)),
        City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566))
    ]
    
    @Published var filteredCityList: [City] = []
    @Published var selectedCity: City? = City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037))
    
    func perform(_ action: CitySearchDetailViewAction) {
        switch action {
        case .searchQuery(let query):
            if query.isEmpty {
                filteredCityList = cityList
            } else {
                filteredCityList = cityList.filter { $0.name.lowercased().contains(query.lowercased()) }
            }
        case .selectCity(let city):
            print("CitySearchDetailView: City selected: \(city.name) at coordinates: lat: \(city.coord.lat), lon: \(city.coord.lon)")
            selectedCity = city
        case .loadMore:
            print("Load more requested")
        case .toggleFavorite(let city):
            print("Toggle favorite for: \(city.name)")
        case .toggleDetailFavorite:
            isDetailFavorite.toggle()
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
    CitySearchDetailView(viewState: CitySearchDetailViewStatePreview())
}
