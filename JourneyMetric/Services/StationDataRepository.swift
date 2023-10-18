//
//  StationDataRepository.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

import Foundation

class StationDataRepository: DataRepository {
    private let apiClient: APIClient
    private let stationsFileName = "stations.json"
    private let keywordsFileName = "keywords.json"
    private let lastFetchDateKey = "lastFetchDateKey"

    private let jsonStorage: FileStorage
    private let userDefaultsStorage: UserDefaultsStorage

    init(apiClient: APIClient = APIClient(),
         jsonStorage: FileStorage = JSONStorage(),
         userDefaultsStorage: UserDefaultsStorage = UserDefaultsStorageImpl()) {
        self.apiClient = apiClient
        self.jsonStorage = jsonStorage
        self.userDefaultsStorage = userDefaultsStorage
    }

    func getStations() async throws -> [Station] {
        if try await shouldFetchData() {
            try await fetchData()
        }
        return try loadStationsFromFile()
    }

    func getKeywords() async throws -> [Keyword] {
        if try await shouldFetchData() {
            try await fetchData()
        }
        return try loadKeywordsFromFile()
    }

    private func shouldFetchData() async throws -> Bool {
        guard let lastFetchDate = try? loadLastFetchDate() else {
            return true
        }

        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(lastFetchDate)
        return timeInterval > 24 * 60 * 60
    }

    private func fetchData() async throws {
        let fetchedStations = try await apiClient.fetchStations()
        let fetchedKeywords = try await apiClient.fetchKeywords()

        try saveStationsToFile(stations: fetchedStations)
        try saveKeywordsToFile(keywords: fetchedKeywords)
        try saveLastFetchDate()
    }

    private func saveStationsToFile(stations: [Station]) throws {
        try jsonStorage.save(object: stations, to: stationsFileName)
    }

    private func loadStationsFromFile() throws -> [Station] {
        return try jsonStorage.load(from: stationsFileName)
    }

    private func saveKeywordsToFile(keywords: [Keyword]) throws {
        try jsonStorage.save(object: keywords, to: keywordsFileName)
    }

    private func loadKeywordsFromFile() throws -> [Keyword] {
        return try jsonStorage.load(from: keywordsFileName)
    }

    private func saveLastFetchDate() throws {
        let currentDate = Date()
        userDefaultsStorage.save(object: currentDate, forKey: lastFetchDateKey)
    }

    private func loadLastFetchDate() throws -> Date {
        guard let lastFetchDate = userDefaultsStorage.loadObject(forKey: lastFetchDateKey) as? Date else {
            throw NSError(domain: "Invalid Date", code: 0, userInfo: nil)
        }
        return lastFetchDate
    }
}
