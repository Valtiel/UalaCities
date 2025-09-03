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
    }
    
    var body: some View {
            mainContent
        .sheet(item: $coordinator.presentedSheet) { destination in
            sheetContent(for: destination)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
    }
    
    // MARK: - Private Helper Views
    
    private var mainContent: some View {
        Group {
            if isPortrait {
                // Show CitySearchView in portrait mode
                NavigationStack(path: $coordinator.navigationPath) {
                    let viewModel = viewModelFactory.makeCitySearchViewModel(coordinator: coordinator)
                    CitySearchView(viewState: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        ))
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            viewFactory.makeView(for: destination, coordinator: coordinator)
                        }
                }
            } else {
                // Show CitySearchDetailView in landscape mode
                let viewModel = viewModelFactory.makeCitySearchDetailViewModel(coordinator: coordinator)
                CitySearchDetailView(viewState: viewModel)
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
