//
//  BuddySystem.swift
//  Circa
//
//  Created by AI Assistant on 8/30/25.
//

import Foundation

// MARK: - Buddy Request Profile
struct BuddyRequest: Codable, Identifiable {
    var id = UUID()
    let username: String
    let eventId: String
    let createdAt: Date
    let buddyPreferences: BuddyPreferences
    var status: BuddyRequestStatus
    var matchedWith: String? // Username of matched buddy
    
    init(username: String, eventId: String, buddyPreferences: BuddyPreferences) {
        self.username = username
        self.eventId = eventId
        self.createdAt = Date()
        self.buddyPreferences = buddyPreferences
        self.status = .looking
        self.matchedWith = nil
    }
}

// MARK: - Buddy Preferences
struct BuddyPreferences: Codable {
    var lookingFor: BuddyType
    var ageRange: AgeRange?
    var interests: [String]
    var meetupPreference: MeetupPreference
    var communicationStyle: CommunicationStyle
    var description: String
    
    init(
        lookingFor: BuddyType = .anyone,
        ageRange: AgeRange? = nil,
        interests: [String] = [],
        meetupPreference: MeetupPreference = .atEvent,
        communicationStyle: CommunicationStyle = .friendly,
        description: String = ""
    ) {
        self.lookingFor = lookingFor
        self.ageRange = ageRange
        self.interests = interests
        self.meetupPreference = meetupPreference
        self.communicationStyle = communicationStyle
        self.description = description
    }
}

// MARK: - Buddy Types
enum BuddyType: String, CaseIterable, Codable {
    case anyone = "Anyone"
    case similarAge = "Similar Age"
    case beginner = "Fellow Beginner"
    case experienced = "Experienced Attendee"
    case localGuide = "Local Guide"
    case quietCompanion = "Quiet Companion"
    case socialButterfly = "Social Butterfly"
    
    var description: String {
        switch self {
        case .anyone:
            return "Open to meeting anyone"
        case .similarAge:
            return "Someone around my age"
        case .beginner:
            return "Another first-timer or beginner"
        case .experienced:
            return "Someone who knows the ropes"
        case .localGuide:
            return "A local who can show me around"
        case .quietCompanion:
            return "Someone who enjoys quieter interactions"
        case .socialButterfly:
            return "An outgoing person who loves to socialize"
        }
    }
    
    var icon: String {
        switch self {
        case .anyone: return "person.2"
        case .similarAge: return "person.crop.circle"
        case .beginner: return "graduationcap"
        case .experienced: return "star.fill"
        case .localGuide: return "location.fill"
        case .quietCompanion: return "moon.fill"
        case .socialButterfly: return "sun.max.fill"
        }
    }
}

// MARK: - Age Range
enum AgeRange: String, CaseIterable, Codable {
    case teens = "16-19"
    case twenties = "20-29"
    case thirties = "30-39"
    case forties = "40-49"
    case fifties = "50-59"
    case sixtyPlus = "60+"
    
    var range: ClosedRange<Int> {
        switch self {
        case .teens: return 16...19
        case .twenties: return 20...29
        case .thirties: return 30...39
        case .forties: return 40...49
        case .fifties: return 50...59
        case .sixtyPlus: return 60...100
        }
    }
}

// MARK: - Meetup Preferences
enum MeetupPreference: String, CaseIterable, Codable {
    case beforeEvent = "Meet before the event"
    case atEvent = "Meet at the event"
    case flexible = "Flexible"
    
    var description: String {
        switch self {
        case .beforeEvent:
            return "I'd like to meet up beforehand (coffee, etc.)"
        case .atEvent:
            return "Let's just find each other at the event"
        case .flexible:
            return "I'm flexible with timing"
        }
    }
    
    var icon: String {
        switch self {
        case .beforeEvent: return "clock"
        case .atEvent: return "location"
        case .flexible: return "arrow.clockwise"
        }
    }
}

// MARK: - Communication Style
enum CommunicationStyle: String, CaseIterable, Codable {
    case chatty = "Chatty"
    case friendly = "Friendly"
    case reserved = "Reserved"
    case minimal = "Minimal"
    
    var description: String {
        switch self {
        case .chatty:
            return "I love to chat and get to know people"
        case .friendly:
            return "I'm friendly and enjoy good conversation"
        case .reserved:
            return "I'm more reserved but warm once comfortable"
        case .minimal:
            return "I prefer minimal conversation, just companionship"
        }
    }
    
    var icon: String {
        switch self {
        case .chatty: return "bubble.left.and.bubble.right.fill"
        case .friendly: return "hand.wave.fill"
        case .reserved: return "person.fill"
        case .minimal: return "minus.circle"
        }
    }
}

// MARK: - Buddy Request Status
enum BuddyRequestStatus: String, Codable {
    case looking = "Looking"
    case matched = "Matched"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
    case completed = "Completed"
}

// MARK: - Buddy Match
struct BuddyMatch: Codable, Identifiable {
    var id = UUID()
    let eventId: String
    let user1: String
    let user2: String
    let matchedAt: Date
    var status: BuddyMatchStatus
    var messages: [BuddyMessage]
    var meetupDetails: MeetupDetails?
    
    init(eventId: String, user1: String, user2: String) {
        self.eventId = eventId
        self.user1 = user1
        self.user2 = user2
        self.matchedAt = Date()
        self.status = .pending
        self.messages = []
        self.meetupDetails = nil
    }
    
    func otherUser(from currentUser: String) -> String {
        return currentUser == user1 ? user2 : user1
    }
}

// MARK: - Buddy Match Status
enum BuddyMatchStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    case confirmed = "Confirmed"
    case meetingPlanned = "Meeting Planned"
    case completed = "Completed"
}

// MARK: - Buddy Message
struct BuddyMessage: Codable, Identifiable {
    var id = UUID()
    let from: String
    let to: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    
    init(from: String, to: String, message: String) {
        self.from = from
        self.to = to
        self.message = message
        self.timestamp = Date()
        self.isRead = false
    }
}

// MARK: - Meetup Details
struct MeetupDetails: Codable {
    var time: Date?
    var location: String?
    var notes: String?
    var confirmedBy: [String]
    
    init() {
        self.time = nil
        self.location = nil
        self.notes = nil
        self.confirmedBy = []
    }
}

// MARK: - Buddy Compatibility Score
struct BuddyCompatibility {
    static func calculateScore(request1: BuddyRequest, request2: BuddyRequest, userPrefs1: UserComfortPreferences?, userPrefs2: UserComfortPreferences?) -> Double {
        var score: Double = 0.0
        
        // Basic compatibility - both looking for buddies
        score += 20.0
        
        // Age compatibility
        if let age1 = request1.buddyPreferences.ageRange,
           let age2 = request2.buddyPreferences.ageRange {
            if age1 == age2 {
                score += 15.0
            } else if abs(age1.range.lowerBound - age2.range.lowerBound) <= 10 {
                score += 10.0
            }
        }
        
        // Interest matching
        let commonInterests = Set(request1.buddyPreferences.interests).intersection(Set(request2.buddyPreferences.interests))
        score += Double(commonInterests.count) * 5.0
        
        // Communication style compatibility
        if request1.buddyPreferences.communicationStyle == request2.buddyPreferences.communicationStyle {
            score += 15.0
        } else {
            // Compatible styles
            let compatiblePairs: [(CommunicationStyle, CommunicationStyle)] = [
                (.chatty, .friendly),
                (.friendly, .reserved),
                (.reserved, .minimal)
            ]
            
            for (style1, style2) in compatiblePairs {
                if (request1.buddyPreferences.communicationStyle == style1 && request2.buddyPreferences.communicationStyle == style2) ||
                   (request1.buddyPreferences.communicationStyle == style2 && request2.buddyPreferences.communicationStyle == style1) {
                    score += 10.0
                    break
                }
            }
        }
        
        // Comfort level compatibility from user preferences
        if let prefs1 = userPrefs1, let prefs2 = userPrefs2 {
            if prefs1.preferredComfortLevel == prefs2.preferredComfortLevel {
                score += 10.0
            }
            
            if prefs1.maxSocialIntensity == prefs2.maxSocialIntensity {
                score += 10.0
            }
            
            if prefs1.prefersBeginnerFriendly == prefs2.prefersBeginnerFriendly {
                score += 10.0
            }
        }
        
        // Meetup preference alignment
        if request1.buddyPreferences.meetupPreference == request2.buddyPreferences.meetupPreference ||
           request1.buddyPreferences.meetupPreference == .flexible ||
           request2.buddyPreferences.meetupPreference == .flexible {
            score += 5.0
        }
        
        return min(score, 100.0) // Cap at 100%
    }
}
