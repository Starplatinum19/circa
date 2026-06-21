//
//  CircaApp.swift
//  Circa
//
//  Created by Jackenson Charles on 3/23/25.
//

import SwiftUI

@main
struct CircaApp: App {
    private let locationManager = LocationManager()
    private let viewModel = EventsViewModel()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(locationManager)
                .environmentObject(viewModel)
        }
    }
}
