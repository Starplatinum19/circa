//
//  EventsViewModel.swift
//  Circa
//
//  Created by Jackenson Charles on 3/23/25.
//

import SwiftUI
import Foundation

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [Event] = [] {
        didSet {
            PersistenceManager.saveEvents(events)
        }
    }

    @Published var showingAddEvent = false

    init() {
        loadEvents()
    }

    func loadEvents() {
        let savedEvents = PersistenceManager.loadEvents()
        events = savedEvents.isEmpty ? [] : savedEvents
    }

    func loadMockEvents() {
        events = [
            Event(
                title: "Art Exhibition",
                description: "Discover local art and meet the artists.",
                location: "Art Gallery",
                date: Date(),
                category: "Art",
                imageUrl: "art",
                imageData: UIImage(named: "art")?.jpegData(compressionQuality: 1.0),
                city: "Miami",
                latitude: 25.7743,
                longitude: -80.1937
            ),
            Event(
                title: "Local Music Festival",
                description: "Live performances from top local bands.",
                location: "Downtown Amphitheater",
                date: Date(),
                category: "Music",
                imageUrl: nil,
                imageData: UIImage(named: "music")?.jpegData(compressionQuality: 1.0),
                city: "Miami",
                latitude: 25.7617,
                longitude: -80.1918
            ),
            Event(
                title: "Citywide Art Show",
                description: "Browse artwork from over 100 artists.",
                location: "Wynwood Art District",
                date: Date().addingTimeInterval(86400),
                category: "Art",
                imageUrl: nil,
                imageData: UIImage(named: "art2")?.jpegData(compressionQuality: 1.0),
                city: "Miami",
                latitude: 25.8000,
                longitude: -80.2000
            ),
            Event(
                title: "Tech Meetup",
                description: "Network with local developers and startups.",
                location: "Innovation Hub",
                date: Date().addingTimeInterval(86400 * 3),
                category: "Tech",
                imageUrl: nil,
                imageData: UIImage(named: "tech")?.jpegData(compressionQuality: 1.0),
                city: "San Francisco",
                latitude: 37.7749,
                longitude: -122.4194
            ),
            Event(
                title: "Food Truck Rally",
                description: "Taste the best food trucks in the city.",
                location: "City Park",
                date: Date().addingTimeInterval(86400 * 4),
                category: "Food",
                imageUrl: nil,
                imageData: UIImage(named: "truck")?.jpegData(compressionQuality: 1.0),
                city: "Portland",
                latitude: 30.2672,
                longitude: -97.7431
            ),
            Event(
                title: "Outdoor Movie Night",
                description: "Bring a blanket and enjoy a movie under the stars.",
                location: "Bayfront Park",
                date: Date().addingTimeInterval(86400 * 5),
                category: "Film",
                imageUrl: nil,
                imageData: UIImage(named: "movie")?.jpegData(compressionQuality: 1.0),
                city: "Miami",
                latitude: 25.7751,
                longitude: -80.1893
            ),
            Event(
                title: "Yoga in the Park",
                description: "Morning yoga session for all levels.",
                location: "Oceanfront Green",
                date: Date().addingTimeInterval(86400 * 6),
                category: "Wellness",
                imageUrl: nil,
                imageData: UIImage(named: "yoga")?.jpegData(compressionQuality: 1.0),
                city: "Portland",
                latitude: 32.7157,
                longitude: -117.1611
            ),
            Event(
                title: "Farmers Market",
                description: "Local produce, crafts, and music every Sunday.",
                location: "Historic Downtown",
                date: Date().addingTimeInterval(86400 * 7),
                category: "Community",
                imageUrl: nil,
                imageData: UIImage(named: "farmer")?.jpegData(compressionQuality: 1.0),
                city: "Portland",
                latitude: 45.5051,
                longitude: -122.6750
            ),
            Event(
                title: "Charity Fun Run",
                description: "5K run to support local shelters. All ages welcome.",
                location: "Waterfront Trail",
                date: Date().addingTimeInterval(86400 * 9),
                category: "Fitness",
                imageUrl: nil,
                imageData: UIImage(named: "run")?.jpegData(compressionQuality: 1.0),
                city: "Chicago",
                latitude: 41.8781,
                longitude: -87.6298
            )
        ]
        PersistenceManager.saveEvents(events) // ✅ ensure they’re persisted
    }


    func saveManually() {
        PersistenceManager.saveEvents(events)
    }
}
