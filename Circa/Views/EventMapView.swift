//
//  EventMapView.swift
//  Circa
//
//  Created by Jackenson Charles on 4/9/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct EventMapView: View {
    let events: [Event]
    let onCitySelected: (String) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapCenterCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
    @State private var selectedCity: String = "..."
    @State private var searchQuery: String = ""

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(events) { event in
                    if let lat = event.latitude, let lon = event.longitude {
                        Marker(event.title, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                }
            }

                .onMapCameraChange { context in
                    mapCenterCoordinate = context.camera.centerCoordinate
                    updateCity(for: mapCenterCoordinate)
                }
                .edgesIgnoringSafeArea(.all)

            // Crosshair
            Image(systemName: "scope")
                .font(.system(size: 36))
                .foregroundColor(.accentColor)
                .offset(y: -18)

            VStack {
                // Search bar
                TextField("Enter city or ZIP", text: $searchQuery, onCommit: {
                    geocodeAndCenterMap(for: searchQuery)
                })
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.top, 50)

                Spacer()

                // Bottom buttons
                VStack(spacing: 12) {
                    Button {
                        onCitySelected(selectedCity)
                        dismiss()
                    } label: {
                        Text("View Events in \(selectedCity)")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            updateMap(to: mapCenterCoordinate)
        }
    }

    private func updateMap(to location: CLLocationCoordinate2D) {
        mapCenterCoordinate = location
        cameraPosition = .region(MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        updateCity(for: location)
    }

    private func updateCity(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            if let city = placemarks?.first?.locality {
                selectedCity = city
            }
        }
    }

    private func geocodeAndCenterMap(for query: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { placemarks, _ in
            if let coordinate = placemarks?.first?.location?.coordinate {
                updateMap(to: coordinate)
            }
        }
    }
}
