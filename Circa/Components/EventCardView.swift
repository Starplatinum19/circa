//
//  EventCardView.swift
//  Circa
//
//  Created by Jackenson Charles on 3/23/25.
//


import SwiftUI

struct EventCardView: View {
    @ObservedObject var event: Event
    @ObservedObject var locationManager: LocationManager
    
    @State private var showingBuddySystem = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with comfort level overlay
            ZStack(alignment: .topTrailing) {
                // Photo carousel
                PhotoCarouselView(
                    imageDataArray: event.imageDataArray.isEmpty ? 
                        (event.imageData != nil ? [event.imageData!] : []) : event.imageDataArray,
                    height: 180,
                    cornerRadius: 16
                )
            }
            // Title + Star + Beginner Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    if event.isBeginnerFriendly {
                        HStack(spacing: 4) {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                            Text("Beginner Friendly")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                Spacer()
                Button(action: {
                    event.isStarred.toggle()
                }) {
                    Image(systemName: event.isStarred ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 18))
                }
            }
            // Comfort indicators row
            HStack(spacing: 12) {
                // Comfort level
                HStack(spacing: 4) {
                    Image(systemName: event.comfortLevel.icon)
                        .foregroundColor(Color(event.comfortLevel.color))
                        .font(.system(size: 14))
                    Text(event.comfortLevel.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Social intensity
                HStack(spacing: 4) {
                    Image(systemName: event.socialIntensity.icon)
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    Text(event.socialIntensity.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            // Additional comfort features
            HStack(spacing: 8) {
                if event.hasQuietSpaces {
                    FeatureBadge(icon: "speaker.slash.fill", text: "Quiet spaces", color: .blue)
                }
                if event.allowsEarlyExit {
                    FeatureBadge(icon: "door.left.hand.open", text: "Early exit OK", color: .green)
                }
                if !event.conversationStarters.isEmpty {
                    FeatureBadge(icon: "text.bubble.fill", text: "Convo starters", color: .purple)
                }
                Spacer()
            }
            
            // RSVP Section - only show for events that require RSVP
            if event.requiresRSVP {
                RSVPCardView(event: event)
            }
            
            // Buddy system section
            if !event.buddyRequestUsers.isEmpty || locationManager.userComfortPreferences?.wantsBuddySystem == true {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                        Text("\(event.buddyRequestUsers.count) looking for buddies")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        showingBuddySystem = true
                    }) {
                        Text("Find Buddy")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    }
                }
            }
            // Expected attendance
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    Text("~\(event.expectedAttendees)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            // Location + Date
            HStack {
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                Text(formattedDate(event.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 5)
        .sheet(isPresented: $showingBuddySystem) {
            BuddySystemView(event: event, locationManager: locationManager)
        }
    }
    // MARK: - Methods
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
// MARK: - Supporting Views
struct FeatureBadge: View {
    let icon: String
    let text: String
    let color: Color
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}
