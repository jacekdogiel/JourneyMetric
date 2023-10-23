//
//  DashboardView.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 17/10/2023.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @EnvironmentObject private var viewModel: StationViewModel

    var body: some View {
        content
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .empty:
            loadingView
        case .success:
            mainView
        case .failure:
            errorView
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
                Task {
                    await viewModel.fetch()
                }
            }
            .padding()
        }
    }
    
    private var mainView: some View {
        Form {
            Section(header: Text("Stacja początkowa")) {
                Button(action: {
                    viewModel.clearStartStations()
                    coordinator.push(.startStationSelection)
                }) {
                    Text(viewModel.selectedStartStation == nil ? "Wybierz stację" : viewModel.startStationText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                        .padding(8)
                        .background(Color(white: 0.7))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Section(header: Text("Stacja docelowa")) {
                Button(action: {
                    viewModel.clearEndStations()
                    coordinator.push(.endStationSelection)
                }) {
                    Text(viewModel.selectedEndStation == nil ? "Wybierz stację" : viewModel.endStationText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                        .padding(8)
                        .background(Color(white: 0.7))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            
            Section(header: Text("Odległość")) {
                Text(viewModel.calculateDistance())
                    .padding(8)
            }
        }
        .navigationBarTitle("Journey Metric", displayMode: .inline)
        .padding()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(StationViewModel())
            .environmentObject(Coordinator())
    }
}
