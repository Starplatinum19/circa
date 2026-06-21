//
//  BuddyMatchesView.swift
//  Circa
//
//  Created by Jackenson on 8/30/25.
//

import SwiftUI

struct BuddyMatchesView: View {
    @State var matches: [BuddyMatch]
    let currentUser: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMatch: BuddyMatch?
    @State private var showingChat = false
    
    var body: some View {
        NavigationView {
            VStack {
                if matches.isEmpty {
                    emptyStateView
                } else {
                    matchesListView
                }
            }
            .navigationTitle("Your Buddy Matches")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedMatch) { match in
            BuddyChatView(match: match, currentUser: currentUser)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Matches Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Once you set your buddy preferences, we'll find compatible event attendees for you!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var matchesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(matches) { match in
                    BuddyMatchDetailCard(
                        match: match,
                        currentUser: currentUser,
                        onAccept: { acceptMatch(match) },
                        onDecline: { declineMatch(match) },
                        onMessage: { openChat(match) },
                        onPlanMeeting: { planMeeting(match) }
                    )
                }
            }
            .padding()
        }
    }
    
    private func acceptMatch(_ match: BuddyMatch) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index].status = .accepted
        }
    }
    
    private func declineMatch(_ match: BuddyMatch) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index].status = .declined
        }
    }
    
    private func openChat(_ match: BuddyMatch) {
        selectedMatch = match
        showingChat = true
    }
    
    private func planMeeting(_ match: BuddyMatch) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index].status = .meetingPlanned
        }
    }
}

// MARK: - Buddy Match Detail Card
struct BuddyMatchDetailCard: View {
    let match: BuddyMatch
    let currentUser: String
    let onAccept: () -> Void
    let onDecline: () -> Void
    let onMessage: () -> Void
    let onPlanMeeting: () -> Void
    
    private var otherUser: String {
        match.otherUser(from: currentUser)
    }
    
    private var compatibilityScore: Int {
        // Simulate compatibility score calculation
        Int.random(in: 75...95)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            headerSection
            
            compatibilitySection
            
            if match.status == .pending {
                pendingActionsSection
            } else if match.status == .accepted {
                acceptedActionsSection
            } else {
                statusSection
            }
            
            if !match.messages.isEmpty {
                recentMessageSection
            }
        }
        .padding()
        .background(backgroundColorForStatus)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColorForStatus, lineWidth: 1)
        )
        .cornerRadius(16)
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUser)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    statusBadge
                }
                
                Text("Matched \(timeAgoSince(match.matchedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var compatibilitySection: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                    .font(.system(size: 14))
                Text("\(compatibilityScore)% compatible")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                Text("Responds quickly")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.pink.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var pendingActionsSection: some View {
        VStack(spacing: 12) {
            Text("You have a potential buddy match!")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button(action: onDecline) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Pass")
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: onAccept) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Connect")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var acceptedActionsSection: some View {
        VStack(spacing: 12) {
            Text("You're connected! Start planning your meetup.")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button(action: onMessage) {
                    HStack {
                        Image(systemName: "message")
                        Text("Message")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: onPlanMeeting) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Plan Meeting")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var statusSection: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text(statusText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(statusColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var recentMessageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Message")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Spacer()
                if let lastMessage = match.messages.last {
                    Text(timeAgoSince(lastMessage.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let lastMessage = match.messages.last {
                HStack {
                    Text(lastMessage.from == currentUser ? "You:" : "\(lastMessage.from):")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(lastMessage.message)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var statusBadge: some View {
        Text(match.status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var backgroundColorForStatus: Color {
        switch match.status {
        case .pending: return Color.orange.opacity(0.03)
        case .accepted: return Color.green.opacity(0.03)
        case .declined: return Color.red.opacity(0.03)
        case .confirmed: return Color.blue.opacity(0.03)
        case .meetingPlanned: return Color.purple.opacity(0.03)
        case .completed: return Color.gray.opacity(0.03)
        }
    }
    
    private var borderColorForStatus: Color {
        switch match.status {
        case .pending: return Color.orange.opacity(0.3)
        case .accepted: return Color.green.opacity(0.3)
        case .declined: return Color.red.opacity(0.3)
        case .confirmed: return Color.blue.opacity(0.3)
        case .meetingPlanned: return Color.purple.opacity(0.3)
        case .completed: return Color.gray.opacity(0.3)
        }
    }
    
    private var statusColor: Color {
        switch match.status {
        case .pending: return .orange
        case .accepted: return .green
        case .declined: return .red
        case .confirmed: return .blue
        case .meetingPlanned: return .purple
        case .completed: return .gray
        }
    }
    
    private var statusIcon: String {
        switch match.status {
        case .pending: return "clock"
        case .accepted: return "checkmark.circle"
        case .declined: return "xmark.circle"
        case .confirmed: return "handshake"
        case .meetingPlanned: return "calendar.badge.checkmark"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch match.status {
        case .pending: return "Waiting for response"
        case .accepted: return "Connected! Ready to chat"
        case .declined: return "This match was declined"
        case .confirmed: return "Meeting confirmed"
        case .meetingPlanned: return "Meeting planned"
        case .completed: return "Event completed"
        }
    }
    
    private func timeAgoSince(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Simple Chat View
struct BuddyChatView: View {
    @State var match: BuddyMatch
    let currentUser: String
    @Environment(\.dismiss) private var dismiss
    @State private var newMessage = ""
    @State private var showingMeetupPlanner = false
    
    private var otherUser: String {
        match.otherUser(from: currentUser)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if match.messages.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "hand.wave.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                
                                Text("Say hello to \(otherUser)!")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Start the conversation and plan your meetup for the event.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ForEach(match.messages) { message in
                                MessageBubble(message: message, isFromCurrentUser: message.from == currentUser)
                            }
                        }
                    }
                    .padding()
                }
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(newMessage.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
            }
            .navigationTitle(otherUser)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingMeetupPlanner = true
                    }) {
                        Image(systemName: "calendar")
                    }
                }
            }
        }
        .sheet(isPresented: $showingMeetupPlanner) {
            MeetupPlannerView(match: $match)
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let message = BuddyMessage(from: currentUser, to: otherUser, message: newMessage)
        match.messages.append(message)
        newMessage = ""
    }
}

struct MessageBubble: View {
    let message: BuddyMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(18)
                
                Text(timeAgoSince(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
    
    private func timeAgoSince(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Meetup Planner
struct MeetupPlannerView: View {
    @Binding var match: BuddyMatch
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var meetupLocation = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Meeting Time") {
                    DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Meeting Location") {
                    TextField("Where should you meet?", text: $meetupLocation)
                    Text("Examples: Coffee shop nearby, event entrance, parking area")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notes") {
                    TextField("Any additional details...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(action: saveMeetupDetails) {
                        Text("Share Meeting Plan")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .disabled(meetupLocation.isEmpty)
                }
            }
            .navigationTitle("Plan Your Meetup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveMeetupDetails() {
        var meetupDetails = MeetupDetails()
        meetupDetails.time = selectedDate
        meetupDetails.location = meetupLocation
        meetupDetails.notes = notes.isEmpty ? nil : notes
        
        match.meetupDetails = meetupDetails
        match.status = .meetingPlanned
        
        dismiss()
    }
}

#Preview {
    let sampleMatch = BuddyMatch(eventId: "1", user1: "Alice", user2: "Bob")
    BuddyMatchesView(matches: [sampleMatch], currentUser: "Alice")
}
