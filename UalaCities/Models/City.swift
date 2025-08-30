import Foundation
import CoreLocation

struct City: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let country: String
    let coord: Coordinate
    
    struct Coordinate: Codable, Hashable {
        let lon: Double
        let lat: Double
    }
    
    var displayName: String {
        "\(name), \(country)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case country
        case coord
    }
}
