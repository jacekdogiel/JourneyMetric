//
//  JSONStorageTests.swift
//  JourneyMetricTests
//
//  Created by Jacek Dogiel on 19/10/2023.
//
import XCTest
@testable import JourneyMetric

final class JSONStorageTests: XCTestCase {

    func testSaveAndLoadObject() throws {
        // Arrange
        let storage = JSONStorage()
        let fileName = "testFile.json"
        let originalObject = TestData(id: 1, name: "TestObject")

        // Act
        try storage.save(object: originalObject, to: fileName)
        let loadedObject: TestData = try storage.load(from: fileName)

        // Assert
        XCTAssertEqual(originalObject, loadedObject)
    }

    func testLoadFromNonexistentFile() {
        // Arrange
        let storage = JSONStorage()
        let fileName = "nonexistentFile.json"

        // Act & Assert
        XCTAssertThrowsError(try storage.load(from: fileName) as TestData) { error in
            XCTAssertEqual((error as NSError).code, 260) // File not found error code
        }
    }

    func testLoadInvalidJSON() throws {
        // Arrange
        let storage = JSONStorage()
        let fileName = "invalidJSONFile.json"
        let invalidData = "invalidJSON".data(using: .utf8)!
        try storage.save(object: invalidData, to: fileName)
        
        // Act & Assert
        XCTAssertThrowsError(try storage.load(from: fileName) as TestData) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testSaveFailure() {
        // Arrange
        let storage = JSONStorage()
        let invalidURL = URL(fileURLWithPath: "/invalid/path")
        let invalidObject = TestData(id: 1, name: "InvalidObject")

        // Act & Assert
        XCTAssertThrowsError(try storage.save(object: invalidObject, to: invalidURL.path))
    }
    
    struct TestData: Codable, Equatable {
        let id: Int
        let name: String
    }
}
