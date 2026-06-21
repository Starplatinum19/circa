//
//  BuddySystemView.swift
//  Circa
//
//  Created by Jackenson on 8/30/25.
//

import SwiftUI

struct BuddySystemView: View {
    let event: Event
    @ObservedObject var locationManager: LocationManager
    @State private var showingBuddyPreferences = false
    @State private var showingBuddyMatches = false
    @State private var buddyRequests: [BuddyRequest] = []
    @State private var matches: [BuddyMatch] = []
    @State private var userBuddyRequest: BuddyRequest?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                
                if let userRequest = userBuddyRequest {
                    currentRequestSection(userRequest)
                } else {
                    findBuddySection
                }
                
                if !matches.isEmpty {
                    matchesSection
                }
                
                buddyRequestsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Find a Buddy")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadBuddyData()
            }
        }
        .sheet(isPresented: $showingBuddyPreferences) {
            BuddyPreferencesView(event: event, locationManager: locationManager) { request in
                userBuddyRequest = request
                buddyRequests.append(request)
                findMatches()
            }
        }
        .sheet(isPresented: $showingBuddyMatches) {
            BuddyMatchesView(matches: matches, currentUser: locationManager.username)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 24))
                Text("Buddy System")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Connect with other attendees for \(event.title)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 4) {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                Text("\(buddyRequests.count) people looking for buddies")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var findBuddySection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Find Your Event Buddy")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Set your preferences and we'll help you connect with compatible attendees")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingBuddyPreferences = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    Text("Set Buddy Preferences")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
    
    private func currentRequestSection(_ request: BuddyRequest) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your Buddy Request")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Looking for: \(request.buddyPreferences.lookingFor.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                VStack {
                    Text(request.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(for: request.status).opacity(0.2))
                        .foregroundColor(statusColor(for: request.status))
                        .cornerRadius(8)
                }
            }
            
            if !request.buddyPreferences.description.isEmpty {
                Text(request.buddyPreferences.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    showingBuddyPreferences = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    cancelBuddyRequest()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Cancel")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(15)
    }
    
    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Matches")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    showingBuddyMatches = true
                }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(matches.prefix(3)) { match in
                        BuddyMatchCard(match: match, currentUser: locationManager.username)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var buddyRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("People Looking for Buddies")
                .font(.headline)
                .fontWeight(.semibold)
            
            if buddyRequests.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No one is looking for buddies yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Be the first to set your preferences!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(buddyRequests.filter { $0.username != locationManager.username }) { request in
                        BuddyRequestCard(request: request, currentUser: locationManager.username) {
                            sendBuddyRequest(to: request)
                        }
                    }
                }
            }
        }
    }
    
    private func statusColor(for status: BuddyRequestStatus) -> Color {
        switch status {
        case .looking: return .orange
        case .matched: return .blue
        case .confirmed: return .green
        case .cancelled: return .red
        case .completed: return .purple
        }
    }
    
    private func loadBuddyData() {
        // In a real app, this would load from a database
        // For now, simulate some buddy requests
        buddyRequests = []
        matches = []
        
        // Check if user has an existing buddy request
        userBuddyRequest = buddyRequests.first { $0.username == locationManager.username }
    }
    
    private func findMatches() {
        guard let userRequest = userBuddyRequest else { return }
        
        // Find compatible buddy requests
        let compatibleRequests = buddyRequests.filter { request in
            request.username != userRequest.username &&
            request.status == .looking
        }
        
        // Calculate compatibility scores and create matches
        for request in compatibleRequests {
            let score = BuddyCompatibility.calculateScore(
                request1: userRequest,
                request2: request,
                userPrefs1: locationManager.userComfortPreferences,
                userPrefs2: nil // Would load other user's preferences in real app
            )
            
            if score >= 50.0 { // Minimum compatibility threshold
                let match = BuddyMatch(
                    eventId: event.id.uuidString,
                    user1: userRequest.username,
                    user2: request.username
                )
                matches.append(match)
            }
        }
    }
    
    private func sendBuddyRequest(to request: BuddyRequest) {
        // Create a match between current user and the selected buddy request
        guard let userRequest = userBuddyRequest else { return }
        
        let match = BuddyMatch(
            eventId: event.id.uuidString,
            user1: userRequest.username,
            user2: request.username
        )
        
        matches.append(match)
    }
    
    private func cancelBuddyRequest() {
        userBuddyRequest?.status = .cancelled
        userBuddyRequest = nil
        
        // Remove from buddy requests list
        buddyRequests.removeAll { $0.username == locationManager.username }
        
        // Clear matches
        matches.removeAll()
    }
}

// MARK: - Buddy Request Card
struct BuddyRequestCard: View {
    let request: BuddyRequest
    let currentUser: String
    let onConnect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(request.username)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: request.buddyPreferences.lookingFor.icon)
                            .font(.caption)
                        Text(request.buddyPreferences.lookingFor.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(6)
                }
                
                if !request.buddyPreferences.description.isEmpty {
                    Text(request.buddyPreferences.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    Label(request.buddyPreferences.communicationStyle.rawValue, systemImage: request.buddyPreferences.communicationStyle.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(request.buddyPreferences.meetupPreference.rawValue, systemImage: request.buddyPreferences.meetupPreference.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: onConnect) {
                Image(systemName: "hand.wave.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Buddy Match Card
struct BuddyMatchCard: View {
    let match: BuddyMatch
    let currentUser: String
    
    private var otherUser: String {
        match.otherUser(from: currentUser)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(otherUser)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Matched!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                Spacer()
                
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                }
            }
            
            Text(match.status.rawValue)
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor(for: match.status).opacity(0.1))
                .foregroundColor(statusColor(for: match.status))
                .cornerRadius(4)
        }
        .padding()
        .frame(width: 160)
        .background(Color.green.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    private func statusColor(for status: BuddyMatchStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .accepted: return .blue
        case .declined: return .red
        case .confirmed: return .green
        case .meetingPlanned: return .purple
        case .completed: return .gray
        }
    }
}

#Preview {
    let sampleEvent = Event(
        title: "Tech Meetup",
        description: "A great tech meetup",
        location: "San Francisco",
        date: Date(),
        category: "tech",
        city: "San Francisco"
    )
    
    return BuddySystemView(event: sampleEvent, locationManager: LocationManager())
}
