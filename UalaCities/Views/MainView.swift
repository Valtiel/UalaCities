//
//  MainView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var servicesManager: ServicesManager
    private let viewModelFactory: ViewModelFactory
    private let viewFactory: ViewFactory
    
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
        NavigationStack(path: $coordinator.navigationPath) {
            mainContent
                .navigationDestination(for: NavigationDestination.self) { destination in
                    viewFactory.makeView(for: destination, coordinator: coordinator)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { destination in
            sheetContent(for: destination)
        }
    }
    
    // MARK: - Private Helper Views
    
    private var mainContent: some View {
        viewFactory.makeView(for: .citySearch, coordinator: coordinator)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("UalaCities")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Welcome to the city search app")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Button("Search Cities") {
                coordinator.navigate(to: .citySearch)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
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

#Preview {
    MainView()
}
