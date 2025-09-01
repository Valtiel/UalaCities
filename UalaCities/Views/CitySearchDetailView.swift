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
    
    @ObservedObject var viewState: ViewState
    @State private var query: String = ""
    
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
        .onChange(of: query) { oldQuery, newQuery in
            viewState.perform(.searchQuery(newQuery))
        }
        .onAppear {
            viewState.onViewAppear()
        }
    }
    
    // MARK: - Private Helper Views
    
    private var searchSection: some View {
        VStack {
            searchHeader
            contentSection
        }
    }
    
    private var searchHeader: some View {
        HStack {
            TextField("Search city...", text: $query)
                .textFieldStyle(.roundedBorder)
            
            favoritesButton
        }
        .padding()
        .onSubmit {
            viewState.perform(.searchQuery(query))
        }
    }
    
    private var favoritesButton: some View {
        Button(action: {
            viewState.perform(.showFavorites)
        }) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
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
    }
    
    private var loadingView: some View {
        ProgressView()
            .padding()
    }
    
    private var cityListView: some View {
        List {
            ForEach(viewState.filteredCityList, id: \.id) { city in
                CityRowView(
                    city: city,
                    isFavorite: viewState.isFavorite(city),
                    isSelected: viewState.selectedCity?.id == city.id,
                    onSelect: { viewState.perform(.selectCity(city)) },
                    onToggleFavorite: { viewState.perform(.toggleFavorite(city)) }
                )
            }
            
            if viewState.hasMorePages {
                loadMoreSection
            }
        }
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
    }
    
    private var detailSection: some View {
        Group {
            if let selectedCity = viewState.selectedCity {
                CityDetailView(viewState: DetailViewStateAdapter(
                    city: selectedCity,
                    isFavorite: viewState.isDetailFavorite,
                    onToggleFavorite: { viewState.perform(.toggleDetailFavorite) }
                ))
            } else {
                emptyDetailView
            }
        }
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

// MARK: - City Row View

private struct CityRowView: View {
    let city: City
    let isFavorite: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
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
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
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
