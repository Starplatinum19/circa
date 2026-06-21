//
//  EventsView.swift
//  Circa
//
//  Created by Jackenson Charles on 4/9/25.
//

import SwiftUI

struct EventsView: View {
    @EnvironmentObject var viewModel: EventsViewModel
    @EnvironmentObject var locationManager: LocationManager

    @AppStorage("userCity") private var userCity: String = ""
    @AppStorage("userZip") private var userZip: String = ""

    @State private var selectedCity: String = ""
    @State private var showMapView = false
    @State private var showProfile = false
    @State private var searchQuery: String = ""
    @StateObject var mascotViewModel = MascotViewModel()
    
    // Add mascot visibility state
    @State private var showMascot = false
    
    // Track if this is the user's first session
    @AppStorage("hasSeenFirstTimeGreeting") private var hasSeenFirstTimeGreeting = false
    @AppStorage("lastLoginDate") private var lastLoginDateString = ""
    
    var filteredEvents: [Event] {
        viewModel.events.filter { event in
            event.city.localizedCaseInsensitiveContains(selectedCity) || selectedCity.isEmpty
        }
    }

    // Helper to get current TimeOfDay
    private var currentTimeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                LinearGradient(
                    colors: [
                        Color("GradientTop"),
                        Color("GradientMiddle"),
                        Color("GradientBottom")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Replaced inline search/list with EventListView
                EventListView(searchQuery: $searchQuery, selectedCity: $selectedCity)
                    .environmentObject(viewModel)
                    .environmentObject(locationManager)

                // Floating Bottom Bar - back to original 3 buttons
                HStack(spacing: 50) {
                    Button { showProfile = true } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .frame(width: 56, height: 36)
                            .background(Color.black)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }

                    Button { showMapView = true } label: {
                        Image(systemName: "safari")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .frame(width: 56, height: 36)
                            .background(Color.black)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }

                    Button { viewModel.showingAddEvent = true } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .frame(width: 56, height: 36)
                            .background(Color.black)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.bottom, 20)
                
                // Mascot toggle button - positioned at top-right above the navigation bar
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button { 
                            showMascot.toggle()
                            // When showing mascot for the first time, trigger appropriate greeting
                            if showMascot && mascotViewModel.currentMessage.isEmpty {
                                determineUserTypeAndGreet()
                            }
                        } label: {
                            Image(systemName: showMascot ? "face.smiling.fill" : "face.smiling")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 44, height: 44)
                                .background(showMascot ? Color.blue : Color.black.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 90) // positioned above the navigation bar
                    }
                }
                
                // Floating Mascot Overlay - only show when toggled on
                if showMascot {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            FloatingMascotView(
                                message: mascotViewModel.currentMessage,
                                onMascotTap: {
                                    // When mascot face is tapped, generate a new message
                                    mascotViewModel.updateContext(.browsing(timeOfDay: currentTimeOfDay), user: locationManager, forceUpdate: true)
                                }
                            )
                                .padding(.trailing, 16)
                                .padding(.bottom, 90) // above the floating bar
                        }
                    }
                    .ignoresSafeArea()
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showMascot)
                }
            }
            .onAppear {
                let defaultLocation = userCity.isEmpty ? userZip : userCity
                if selectedCity.isEmpty {
                    selectedCity = defaultLocation
                    searchQuery = defaultLocation
                }
                
                // Determine user type and trigger appropriate mascot greeting
                determineUserTypeAndGreet()
            }
            .fullScreenCover(isPresented: $viewModel.showingAddEvent) {
                AddEventView(viewModel: viewModel)
                    .environmentObject(locationManager)
            }
            .fullScreenCover(isPresented: $showMapView) {
                EventMapView(
                    events: viewModel.events,
                    onCitySelected: { newCity in
                        selectedCity = newCity
                        searchQuery = newCity
                    }
                )
                .environmentObject(locationManager)
            }
            .fullScreenCover(isPresented: $showProfile) {
                NavigationStack {
                    ProfileView()
                        .environmentObject(viewModel)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Mascot Greeting Logic
    private func determineUserTypeAndGreet() {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Check if this is a first-time user
        if !hasSeenFirstTimeGreeting {
            // First time user - just completed onboarding
            mascotViewModel.updateContext(.firstTimeUser, user: locationManager)
            hasSeenFirstTimeGreeting = true
            lastLoginDateString = dateFormatter.string(from: now)
            return
        }
        
        // Returning user - check how long since last visit
        if let lastLoginDate = dateFormatter.date(from: lastLoginDateString) {
            let daysSinceLastLogin = Calendar.current.dateComponents([.day], from: lastLoginDate, to: now).day ?? 0
            
            if daysSinceLastLogin > 0 {
                // Returning user after time away
                mascotViewModel.updateContext(.returningUser(daysSinceLast: daysSinceLastLogin), user: locationManager)
            } else {
                // Same day return - regular browsing
                mascotViewModel.updateContext(.browsing(timeOfDay: currentTimeOfDay), user: locationManager)
            }
        } else {
            // No valid last login date - treat as returning user
            mascotViewModel.updateContext(.returningUser(daysSinceLast: 1), user: locationManager)
        }
        
        // Update last login date
        lastLoginDateString = dateFormatter.string(from: now)
    }
}

#Preview {
    let mockEvents = [
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
                imageData:UIImage(named: "farmer")?.jpegData(compressionQuality: 1.0),
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

    let viewModel = EventsViewModel()
    viewModel.events = mockEvents

    let locationManager = LocationManager()
    locationManager.currentCity = "Miami"

    return EventsView()
        .environmentObject(viewModel)
        .environmentObject(locationManager)
}
