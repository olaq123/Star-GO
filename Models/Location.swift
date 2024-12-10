import Foundation
import CoreLocation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    // Convert real-world kilometers to light years in game
    static func kmToLightYears(_ kilometers: Double) -> Double {
        return kilometers / 10.0 // 10km = 1 light year
    }
    
    // Convert light years to kilometers
    static func lightYearsToKm(_ lightYears: Double) -> Double {
        return lightYears * 10.0
    }
    
    // Calculate real-world distance in kilometers
    func distance(to other: Location) -> Double {
        let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
        let coordinate2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        
        return coordinate1.distance(from: coordinate2) / 1000.0 // Convert meters to kilometers
    }
    
    // Calculate distance in light years
    func lightYearsTo(_ other: Location) -> Double {
        return Location.kmToLightYears(distance(to: other))
    }
    
    // Generate a random location within a radius (in kilometers)
    static func random(around center: Location, radiusKm: Double) -> Location {
        // Earth's radius in kilometers
        let earthRadius = 6371.0
        
        // Convert radius to radians
        let radiusRadians = radiusKm / earthRadius
        
        // Random angle
        let randomAngle = Double.random(in: 0...(2 * .pi))
        
        // Random radius (using square root for even distribution)
        let randomRadius = radiusRadians * sqrt(Double.random(in: 0...1))
        
        // Calculate new coordinates
        let centerLatRadians = center.latitude * .pi / 180
        let centerLonRadians = center.longitude * .pi / 180
        
        let newLatRadians = asin(
            sin(centerLatRadians) * cos(randomRadius) +
            cos(centerLatRadians) * sin(randomRadius) * cos(randomAngle)
        )
        
        let newLonRadians = centerLonRadians + atan2(
            sin(randomAngle) * sin(randomRadius) * cos(centerLatRadians),
            cos(randomRadius) - sin(centerLatRadians) * sin(newLatRadians)
        )
        
        return Location(
            coordinate: CLLocationCoordinate2D(
                latitude: newLatRadians * 180 / .pi,
                longitude: newLonRadians * 180 / .pi
            )
        )
    }
} 