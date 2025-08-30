//
//  MainView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var coordinator = AppCoordinator()
    private let viewFactory = ViewFactory()
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            VStack(spacing: 20) {
                Text("UalaCities")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Welcome to the city search app")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    Button("Search Cities") {
                        coordinator.navigate(to: .citySearch)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("Settings") {
                        coordinator.navigate(to: .settings)
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("UalaCities")
            .navigationDestination(for: NavigationDestination.self) { destination in
                viewFactory.makeView(for: destination, coordinator: coordinator)
            }
        }
        .sheet(item: $coordinator.presentedSheet) { destination in
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
        .fullScreenCover(item: $coordinator.presentedFullScreenCover) { destination in
            NavigationView {
                viewFactory.makeFullScreenView(for: destination, coordinator: coordinator)
                    .navigationTitle("Search Cities")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                coordinator.dismissFullScreen()
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
