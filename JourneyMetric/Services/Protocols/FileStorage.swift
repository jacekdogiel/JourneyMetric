//
//  FileStorage.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

protocol FileStorage {
    func save<T: Encodable>(object: T, to fileName: String) throws
    func load<T: Decodable>(from fileName: String) throws -> T
}
