//
//  StationViewModel.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//
import Foundation
import Combine

@MainActor
class StationViewModel: ObservableObject {
    @Published var startStationText: String = ""
    @Published var endStationText: String = ""
    @Published var searchedStartStations: [Station] = []
    @Published var searchedEndStations: [Station] = []
    @Published var selectedStartStation: Station?
    @Published var selectedEndStation: Station?
    @Published var stations: [Station] = []
    @Published var keywords: [Keyword] = []
    @Published var isLoading: Bool = true
    @Published var hasError: Bool = false
    
    private let dataRepository: DataRepository
    private let distanceCalculator: DistanceCalculator
    private var cancellables: Set<AnyCancellable> = []
    
    private var startStationTextPublisher: AnyPublisher<String, Never> {
        $startStationText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private var endStationTextPublisher: AnyPublisher<String, Never> {
        $endStationText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    init(dataRepository: DataRepository = StationDataRepository(),
         distanceCalculator: DistanceCalculator = DistanceCalculator()) {
        self.dataRepository = dataRepository
        self.distanceCalculator = distanceCalculator
        
        startStationTextPublisher
            .sink { [weak self] text in
                guard let self = self else {
                    return
                }
                self.searchedStartStations = self.searchStations(with: text)
            }
            .store(in: &cancellables)
        
        endStationTextPublisher
            .sink { [weak self] text in
                guard let self = self else {
                    return
                }
                self.searchedEndStations = self.searchStations(with: text)
            }
            .store(in: &cancellables)
        
        Task {
            await fetch()
        }
    }
    
    func fetch() async {
        isLoading = true
        hasError = false
        do {
            stations = try await dataRepository.getStations()
            keywords = try await dataRepository.getKeywords()
        } catch {
            hasError = true
        }
        isLoading = false
    }

    func searchStations(with text: String) -> [Station] {
        guard text.count > 3 else {
            return []
        }

        let lowercasedText = text.lowercased()

        let filteredKeywords = keywords.filter { keyword in
            keyword.keyword.lowercased().contains(lowercasedText)
        }

        return filteredKeywords.compactMap { keyword in
            stations.first { $0.id == keyword.stationID }
        }.sorted { $0.hits > $1.hits }
    }



    func calculateDistance() -> String {
        guard let startStation = selectedStartStation,
              let endStation = selectedEndStation else {
            return "Wybierz stacje początkową i docelową"
        }
        
        return distanceCalculator.calculateDistance(
            startStation: startStation,
            endStation: endStation
        )
    }
}
