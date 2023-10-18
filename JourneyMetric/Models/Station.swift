//
//  Station.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

struct Station: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    var latitude: Double?
    var longitude: Double?
    let hits: Int
}
