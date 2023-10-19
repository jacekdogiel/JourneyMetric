//
//  API.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 19/10/2023.
//

protocol API {
    func fetchStations() async throws -> [Station]
    func fetchKeywords() async throws -> [Keyword]
}
