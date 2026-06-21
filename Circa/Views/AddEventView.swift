//
//  AddEventView.swift
//  Circa
//
//  Created by Jackenson Charles on 3/24/25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: EventsViewModel
    @EnvironmentObject var locationManager: LocationManager

    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var imageData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageDataArray: [Data] = [] // New: Array for multiple photos
    @State private var selectedPhotos: [PhotosPickerItem] = [] // New: Array for selected photos

    // RSVP Configuration
    @State private var requiresRSVP = false
    @State private var hasRSVPDeadline = false
    @State private var rsvpDeadline = Date()
    @State private var hasMaxAttendees = false
    @State private var maxAttendees = 50

    // Comfort Settings
    @State private var comfortLevel: ComfortLevel = .medium
    @State private var socialIntensity: SocialIntensity = .moderate
    @State private var noiseLevel: NoiseLevel = .moderate
    @State private var isBeginnerFriendly = false
    @State private var expectedAttendees = 50
    @State private var hasQuietSpaces = false
    @State private var allowsEarlyExit = true

    // Additional Features
    @State private var conversationStarters: [String] = []
    @State private var preparationTips: [String] = []
    @State private var newConversationStarter = ""
    @State private var newPreparationTip = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color("GradientTop"), Color("GradientMiddle"), Color("GradientBottom")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("EVENT INFO")
                            .font(.caption)
                            .foregroundColor(.white)

                        TextField("Title", text: $title)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .foregroundColor(.black)

                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
                            .foregroundColor(.black)
                            .scrollContentBackground(.hidden)

                        TextField("Location", text: $location)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .foregroundColor(.black)

                        DatePicker("Date", selection: $date, displayedComponents: [.date])
                            .foregroundColor(.black)

                        Divider().background(Color.white.opacity(0.5))

                        Text("EVENT PHOTOS (Up to 6)")
                            .font(.caption)
                            .foregroundColor(.white)

                        VStack(spacing: 12) {
                            // Display selected photos in a grid
                            if !imageDataArray.isEmpty {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 8) {
                                    ForEach(Array(imageDataArray.enumerated()), id: \.offset) { index, data in
                                        ZStack(alignment: .topTrailing) {
                                            if let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }
                                            
                                            // Remove button
                                            Button(action: {
                                                imageDataArray.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }

                            // Photo picker button
                            PhotosPicker(
                                selection: $selectedPhotos,
                                maxSelectionCount: 6,
                                matching: .images
                            ) {
                                HStack {
                                    Image(systemName: "photo.badge.plus")
                                    Text(imageDataArray.isEmpty ? "Select Photos (up to 6)" : "Add More Photos (\(imageDataArray.count)/6)")
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }
                            .disabled(imageDataArray.count >= 6)
                            .onChange(of: selectedPhotos) {
                                Task {
                                    var newImages: [Data] = []
                                    for photo in selectedPhotos {
                                        if let data = try? await photo.loadTransferable(type: Data.self) {
                                            newImages.append(data)
                                        }
                                    }
                                    // Ensure we don't exceed 6 photos
                                    let remainingSlots = 6 - imageDataArray.count
                                    let photosToAdd = Array(newImages.prefix(remainingSlots))
                                    imageDataArray.append(contentsOf: photosToAdd)
                                    selectedPhotos = [] // Clear selection after processing
                                }
                            }
                            
                            if imageDataArray.count >= 6 {
                                Text("Maximum 6 photos reached")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }

                        // RSVP Configuration Section
                        Group {
                            Text("RSVP CONFIGURATION")
                                .font(.caption)
                                .foregroundColor(.white)

                            Toggle("Requires RSVP", isOn: $requiresRSVP)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))

                            if requiresRSVP {
                                VStack(spacing: 10) {
                                    Toggle("Has RSVP Deadline", isOn: $hasRSVPDeadline)
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))

                                    if hasRSVPDeadline {
                                        DatePicker("RSVP Deadline", selection: $rsvpDeadline, displayedComponents: [.date, .hourAndMinute])
                                            .foregroundColor(.black)
                                    }

                                    Toggle("Has Max Attendees", isOn: $hasMaxAttendees)
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))

                                    if hasMaxAttendees {
                                        Stepper("Max Attendees: \(maxAttendees)", value: $maxAttendees, in: 1...100)
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }
                        }

                        // Comfort Settings Section
                        Group {
                            Text("COMFORT SETTINGS")
                                .font(.caption)
                                .foregroundColor(.white)

                            Picker("Comfort Level", selection: $comfortLevel) {
                                ForEach(ComfortLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue.capitalized).tag(level)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .foregroundColor(.black)

                            Picker("Social Intensity", selection: $socialIntensity) {
                                ForEach(SocialIntensity.allCases, id: \.self) { intensity in
                                    Text(intensity.rawValue.capitalized).tag(intensity)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .foregroundColor(.black)

                            Picker("Noise Level", selection: $noiseLevel) {
                                ForEach(NoiseLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue.capitalized).tag(level)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .foregroundColor(.black)

                            Toggle("Beginner Friendly", isOn: $isBeginnerFriendly)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))

                            Stepper("Expected Attendees: \(expectedAttendees)", value: $expectedAttendees, in: 1...100)
                                .foregroundColor(.black)

                            Toggle("Has Quiet Spaces", isOn: $hasQuietSpaces)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))

                            Toggle("Allows Early Exit", isOn: $allowsEarlyExit)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                        // Additional Features Section
                        Group {
                            Text("ADDITIONAL FEATURES")
                                .font(.caption)
                                .foregroundColor(.white)

                            ForEach(conversationStarters, id: \.self) { starter in
                                Text("• \(starter)")
                                    .foregroundColor(.black)
                            }

                            ForEach(preparationTips, id: \.self) { tip in
                                Text("• \(tip)")
                                    .foregroundColor(.black)
                            }

                            HStack {
                                TextField("New Conversation Starter", text: $newConversationStarter)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.black)

                                Button(action: {
                                    if !newConversationStarter.isEmpty {
                                        conversationStarters.append(newConversationStarter)
                                        newConversationStarter = ""
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.blue)
                                }
                            }

                            HStack {
                                TextField("New Preparation Tip", text: $newPreparationTip)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.black)

                                Button(action: {
                                    if !newPreparationTip.isEmpty {
                                        preparationTips.append(newPreparationTip)
                                        newPreparationTip = ""
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(location) { placemarks, error in
                            guard let placemark = placemarks?.first,
                                  let coordinate = placemark.location?.coordinate else {
                                print("Geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }

                            let newEvent = Event(
                                title: title,
                                description: description,
                                location: location,
                                date: date,
                                category: "General",
                                imageUrl: nil,
                                imageData: imageDataArray.first, // Use first image for backward compatibility
                                imageDataArray: imageDataArray, // Pass the full array
                                city: locationManager.currentCity,
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude,
                                createdByUser: true,
                                isStarred: false,
                                // Comfort Settings
                                comfortLevel: comfortLevel,
                                socialIntensity: socialIntensity,
                                noiseLevel: noiseLevel,
                                isBeginnerFriendly: isBeginnerFriendly,
                                expectedAttendees: expectedAttendees,
                                buddyRequestUsers: [],
                                conversationStarters: conversationStarters,
                                preparationTips: preparationTips,
                                hasQuietSpaces: hasQuietSpaces,
                                allowsEarlyExit: allowsEarlyExit,
                                requiresRSVP: requiresRSVP,
                                // RSVP Settings
                                rsvpResponses: [],
                                rsvpDeadline: hasRSVPDeadline ? rsvpDeadline : nil,
                                maxAttendees: hasMaxAttendees ? maxAttendees : nil
                            )

                            viewModel.events.append(newEvent)
                            locationManager.incrementEventsCreated()
                            PersistenceManager.saveEvents(viewModel.events) // ✅ Immediate save
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || location.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddEventView(viewModel: EventsViewModel())
        .environmentObject(LocationManager())
}
