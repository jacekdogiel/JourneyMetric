//
//  APIClient.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//
import Foundation

final class APIClient: API {
    private let baseURL: String = "https://koleo.pl/api/v2/main/"

    func fetchStations() async throws -> [Station] {
        guard let url = URL(string: "\(baseURL)stations") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        return try await fetchData(from: url, decodingType: [Station].self)
    }

    func fetchKeywords() async throws -> [Keyword] {
        guard let url = URL(string: "\(baseURL)station_keywords") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        return try await fetchData(from: url, decodingType: [Keyword].self)
    }

    private func fetchData<T: Decodable>(from url: URL, decodingType: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        addCommonHeaders(to: &request)

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    private func addCommonHeaders(to request: inout URLRequest) {
        request.addValue("1", forHTTPHeaderField: "X-KOLEO-Version")
        request.addValue("iOS-100", forHTTPHeaderField: "X-KOLEO-Client")
    }
}
