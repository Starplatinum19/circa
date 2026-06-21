//
//  LocationManager.swift
//  Circa
//
//  Created by Jackenson Charles on 4/5/25.
//

import Foundation
import CoreLocation
import SwiftUI

struct UserStats: Codable {
    var eventsCreated: Int = 0
    var checkIns: Int = 0
    var comments: Int = 0
}

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @AppStorage("currentCity") var currentCity: String = "Miami"
    @AppStorage("authorizationStatusRawValue") var authorizationStatusRawValue: Int = 0
    @AppStorage("lastKnownLatitude") var lastKnownLatitude: Double = 0
    @AppStorage("lastKnownLongitude") var lastKnownLongitude: Double = 0
    @AppStorage("currentZip") var currentZip: String = ""
    @AppStorage("username") var username: String = ""

    @AppStorage("userStats") private var userStatsData: Data = Data()
    @Published var userStats: UserStats = UserStats() {
        didSet {
            if let encoded = try? JSONEncoder().encode(userStats) {
                userStatsData = encoded
            }
        }
    }

    @AppStorage("profileImageData") var profileImageData: Data?
    var profileImage: UIImage? {
        guard let data = profileImageData else { return nil }
        return UIImage(data: data)
    }

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastKnownLocation: CLLocationCoordinate2D?

    var currentLatitude: Double? {
        lastKnownLocation?.latitude
    }
    var currentLongitude: Double? {
        lastKnownLocation?.longitude
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        authorizationStatus = CLAuthorizationStatus(rawValue: Int32(Int(authorizationStatusRawValue))) ?? .notDetermined

        if lastKnownLatitude != 0 && lastKnownLongitude != 0 {
            lastKnownLocation = CLLocationCoordinate2D(latitude: lastKnownLatitude, longitude: lastKnownLongitude)
        }
        if let stats = try? JSONDecoder().decode(UserStats.self, from: userStatsData), userStatsData.count > 0 {
            userStats = stats
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.lastKnownLocation = location.coordinate
            self.lastKnownLatitude = location.coordinate.latitude
            self.lastKnownLongitude = location.coordinate.longitude
            self.fetchCityName(from: location)
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            self.authorizationStatusRawValue = Int(Int32(manager.authorizationStatus.rawValue))
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    func fetchCityName(from location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let city = placemarks?.first?.locality {
                self?.currentCity = city
            }
        }
    }

    // Stat increment helpers
    func incrementEventsCreated() {
        userStats.eventsCreated += 1
    }
    func incrementCheckIns() {
        userStats.checkIns += 1
    }
    func incrementComments() {
        userStats.comments += 1
    }

    func logout() {
        username = ""
        currentCity = ""
        currentZip = ""
    }
}

// MARK: - User Comfort Preferences Extension
extension LocationManager {
    var userComfortPreferences: UserComfortPreferences? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "userComfortPreferences"),
                  let preferences = try? JSONDecoder().decode(UserComfortPreferences.self, from: data) else {
                return nil
            }
            return preferences
        }
        set {
            if let preferences = newValue,
               let data = try? JSONEncoder().encode(preferences) {
                UserDefaults.standard.set(data, forKey: "userComfortPreferences")
            }
        }
    }
}
