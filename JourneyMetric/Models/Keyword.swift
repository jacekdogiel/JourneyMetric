//
//  Keyword.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

struct Keyword: Codable {
    let id: Int
    let keyword: String
    let stationID: Int

    enum CodingKeys: String, CodingKey {
        case id, keyword, stationID = "station_id"
    }
}
