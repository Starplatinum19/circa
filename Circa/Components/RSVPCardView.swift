//
//  RSVPCardView.swift
//  Circa
//
//  Created by Jackenson on 8/28/25.
//

import SwiftUI

struct RSVPCardView: View {
    @ObservedObject var event: Event
    
    // Mock current user - in a real app this would come from user session
    private let currentUser = "CurrentUser"
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                Text("RSVP Required")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                // User's current RSVP status
                let userStatus = event.getCurrentRSVP(for: currentUser)
                if userStatus != .none {
                    HStack(spacing: 4) {
                        Image(systemName: userStatus.icon)
                            .foregroundColor(Color(userStatus.color))
                            .font(.system(size: 12))
                        Text(userStatus.rawValue)
                            .font(.caption2)
                            .foregroundColor(Color(userStatus.color))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(userStatus.color).opacity(0.1))
                    .cornerRadius(6)
                }
            }
            
            // RSVP counts summary
            HStack(spacing: 12) {
                let counts = event.rsvpCounts
                
                RSVPMiniCount(icon: "checkmark.circle.fill", count: counts.going, color: .green)
                RSVPMiniCount(icon: "questionmark.circle.fill", count: counts.maybe, color: .orange)
                RSVPMiniCount(icon: "xmark.circle.fill", count: counts.notGoing, color: .red)
                
                Spacer()
                
                // Capacity warning
                if let maxAttendees = event.maxAttendees {
                    let spotsLeft = maxAttendees - counts.going
                    if spotsLeft <= 5 && spotsLeft > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.system(size: 10))
                            Text("\(spotsLeft) left")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    } else if spotsLeft <= 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                                .font(.system(size: 10))
                            Text("Full")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Deadline warning
                if let deadline = event.rsvpDeadline {
                    let timeLeft = deadline.timeIntervalSince(Date())
                    if timeLeft > 0 && timeLeft < 86400 { // Less than 24 hours
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                                .font(.system(size: 10))
                            Text("Soon")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

struct RSVPMiniCount: View {
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 10))
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

#Preview {
    let sampleEvent = Event(
        title: "Sample Event",
        description: "A sample event for preview",
        location: "Sample Location",
        date: Date().addingTimeInterval(86400),
        category: "Sample",
        city: "Sample City",
        requiresRSVP: true,
        rsvpResponses: [
            RSVPResponse(username: "User1", status: .going),
            RSVPResponse(username: "User2", status: .going),
            RSVPResponse(username: "User3", status: .maybe),
            RSVPResponse(username: "User4", status: .notGoing)
        ],
        rsvpDeadline: Date().addingTimeInterval(43200), // 12 hours from now
        maxAttendees: 25
    )
    
    return RSVPCardView(event: sampleEvent)
        .padding()
}
