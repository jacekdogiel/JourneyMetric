//
//  UserDefaultsStorage.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

protocol UserDefaultsStorage {
    func save(object: Any, forKey key: String)
    func loadObject(forKey key: String) -> Any?
}
