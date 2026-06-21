//
//  ComfortPreferencesView.swift
//  Circa
//
//  Created by Jackenson Charles on 8/26/25.
//


//
//  ComfortPreferencesView.swift
//  Circa
//
//  Setup view for user comfort preferences

import SwiftUI

struct ComfortPreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var preferredComfortLevel: ComfortLevel = .small
    @State private var maxSocialIntensity: SocialIntensity = .moderate
    @State private var maxNoiseLevel: NoiseLevel = .moderate
    @State private var requiresQuietSpaces: Bool = true
    @State private var needsPreparationTips: Bool = true
    @State private var prefersBeginnerFriendly: Bool = true
    @State private var wantsBuddySystem: Bool = true
    @State private var currentStep: Int = 0
    
    let totalSteps = 7
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 30) {
                // Progress indicator
                HStack {
                    Text("Step \(currentStep + 1) of \(totalSteps)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .frame(width: 120)
                }
                .padding(.horizontal)
                Spacer()
                // Step content
                VStack(spacing: 24) {
                    switch currentStep {
                    case 0:
                        welcomeStep
                    case 1:
                        comfortLevelStep
                    case 2:
                        socialIntensityStep
                    case 3:
                        noiseLevelStep
                    case 4:
                        featuresStep
                    case 5:
                        buddySystemStep
                    case 6:
                        summaryStep
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal)
                Spacer()
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut) {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 100)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                    }
                    Spacer()
                    Button(currentStep == totalSteps - 1 ? "Finish" : "Next") {
                        if currentStep == totalSteps - 1 {
                            savePreferences()
                        } else {
                            withAnimation(.easeInOut) {
                                currentStep += 1
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(width: 100)
                    .background(Color.white)
                    .cornerRadius(25)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    // MARK: - Step Views
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
            Text("Let's personalize your experience")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("We'll help you find events that match your comfort level and preferences. This takes just a minute!")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    private var comfortLevelStep: some View {
        VStack(spacing: 20) {
            Text("What group size feels most comfortable?")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                ForEach(ComfortLevel.allCases, id: \.self) { level in
                    Button(action: {
                        preferredComfortLevel = level
                    }) {
                        HStack {
                            Image(systemName: level.icon)
                                .foregroundColor(Color(level.color))
                                .font(.system(size: 20))
                            Text(level.rawValue)
                                .foregroundColor(.white)
                                .font(.body)
                            Spacer()
                            if preferredComfortLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding()
                        .background(preferredComfortLevel == level ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                        .cornerRadius(15)
                    }
                }
            }
        }
    }
    private var socialIntensityStep: some View {
        VStack(spacing: 20) {
            Text("How much social interaction do you prefer?")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                ForEach(SocialIntensity.allCases, id: \.self) { intensity in
                    Button(action: {
                        maxSocialIntensity = intensity
                    }) {
                        HStack {
                            Image(systemName: intensity.icon)
                                .foregroundColor(.blue)
                                .font(.system(size: 20))
                            Text(intensity.rawValue)
                                .foregroundColor(.white)
                                .font(.body)
                            Spacer()
                            if maxSocialIntensity == intensity {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding()
                        .background(maxSocialIntensity == intensity ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                        .cornerRadius(15)
                    }
                }
            }
        }
    }
    private var noiseLevelStep: some View {
        VStack(spacing: 20) {
            Text("What noise level works best for you?")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                ForEach(NoiseLevel.allCases, id: \.self) { noise in
                    Button(action: {
                        maxNoiseLevel = noise
                    }) {
                        HStack {
                            Image(systemName: noise.icon)
                                .foregroundColor(.purple)
                                .font(.system(size: 20))
                            Text(noise.rawValue)
                                .foregroundColor(.white)
                                .font(.body)
                            Spacer()
                            if maxNoiseLevel == noise {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding()
                        .background(maxNoiseLevel == noise ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                        .cornerRadius(15)
                    }
                }
            }
        }
    }
    private var featuresStep: some View {
        VStack(spacing: 20) {
            Text("Which features would help you feel more comfortable?")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                ToggleRow(
                    icon: "speaker.slash.fill",
                    title: "Quiet spaces available",
                    description: "Events with designated quiet areas for breaks",
                    isOn: $requiresQuietSpaces
                )
                ToggleRow(
                    icon: "list.bullet.clipboard",
                    title: "Preparation tips",
                    description: "What to expect and how to prepare for events",
                    isOn: $needsPreparationTips
                )
                ToggleRow(
                    icon: "graduationcap.fill",
                    title: "Beginner-friendly events",
                    description: "Events designed for newcomers and first-timers",
                    isOn: $prefersBeginnerFriendly
                )
            }
        }
    }
    private var buddySystemStep: some View {
        VStack(spacing: 20) {
            Text("Would you like help finding event buddies?")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("Going with someone can make events more comfortable and fun!")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            VStack(spacing: 12) {
                Button(action: {
                    wantsBuddySystem = true
                }) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                        VStack(alignment: .leading) {
                            Text("Yes, help me find buddies")
                                .foregroundColor(.white)
                                .font(.body)
                                .fontWeight(.medium)
                            Text("Connect with others attending the same events")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.caption)
                        }
                        Spacer()
                        if wantsBuddySystem {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                        }
                    }
                    .padding()
                    .background(wantsBuddySystem ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                    .cornerRadius(15)
                }
                Button(action: {
                    wantsBuddySystem = false
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                        VStack(alignment: .leading) {
                            Text("No thanks, I prefer going solo")
                                .foregroundColor(.white)
                                .font(.body)
                                .fontWeight(.medium)
                            Text("I'm comfortable attending events on my own")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.caption)
                        }
                        Spacer()
                        if !wantsBuddySystem {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                        }
                    }
                    .padding()
                    .background(!wantsBuddySystem ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                    .cornerRadius(15)
                }
            }
        }
    }
    private var summaryStep: some View {
        VStack(spacing: 20) {
            Text("Your preferences")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            VStack(spacing: 12) {
                SummaryRow(icon: preferredComfortLevel.icon, title: "Preferred group size", value: preferredComfortLevel.rawValue, color: Color(preferredComfortLevel.color))
                SummaryRow(icon: maxSocialIntensity.icon, title: "Social interaction", value: maxSocialIntensity.rawValue, color: .blue)
                SummaryRow(icon: maxNoiseLevel.icon, title: "Noise level", value: maxNoiseLevel.rawValue, color: .purple)
                if requiresQuietSpaces {
                    SummaryRow(icon: "speaker.slash.fill", title: "Quiet spaces", value: "Required", color: .green)
                }
                if prefersBeginnerFriendly {
                    SummaryRow(icon: "graduationcap.fill", title: "Experience level", value: "Beginner-friendly", color: .green)
                }
                if wantsBuddySystem {
                    SummaryRow(icon: "person.2.fill", title: "Event buddies", value: "Interested", color: .orange)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            Text("These preferences will help us recommend events that match your comfort level. You can always change them later in your profile.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    // MARK: - Helper Methods
    private func savePreferences() {
        let preferences = UserComfortPreferences(
            preferredComfortLevel: preferredComfortLevel,
            maxSocialIntensity: maxSocialIntensity,
            maxNoiseLevel: maxNoiseLevel,
            requiresQuietSpaces: requiresQuietSpaces,
            needsPreparationTips: needsPreparationTips,
            prefersBeginnerFriendly: prefersBeginnerFriendly,
            wantsBuddySystem: wantsBuddySystem
        )
        locationManager.userComfortPreferences = preferences
        dismiss()
    }
}

// MARK: - Supporting Views
struct ToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 20))
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.body)
                    .fontWeight(.medium)
                Text(description)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
                .frame(width: 24)
            Text(title)
                .foregroundColor(.white)
                .font(.subheadline)
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)
        }
    }
}

#Preview {
    ComfortPreferencesView()
        .environmentObject(LocationManager())
}
