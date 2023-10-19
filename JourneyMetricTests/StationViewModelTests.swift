//
//  StationViewModelTests.swift
//  JourneyMetricTests
//
//  Created by Jacek Dogiel on 18/10/2023.
//

import XCTest
@testable import JourneyMetric

@MainActor
final class StationViewModelTests: XCTestCase {
    var sut: StationViewModel!
    var mockDataRepository: MockDataRepository!

    override func setUpWithError() throws {
        mockDataRepository = MockDataRepository()
        sut = StationViewModel(dataRepository: mockDataRepository)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDataRepository = nil
    }

    func testFetchSuccess() async throws {
        // Arrange
        mockDataRepository.stationsToReturn = [Station(id: 1, name: "Station1", hits: 5)]
        mockDataRepository.keywordsToReturn = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]

        // Act
        await sut.fetch()

        // Assert
        XCTAssertEqual(sut.stations.count, 1)
        XCTAssertEqual(sut.keywords.count, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.hasError)
    }

    func testFetchFailure() async throws {
        // Arrange
        mockDataRepository.error = NSError(domain: "TestErrorDomain", code: 42, userInfo: nil)

        // Act
        await sut.fetch()

        // Assert
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.hasError)
        XCTAssertEqual(sut.stations.count, 0)
        XCTAssertEqual(sut.keywords.count, 0)
    }

    func testSearchStationsWithValidText() {
        // Arrange
        sut.keywords = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        sut.stations = [Station(id: 1, name: "Station1", hits: 5)]

        // Act
        sut.startStationText = "Keyword"
        let resultStations = sut.searchStations(with: sut.startStationText)

        // Assert
        XCTAssertEqual(resultStations.count, 1)
        XCTAssertEqual(resultStations.first?.id, 1)
    }

    func testSearchStationsWithInvalidText() {
        // Arrange
        sut.keywords = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        sut.stations = [Station(id: 1, name: "Station1", hits: 5)]

        // Act
        sut.startStationText = "Invalid"
        let resultStations = sut.searchStations(with: sut.startStationText)

        // Assert
        XCTAssertEqual(resultStations.count, 0)
    }
    
    func testSearchStationsWithThreeChars() {
        // Arrange
        sut.keywords = [Keyword(id: 1, keyword: "Keyword1", stationID: 1)]
        sut.stations = [Station(id: 1, name: "Station1", hits: 5)]

        // Act
        sut.startStationText = "Key"
        let resultStations = sut.searchStations(with: sut.startStationText)

        // Assert
        XCTAssertEqual(resultStations.count, 0)
    }

    func testCalculateDistanceWithSelectedStations() {
        // Arrange
        let startStation = Station(id: 1, name: "StartStation", latitude: 40.0, longitude: -74.0, hits: 5)
        let endStation = Station(id: 2, name: "EndStation", latitude: 41.0, longitude: -75.0, hits: 3)
        sut.selectedStartStation = startStation
        sut.selectedEndStation = endStation

        // Act
        let distance = sut.calculateDistance()

        // Assert
        XCTAssertEqual(distance, "Odległość: 139.70 km") // The expected distance value may vary based on actual calculations.
    }

    func testCalculateDistanceWithoutSelectedStations() {
        // Act
        let distance = sut.calculateDistance()

        // Assert
        XCTAssertEqual(distance, "Wybierz stacje początkową i docelową")
    }
    
    func testClearStartStations() {
        // Arrange
        sut.startStationText = "Keyword"
        sut.selectedStartStation = Station(id: 1, name: "StartStation", hits: 5)
        sut.searchedStartStations = [Station(id: 2, name: "Station2", hits: 3)]

        // Act
        sut.clearStartStations()

        // Assert
        XCTAssertEqual(sut.startStationText, "")
        XCTAssertNil(sut.selectedStartStation)
        XCTAssertEqual(sut.searchedStartStations.count, 0)
    }

    func testClearEndStations() {
        // Arrange
        sut.endStationText = "Keyword"
        sut.selectedEndStation = Station(id: 1, name: "EndStation", hits: 5)
        sut.searchedEndStations = [Station(id: 2, name: "Station2", hits: 3)]

        // Act
        sut.clearEndStations()

        // Assert
        XCTAssertEqual(sut.endStationText, "")
        XCTAssertNil(sut.selectedEndStation)
        XCTAssertEqual(sut.searchedEndStations.count, 0)
    }

    class MockDataRepository: DataRepository {
        var stationsToReturn: [Station]?
        var keywordsToReturn: [Keyword]?
        var error: Error?

        func getStations() async throws -> [Station] {
            if let error = error {
                throw error
            }
            return stationsToReturn ?? []
        }

        func getKeywords() async throws -> [Keyword] {
            if let error = error {
                throw error
            }
            return keywordsToReturn ?? []
        }
    }
}
