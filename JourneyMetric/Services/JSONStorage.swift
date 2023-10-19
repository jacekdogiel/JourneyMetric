//
//  JSONStorage.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//
import Foundation

final class JSONStorage: FileStorage {
    func save<T: Encodable>(object: T, to fileName: String) throws {
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL(for: fileName))
    }

    func load<T: Decodable>(from fileName: String) throws -> T {
        let data = try Data(contentsOf: fileURL(for: fileName))
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func fileURL(for fileName: String) -> URL {
        let dataDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dataDirectory.appendingPathComponent(fileName)
    }
}
