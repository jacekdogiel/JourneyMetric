//
//  JourneyMetricApp.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 17/10/2023.
//

import SwiftUI

@main
struct JourneyMetricApp: App {
    @StateObject var viewModel: StationViewModel = StationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel,
                        startStationSelection: StationSelectionView(
                            searchedStations: $viewModel.searchedStartStations,
                            selectedStation: $viewModel.selectedStartStation,
                            stationName: $viewModel.startStationText
                        ),
                        endStationSelection: StationSelectionView(
                            searchedStations: $viewModel.searchedEndStations,
                            selectedStation: $viewModel.selectedEndStation,
                            stationName: $viewModel.endStationText
                        )
            )
        }
    }
}
