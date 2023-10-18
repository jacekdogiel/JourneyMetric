//
//  StationSelectionView.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 18/10/2023.
//

import SwiftUI

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
