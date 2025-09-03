//
//  CityDetailView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI
import MapKit

protocol CityDetailViewState {
    var city: City { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    var isFavorite: Bool { get }
    func perform(_ action: CityDetailViewAction)
}

enum CityDetailViewAction {
    case toggleFavorite
}

struct CityDetailView<ViewState: ObservableObject & CityDetailViewState>: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static var mapEntranceDuration: Double { 0.3 }
        static var mapInitialScale: Double { 0.95 }
        static var mapInitialOpacity: Double { 0.8 }
        static var favoriteButtonPressDuration: Double { 0.1 }
        static var favoriteButtonPressDelay: Double { 0.1 }
        static var favoriteButtonScale: Double { 0.9 }
        static var loadingTransitionDuration: Double { 0.2 }
        static var mapFadeDuration: Double { 0.3 }
        static var headerEntranceDuration: Double { 0.5 }
        static var headerEntranceDelay: Double { 0.2 }
        static var infoSectionEntranceDuration: Double { 0.6 }
        static var infoSectionEntranceDelay: Double { 0.3 }
        static var coordinatesEntranceDuration: Double { 0.7 }
        static var coordinatesEntranceDelay: Double { 0.4 }
        static var actionButtonsEntranceDuration: Double { 0.5 }
        static var actionButtonsEntranceDelay: Double { 0.3 }
        static var infoRowAnimationDuration: Double { 0.5 }
    }
    
    @ObservedObject var viewState: ViewState
    @State private var mapAppeared = false
    @State private var favoriteButtonPressed = false
    @State private var animateEntrance = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                mapSection
                cityHeaderSection
                actionButtonsSection
                cityInformationSection
                Spacer(minLength: 20)
            }
            .padding()
        }
        .overlay(loadingOverlay)
        .alert("Error", isPresented: .constant(viewState.error != nil)) {
            Button("OK") { }
        } message: {
            if let error = viewState.error {
                Text(error.localizedDescription)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: Constants.mapEntranceDuration)) {
                mapAppeared = true
            }
            withAnimation(.easeOut(duration: Constants.headerEntranceDuration).delay(Constants.headerEntranceDelay)) {
                animateEntrance = true
            }
        }
    }
    
    // MARK: - Private Helper Views
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location on Map")
                .font(.headline)
                .fontWeight(.semibold)
                .opacity(animateEntrance ? 1 : 0)
                .offset(y: animateEntrance ? 0 : 20)
            
            CityMapView(coordinate: viewState.city.coord, cityName: viewState.city.name)
                .frame(height: 200)
                .cornerRadius(12)
                .scaleEffect(mapAppeared ? 1.0 : Constants.mapInitialScale)
                .opacity(mapAppeared ? 1.0 : Constants.mapInitialOpacity)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 30)
        .animation(.easeOut(duration: Constants.mapEntranceDuration).delay(Constants.headerEntranceDelay), value: animateEntrance)
    }
    
    private var cityHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewState.city.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .opacity(animateEntrance ? 1 : 0)
                .offset(x: animateEntrance ? 0 : -30)
            
            Text(viewState.city.country)
                .font(.title2)
                .foregroundColor(.secondary)
                .opacity(animateEntrance ? 1 : 0)
                .offset(x: animateEntrance ? 0 : -30)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
        .animation(.easeOut(duration: Constants.headerEntranceDuration).delay(Constants.headerEntranceDelay), value: animateEntrance)
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            favoriteButton
        }
        .padding(.bottom, 10)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 20)
        .animation(.easeOut(duration: Constants.actionButtonsEntranceDuration).delay(Constants.actionButtonsEntranceDelay), value: animateEntrance)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: Constants.favoriteButtonPressDuration)) {
                favoriteButtonPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.favoriteButtonPressDelay) {
                withAnimation(.easeInOut(duration: Constants.favoriteButtonPressDuration)) {
                    favoriteButtonPressed = false
                }
            }
            
            viewState.perform(.toggleFavorite)
        }) {
            HStack {
                Image(systemName: viewState.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewState.isFavorite ? .red : .gray)
                    .scaleEffect(viewState.isFavorite ? 1.1 : 1.0)
                    .scaleEffect(favoriteButtonPressed ? Constants.favoriteButtonScale : 1.0)
                
                Text(viewState.isFavorite ? "Favorited" : "Add to Favorites")
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(viewState.isFavorite ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cityInformationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("City Information")
                .font(.headline)
                .fontWeight(.semibold)
                .opacity(animateEntrance ? 1 : 0)
                .offset(y: animateEntrance ? 0 : 20)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(title: "Full Name", value: viewState.city.displayName)
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(x: animateEntrance ? 0 : -20)
                
                InfoRow(title: "Country", value: viewState.city.country)
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(x: animateEntrance ? 0 : -20)
                
                InfoRow(title: "City ID", value: "\(viewState.city.id)")
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(x: animateEntrance ? 0 : -20)
                
                coordinatesSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 40)
        .animation(.easeOut(duration: Constants.infoSectionEntranceDuration).delay(Constants.infoSectionEntranceDelay), value: animateEntrance)
    }
    
    private var coordinatesSection: some View {
        HStack(spacing: 20) {
            CoordinateView(
                title: "Latitude",
                value: String(format: "%.4f", viewState.city.coord.lat)
            )
            .opacity(animateEntrance ? 1 : 0)
            .offset(x: animateEntrance ? 0 : -30)
            
            CoordinateView(
                title: "Longitude",
                value: String(format: "%.4f", viewState.city.coord.lon)
            )
            .opacity(animateEntrance ? 1 : 0)
            .offset(x: animateEntrance ? 0 : 30)
        }
        .animation(.easeOut(duration: Constants.coordinatesEntranceDuration).delay(Constants.coordinatesEntranceDelay), value: animateEntrance)
    }
    
    private var loadingOverlay: some View {
        Group {
            if viewState.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .background(Color(.systemBackground).opacity(0.8))
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: Constants.loadingTransitionDuration), value: viewState.isLoading)
    }
}

// MARK: - Helper Views

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .animation(.easeOut(duration: 0.5), value: value)
    }
}

private struct CoordinateView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .animation(.easeOut(duration: 0.5), value: value)
    }
}

private struct CityMapView: View {
    let coordinate: City.Coordinate
    let cityName: String
    
    @State private var region: MKCoordinateRegion
    @State private var mapOpacity: Double = 0
    
    init(coordinate: City.Coordinate, cityName: String) {
        self.coordinate = coordinate
        self.cityName = cityName
        
        let mkCoordinate = CLLocationCoordinate2D(
            latitude: coordinate.lat,
            longitude: coordinate.lon
        )
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: mkCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        let mkCoordinate = CLLocationCoordinate2D(
            latitude: coordinate.lat,
            longitude: coordinate.lon
        )
        
        return Map(coordinateRegion: $region, annotationItems: [MapAnnotation(coordinate: mkCoordinate, cityName: cityName)]) { annotation in
            MapMarker(coordinate: annotation.coordinate, tint: .red)
        }
        .opacity(mapOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                mapOpacity = 1.0
            }
        }
    }
}

private struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let cityName: String
}

// MARK: - Preview

final class CityDetailViewStatePreview: CityDetailViewState, ObservableObject {
    @Published var city: City = City(
        id: 1,
        name: "Buenos Aires",
        country: "Argentina",
        coord: City.Coordinate(lon: -58.3816, lat: -34.6037)
    )
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var isFavorite: Bool = false
    
    func perform(_ action: CityDetailViewAction) {
        switch action {
        case .toggleFavorite:
            isFavorite.toggle()
        }
    }
}

#Preview {
    NavigationView {
        CityDetailView(viewState: CityDetailViewStatePreview())
    }
}
