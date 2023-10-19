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
        let startStationSelection = StationSelectionView(
            searchedStations: $viewModel.searchedStartStations,
            selectedStation: $viewModel.selectedStartStation,
            stationName: $viewModel.startStationText
        )
        
        let endStationSelection = StationSelectionView(
            searchedStations: $viewModel.searchedEndStations,
            selectedStation: $viewModel.selectedEndStation,
            stationName: $viewModel.endStationText
        )
        
        WindowGroup {
            DashboardView(
                viewModel: viewModel,
                startStationSelection: startStationSelection,
                endStationSelection: endStationSelection
            )
        }
    }
}
