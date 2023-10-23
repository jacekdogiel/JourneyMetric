//
//  Coordinator.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 23/10/2023.
//

import SwiftUI

enum Page: String, Identifiable {
    case dashboard
    case startStationSelection
    case endStationSelection
    
    var id: String {
        self.rawValue
    }
}

@MainActor
class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .dashboard:
            DashboardView()
        case .startStationSelection:
            StartStationSelectionView()
        case .endStationSelection:
            EndStationSelectionView()
        }
    }
}

