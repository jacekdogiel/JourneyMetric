//
//  JourneyMetricApp.swift
//  JourneyMetric
//
//  Created by Jacek Dogiel on 17/10/2023.
//

import SwiftUI

@main
struct JourneyMetricApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .preferredColorScheme(.dark)
        }
    }
}
