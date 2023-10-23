//
//  StartStationSelectionView.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 23/10/2023.
//

import SwiftUI

struct StartStationSelectionView: View {
    @EnvironmentObject private var viewModel: StationViewModel

    var body: some View {
        StationSelectionView(
            searchedStations: $viewModel.searchedStartStations,
            selectedStation: $viewModel.selectedStartStation,
            stationName: $viewModel.startStationText
        )
    }
}

#Preview {
    StartStationSelectionView()
        .environmentObject(StationViewModel())
}
