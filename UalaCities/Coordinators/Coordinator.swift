//
//  Coordinator.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation

// MARK: - Navigation Destination Types

/// Navigation destinations for the app
enum NavigationDestination: Hashable {
    case citySearch
    case cityDetail(City)
    case settings
}

/// Sheet presentation destinations
enum SheetDestination: Identifiable {
    case citySearch
    case cityDetail(City)
    
    var id: String {
        switch self {
        case .citySearch:
            return "citySearch"
        case .cityDetail(let city):
            return "cityDetail-\(city.id)"
        }
    }
}

/// Full screen presentation destinations
enum FullScreenDestination: Identifiable {
    case citySearch
    
    var id: String {
        switch self {
        case .citySearch:
            return "citySearch"
        }
    }
}

/// Protocol defining the interface for app coordination and navigation
@MainActor
protocol Coordinator: ObservableObject {
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific destination
    func navigate(to destination: NavigationDestination)
    
    /// Present a sheet
    func presentSheet(_ destination: SheetDestination)
    
    /// Present a full screen cover
    func presentFullScreen(_ destination: FullScreenDestination)
    
    /// Dismiss the current sheet
    func dismissSheet()
    
    /// Dismiss the current full screen cover
    func dismissFullScreen()
    
    /// Pop to root view
    func popToRoot()
    
    /// Pop the last view
    func pop()
}
