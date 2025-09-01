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
    case citySearchDetail
}

/// Sheet presentation destinations
enum SheetDestination: Identifiable {
    case favorites
    
    var id: String {
        switch self {
        case .favorites:
            return "favorites"
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
    
    /// Dismiss the current sheet
    func dismissSheet()
    
    /// Pop to root view
    func popToRoot()
    
    /// Pop the last view
    func pop()
}
