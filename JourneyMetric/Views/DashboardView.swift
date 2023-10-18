//
//  DashboardView.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 17/10/2023.
//

import SwiftUI

struct DashboardView<Content: View>: View {
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(viewModel: StationViewModel(), startStationSelection: EmptyView(), endStationSelection: EmptyView())
    }
}
