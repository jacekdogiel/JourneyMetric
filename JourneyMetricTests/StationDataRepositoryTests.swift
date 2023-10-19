//
//  StationDataRepositoryTests.swift
//  JourneyMetricTests
//
//  Created by Jacek Dogiel on 19/10/2023.
//
import XCTest
@testable import JourneyMetric

final class StationDataRepositoryTests: XCTestCase {
    var sut: StationDataRepository!
    var mockUserDefaultsStorage: MockUserDefaultsStorage!
    var mockJSONStorage: MockJSONStorage!
    var mockAPIClient: MockAPIClient!

    override func setUpWithError() throws {
        mockUserDefaultsStorage = MockUserDefaultsStorage()
        mockJSONStorage = MockJSONStorage()
        mockAPIClient = MockAPIClient()
        sut = StationDataRepository(apiClient: mockAPIClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockUserDefaultsStorage = nil
        mockJSONStorage = nil
        mockAPIClient = nil
    }

    func testShouldFetchDataWhenLastFetchDateIsNil() async throws {
        // Arrange
        let mockApiClient = MockAPIClient()
        mockApiClient.stationsToReturn = [Station(id: 1, name: "Station1", hits: 5)]
        mockApiClient.keywordsToReturn = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        
        mockUserDefaultsStorage.loadedObject = nil
        
        let stationsToLoad = [Station(id: 1, name: "Station1", hits: 5)]
        mockJSONStorage.loadedStations = stationsToLoad
        
        let sut = StationDataRepository(apiClient: mockApiClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)

        // Act
        let stations = try await sut.getStations()

        // Assert
        XCTAssertEqual(stations.count, 1)
    }

    func testFetchStations() async throws {
        // Arrange
        let mockApiClient = MockAPIClient()
        mockApiClient.stationsToReturn = [Station(id: 1, name: "Station1", hits: 5)]
        mockApiClient.keywordsToReturn = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        
        let currentDate = Date()
        let expiredDate = currentDate.addingTimeInterval(-25 * 60 * 60)
        mockUserDefaultsStorage.loadedObject = expiredDate
        
        let stationsToLoad = [Station(id: 1, name: "Station1", hits: 5)]
        mockJSONStorage.loadedStations = stationsToLoad
        
        let sut = StationDataRepository(apiClient: mockApiClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)

        // Act
        let stations = try await sut.getStations()

        // Assert
        XCTAssertEqual(stations.count, 1)
    }
    
    func testFetchKeywords() async throws {
        // Arrange
        let mockApiClient = MockAPIClient()
        mockApiClient.stationsToReturn = [Station(id: 1, name: "Station1", hits: 5)]
        mockApiClient.keywordsToReturn = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        
        let currentDate = Date()
        let expiredDate = currentDate.addingTimeInterval(-25 * 60 * 60)
        mockUserDefaultsStorage.loadedObject = expiredDate
        
        let keywordsToLoad = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        mockJSONStorage.loadedKeywords = keywordsToLoad
        
        let sut = StationDataRepository(apiClient: mockApiClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)

        // Act
        let keywords = try await sut.getKeywords()

        // Assert
        XCTAssertEqual(keywords.count, 1)
    }

    func testFetchDataFailure() async throws {
        // Arrange
        let mockApiClient = MockAPIClient()
        mockApiClient.error = NSError(domain: "TestErrorDomain", code: 42, userInfo: nil)
        let sut = StationDataRepository(apiClient: mockApiClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)

        // Act & Assert
        do {
            _ = try await sut.getKeywords()
            XCTFail("Expected an error but none was thrown.")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testSaveStationsToFile() async throws {
        // Arrange
        let stationsToSave = [Station(id: 1, name: "Station1", hits: 5)]
        
        let mockApiClient = MockAPIClient()
        mockApiClient.stationsToReturn = stationsToSave
        
        let currentDate = Date()
        let expiredDate = currentDate.addingTimeInterval(-25 * 60 * 60)
        mockUserDefaultsStorage.loadedObject = expiredDate
        
        mockJSONStorage.loadedStations = stationsToSave
        
        let sut = StationDataRepository(apiClient: mockApiClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)
        
        // Act
        _ = try await sut.getStations()

        // Assert
        XCTAssertEqual(mockJSONStorage.savedStations, stationsToSave)
    }

    func testLoadStationsFromFileSuccess() async throws {
        // Arrange
        let stationsFromFile = [Station(id: 1, name: "Station1", hits: 5)]
        
        let currentDate = Date()
        let validDate = currentDate.addingTimeInterval(-23 * 60 * 60)
        mockUserDefaultsStorage.loadedObject = validDate
        
        mockJSONStorage.loadedStations = stationsFromFile
        
        let sut = StationDataRepository(apiClient: mockAPIClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)
        
        // Act
        let stations = try await sut.getStations()

        // Assert
        XCTAssertEqual(stations, stationsFromFile)
    }

    func testLoadStationsFromFileFailure() async throws {
        // Arrange
        let currentDate = Date()
        let validDate = currentDate.addingTimeInterval(-23 * 60 * 60)
        mockUserDefaultsStorage.loadedObject = validDate
        
        mockJSONStorage.error = NSError(domain: "TestErrorDomain", code: 42, userInfo: nil)
        
        let sut = StationDataRepository(apiClient: mockAPIClient, jsonStorage: mockJSONStorage, userDefaultsStorage: mockUserDefaultsStorage)
        
        // Act & Assert
        do {
            _ = try await sut.getStations()
            XCTFail("Expected an error but none was thrown.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    class MockUserDefaultsStorage: UserDefaultsStorage {
        var savedObject: Any?
        var loadedObject: Any?

        func save(object: Any, forKey key: String) {
            savedObject = object
        }

        func loadObject(forKey key: String) -> Any? {
            return loadedObject
        }
    }

    class MockJSONStorage: FileStorage {
        var savedStations: [Station]?
        var savedKeywords: [Keyword]?
        var loadedStations: [Station]?
        var loadedKeywords: [Keyword]?
        var error: Error?

        func save<T>(object: T, to fileName: String) throws where T : Encodable {
            if let error = error {
                throw error
            }

            if T.self == [Station].self {
                savedStations = object as? [Station]
            } else if T.self == [Keyword].self {
                savedKeywords = object as? [Keyword]
            }
        }

        func load<T>(from fileName: String) throws -> T where T : Decodable {
            if let error = error {
                throw error
            }

            if T.self == [Station].self {
                return loadedStations as! T
            } else if T.self == [Keyword].self {
                return loadedKeywords as! T
            }

            fatalError("Unsupported type for loading")
        }
    }

    class MockAPIClient: API {
        var stationsToReturn: [Station]?
        var keywordsToReturn: [Keyword]?
        var error: Error?

        func fetchStations() async throws -> [Station] {
            if let error = error {
                throw error
            }
            return stationsToReturn ?? []
        }

        func fetchKeywords() async throws -> [Keyword] {
            if let error = error {
                throw error
            }
            return keywordsToReturn ?? []
        }
    }
}

