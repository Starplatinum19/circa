//
//  EventDetailView.swift
//  Circa
//
//  Created by Jackenson Charles on 3/23/25.
//


import SwiftUI

struct EventDetailView: View {
    @ObservedObject var event: Event
    @State private var newComment: String = ""
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color("GradientTop"),
                    Color("GradientMiddle")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    EventImageView(imageData: event.imageData)

                    Text(event.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.white)

                    Text("Location: \(event.location)")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Text("Date: \(formattedDate(event.date))")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    // RSVP Section
                    RSVPView(event: event)

                    Divider()

                    // Reactions Row
                    reactionsRow
                        .padding(.vertical, 10)

                    Divider()

                    // Check-in Button
                    if let eventLat = event.latitude, let eventLon = event.longitude, let userLat = locationManager.currentLatitude, let userLon = locationManager.currentLongitude {
                        let distance = haversineDistance(lat1: eventLat, lon1: eventLon, lat2: userLat, lon2: userLon)
                        let user = locationManager.username.isEmpty ? "AnonymousUser" : locationManager.username
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                if !event.checkedInUsers.contains(user) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        event.checkedInUsers.append(user)
                                        locationManager.incrementCheckIns()
                                        event.objectWillChange.send()
                                        print("DEBUG: User \(user) checked in. Total: \(event.checkedInUsers.count)")
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: event.checkedInUsers.contains(user) ? "checkmark.seal.fill" : "location.fill")
                                        .foregroundColor(event.checkedInUsers.contains(user) ? .green : (distance < 0.2 ? .blue : .gray))
                                        .scaleEffect(event.checkedInUsers.contains(user) ? 1.2 : 1.0)
                                        .animation(.spring(), value: event.checkedInUsers.contains(user))
                                    Text(event.checkedInUsers.contains(user) ? "Checked In" : (distance < 0.2 ? "Check In" : "Too Far to Check In"))
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(event.checkedInUsers.contains(user) ? Color.green.opacity(0.7) : (distance < 0.2 ? Color.blue.opacity(0.7) : Color.gray.opacity(0.5)))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(distance >= 0.2 || event.checkedInUsers.contains(user))
                            // Checked-in users horizontal list
                            if !event.checkedInUsers.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(event.checkedInUsers, id: \.self) { username in
                                            VStack {
                                                if username == locationManager.username, let image = locationManager.profileImage {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 36, height: 36)
                                                        .clipShape(Circle())
                                                } else {
                                                    Circle()
                                                        .fill(Color.accentColor.opacity(0.8))
                                                        .frame(width: 36, height: 36)
                                                        .overlay(
                                                            Text(String(username.prefix(2)).uppercased())
                                                                .font(.headline)
                                                                .foregroundColor(.white)
                                                        )
                                                }
                                                Text(username)
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            Text("Checked-in users: \(event.checkedInUsers.count)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Divider()

                    // Comments Section
                    Text("Comments")
                        .font(.headline)
                        .foregroundColor(.white)
                    ForEach(event.comments) { comment in
                        HStack(alignment: .top, spacing: 10) {
                            if comment.username == locationManager.username, let image = locationManager.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.8))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(String(comment.username.prefix(2)).uppercased())
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    )
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(comment.username)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                    Text(comment.timestamp, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Text(comment.text)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    HStack {
                        TextField("Add your comment...", text: $newComment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Submit") {
                            let trimmed = newComment.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty {
                                let comment = Comment(username: locationManager.username.isEmpty ? "User" : locationManager.username, text: trimmed)
                                event.comments.append(comment)
                                locationManager.incrementComments()
                                newComment = ""
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if event.reactions["👍"] == nil { event.reactions["👍"] = 0 }
            if event.reactions["👎"] == nil { event.reactions["👎"] = 0 }
        }
    }

    private var reactionsRow: some View {
        let user = locationManager.username.isEmpty ? "AnonymousUser" : locationManager.username
        return HStack(spacing: 16) {
            ForEach(event.reactions.keys.sorted(), id: \.self) { emoji in
                ReactionButton(
                    emoji: emoji,
                    count: max(0, event.reactions[emoji, default: 0]),
                    isSelected: event.userReactions[user] == emoji
                ) {
                    let previousReaction = event.userReactions[user]
                    
                    print("DEBUG: User '\(user)' tapping \(emoji)")
                    print("DEBUG: Previous reaction: \(previousReaction ?? "none")")
                    print("DEBUG: Current count for \(emoji): \(event.reactions[emoji, default: 0])")
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if previousReaction == emoji {
                            // Remove reaction
                            event.userReactions[user] = nil
                            let currentCount = event.reactions[emoji, default: 0]
                            event.reactions[emoji] = max(0, currentCount - 1)
                            print("DEBUG: Removed reaction. New count: \(event.reactions[emoji, default: 0])")
                        } else {
                            // Remove previous reaction if exists
                            if let prev = previousReaction {
                                let prevCount = event.reactions[prev, default: 0]
                                event.reactions[prev] = max(0, prevCount - 1)
                                print("DEBUG: Removed previous reaction \(prev). New count: \(event.reactions[prev, default: 0])")
                            }
                            // Add new reaction
                            event.userReactions[user] = emoji
                            let currentCount = event.reactions[emoji, default: 0]
                            event.reactions[emoji] = currentCount + 1
                            print("DEBUG: Added reaction \(emoji). New count: \(event.reactions[emoji, default: 0])")
                        }
                        
                        // Trigger UI update by modifying the event object
                        event.objectWillChange.send()
                    }
                    
                    print("DEBUG: Final reactions state: \(event.reactions)")
                    print("DEBUG: Final user reactions: \(event.userReactions)")
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Haversine formula for distance in miles
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 3958.8 // Radius of Earth in miles
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c
    }
}
#Preview {
    struct PreviewWrapper: View {
        let sampleEvent = Event(
            title: "Sample Event",
            description: "This is a preview of the event detail view.",
            location: "Preview Park",
            date: Date(),
            category: "Music",
            imageUrl: nil,
            imageData: nil,
            city: "Miami"
        )
        @StateObject var mockLocationManager = LocationManager()
        var body: some View {
            EventDetailView(event: sampleEvent)
                .environmentObject(mockLocationManager)
        }
    }
    return PreviewWrapper()
}
