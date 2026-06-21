//
//  Event.swift
//  Circa
//
//  Created by Jackenson Charles on 3/23/25.
//

import Foundation
import Combine

// MARK: - RSVP System
enum RSVPStatus: String, CaseIterable, Codable {
    case going = "Going"
    case maybe = "Maybe"
    case notGoing = "Not Going"
    case none = "No Response"
    
    var color: String {
        switch self {
        case .going: return "green"
        case .maybe: return "orange"
        case .notGoing: return "red"
        case .none: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .going: return "checkmark.circle.fill"
        case .maybe: return "questionmark.circle.fill"
        case .notGoing: return "xmark.circle.fill"
        case .none: return "circle"
        }
    }
}

struct RSVPResponse: Identifiable, Codable {
    let id: UUID
    let username: String
    let status: RSVPStatus
    let timestamp: Date
    let note: String? // Optional note from user
    
    init(id: UUID = UUID(), username: String, status: RSVPStatus, timestamp: Date = Date(), note: String? = nil) {
        self.id = id
        self.username = username
        self.status = status
        self.timestamp = timestamp
        self.note = note
    }
}

struct Comment: Identifiable, Codable, Hashable {
    let id: UUID
    let username: String
    let text: String
    let timestamp: Date

    init(id: UUID = UUID(), username: String, text: String, timestamp: Date = Date()) {
        self.id = id
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}

// MARK: - Introvert-friendly Enums

enum ComfortLevel: String, CaseIterable, Codable {
    case intimate = "Intimate (< 20 people)"
    case small = "Small Group (20-50 people)"
    case medium = "Medium (50-100 people)"
    case large = "Large (100+ people)"
    
    var icon: String {
        switch self {
        case .intimate: return "person.2.fill"
        case .small: return "person.3.fill"
        case .medium: return "person.crop.circle.fill"
        case .large: return "person.3.sequence.fill"
        }
    }
    
    var color: String {
        switch self {
        case .intimate: return "green"
        case .small: return "blue"
        case .medium: return "orange"
        case .large: return "red"
        }
    }
}

enum SocialIntensity: String, CaseIterable, Codable {
    case minimal = "Minimal interaction required"
    case optional = "Interaction optional"
    case moderate = "Some interaction expected"
    case high = "High social interaction"
    
    var icon: String {
        switch self {
        case .minimal: return "eye.slash"
        case .optional: return "hand.wave"
        case .moderate: return "message"
        case .high: return "megaphone"
        }
    }
}

enum NoiseLevel: String, CaseIterable, Codable {
    case quiet = "Quiet environment"
    case moderate = "Moderate noise"
    case loud = "Loud environment"
    
    var icon: String {
        switch self {
        case .quiet: return "speaker.slash"
        case .moderate: return "speaker.wave.1"
        case .loud: return "speaker.wave.3"
        }
    }
}

class Event: Identifiable, Codable, ObservableObject {
    let id: UUID
    let title: String
    let description: String
    let location: String
    let date: Date
    let category: String
    let imageUrl: String? // Keep for backward compatibility
    let imageData: Data? // Keep for backward compatibility
    @Published var imageDataArray: [Data] // New: Array of image data for multiple photos
    let city: String

    let latitude: Double?
    let longitude: Double?

    @Published var comments: [Comment]
    @Published var reactions: [String: Int] {
        didSet {
            print("DEBUG: reactions changed to", reactions)
        }
    }
    @Published var checkedInUsers: [String]
    @Published var userReactions: [String: String] // [username: emoji]
    var createdByUser: Bool
    @Published var isStarred: Bool // ✅ New: tracks interest

    // MARK: - Introvert-friendly properties
    var comfortLevel: ComfortLevel
    var socialIntensity: SocialIntensity
    var noiseLevel: NoiseLevel
    var isBeginnerFriendly: Bool
    var expectedAttendees: Int
    @Published var buddyRequestUsers: [String] // Users looking for event buddies
    var conversationStarters: [String] // Helpful for shy attendees
    var preparationTips: [String] // What to expect, how to prepare
    var hasQuietSpaces: Bool // Designated quiet areas for breaks
    var allowsEarlyExit: Bool // No pressure to stay entire time
    var requiresRSVP: Bool // Helps with planning and reduces anxiety
    
    // MARK: - RSVP Properties
    @Published var rsvpResponses: [RSVPResponse] // All RSVP responses
    var rsvpDeadline: Date? // Optional deadline for RSVPs
    var maxAttendees: Int? // Optional capacity limit

    // MARK: - Codable Keys
    private enum CodingKeys: String, CodingKey {
        case id, title, description, location, date, category, imageUrl, imageData, imageDataArray, city
        case latitude, longitude, comments, reactions, checkedInUsers, userReactions, createdByUser, isStarred
        case comfortLevel, socialIntensity, noiseLevel, isBeginnerFriendly, expectedAttendees, buddyRequestUsers
        case conversationStarters, preparationTips, hasQuietSpaces, allowsEarlyExit, requiresRSVP
        case rsvpResponses, rsvpDeadline, maxAttendees
    }

    // MARK: - Codable Implementation
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        location = try container.decode(String.self, forKey: .location)
        date = try container.decode(Date.self, forKey: .date)
        category = try container.decode(String.self, forKey: .category)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        imageDataArray = try container.decodeIfPresent([Data].self, forKey: .imageDataArray) ?? []
        city = try container.decode(String.self, forKey: .city)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        comments = try container.decodeIfPresent([Comment].self, forKey: .comments) ?? []
        reactions = try container.decodeIfPresent([String: Int].self, forKey: .reactions) ?? ["👍": 0, "👎": 0]
        checkedInUsers = try container.decodeIfPresent([String].self, forKey: .checkedInUsers) ?? []
        userReactions = try container.decodeIfPresent([String: String].self, forKey: .userReactions) ?? [:]
        createdByUser = try container.decodeIfPresent(Bool.self, forKey: .createdByUser) ?? false
        isStarred = try container.decodeIfPresent(Bool.self, forKey: .isStarred) ?? false
        comfortLevel = try container.decodeIfPresent(ComfortLevel.self, forKey: .comfortLevel) ?? .medium
        socialIntensity = try container.decodeIfPresent(SocialIntensity.self, forKey: .socialIntensity) ?? .moderate
        noiseLevel = try container.decodeIfPresent(NoiseLevel.self, forKey: .noiseLevel) ?? .moderate
        isBeginnerFriendly = try container.decodeIfPresent(Bool.self, forKey: .isBeginnerFriendly) ?? false
        expectedAttendees = try container.decodeIfPresent(Int.self, forKey: .expectedAttendees) ?? 50
        buddyRequestUsers = try container.decodeIfPresent([String].self, forKey: .buddyRequestUsers) ?? []
        conversationStarters = try container.decodeIfPresent([String].self, forKey: .conversationStarters) ?? []
        preparationTips = try container.decodeIfPresent([String].self, forKey: .preparationTips) ?? []
        hasQuietSpaces = try container.decodeIfPresent(Bool.self, forKey: .hasQuietSpaces) ?? false
        allowsEarlyExit = try container.decodeIfPresent(Bool.self, forKey: .allowsEarlyExit) ?? true
        requiresRSVP = try container.decodeIfPresent(Bool.self, forKey: .requiresRSVP) ?? false
        rsvpResponses = try container.decodeIfPresent([RSVPResponse].self, forKey: .rsvpResponses) ?? []
        rsvpDeadline = try container.decodeIfPresent(Date.self, forKey: .rsvpDeadline)
        maxAttendees = try container.decodeIfPresent(Int.self, forKey: .maxAttendees)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(location, forKey: .location)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encode(imageDataArray, forKey: .imageDataArray)
        try container.encode(city, forKey: .city)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encode(comments, forKey: .comments)
        try container.encode(reactions, forKey: .reactions)
        try container.encode(checkedInUsers, forKey: .checkedInUsers)
        try container.encode(userReactions, forKey: .userReactions)
        try container.encode(createdByUser, forKey: .createdByUser)
        try container.encode(isStarred, forKey: .isStarred)
        try container.encode(comfortLevel, forKey: .comfortLevel)
        try container.encode(socialIntensity, forKey: .socialIntensity)
        try container.encode(noiseLevel, forKey: .noiseLevel)
        try container.encode(isBeginnerFriendly, forKey: .isBeginnerFriendly)
        try container.encode(expectedAttendees, forKey: .expectedAttendees)
        try container.encode(buddyRequestUsers, forKey: .buddyRequestUsers)
        try container.encode(conversationStarters, forKey: .conversationStarters)
        try container.encode(preparationTips, forKey: .preparationTips)
        try container.encode(hasQuietSpaces, forKey: .hasQuietSpaces)
        try container.encode(allowsEarlyExit, forKey: .allowsEarlyExit)
        try container.encode(requiresRSVP, forKey: .requiresRSVP)
        try container.encode(rsvpResponses, forKey: .rsvpResponses)
        try container.encodeIfPresent(rsvpDeadline, forKey: .rsvpDeadline)
        try container.encodeIfPresent(maxAttendees, forKey: .maxAttendees)
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        location: String,
        date: Date,
        category: String,
        imageUrl: String? = nil,
        imageData: Data? = nil,
        imageDataArray: [Data] = [], // New parameter for multiple images
        city: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        comments: [Comment] = [],
        reactions: [String: Int] = [
            "👍": 0,
            "👎": 0
        ],
        checkedInUsers: [String] = [],
        userReactions: [String: String] = [:],
        createdByUser: Bool = false,
        isStarred: Bool = false,
        // Introvert-friendly defaults
        comfortLevel: ComfortLevel = .medium,
        socialIntensity: SocialIntensity = .moderate,
        noiseLevel: NoiseLevel = .moderate,
        isBeginnerFriendly: Bool = false,
        expectedAttendees: Int = 50,
        buddyRequestUsers: [String] = [],
        conversationStarters: [String] = [],
        preparationTips: [String] = [],
        hasQuietSpaces: Bool = false,
        allowsEarlyExit: Bool = true,
        requiresRSVP: Bool = false,
        // RSVP defaults
        rsvpResponses: [RSVPResponse] = [],
        rsvpDeadline: Date? = nil,
        maxAttendees: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.location = location
        self.date = date
        self.category = category
        self.imageUrl = imageUrl
        self.imageData = imageData
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.comments = comments
        self.reactions = reactions
        self.checkedInUsers = checkedInUsers
        self.userReactions = userReactions
        self.createdByUser = createdByUser
        self.isStarred = isStarred
        // Introvert-friendly
        self.comfortLevel = comfortLevel
        self.socialIntensity = socialIntensity
        self.noiseLevel = noiseLevel
        self.isBeginnerFriendly = isBeginnerFriendly
        self.expectedAttendees = expectedAttendees
        self.buddyRequestUsers = buddyRequestUsers
        self.conversationStarters = conversationStarters
        self.preparationTips = preparationTips
        self.hasQuietSpaces = hasQuietSpaces
        self.allowsEarlyExit = allowsEarlyExit
        self.requiresRSVP = requiresRSVP
        // RSVP
        self.rsvpResponses = rsvpResponses
        self.rsvpDeadline = rsvpDeadline
        self.maxAttendees = maxAttendees
        
        // Handle imageDataArray: use provided array, or create from single imageData if available
        if !imageDataArray.isEmpty {
            self.imageDataArray = imageDataArray
        } else if let imageData = imageData {
            self.imageDataArray = [imageData]
        } else {
            self.imageDataArray = []
        }
    }
}

// MARK: - Event RSVP Extensions
extension Event {
    // Get user's current RSVP status
    func getCurrentRSVP(for username: String) -> RSVPStatus {
        return rsvpResponses.first { $0.username == username }?.status ?? .none
    }
    
    // Update or add RSVP for a user
    func updateRSVP(username: String, status: RSVPStatus, note: String? = nil) {
        // Remove existing RSVP if any
        rsvpResponses.removeAll { $0.username == username }
        
        // Add new RSVP response
        if status != .none {
            let response = RSVPResponse(username: username, status: status, note: note)
            rsvpResponses.append(response)
        }
    }
    
    // Get RSVP counts
    var rsvpCounts: (going: Int, maybe: Int, notGoing: Int) {
        let going = rsvpResponses.filter { $0.status == .going }.count
        let maybe = rsvpResponses.filter { $0.status == .maybe }.count
        let notGoing = rsvpResponses.filter { $0.status == .notGoing }.count
        return (going: going, maybe: maybe, notGoing: notGoing)
    }
    
    // Check if event is at capacity
    var isAtCapacity: Bool {
        guard let maxAttendees = maxAttendees else { return false }
        return rsvpCounts.going >= maxAttendees
    }
    
    // Check if RSVP deadline has passed
    var rsvpDeadlinePassed: Bool {
        guard let deadline = rsvpDeadline else { return false }
        return Date() > deadline
    }
    
    // Get formatted RSVP summary
    var rsvpSummary: String {
        let counts = rsvpCounts
        if requiresRSVP {
            return "\(counts.going) Going • \(counts.maybe) Maybe • \(counts.notGoing) Not Going"
        } else {
            return "No RSVP required"
        }
    }
}

// MARK: - User Comfort Preferences
struct UserComfortPreferences: Codable {
    var preferredComfortLevel: ComfortLevel
    var maxSocialIntensity: SocialIntensity
    var maxNoiseLevel: NoiseLevel
    var requiresQuietSpaces: Bool
    var needsPreparationTips: Bool
    var prefersBeginnerFriendly: Bool
    var wantsBuddySystem: Bool
    init(
        preferredComfortLevel: ComfortLevel = .small,
        maxSocialIntensity: SocialIntensity = .moderate,
        maxNoiseLevel: NoiseLevel = .moderate,
        requiresQuietSpaces: Bool = true,
        needsPreparationTips: Bool = true,
        prefersBeginnerFriendly: Bool = true,
        wantsBuddySystem: Bool = true
    ) {
        self.preferredComfortLevel = preferredComfortLevel
        self.maxSocialIntensity = maxSocialIntensity
        self.maxNoiseLevel = maxNoiseLevel
        self.requiresQuietSpaces = requiresQuietSpaces
        self.needsPreparationTips = needsPreparationTips
        self.prefersBeginnerFriendly = prefersBeginnerFriendly
        self.wantsBuddySystem = wantsBuddySystem
    }
}
