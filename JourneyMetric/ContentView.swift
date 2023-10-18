//
//  ContentView.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 17/10/2023.
//

import SwiftUI
import Combine
import CoreLocation

protocol JSONStorage {
    func save<T: Encodable>(object: T, to fileName: String) throws
    func load<T: Decodable>(from fileName: String) throws -> T
}

protocol UserDefaultsStorage {
    func save(object: Any, forKey key: String)
    func loadObject(forKey key: String) -> Any?
}

class StationDataRepository: DataRepository {
    private let apiClient: APIClient
    private let stationsFileName = "stations.json"
    private let keywordsFileName = "keywords.json"
    private let lastFetchDateKey = "lastFetchDateKey"

    private let jsonStorage: JSONStorage
    private let userDefaultsStorage: UserDefaultsStorage

    init(apiClient: APIClient = APIClient(),
         jsonStorage: JSONStorage = FileStorage(),
         userDefaultsStorage: UserDefaultsStorage = UserDefaultsStorageImpl()) {
        self.apiClient = apiClient
        self.jsonStorage = jsonStorage
        self.userDefaultsStorage = userDefaultsStorage
    }

    func getStations() async throws -> [Station] {
        if try await shouldFetchData() {
            try await fetchData()
        }
        return try loadStationsFromFile()
    }

    func getKeywords() async throws -> [Keyword] {
        if try await shouldFetchData() {
            try await fetchData()
        }
        return try loadKeywordsFromFile()
    }

    private func shouldFetchData() async throws -> Bool {
        guard let lastFetchDate = try? loadLastFetchDate() else {
            return true
        }

        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(lastFetchDate)
        return timeInterval > 24 * 60 * 60
    }

    private func fetchData() async throws {
        let fetchedStations = try await apiClient.fetchStations()
        let fetchedKeywords = try await apiClient.fetchKeywords()

        try saveStationsToFile(stations: fetchedStations)
        try saveKeywordsToFile(keywords: fetchedKeywords)
        try saveLastFetchDate()
    }

    private func saveStationsToFile(stations: [Station]) throws {
        try jsonStorage.save(object: stations, to: stationsFileName)
    }

    private func loadStationsFromFile() throws -> [Station] {
        return try jsonStorage.load(from: stationsFileName)
    }

    private func saveKeywordsToFile(keywords: [Keyword]) throws {
        try jsonStorage.save(object: keywords, to: keywordsFileName)
    }

    private func loadKeywordsFromFile() throws -> [Keyword] {
        return try jsonStorage.load(from: keywordsFileName)
    }

    private func saveLastFetchDate() throws {
        let currentDate = Date()
        userDefaultsStorage.save(object: currentDate, forKey: lastFetchDateKey)
    }

    private func loadLastFetchDate() throws -> Date {
        guard let lastFetchDate = userDefaultsStorage.loadObject(forKey: lastFetchDateKey) as? Date else {
            throw NSError(domain: "Invalid Date", code: 0, userInfo: nil)
        }
        return lastFetchDate
    }
}

class FileStorage: JSONStorage {
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

class UserDefaultsStorageImpl: UserDefaultsStorage {
    func save(object: Any, forKey key: String) {
        UserDefaults.standard.set(object, forKey: key)
    }

    func loadObject(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
}

class APIClient {
    private let baseURL: String = "https://koleo.pl/api/v2/main/"

    func fetchStations() async throws -> [Station] {
        guard let url = URL(string: "\(baseURL)stations") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        return try await fetchData(from: url, decodingType: [Station].self)
    }

    func fetchKeywords() async throws -> [Keyword] {
        guard let url = URL(string: "\(baseURL)station_keywords") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        return try await fetchData(from: url, decodingType: [Keyword].self)
    }

    private func fetchData<T: Decodable>(from url: URL, decodingType: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        addCommonHeaders(to: &request)

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    private func addCommonHeaders(to request: inout URLRequest) {
        request.addValue("1", forHTTPHeaderField: "X-KOLEO-Version")
        request.addValue("iOS-100", forHTTPHeaderField: "X-KOLEO-Client")
    }
}

protocol DataRepository {
    func getStations() async throws -> [Station]
    func getKeywords() async throws -> [Keyword]
}

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
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    
    private let dataRepository: DataRepository
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
    
    init(dataRepository: DataRepository = StationDataRepository()) {
        self.dataRepository = dataRepository
        
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
        
        fetch()
    }
    
    func fetch() {
        Task {
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
        
        let startLocation = CLLocation(latitude: startStation.latitude ?? 0.0,
                                       longitude: startStation.longitude ?? 0.0)
        let endLocation = CLLocation(latitude: endStation.latitude ?? 0.0,
                                     longitude: endStation.longitude ?? 0.0)
        
        let distanceInMeters = startLocation.distance(from: endLocation)
        let distanceInKilometers = distanceInMeters / 1000
        
        return String(format: "Odległość: %.2f km", distanceInKilometers)
    }
}

struct ContentView<Content: View>: View {
    @State private var isStartStationSelectionPresented = false
    @State private var isEndStationSelectionPresented = false
    
    @StateObject var viewModel: StationViewModel
    var startStationSelection: Content
    var endStationSelection: Content
    

    var body: some View {
        content
            .background(Color(white: 0.95))
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.hasError {
            errorView
        } else {
            mainView
        }
    }
    
    private var loadingView: some View {
        VStack {
            Text("Ładowanie danych stacji...")
                .padding()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
        .padding()
    }
    
    private var errorView: some View {
        VStack {
            Text("Błąd ładowania danych.")
                .foregroundColor(.red)
                .padding()
            Button("Ponów") {
                viewModel.fetch()
            }
            .padding()
        }
    }
    
    private var mainView: some View {
        NavigationStack {
            Form {
                Section(header: Text("Stacja początkowa")) {
                    TextField("Wybierz stację", text: $viewModel.startStationText)
                        .font(.title3)
                        .padding(8)
                        .background(Color(white: 0.9))
                        .cornerRadius(8)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            self.isStartStationSelectionPresented = true
                        }
                        .navigationDestination(isPresented: $isStartStationSelectionPresented) {
                            startStationSelection
                        }
                }
                
                Section(header: Text("Stacja docelowa")) {
                    TextField("Wybierz stację", text: $viewModel.endStationText)
                        .font(.title3)
                        .padding(8)
                        .background(Color(white: 0.9))
                        .cornerRadius(8)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            self.isEndStationSelectionPresented = true
                        }
                        .navigationDestination(isPresented: $isEndStationSelectionPresented) {
                            endStationSelection
                        }
                }
                
                Section(header: Text("Odległość")) {
                    Text(viewModel.calculateDistance())
                        .padding(8)
                }
            }
            .navigationBarTitle("Journey Metric", displayMode: .inline)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: StationViewModel(), startStationSelection: EmptyView(), endStationSelection: EmptyView())
    }
}

struct Station: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    var latitude: Double?
    var longitude: Double?
    let hits: Int
}

struct Keyword: Codable {
    let id: Int
    let keyword: String
    let stationID: Int

    enum CodingKeys: String, CodingKey {
        case id, keyword, stationID = "station_id"
    }
}

struct StationSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var searchedStations: [Station]
    @Binding var selectedStation: Station?
    @Binding var stationName: String

    var body: some View {
        VStack {
            TextField("Wpisz nazwę stacji", text: $stationName)
                .font(.title3)
                .padding(8)
                .background(Color(white: 0.9))
                .cornerRadius(8)
                .disableAutocorrection(true)
            
            List(searchedStations, id: \.id) { station in
                Button(action: {
                    selectedStation = station
                    stationName = station.name
                    searchedStations.removeAll()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(station.name)
                        .padding(8)
                        .background(selectedStation == station ? Color.blue : Color.clear)
                        .cornerRadius(8)
                        .foregroundColor(selectedStation == station ? .white : .primary)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .background(Color(white: 0.95))
    }
}


