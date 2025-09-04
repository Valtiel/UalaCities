//
//  MainView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static var orientationTransitionDuration: Double { 0.3 }
    }
    
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var servicesManager: ServicesManager
    @StateObject private var citySearchDetailViewModel: CitySearchDetailViewModel
    @StateObject private var citySearchViewModel: CitySearchViewModel
    private let viewModelFactory: ViewModelFactory
    private let viewFactory: ViewFactory
    @State private var orientation = UIDeviceOrientation.portrait
    
    init() {
        // Create services manager first
        let servicesManager = ServicesManager()
        
        // Create view model factory with services manager
        self.viewModelFactory = ViewModelFactory(servicesManager: servicesManager)
        
        // Create view factory with view model factory
        self.viewFactory = ViewFactory(viewModelFactory: viewModelFactory)
        
        // Initialize state objects
        self._coordinator = StateObject(wrappedValue: AppCoordinator())
        self._servicesManager = StateObject(wrappedValue: servicesManager)
        
        // Create the CitySearchDetailViewModel once and persist it
        self._citySearchDetailViewModel = StateObject(wrappedValue: CitySearchDetailViewModel(
            searchService: servicesManager.searchService,
            cityDataService: servicesManager.cityDataService,
            favoritesService: servicesManager.favoritesService,
            coordinator: nil // Will be set in onAppear
        ))
        
        // Create the CitySearchViewModel once and persist it
        self._citySearchViewModel = StateObject(wrappedValue: CitySearchViewModel(
            searchService: servicesManager.searchService,
            cityDataService: servicesManager.cityDataService,
            favoritesService: servicesManager.favoritesService,
            coordinator: nil // Will be set in onAppear
        ))
    }
    
    var body: some View {
            mainContent
        .sheet(item: $coordinator.presentedSheet) { destination in
            sheetContent(for: destination)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        .onAppear {
            // Set the coordinator reference in the view models
            citySearchDetailViewModel.setCoordinator(coordinator)
            citySearchViewModel.setCoordinator(coordinator)
        }
    }
    
    // MARK: - Private Helper Views
    
    private var mainContent: some View {
        Group {
            if isPortrait {
                // Show CitySearchView in portrait mode using the persisted view model
                NavigationStack(path: $coordinator.navigationPath) {
                    CitySearchView(viewState: citySearchViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        ))
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            viewFactory.makeView(for: destination, coordinator: coordinator)
                        }
                }
            } else {
                // Show CitySearchDetailView in landscape mode using the persisted view model
                CitySearchDetailView(viewState: citySearchDetailViewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            }
        }
        .animation(.easeInOut(duration: Constants.orientationTransitionDuration), value: isPortrait)
    }
    
    private var isPortrait: Bool {
        orientation == .portrait || orientation == .portraitUpsideDown
    }
    
    private func sheetContent(for destination: SheetDestination) -> some View {
        NavigationView {
            viewFactory.makeSheetView(for: destination, coordinator: coordinator)
                .navigationTitle("Search Cities")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            coordinator.dismissSheet()
                        }
                    }
                }
        }
    }
}

#Preview("Portrait") {
    MainView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 15"))
        .previewInterfaceOrientation(.portrait)
}

#Preview("Landscape") {
    MainView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 15"))
        .previewInterfaceOrientation(.landscapeLeft)
}
