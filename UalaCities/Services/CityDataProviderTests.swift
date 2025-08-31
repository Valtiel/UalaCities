//
//  CityDataProviderTests.swift
//  UalaCities
//
//  Created by César Rosales on 30/08/2025.
//

import Foundation

/// Simple test runner for CityDataProvider functionality
@MainActor
class CityDataProviderTests {
    
    static func runLocalFileTest() async {
        print("🧪 Starting LocalFileCityDataProvider test...")
        
        let provider = LocalFileCityDataProvider(fileName: "cities")
        
        var progressValues: [Double] = []
        var loadedCities: [City] = []
        var receivedError: Error?
        
        do {
            let cities = try await provider.fetchCities { progress in
                progressValues.append(progress)
                print("📊 Progress: \(Int(progress * 100))%")
            }
            
            loadedCities = cities
            
            print("✅ Successfully loaded \(cities.count) cities")
            
            // Show sample cities
            let sampleCities = Array(cities.prefix(5))
            print("📋 Sample cities:")
            for city in sampleCities {
                print("   - \(city.displayName) (ID: \(city.id))")
            }
            
            // Verify data structure
            if let firstCity = cities.first {
                print("🔍 Data structure verification:")
                print("   - ID: \(firstCity.id)")
                print("   - Name: \(firstCity.name)")
                print("   - Country: \(firstCity.country)")
                print("   - Coordinates: (\(firstCity.coord.lat), \(firstCity.coord.lon))")
                print("   - Display Name: \(firstCity.displayName)")
            }
            
            // Test search functionality
            let searchResults = cities.filter { city in
                city.name.lowercased().contains("new") ||
                city.country.lowercased().contains("united")
            }
            
            print("🔍 Search test results:")
            print("   - Cities with 'new' in name or 'united' in country: \(searchResults.count)")
            
        } catch {
            receivedError = error
            print("❌ Error loading cities: \(error.localizedDescription)")
        }
        
        // Summary
        print("\n📈 Test Summary:")
        print("   - Progress updates received: \(progressValues.count)")
        print("   - Final progress: \(progressValues.last ?? 0.0)")
        print("   - Cities loaded: \(loadedCities.count)")
        print("   - Error occurred: \(receivedError != nil)")
        
        if receivedError == nil && loadedCities.count > 0 {
            print("🎉 Test PASSED!")
        } else {
            print("💥 Test FAILED!")
        }
    }
    
    static func runMockTest() async {
        print("🧪 Starting MockCityDataProvider test...")
        
        let mockCities = [
            City(id: 1, name: "Test City", country: "Test Country", coord: City.Coordinate(lon: 0, lat: 0)),
            City(id: 2, name: "Another City", country: "Another Country", coord: City.Coordinate(lon: 1, lat: 1))
        ]
        
        let provider = MockCityDataProvider(cities: mockCities, delay: 0.5)
        
        var progressValues: [Double] = []
        
        do {
            let cities = try await provider.fetchCities { progress in
                progressValues.append(progress)
                print("📊 Progress: \(Int(progress * 100))%")
            }
            
            print("✅ Successfully loaded \(cities.count) mock cities")
            print("📋 Mock cities:")
            for city in cities {
                print("   - \(city.displayName)")
            }
            
            print("🎉 Mock test PASSED!")
            
        } catch {
            print("❌ Error in mock test: \(error.localizedDescription)")
            print("💥 Mock test FAILED!")
        }
    }
    
    static func runNetworkTest() async {
        print("🧪 Starting NetworkCityDataProvider test...")
        
        // Note: This would need a real URL to test
        // For now, we'll just test the structure
        guard let url = URL(string: "https://example.com/cities.json") else {
            print("❌ Invalid URL")
            return
        }
        
        let provider = NetworkCityDataProvider(url: url)
        
        do {
            let cities = try await provider.fetchCities { progress in
                print("📊 Progress: \(Int(progress * 100))%")
            }
            
            print("✅ Successfully loaded \(cities.count) cities from network")
            print("🎉 Network test PASSED!")
            
        } catch {
            print("❌ Error in network test: \(error.localizedDescription)")
            print("💥 Network test FAILED!")
        }
    }
}
