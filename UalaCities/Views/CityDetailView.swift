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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Map Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location on Map")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    CityMapView(coordinate: viewState.city.coord, cityName: viewState.city.name)
                        .frame(height: 200)
                        .cornerRadius(12)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // City Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewState.city.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(viewState.city.country)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewState.perform(.toggleFavorite)
                    }) {
                        HStack {
                            Image(systemName: viewState.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(viewState.isFavorite ? .red : .gray)
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
                .padding(.bottom, 10)
                
                // City Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("City Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(title: "Full Name", value: viewState.city.displayName)
                        InfoRow(title: "Country", value: viewState.city.country)
                        InfoRow(title: "City ID", value: "\(viewState.city.id)")
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Latitude")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(String(format: "%.4f", viewState.city.coord.lat))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Longitude")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(String(format: "%.4f", viewState.city.coord.lon))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .overlay(
            Group {
                if viewState.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        )
        .alert("Error", isPresented: .constant(viewState.error != nil)) {
            Button("OK") { }
        } message: {
            if let error = viewState.error {
                Text(error.localizedDescription)
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
    }
}

private struct CityMapView: View {
    let coordinate: City.Coordinate
    let cityName: String
    
    @State private var region: MKCoordinateRegion
    
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
