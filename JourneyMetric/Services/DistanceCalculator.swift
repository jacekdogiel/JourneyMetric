//
//  DistanceCalculator.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 19/10/2023.
//
import CoreLocation

final class DistanceCalculator {
    func calculateDistance(startStation: Station, endStation: Station) -> String {
        guard let startLatitude = startStation.latitude,
              let startLongitude = startStation.longitude,
              let endLatitude = endStation.latitude,
              let endLongitude = endStation.longitude else {
            return "Nie można zmierzyć odległości."
        }

        let startLocation = CLLocation(latitude: startLatitude, longitude: startLongitude)
        let endLocation = CLLocation(latitude: endLatitude, longitude: endLongitude)

        let distanceInMeters = startLocation.distance(from: endLocation)
        let distanceInKilometers = distanceInMeters / 1000

        return String(format: "Odległość: %.2f km", distanceInKilometers)
    }
}
