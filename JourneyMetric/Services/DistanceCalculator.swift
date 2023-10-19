//
//  DistanceCalculator.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 19/10/2023.
//
import CoreLocation

final class DistanceCalculator {
    func calculateDistance(startStation: Station, endStation: Station) -> String {
        let startLocation = CLLocation(latitude: startStation.latitude ?? 0.0,
                                       longitude: startStation.longitude ?? 0.0)
        let endLocation = CLLocation(latitude: endStation.latitude ?? 0.0,
                                     longitude: endStation.longitude ?? 0.0)
        
        let distanceInMeters = startLocation.distance(from: endLocation)
        let distanceInKilometers = distanceInMeters / 1000
        
        return String(format: "Odległość: %.2f km", distanceInKilometers)
    }
}
