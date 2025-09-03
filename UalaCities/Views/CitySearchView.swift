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
    
    @ObservedObject var viewState: ViewState
    @State private var query: String = ""
    @State private var animateEntrance = false
    @State private var searchFieldScale: CGFloat = 0.95
    @State private var favoritesButtonScale: CGFloat = 1.0
    
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
            withAnimation(.easeOut(duration: 0.6)) {
                animateEntrance = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                searchFieldScale = 1.0
            }
        }
    }
    
    // MARK: - Private Helper Views
    
    private var searchHeader: some View {
        HStack {
            TextField("Search city...", text: $query)
                .textFieldStyle(.roundedBorder)
                .scaleEffect(searchFieldScale)
                .opacity(animateEntrance ? 1 : 0)
                .offset(y: animateEntrance ? 0 : -20)
            
            favoritesButton
                .opacity(animateEntrance ? 1 : 0)
                .offset(x: animateEntrance ? 0 : 30)
        }
        .padding()
        .onSubmit {
            viewState.perform(.searchQuery(query))
        }
        .animation(.easeOut(duration: 0.7).delay(0.1), value: animateEntrance)
    }
    
    private var favoritesButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesButtonScale = 0.9
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoritesButtonScale = 1.0
                }
            }
            
            viewState.perform(.showFavorites)
        }) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .scaleEffect(favoritesButtonScale)
                Text("\(viewState.favoritesCount)")
                    .font(.caption)
                    .scaleEffect(favoritesButtonScale)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favoritesButtonScale)
    }
    
    private var contentSection: some View {
        Group {
            if viewState.isLoading {
                loadingView
                    .opacity(animateEntrance ? 1 : 0)
                    .scaleEffect(animateEntrance ? 1 : 0.8)
                Spacer()
            } else {
                cityListView
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 30)
            }
        }
        .animation(.easeOut(duration: 0.8).delay(0.3), value: animateEntrance)
    }
    
    private var loadingView: some View {
        ProgressView()
            .padding()
            .scaleEffect(animateEntrance ? 1 : 0.8)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: animateEntrance)
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
                .opacity(animateEntrance ? 1 : 0)
                .offset(x: animateEntrance ? 0 : -50)
                .animation(.easeOut(duration: 0.6).delay(0.4 + Double(index) * 0.05), value: animateEntrance)
            }
            
            if viewState.hasMorePages {
                loadMoreSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)
                    .animation(.easeOut(duration: 0.7).delay(0.6), value: animateEntrance)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var loadMoreSection: some View {
        HStack {
            Spacer()
            if viewState.isLoadingMore {
                ProgressView()
                    .scaleEffect(0.8)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: viewState.isLoadingMore)
            } else {
                Button("Load More") {
                    viewState.perform(.loadMore)
                }
                .foregroundColor(.blue)
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.3), value: viewState.isLoadingMore)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - City Row View

private struct CityRowView: View {
    let city: City
    let isFavorite: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var favoriteButtonScale: CGFloat = 1.0
    @State private var rowOpacity: Double = 1.0
    
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
            .opacity(rowOpacity)
            .scaleEffect(rowOpacity)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoriteButtonScale = 0.8
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favoriteButtonScale = 1.0
                    }
                }
                
                onToggleFavorite()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .scaleEffect(favoriteButtonScale)
                    .scaleEffect(isFavorite ? 1.1 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favoriteButtonScale)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                rowOpacity = 1.0
            }
        }
        .onDisappear {
            rowOpacity = 0.8
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
