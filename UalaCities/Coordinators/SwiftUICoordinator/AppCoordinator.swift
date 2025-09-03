//
//  AppCoordinator.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

/// Main coordinator that manages navigation and view instantiation
final class AppCoordinator: Coordinator {
    
    // MARK: - Published Properties
    
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: SheetDestination?
    @Published var selectedCity: City?
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific destination
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    /// Present a sheet
    func presentSheet(_ destination: SheetDestination) {
        presentedSheet = destination
    }
    
    /// Dismiss the current sheet
    func dismissSheet() {
        presentedSheet = nil
    }
    
    /// Pop to root view
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    /// Pop the last view
    func pop() {
        guard navigationPath.count > 0 else {
            return
        }
        navigationPath.removeLast()
    }
    
    /// Set the selected city (used for state persistence across orientation changes)
    func setSelectedCity(_ city: City?) {
        if selectedCity != nil {
            pop()
        }
        selectedCity = city
        if let city {
            navigationPath.append(NavigationDestination.cityDetail(city))
        }
    }
}
