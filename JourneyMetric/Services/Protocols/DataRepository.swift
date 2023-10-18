//
//  DataRepository.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

protocol DataRepository {
    func getStations() async throws -> [Station]
    func getKeywords() async throws -> [Keyword]
}
