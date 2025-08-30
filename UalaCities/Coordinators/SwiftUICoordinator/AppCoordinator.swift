//
//  AppCoordinator.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

/// Main coordinator that manages navigation and view instantiation
@MainActor
final class AppCoordinator: Coordinator {
    
    // MARK: - Published Properties
    
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: SheetDestination?
    @Published var presentedFullScreenCover: FullScreenDestination?
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific destination
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    /// Present a sheet
    func presentSheet(_ destination: SheetDestination) {
        presentedSheet = destination
    }
    
    /// Present a full screen cover
    func presentFullScreen(_ destination: FullScreenDestination) {
        presentedFullScreenCover = destination
    }
    
    /// Dismiss the current sheet
    func dismissSheet() {
        presentedSheet = nil
    }
    
    /// Dismiss the current full screen cover
    func dismissFullScreen() {
        presentedFullScreenCover = nil
    }
    
    /// Pop to root view
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    /// Pop the last view
    func pop() {
        navigationPath.removeLast()
    }
}
