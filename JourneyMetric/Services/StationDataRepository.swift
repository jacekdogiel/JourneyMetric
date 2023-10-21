//
//  StationDataRepository.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

import Foundation

actor StationDataRepository<StationCache: DiskCacheProtocol, KeywordCache: DiskCacheProtocol>: DataRepository where StationCache.V == [Station], KeywordCache.V == [Keyword] {
    private let apiClient: API
    private let stationsCache: StationCache
    private let keywordsCache: KeywordCache

    init(apiClient: API = APIClient(),
         stationsCache: StationCache = DiskCache(filename: "stations", expirationInterval: 24 * 60 * 60),
         keywordsCache: KeywordCache = DiskCache(filename: "keywords", expirationInterval: 24 * 60 * 60)) {
        self.apiClient = apiClient
        self.stationsCache = stationsCache
        self.keywordsCache = keywordsCache
    }

    func getStations() async throws -> [Station] {
        if await shouldFetchStations() {
            try await fetchStations()
        }
        return try await loadStationsFromCache()
    }

    func getKeywords() async throws -> [Keyword] {
        if await shouldFetchKeywords() {
            try await fetchKeywords()
        }
        return try await loadKeywordsFromCache()
    }

    private func shouldFetchStations() async -> Bool {
        try? await stationsCache.loadFromDisk()
        return await stationsCache.value(forKey: "stations") == nil
    }

    private func shouldFetchKeywords() async -> Bool {
        try? await keywordsCache.loadFromDisk()
        return await keywordsCache.value(forKey: "keywords") == nil
    }

    private func fetchStations() async throws {
        let fetchedStations = try await apiClient.fetchStations()
        try await saveStationsToCache(stations: fetchedStations)
    }

    private func fetchKeywords() async throws {
        let fetchedKeywords = try await apiClient.fetchKeywords()
        try await saveKeywordsToCache(keywords: fetchedKeywords)
    }

    private func saveStationsToCache(stations: [Station]) async throws {
        await stationsCache.setValue(stations, forKey: "stations")
        try await stationsCache.saveToDisk()
    }

    private func loadStationsFromCache() async throws -> [Station] {
        try await stationsCache.loadFromDisk()
        return await stationsCache.value(forKey: "stations") ?? []
    }

    private func saveKeywordsToCache(keywords: [Keyword]) async throws {
        await keywordsCache.setValue(keywords, forKey: "keywords")
        try await keywordsCache.saveToDisk()
    }

    private func loadKeywordsFromCache() async throws -> [Keyword] {
        try await keywordsCache.loadFromDisk()
        return await keywordsCache.value(forKey: "keywords") ?? []
    }
}

