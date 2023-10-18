//
//  UserDefaultsStorageImpl.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//
import Foundation

class UserDefaultsStorageImpl: UserDefaultsStorage {
    func save(object: Any, forKey key: String) {
        UserDefaults.standard.set(object, forKey: key)
    }

    func loadObject(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
}
