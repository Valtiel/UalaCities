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
    @Published var progress: Double = 0.0
    @Published var error: Error?
    
    // MARK: - Pagination Properties
    
    @Published var currentPage: Int = 1
    @Published var hasMorePages: Bool = false
    @Published var isLoadingMore: Bool = false
    
    private let itemsPerPage: Int = 20
    private var allFilteredCities: [City] = []
    
    // MARK: - Private Properties
    
    private let searchService: CitySearchService
    private let cityDataService: CityDataService
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: (any Coordinator)?
    
    // MARK: - Initialization
    
    init(searchService: CitySearchService, cityDataService: CityDataService, coordinator: (any Coordinator)? = nil) {
        self.searchService = searchService
        self.cityDataService = cityDataService
        self.coordinator = coordinator
        setupBindings()
        setupInitialData()
    }
    
    /// Convenience initializer that creates a ViewModel with default services
    convenience init(coordinator: (any Coordinator)? = nil) {
        let searchService = CitySearchService(strategy: TrieSearchStrategy())
        let cityDataService = CityDataService.withLocalFileProvider(fileName: "cities")
        self.init(searchService: searchService, cityDataService: cityDataService, coordinator: coordinator)
    }
    
    // MARK: - Public Methods
    
    func perform(_ action: CitySearchViewAction) {
        switch action {
        case .searchQuery(let query):
            handleSearchQuery(query)
        case .selectCity(let city):
            handleCitySelection(city)
        case .loadMore:
            loadMoreCities()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Bind to city data service state
        cityDataService.$cities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cities in
                self?.cityList = cities
                self?.searchService.index(cities: cities)
                self?.allFilteredCities = cities
                self?.resetPagination()
            }
            .store(in: &cancellables)
        
        cityDataService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        cityDataService.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: \.progress, on: self)
            .store(in: &cancellables)
        
        cityDataService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }
    
    private func setupInitialData() {
        // Load cities from the data service
        cityDataService.loadCities()
    }
    
    private func handleSearchQuery(_ query: String) {
        if query.isEmpty {
            allFilteredCities = cityList
            resetPagination()
        } else {
            progress = 0.0
            isLoading = true
            Task {
                let results = await searchService.search(query: query)
                
                Task { @MainActor in
                    progress = 1.0
                    isLoading = false
                    allFilteredCities = results
                    resetPagination()
                }
            }
        }
    }
    
    private func resetPagination() {
        currentPage = 1
        updateFilteredList()
    }
    
    private func updateFilteredList() {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allFilteredCities.count)
        
        if startIndex < allFilteredCities.count {
            let newItems = Array(allFilteredCities[startIndex..<endIndex])
            
            if currentPage == 1 {
                // First page: replace the list
                filteredCityList = newItems
            } else {
                // Subsequent pages: append to existing list
                filteredCityList.append(contentsOf: newItems)
            }
        } else {
            if currentPage == 1 {
                filteredCityList = []
            }
        }
        
        hasMorePages = endIndex < allFilteredCities.count
    }
    
    private func loadMoreCities() {
        guard hasMorePages && !isLoadingMore else { return }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.currentPage += 1
            self.updateFilteredList()
            self.isLoadingMore = false
        }
    }
    
    private func handleCitySelection(_ city: City) {
        print("Selected City: \(city.displayName)")
        // Navigate to city detail using coordinator
        Task { @MainActor in
            coordinator?.navigate(to: .cityDetail(city))            
        }
    }
}
