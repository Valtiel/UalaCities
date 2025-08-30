//
//  MockAppCoordinator.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

/// Mock coordinator for testing purposes
@MainActor
final class MockAppCoordinator: Coordinator {
    
    // MARK: - Published Properties
    
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: SheetDestination?
    @Published var presentedFullScreenCover: FullScreenDestination?
    
    // MARK: - Test Properties
    
    var navigatedDestinations: [NavigationDestination] = []
    var presentedSheets: [SheetDestination] = []
    var presentedFullScreens: [FullScreenDestination] = []
    var dismissedSheets = 0
    var dismissedFullScreens = 0
    var poppedCount = 0
    var poppedToRootCount = 0
    
    // MARK: - Navigation Methods
    
    func navigate(to destination: NavigationDestination) {
        navigatedDestinations.append(destination)
        navigationPath.append(destination)
    }
    
    func presentSheet(_ destination: SheetDestination) {
        presentedSheets.append(destination)
        presentedSheet = destination
    }
    
    func presentFullScreen(_ destination: FullScreenDestination) {
        presentedFullScreens.append(destination)
        presentedFullScreenCover = destination
    }
    
    func dismissSheet() {
        dismissedSheets += 1
        presentedSheet = nil
    }
    
    func dismissFullScreen() {
        dismissedFullScreens += 1
        presentedFullScreenCover = nil
    }
    
    func popToRoot() {
        poppedToRootCount += 1
        navigationPath.removeLast(navigationPath.count)
    }
    
    func pop() {
        poppedCount += 1
        navigationPath.removeLast()
    }
    
    // MARK: - View Creation Methods
    
    func makeCitySearchView() -> some View {
        Text("Mock City Search View")
            .navigationTitle("Mock Search")
    }
    
    func makeCityDetailView(for city: City) -> some View {
        VStack {
            Text("Mock City Detail")
                .font(.title)
            Text(city.displayName)
                .font(.headline)
        }
        .navigationTitle("Mock \(city.name)")
    }
    
    func makeSettingsView() -> some View {
        VStack {
            Text("Mock Settings")
                .font(.title)
            Text("Mock settings view for testing")
        }
        .navigationTitle("Mock Settings")
    }
    
    // MARK: - Test Helper Methods
    
    /// Reset all test counters
    func reset() {
        navigatedDestinations.removeAll()
        presentedSheets.removeAll()
        presentedFullScreens.removeAll()
        dismissedSheets = 0
        dismissedFullScreens = 0
        poppedCount = 0
        poppedToRootCount = 0
        navigationPath = NavigationPath()
        presentedSheet = nil
        presentedFullScreenCover = nil
    }
}
