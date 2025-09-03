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
    
    @ObservedObject var viewState: ViewState
    @State private var animateEntrance = false
    @State private var mapScale: CGFloat = 0.8
    @State private var favoriteButtonScale: CGFloat = 1.0
    
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
            withAnimation(.easeOut(duration: 0.6)) {
                animateEntrance = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                mapScale = 1.0
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
                .scaleEffect(mapScale)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.1), value: animateEntrance)
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
        .animation(.easeOut(duration: 0.7).delay(0.3), value: animateEntrance)
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            favoriteButton
        }
        .padding(.bottom, 10)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 20)
        .animation(.easeOut(duration: 0.7).delay(0.4), value: animateEntrance)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoriteButtonScale = 0.8
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoriteButtonScale = 1.0
                }
            }
            
            viewState.perform(.toggleFavorite)
        }) {
            HStack {
                Image(systemName: viewState.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewState.isFavorite ? .red : .gray)
                    .scaleEffect(viewState.isFavorite ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewState.isFavorite)
                
                Text(viewState.isFavorite ? "Favorited" : "Add to Favorites")
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(viewState.isFavorite ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(favoriteButtonScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favoriteButtonScale)
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
        .animation(.easeOut(duration: 0.8).delay(0.5), value: animateEntrance)
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
        .animation(.easeOut(duration: 0.9).delay(0.6), value: animateEntrance)
    }
    
    private var loadingOverlay: some View {
        Group {
            if viewState.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .background(Color(.systemBackground).opacity(0.8))
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.3), value: viewState.isLoading)
            }
        }
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
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
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
