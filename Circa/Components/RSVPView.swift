//
//  RSVPView.swift
//  Circa
//
//  Created by Jackenson on 8/28/25.
//

import SwiftUI

struct RSVPView: View {
    @ObservedObject var event: Event
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedStatus: RSVPStatus
    @State private var rsvpNote: String = ""
    @State private var showingNoteSheet = false
    
    init(event: Event) {
        self.event = event
        self._selectedStatus = State(initialValue: .none)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if event.requiresRSVP {
                // RSVP Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.blue)
                        Text("RSVP Required")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    // RSVP Deadline Warning
                    if let deadline = event.rsvpDeadline {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("RSVP by \(deadline, format: .dateTime.weekday().month().day().hour().minute())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    
                    // Capacity Warning
                    if let maxAttendees = event.maxAttendees {
                        let goingCount = event.rsvpCounts.going
                        let spotsLeft = maxAttendees - goingCount
                        
                        if spotsLeft <= 5 {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("\(spotsLeft) spots left")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // RSVP Options
                VStack(spacing: 12) {
                    Text("Your Response")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach([RSVPStatus.going, RSVPStatus.maybe, RSVPStatus.notGoing], id: \.self) { status in
                            RSVPButton(
                                status: status,
                                isSelected: selectedStatus == status,
                                isDisabled: event.rsvpDeadlinePassed || (status == .going && event.isAtCapacity && selectedStatus != .going)
                            ) {
                                selectRSVPStatus(status)
                            }
                        }
                    }
                    
                    // Add Note Button
                    if selectedStatus != .none {
                        Button(action: {
                            showingNoteSheet = true
                        }) {
                            HStack {
                                Image(systemName: "note.text")
                                Text(rsvpNote.isEmpty ? "Add a note (optional)" : "Edit note")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                
                // RSVP Summary
                RSVPSummaryView(event: event)
                
            } else {
                // No RSVP Required
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                        Text("No RSVP Required")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    Text("Just show up! This event welcomes drop-ins.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .onAppear {
            let currentUser = locationManager.username.isEmpty ? "AnonymousUser" : locationManager.username
            selectedStatus = event.getCurrentRSVP(for: currentUser)
        }
        .sheet(isPresented: $showingNoteSheet) {
            RSVPNoteSheet(note: $rsvpNote) {
                updateRSVP()
            }
        }
    }
    
    private func selectRSVPStatus(_ status: RSVPStatus) {
        selectedStatus = status
        updateRSVP()
    }
    
    private func updateRSVP() {
        let currentUser = locationManager.username.isEmpty ? "AnonymousUser" : locationManager.username
        event.updateRSVP(username: currentUser, status: selectedStatus, note: rsvpNote.isEmpty ? nil : rsvpNote)
        event.objectWillChange.send()
        print("DEBUG: RSVP updated for user \(currentUser) with status \(selectedStatus)")
        print("DEBUG: RSVP counts - Going: \(event.rsvpCounts.going), Maybe: \(event.rsvpCounts.maybe), Not Going: \(event.rsvpCounts.notGoing)")
    }
}

struct RSVPButton: View {
    let status: RSVPStatus
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: status.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color(status.color))
                
                Text(status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color(status.color) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(status.color), lineWidth: isSelected ? 0 : 1)
            )
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled)
    }
}

struct RSVPSummaryView: View {
    @ObservedObject var event: Event
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Event Attendance")
                    .font(.headline)
                Spacer()
            }
            
            let counts = event.rsvpCounts
            
            HStack(spacing: 20) {
                RSVPCountBadge(
                    icon: "checkmark.circle.fill",
                    count: counts.going,
                    label: "Going",
                    color: .green
                )
                
                RSVPCountBadge(
                    icon: "questionmark.circle.fill",
                    count: counts.maybe,
                    label: "Maybe",
                    color: .orange
                )
                
                RSVPCountBadge(
                    icon: "xmark.circle.fill",
                    count: counts.notGoing,
                    label: "Not Going",
                    color: .red
                )
                
                Spacer()
            }
            
            // Capacity Progress
            if let maxAttendees = event.maxAttendees {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Capacity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(counts.going)/\(maxAttendees)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    ProgressView(value: Double(counts.going), total: Double(maxAttendees))
                        .progressViewStyle(LinearProgressViewStyle(tint: counts.going >= maxAttendees ? .red : .blue))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RSVPCountBadge: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct RSVPNoteSheet: View {
    @Binding var note: String
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add a note to your RSVP (optional)")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text("Let the organizer know about any special needs, questions, or just say hi!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                TextEditor(text: $note)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("RSVP Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var sampleEvent = Event(
        title: "Sample Event",
        description: "A sample event for preview",
        location: "Sample Location",
        date: Date().addingTimeInterval(86400),
        category: "Sample",
        city: "Sample City",
        requiresRSVP: true,
        rsvpDeadline: Date().addingTimeInterval(43200), // 12 hours from now
        maxAttendees: 25
    )
    
    let mockLocationManager = LocationManager()
    mockLocationManager.username = "PreviewUser"
    
    return RSVPView(event: sampleEvent)
        .environmentObject(mockLocationManager)
        .padding()
}
