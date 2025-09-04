//
//  CitySearchViewModel.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation
import Combine

final class CitySearchViewModel: ObservableObject, CitySearchViewState {
    
    // MARK: - Published Properties
    
    @Published var cityList: [City] = []
    @Published var filteredCityList: [City] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentPage: Int = 1
    @Published var hasMorePages: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var favoritesCount: Int = 0
    
    // MARK: - Private Properties
    
    private let searchService: any CitySearchService
    private let cityDataService: any CityDataService
    let favoritesService: any FavoritesService
    private let itemsPerPage: Int = 20
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: (any Coordinator)?
    private var currentSearchResults: [City] = []
    
    // MARK: - Initialization
    
    init(searchService: any CitySearchService, cityDataService: any CityDataService, favoritesService: any FavoritesService, coordinator: (any Coordinator)? = nil) {
        self.searchService = searchService
        self.cityDataService = cityDataService
        self.favoritesService = favoritesService
        self.coordinator = coordinator
        setupBindings()
        // Only load cities if they haven't been loaded yet
        if !cityDataService.isDataLoaded {
            cityDataService.loadCities()
        }
    }
    
    convenience init(coordinator: (any Coordinator)? = nil, favoritesService: (any FavoritesService)? = nil) {
        let searchService = CitySearchByStrategyService(strategy: TrieSearchStrategy())
        let cityDataService = CityDataByProviderService.withLocalFileProvider(fileName: "cities")
        let service = favoritesService ?? UserDefaultsFavoritesService()
        self.init(searchService: searchService, cityDataService: cityDataService, favoritesService: service, coordinator: coordinator)
    }
    
    // MARK: - Public Methods
    
    func perform(_ action: CitySearchViewAction) {
        switch action {
        case .searchQuery(let query):
            searchCities(query)
        case .selectCity(let city):
            // Save selected city to coordinator state
            if let appCoordinator = coordinator as? AppCoordinator {
                Task { @MainActor in
                    appCoordinator.setSelectedCity(city)
                }
            }
        case .loadMore:
            loadMoreCities()
        case .toggleFavorite(let city):
            toggleFavorite(city)
        case .showFavorites:
            showFavorites()
        }
    }
    
    /// Called when the view appears to ensure data is properly set up
    func onViewAppear() {
        // If data is loaded but we don't have any filtered results, initialize them
        if cityDataService.isDataLoaded && filteredCityList.isEmpty {
            currentSearchResults = cityDataService.cities
            searchCities("")
        }
    }
    
    /// Updates the coordinator reference (used for state synchronization)
    func updateCoordinator(_ newCoordinator: any Coordinator) {
        self.coordinator = newCoordinator
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        cityDataService.citiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cities in
                self?.cityList = cities
                // Only index if not already indexed
                if !(self?.searchService.isIndexed ?? false) {
                    self?.searchService.index(cities: cities)
                }
                self?.currentSearchResults = cities
                self?.searchCities("")
            }
            .store(in: &cancellables)
        
        // If cities are already loaded when the view model is created, set them immediately
        if cityDataService.isDataLoaded {
            cityList = cityDataService.cities
            // Only index if not already indexed
            if !searchService.isIndexed {
                searchService.index(cities: cityDataService.cities)
            }
            currentSearchResults = cityDataService.cities
            searchCities("")
        }
        
        cityDataService.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        cityDataService.errorPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
        
        favoritesService.favoriteCitiesPublisher
            .receive(on: DispatchQueue.main)
            .map { $0.count }
            .assign(to: \.favoritesCount, on: self)
            .store(in: &cancellables)
    }
    
    private func searchCities(_ query: String) {
        currentPage = 1 // Reset pagination for new search
        
        if query.isEmpty {
            currentSearchResults = cityList
            updateFilteredList(with: cityList)
        } else {
            isLoading = true
            
            Task {
                let results = await searchService.search(query: query)
                
                await MainActor.run {
                    isLoading = false
                    currentSearchResults = results
                    updateFilteredList(with: results)
                }
            }
        }
    }
    
    private func updateFilteredList(with allCities: [City]) {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allCities.count)
        
        let newItems = startIndex < allCities.count ? Array(allCities[startIndex..<endIndex]) : []
        
        if currentPage == 1 {
            filteredCityList = newItems
        } else {
            filteredCityList.append(contentsOf: newItems)
        }
        
        hasMorePages = endIndex < allCities.count
    }
    
    private func loadMoreCities() {
        guard hasMorePages && !isLoadingMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.isLoadingMore = false
            self.updateFilteredList(with: self.currentSearchResults)
        }
    }
    
    private func toggleFavorite(_ city: City) {
        favoritesService.toggleFavorite(city)
    }
    
    private func showFavorites() {
        Task { @MainActor in
            coordinator?.presentSheet(.favorites)
        }
    }
    
    func isFavorite(_ city: City) -> Bool {
        favoritesService.isFavorite(city)
    }
}





