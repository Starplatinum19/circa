//
//  ProfileView.swift
//  Circa
//
//  Created by Jackenson Charles on 4/12/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: EventsViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true

    @State private var selectedTab: ProfileTab = .myEvents
    @State private var eventToDelete: Event? = nil
    @State private var showDeleteConfirmation = false
    @State private var selectedPhoto: PhotosPickerItem? = nil

    enum ProfileTab: String, CaseIterable, Identifiable {
        case myEvents = "My Events"
        case starred = "Starred Events"
        var id: String { self.rawValue }
    }
    
    // Break out gradient colors as a computed property
    private var gradientColors: [Color] {
        [Color("GradientTop"), Color("GradientMiddle"), Color("GradientBottom")]
    }
    
    // Separate the background view
    private var backgroundView: some View {
        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
    
    // Separate the main content
    private var mainContent: some View {
        VStack {
            profileHeader
            tabPicker
            eventsList
            Spacer()
        }
    }
    
    // Break out the profile header
    private var profileHeader: some View {
        VStack(spacing: 8) {
            ProfileImageView(selectedPhoto: $selectedPhoto, locationManager: locationManager)
            
            Text(locationManager.username.isEmpty ? "Circa User" : locationManager.username)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            BadgesView(userStats: locationManager.userStats)
        }
        .padding(.top)
    }
    
    // Break out the tab picker
    private var tabPicker: some View {
        Picker("Tab", selection: $selectedTab) {
            ForEach(ProfileTab.allCases) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    // Break out the events list
    private var eventsList: some View {
        List {
            if selectedTab == .myEvents {
                myEventsSection
            } else {
                starredEventsSection
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }
    
    // Separate my events section
    @ViewBuilder
    private var myEventsSection: some View {
        if myEvents.isEmpty {
            Text("🗒️ You haven't created any events yet.")
                .foregroundColor(.white.opacity(0.7))
                .padding()
                .listRowBackground(Color.clear)
        } else {
            ForEach(myEvents, id: \.id) { event in
                EventCardView(event: event, locationManager: locationManager)
                    .listRowBackground(Color.clear)
                    .swipeActions {
                        Button(role: .destructive) {
                            eventToDelete = event
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    // Separate starred events section
    @ViewBuilder
    private var starredEventsSection: some View {
        if starredEvents.isEmpty {
            Text("⭐ You haven't starred any events yet.")
                .foregroundColor(.white.opacity(0.7))
                .padding()
                .listRowBackground(Color.clear)
        } else {
            ForEach(starredEvents, id: \.id) { event in
                EventCardView(event: event, locationManager: locationManager)
                    .listRowBackground(Color.clear)
            }
        }
    }

    var body: some View {
        ZStack {
            backgroundView
            mainContent
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            viewModel.saveManually()
                            locationManager.logout()
                            isLoggedIn = false
                        }
                        .foregroundColor(.red)
                    }
                }
                .alert("Delete Event", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        if let event = eventToDelete {
                            deleteEvent(event)
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to delete this event?")
                }
        }
    }

    private func deleteEvent(_ event: Event) {
        if let index = viewModel.events.firstIndex(where: { $0.id == event.id }) {
            viewModel.events.remove(at: index)
        }
    }

    var myEvents: [Event] {
        viewModel.events.filter { $0.createdByUser }
    }

    var starredEvents: [Event] {
        viewModel.events.filter { $0.isStarred }
    }
}

struct ProfileImageView: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = locationManager.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(locationManager.username.isEmpty ? "U" : String(locationManager.username.prefix(2)).uppercased())
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
            
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "camera.fill")
                    .padding(6)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .frame(width: 32, height: 32)
            .offset(x: 8, y: 8)
            .onChange(of: selectedPhoto) { newValue, _ in
                if let selectedPhoto = newValue {
                    Task {
                        if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                            locationManager.profileImageData = data
                        }
                    }
                }
            }
        }
    }
}

struct BadgesView: View {
    let userStats: UserStats
    
    var body: some View {
        HStack(spacing: 12) {
            if userStats.eventsCreated > 0 {
                BadgeView(label: "Event Creator", systemImage: "star.fill", color: .yellow)
            }
            if userStats.checkIns > 0 {
                BadgeView(label: "Active Attendee", systemImage: "checkmark.seal.fill", color: .green)
            }
            if userStats.comments > 0 {
                BadgeView(label: "Top Commenter", systemImage: "text.bubble.fill", color: .blue)
            }
        }
        .padding(.top, 4)
    }
}

struct BadgeView: View {
    let label: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(6)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }
}

#Preview {
    var viewModel: EventsViewModel {
        let vm = EventsViewModel()
        vm.events = [
            Event(
                title: "Mock Event 1",
                description: "This is a sample event.",
                location: "Mock Location",
                date: Date(),
                category: "Art",
                imageUrl: nil,
                imageData: nil,
                city: "Miami",
                latitude: 25.7617,
                longitude: -80.1918,
                comments: [
                    Comment(username: "Alice", text: "Looks great!"),
                    Comment(username: "Bob", text: "I'll be there.")
                ],
                reactions: ["❤️": 3, "🔥": 1, "👍": 0],
                createdByUser: false
            ),
            Event(
                title: "Mock Event 2",
                description: "Another sample event.",
                location: "Downtown",
                date: Date(),
                category: "Music",
                imageUrl: nil,
                imageData: nil,
                city: "Miami",
                latitude: 25.7743,
                longitude: -80.1937,
                comments: [],
                reactions: ["❤️": 1, "🔥": 0, "👍": 2],
                createdByUser: false
            ),
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
                longitude: -80.1937,
                comments: [],
                createdByUser: true
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
                longitude: -80.1918,
                comments: [],
                createdByUser: true
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
                longitude: -80.2000,
                comments: [],
                createdByUser: true
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
                longitude: -122.4194,
                comments: [],
                createdByUser: true
            )
        ]
        return vm
    }
    var locationManager: LocationManager {
        let lm = LocationManager()
        lm.username = "Circa User"
        return lm
    }
    return NavigationStack {
        ProfileView()
            .environmentObject(viewModel)
            .environmentObject(locationManager)
    }
}
