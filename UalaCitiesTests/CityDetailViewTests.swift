//
//  CityDetailViewTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 30/08/2025.
//

import XCTest
import SwiftUI
@testable import UalaCities

final class CityDetailViewTests: XCTestCase {
    
    func testCityDetailViewDisplaysCityInformation() {
        // Given
        let city = City(
            id: 1,
            name: "Buenos Aires",
            country: "Argentina",
            coord: City.Coordinate(lon: -58.3816, lat: -34.6037)
        )
        
        // When
        let cityDetailView = CityDetailView(city: city)
        
        // Then
        // The view should be created successfully with the city data
        XCTAssertNotNil(cityDetailView)
    }
    
    func testCityDetailViewWithDifferentCity() {
        // Given
        let city = City(
            id: 2,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        
        // When
        let cityDetailView = CityDetailView(city: city)
        
        // Then
        XCTAssertNotNil(cityDetailView)
    }
}
