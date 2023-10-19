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
                .background(Color(white: 0.7))
                .cornerRadius(8)
                .disableAutocorrection(true)
            
            List(searchedStations, id: \.id) { station in
                Button(action: {
                    selectedStation = station
                    stationName = station.name
                    searchedStations.removeAll()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(station.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                            .padding(.vertical, 12)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .contentShape(Rectangle())
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding(8)
    }
}

struct StationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StationSelectionView(
            searchedStations: .constant(
                [
                    Station(id: 1, name: "Poznań", hits: 5),
                    Station(id: 2, name: "Koszalin", hits: 4),
                    Station(id: 3, name: "Szczecin", hits: 3),
                    Station(id: 4, name: "Warszawa", hits: 2),
                    Station(id: 5, name: "Kielce", hits: 1)
                ]
            ),
            selectedStation: .constant(nil),
            stationName: .constant("Poznań"))
    }
}
