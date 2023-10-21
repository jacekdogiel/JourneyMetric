//
//  DiskCacheTests.swift
//  JourneyMetricTests
//
//  Created by Jacek Dogiel on 21/10/2023.
//

import XCTest
@testable import JourneyMetric

class DiskCacheTests: XCTestCase {
    var diskCache: DiskCache<String>!

    override func setUpWithError() throws {
        let filename = "TestDiskCache"
        let expirationInterval: TimeInterval = 3600
        diskCache = DiskCache<String>(filename: filename, expirationInterval: expirationInterval)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        let filename = "TestDiskCache"
        let saveLocationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(filename).cache")

        try? FileManager.default.removeItem(at: saveLocationURL)
    }

    func testSaveAndLoadNonEmptyCache() async throws {
        // Arrange
        await diskCache.setValue("Value1", forKey: "Key1")
        await diskCache.setValue("Value2", forKey: "Key2")

        // Act
        try await diskCache.saveToDisk()
        try await diskCache.loadFromDisk()

        // Assert
        let value1 = await diskCache.value(forKey: "Key1")
        let value2 = await diskCache.value(forKey: "Key2")
        
        XCTAssertEqual(value1, "Value1")
        XCTAssertEqual(value2, "Value2")
    }
    
    func testSetNilValue() async throws {
        // Arrange
        await diskCache.setValue("Value1", forKey: "Key1")
        await diskCache.setValue(nil, forKey: "Key1")
        // Act
        try await diskCache.saveToDisk()
        try await diskCache.loadFromDisk()

        // Assert
        let value1 = await diskCache.value(forKey: "Key1")
        
        XCTAssertNil(value1)
    }

    func testRemoveValue() async throws {
        // Arrange
        await diskCache.setValue("Value1", forKey: "Key1")

        // Act
        await diskCache.removeValue(forKey: "Key1")

        // Assert
        let valueFromCache = await diskCache.value(forKey: "Key1")
        XCTAssertNil(valueFromCache)
    }

    func testRemoveAllValues() async throws {
        // Arrange
        await diskCache.setValue("Value1", forKey: "Key1")
        await diskCache.setValue("Value2", forKey: "Key2")

        // Act
        await diskCache.removeAllValues()

        // Assert
        let value1 = await diskCache.value(forKey: "Key1")
        let value2 = await diskCache.value(forKey: "Key2")
        
        XCTAssertNil(value1)
        XCTAssertNil(value2)
    }
    
    func testLoadValueFromExpiredCache() async throws {
        // Arrange
        let filename = "TestDiskCache"
        let expirationInterval: TimeInterval = 0
        diskCache = DiskCache<String>(filename: filename, expirationInterval: expirationInterval)
        
        await diskCache.setValue("Value1", forKey: "Key1")
        await diskCache.setValue("Value2", forKey: "Key2")

        // Act
        try await diskCache.saveToDisk()
        try await diskCache.loadFromDisk()

        // Assert
        let value1 = await diskCache.value(forKey: "Key1")
        let value2 = await diskCache.value(forKey: "Key2")
        
        XCTAssertNil(value1)
        XCTAssertNil(value2)
    }
}

