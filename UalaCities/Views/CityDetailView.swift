//
//  CityDetailView.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import SwiftUI

struct CityDetailView: View {
    let city: City
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // City Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(city.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(city.country)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                
                // Coordinates Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Latitude")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.4f", city.coord.lat))
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Longitude")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.4f", city.coord.lon))
                                .font(.body)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // City Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("City Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(title: "Full Name", value: city.displayName)
                        InfoRow(title: "Country", value: city.country)
                        InfoRow(title: "City ID", value: "\(city.id)")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.large)
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

// MARK: - Preview

#Preview {
    NavigationView {
        CityDetailView(city: City(
            id: 1,
            name: "Buenos Aires",
            country: "Argentina",
            coord: City.Coordinate(lon: -58.3816, lat: -34.6037)
        ))
    }
}
