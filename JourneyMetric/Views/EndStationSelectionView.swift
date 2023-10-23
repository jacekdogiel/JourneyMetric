//
//  EndStationSelectionView.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 23/10/2023.
//

import SwiftUI

struct EndStationSelectionView: View {
    @EnvironmentObject private var viewModel: StationViewModel

    var body: some View {
        StationSelectionView(
            searchedStations: $viewModel.searchedEndStations,
            selectedStation: $viewModel.selectedEndStation,
            stationName: $viewModel.endStationText
        )
    }
}

#Preview {
    EndStationSelectionView()
        .environmentObject(StationViewModel())
}
