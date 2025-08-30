//
//  UalaCitiesApp.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

@main
struct UalaCitiesApp: App {
    
    init() {
        // Run data provider tests on app startup (for debugging)
        #if DEBUG
        Task {
            await CityDataProviderTests.runLocalFileTest()
            print("\n" + String(repeating: "-", count: 50) + "\n")
            await CityDataProviderTests.runMockTest()
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
