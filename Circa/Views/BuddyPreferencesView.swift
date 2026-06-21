//
//  BuddyPreferencesView.swift
//  Circa
//
//  Created by Jackenson on 8/30/25.
//

import SwiftUI

struct BuddyPreferencesView: View {
    let event: Event
    @ObservedObject var locationManager: LocationManager
    let onComplete: (BuddyRequest) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var lookingFor: BuddyType = .anyone
    @State private var selectedAgeRange: AgeRange? = nil
    @State private var interests: [String] = []
    @State private var meetupPreference: MeetupPreference = .atEvent
    @State private var communicationStyle: CommunicationStyle = .friendly
    @State private var description: String = ""
    @State private var currentStep = 0
    
    private let availableInterests = [
        "Technology", "Music", "Art", "Food", "Sports", "Gaming", "Reading",
        "Photography", "Travel", "Fitness", "Movies", "Cooking", "Dancing",
        "Networking", "Learning", "Nature", "Comedy", "Fashion", "Business"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case 0: buddyTypeStep
                        case 1: ageRangeStep
                        case 2: interestsStep
                        case 3: meetupPreferenceStep
                        case 4: communicationStyleStep
                        case 5: descriptionStep
                        default: summaryStep
                        }
                    }
                    .padding()
                }
                
                navigationButtons
            }
            .navigationTitle("Buddy Preferences")
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
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<7) { step in
                    Rectangle()
                        .fill(step <= currentStep ? Color.orange : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            
            Text("Step \(currentStep + 1) of 7")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var buddyTypeStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "What kind of buddy are you looking for?",
                subtitle: "This helps us find someone compatible"
            )
            
            LazyVStack(spacing: 12) {
                ForEach(BuddyType.allCases, id: \.self) { type in
                    BuddyTypeCard(
                        type: type,
                        isSelected: lookingFor == type
                    ) {
                        lookingFor = type
                    }
                }
            }
        }
    }
    
    private var ageRangeStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "Age preference?",
                subtitle: "Optional - helps find people in similar life stages"
            )
            
            VStack(spacing: 12) {
                Button(action: {
                    selectedAgeRange = nil
                }) {
                    HStack {
                        Image(systemName: selectedAgeRange == nil ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedAgeRange == nil ? .orange : .gray)
                        Text("No preference")
                            .foregroundColor(selectedAgeRange == nil ? .orange : .primary)
                        Spacer()
                    }
                    .padding()
                    .background(selectedAgeRange == nil ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                
                ForEach(AgeRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedAgeRange = range
                    }) {
                        HStack {
                            Image(systemName: selectedAgeRange == range ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedAgeRange == range ? .orange : .gray)
                            Text(range.rawValue)
                                .foregroundColor(selectedAgeRange == range ? .orange : .primary)
                            Spacer()
                        }
                        .padding()
                        .background(selectedAgeRange == range ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var interestsStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "What are you interested in?",
                subtitle: "Select topics you'd enjoy discussing (optional)"
            )
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(availableInterests, id: \.self) { interest in
                    Button(action: {
                        if interests.contains(interest) {
                            interests.removeAll { $0 == interest }
                        } else {
                            interests.append(interest)
                        }
                    }) {
                        HStack {
                            Image(systemName: interests.contains(interest) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(interests.contains(interest) ? .orange : .gray)
                            Text(interest)
                                .font(.subheadline)
                                .foregroundColor(interests.contains(interest) ? .orange : .primary)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(interests.contains(interest) ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            }
            
            if !interests.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected interests:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(interests, id: \.self) { interest in
                            Text(interest)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(6)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.orange.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    private var meetupPreferenceStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "When would you like to meet?",
                subtitle: "Choose what works best for you"
            )
            
            VStack(spacing: 12) {
                ForEach(MeetupPreference.allCases, id: \.self) { preference in
                    Button(action: {
                        meetupPreference = preference
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: preference.icon)
                                .foregroundColor(meetupPreference == preference ? .orange : .gray)
                                .font(.system(size: 20))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preference.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(meetupPreference == preference ? .orange : .primary)
                                Text(preference.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: meetupPreference == preference ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(meetupPreference == preference ? .orange : .gray)
                        }
                        .padding()
                        .background(meetupPreference == preference ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var communicationStyleStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "What's your communication style?",
                subtitle: "This helps match you with someone compatible"
            )
            
            VStack(spacing: 12) {
                ForEach(CommunicationStyle.allCases, id: \.self) { style in
                    Button(action: {
                        communicationStyle = style
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: style.icon)
                                .foregroundColor(communicationStyle == style ? .orange : .gray)
                                .font(.system(size: 20))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(style.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(communicationStyle == style ? .orange : .primary)
                                Text(style.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: communicationStyle == style ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(communicationStyle == style ? .orange : .gray)
                        }
                        .padding()
                        .background(communicationStyle == style ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var descriptionStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "Tell potential buddies about yourself",
                subtitle: "Optional - a brief introduction or what you're hoping to get from this event"
            )
            
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $description)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                HStack {
                    Spacer()
                    Text("\(description.count)/200")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Examples:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• \"First time at this type of event, would love to meet someone friendly!\"")
                    Text("• \"Love discussing tech trends and meeting fellow developers\"")
                    Text("• \"Looking for someone to grab coffee with before the event\"")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private var summaryStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                title: "Review your buddy preferences",
                subtitle: "Make sure everything looks good before we find your match"
            )
            
            VStack(spacing: 16) {
                PreferenceSummaryRow(
                    icon: lookingFor.icon,
                    title: "Looking for",
                    value: lookingFor.rawValue,
                    color: .orange
                )
                
                if let ageRange = selectedAgeRange {
                    PreferenceSummaryRow(
                        icon: "person.crop.circle",
                        title: "Age range",
                        value: ageRange.rawValue,
                        color: .blue
                    )
                }
                
                if !interests.isEmpty {
                    PreferenceSummaryRow(
                        icon: "heart.fill",
                        title: "Interests",
                        value: "\(interests.count) selected",
                        color: .purple
                    )
                }
                
                PreferenceSummaryRow(
                    icon: meetupPreference.icon,
                    title: "Meeting preference",
                    value: meetupPreference.rawValue,
                    color: .green
                )
                
                PreferenceSummaryRow(
                    icon: communicationStyle.icon,
                    title: "Communication style",
                    value: communicationStyle.rawValue,
                    color: .cyan
                )
                
                if !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.quote")
                                .foregroundColor(.gray)
                            Text("About you")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button(action: {
                    withAnimation {
                        currentStep -= 1
                    }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            Button(action: {
                if currentStep < 6 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    createBuddyRequest()
                }
            }) {
                Text(currentStep < 6 ? "Next" : "Find My Buddy!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
    
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func createBuddyRequest() {
        let preferences = BuddyPreferences(
            lookingFor: lookingFor,
            ageRange: selectedAgeRange,
            interests: interests,
            meetupPreference: meetupPreference,
            communicationStyle: communicationStyle,
            description: description
        )
        
        let request = BuddyRequest(
            username: locationManager.username,
            eventId: event.id.uuidString,
            buddyPreferences: preferences
        )
        
        onComplete(request)
        dismiss()
    }
}

// MARK: - Supporting Views
struct BuddyTypeCard: View {
    let type: BuddyType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(isSelected ? .orange : .gray)
                    .font(.system(size: 20))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .orange : .primary)
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .padding()
            .background(isSelected ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct PreferenceSummaryRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// Simple FlowLayout for interests
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
}

private struct FlowResult {
    var size = CGSize.zero
    var positions: [CGPoint] = []
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if x + subviewSize.width > maxWidth && x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: x, y: y))
            x += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
        }
        
        size = CGSize(width: maxWidth, height: y + lineHeight)
    }
}

#Preview {
    let sampleEvent = Event(
        title: "Tech Meetup",
        description: "A great tech meetup",
        location: "San Francisco", date: Date(),
        category: "tech",
        city: "San Francisco"
    )
    
    BuddyPreferencesView(
        event: sampleEvent,
        locationManager: LocationManager()
    ) { _ in }
}
