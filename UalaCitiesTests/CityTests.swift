//
//  CityTests.swift
//  UalaCitiesTests
//
//  Created by César Rosales on 29/08/2025.
//

import Testing
@testable import UalaCities
import Foundation

struct CityTests {

    @Test func testCityInitialization() async throws {
        let coordinate = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let city = City(id: 1, name: "Buenos Aires", country: "Argentina", coord: coordinate)
        
        #expect(city.id == 1)
        #expect(city.name == "Buenos Aires")
        #expect(city.country == "Argentina")
        #expect(city.coord.lon == -58.3816)
        #expect(city.coord.lat == -34.6037)
    }
    
    @Test func testCityDisplayName() async throws {
        let coordinate = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let city = City(id: 1, name: "Buenos Aires", country: "Argentina", coord: coordinate)
        
        #expect(city.displayName == "Buenos Aires, Argentina")
    }
    
    @Test func testCityEquatable() async throws {
        let coordinate1 = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let city1 = City(id: 1, name: "Buenos Aires", country: "Argentina", coord: coordinate1)
        
        let coordinate2 = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let city2 = City(id: 1, name: "Buenos Aires", country: "Argentina", coord: coordinate2)
        
        let coordinate3 = City.Coordinate(lon: -74.0060, lat: 40.7128)
        let city3 = City(id: 2, name: "New York", country: "USA", coord: coordinate3)
        
        #expect(city1 == city2)
        #expect(city1 != city3)
    }
    
    @Test func testCityHashable() async throws {
        let coordinate = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let city = City(id: 1, name: "Buenos Aires", country: "Argentina", coord: coordinate)
        
        var citySet = Set<City>()
        citySet.insert(city)
        
        #expect(citySet.count == 1)
        #expect(citySet.contains(city))
    }
    
    @Test func testCityCodableEncoding() async throws {
        let coordinate = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let city = City(id: 1, name: "Buenos Aires", country: "Argentina", coord: coordinate)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(city)
        let jsonString = String(data: data, encoding: .utf8)!
        
        #expect(jsonString.contains("\"id\":1"))
        #expect(jsonString.contains("\"name\":\"Buenos Aires\""))
        #expect(jsonString.contains("\"country\":\"Argentina\""))
        #expect(jsonString.contains("\"coord\""))
        #expect(jsonString.contains("\"lon\":-58.3816"))
        #expect(jsonString.contains("\"lat\":-34.6037"))
    }
    
    @Test func testCityCodableDecoding() async throws {
        let jsonString = """
        {
            "id": 1,
            "name": "Buenos Aires",
            "country": "Argentina",
            "coord": {
                "lon": -58.3816,
                "lat": -34.6037
            }
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let city = try decoder.decode(City.self, from: data)
        
        #expect(city.id == 1)
        #expect(city.name == "Buenos Aires")
        #expect(city.country == "Argentina")
        #expect(city.coord.lon == -58.3816)
        #expect(city.coord.lat == -34.6037)
        #expect(city.displayName == "Buenos Aires, Argentina")
    }
    
    @Test func testCityCodableRoundTrip() async throws {
        let originalCoordinate = City.Coordinate(lon: -74.0060, lat: 40.7128)
        let originalCity = City(id: 2, name: "New York", country: "USA", coord: originalCoordinate)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCity)
        
        let decoder = JSONDecoder()
        let decodedCity = try decoder.decode(City.self, from: data)
        
        #expect(originalCity == decodedCity)
        #expect(originalCity.displayName == decodedCity.displayName)
    }
    
    @Test func testCityCodableWithMultipleCities() async throws {
        let cities = [
            City(id: 1, name: "Buenos Aires", country: "Argentina", coord: City.Coordinate(lon: -58.3816, lat: -34.6037)),
            City(id: 2, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1276, lat: 51.5074))
        ]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(cities)
        
        let decoder = JSONDecoder()
        let decodedCities = try decoder.decode([City].self, from: data)
        
        #expect(decodedCities.count == 3)
        #expect(decodedCities[0].name == "Buenos Aires")
        #expect(decodedCities[1].name == "New York")
        #expect(decodedCities[2].name == "London")
        #expect(decodedCities[0].displayName == "Buenos Aires, Argentina")
        #expect(decodedCities[1].displayName == "New York, USA")
        #expect(decodedCities[2].displayName == "London, UK")
    }
    
    @Test func testCityCodableWithSpecialCharacters() async throws {
        let jsonString = """
        {
            "id": 4,
            "name": "São Paulo",
            "country": "Brasil",
            "coord": {
                "lon": -46.6333,
                "lat": -23.5505
            }
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let city = try decoder.decode(City.self, from: data)
        
        #expect(city.id == 4)
        #expect(city.name == "São Paulo")
        #expect(city.country == "Brasil")
        #expect(city.coord.lon == -46.6333)
        #expect(city.coord.lat == -23.5505)
        #expect(city.displayName == "São Paulo, Brasil")
    }
    
    @Test func testCoordinateEquatable() async throws {
        let coord1 = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let coord2 = City.Coordinate(lon: -58.3816, lat: -34.6037)
        let coord3 = City.Coordinate(lon: -74.0060, lat: 40.7128)
        
        #expect(coord1 == coord2)
        #expect(coord1 != coord3)
    }
    
    @Test func testCoordinateHashable() async throws {
        let coordinate = City.Coordinate(lon: -58.3816, lat: -34.6037)
        
        var coordSet = Set<City.Coordinate>()
        coordSet.insert(coordinate)
        
        #expect(coordSet.count == 1)
        #expect(coordSet.contains(coordinate))
    }
    
    @Test func testCoordinateCodable() async throws {
        let originalCoordinate = City.Coordinate(lon: -58.3816, lat: -34.6037)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCoordinate)
        
        let decoder = JSONDecoder()
        let decodedCoordinate = try decoder.decode(City.Coordinate.self, from: data)
        
        #expect(originalCoordinate == decodedCoordinate)
        #expect(originalCoordinate.lon == decodedCoordinate.lon)
        #expect(originalCoordinate.lat == decodedCoordinate.lat)
    }
}
