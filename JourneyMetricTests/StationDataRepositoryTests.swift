//
//  StationDataRepositoryTests.swift
//  JourneyMetricTests
//
//  Created by Jacek Dogiel on 19/10/2023.
//
import XCTest
@testable import JourneyMetric

final class StationDataRepositoryTests: XCTestCase {
    var sut: StationDataRepository<MockDiskCache<[Station]>, MockDiskCache<[Keyword]>>!
    var mockAPIClient: MockAPIClient!
    var mockStationsDiskCache: MockDiskCache<[Station]>!
    var mockKeywordDiskCache: MockDiskCache<[Keyword]>!

    override func setUpWithError() throws {
        mockAPIClient = MockAPIClient()
        mockStationsDiskCache = MockDiskCache()
        mockKeywordDiskCache = MockDiskCache()
        sut = StationDataRepository(apiClient: mockAPIClient, stationsCache: mockStationsDiskCache, keywordsCache: mockKeywordDiskCache)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockAPIClient = nil
        mockStationsDiskCache = nil
        mockKeywordDiskCache = nil
    }

    func testFetchStations() async throws {
        // Arrange
        let mockApiClient = MockAPIClient()
        mockApiClient.stationsToReturn = [Station(id: 1, name: "Station1", hits: 5)]
        
        let sut = StationDataRepository(apiClient: mockApiClient, stationsCache: mockStationsDiskCache, keywordsCache: mockKeywordDiskCache)

        // Act
        let stations = try await sut.getStations()

        // Assert
        XCTAssertEqual(stations.count, 1)
    }
    
    func testFetchKeywords() async throws {
        // Arrange
        let mockApiClient = MockAPIClient()
        mockApiClient.keywordsToReturn = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        
        let sut = StationDataRepository(apiClient: mockApiClient, stationsCache: mockStationsDiskCache, keywordsCache: mockKeywordDiskCache)

        // Act
        let keywords = try await sut.getKeywords()

        // Assert
        XCTAssertEqual(keywords.count, 1)
    }

    func testFetchDataFailure() async throws {
        // Arrange
        let mockApiClient = MockAPIClient()
        mockApiClient.error = NSError(domain: "TestErrorDomain", code: 42, userInfo: nil)
        
        let sut = StationDataRepository(apiClient: mockApiClient, stationsCache: mockStationsDiskCache, keywordsCache: mockKeywordDiskCache)

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
        
        let sut = StationDataRepository(apiClient: mockApiClient, stationsCache: mockStationsDiskCache, keywordsCache: mockKeywordDiskCache)
        
        // Act
        _ = try await sut.getStations()
        let saveCalled = await mockStationsDiskCache.saveToDiskCalled

        // Assert
        XCTAssertTrue(saveCalled)
    }

    func testLoadStationsFromFileSuccess() async throws {
        // Arrange
        let stationsFromFile = [Station(id: 1, name: "Station1", hits: 5)]
        
        let sut = StationDataRepository(apiClient: mockAPIClient, stationsCache: mockStationsDiskCache, keywordsCache: mockKeywordDiskCache)
        
        await mockStationsDiskCache.setStoredValue(stationsFromFile)
        // Act
        let stations = try await sut.getStations()

        // Assert
        XCTAssertEqual(stations, stationsFromFile)
    }

    func testLoadStationsFromFileFailure() async throws {
        // Arrange
        let sut = StationDataRepository(apiClient: mockAPIClient, stationsCache: mockStationsDiskCache, keywordsCache: mockKeywordDiskCache)
        
        await mockStationsDiskCache.setError(CacheError.loadError)
        
        // Act & Assert
        do {
            _ = try await sut.getStations()
            XCTFail("Expected an error but none was thrown.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    enum CacheError: Error {
        case loadError
    }
    
    actor MockDiskCache<V: Codable>: DiskCacheProtocol {
        var saveToDiskCalled = false
        var loadFromDiskCalled = false
        var error: Error?
        var expirationInterval: TimeInterval = 3 * 60

        private var storedValue: V?
        
        func setError(_ error: Error) {
            self.error = error
        }

        func setStoredValue(_ value: V?) {
            storedValue = value
        }

        func getStoredValue() -> V? {
            return storedValue
        }

        func saveToDisk() throws {
            saveToDiskCalled = true
        }

        func loadFromDisk() throws {
            loadFromDiskCalled = true
            
            if let error = error {
                throw error
            }
        }

        func setValue(_ value: V?, forKey key: String) {
            setStoredValue(value)
        }

        func value(forKey key: String) -> V? {
            return getStoredValue()
        }

        func removeValue(forKey key: String) {
            setStoredValue(nil)
        }

        func removeAllValues() {
            setStoredValue(nil)
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

