//
//  AchievementType.swift
//  Circa
//
//  Created by Jackenson Charles on 8/26/25.
//


//
//  AchievementSystem.swift
//  Circa
//
//  Gamification system designed for introverts

import Foundation
import SwiftUI

enum AchievementType: String, CaseIterable, Codable {
    // Gentle progression achievements
    case firstStep = "first_step"
    case comfortZone = "comfort_zone"
    case socialButterfly = "social_butterfly"
    case conversationStarter = "conversation_starter"
    case regularAttendee = "regular_attendee"
    // Buddy system achievements
    case buddyFinder = "buddy_finder"
    case wingman = "wingman"
    case socialConnector = "social_connector"
    // Event creation achievements
    case eventCreator = "event_creator"
    case communityBuilder = "community_builder"
    case inclusiveHost = "inclusive_host"
    // Comfort zone expansion
    case branchingOut = "branching_out"
    case diverseExplorer = "diverse_explorer"
    case confidenceBuilder = "confidence_builder"
    // Streak achievements
    case weeklyWarrior = "weekly_warrior"
    case monthlyMover = "monthly_mover"
    case consistentAttendee = "consistent_attendee"
}

struct Achievement: Identifiable, Codable {
    var id = UUID()
    let type: AchievementType
    let title: String
    let description: String
    let icon: String
    let color: String
    let maxProgress: Int
    var currentProgress: Int
    var isUnlocked: Bool
    let unlockDate: Date?
    
    init(type: AchievementType, currentProgress: Int = 0, isUnlocked: Bool = false, unlockDate: Date? = nil) {
        self.type = type
        self.currentProgress = currentProgress
        self.isUnlocked = isUnlocked
        self.unlockDate = unlockDate
        // Define achievement properties based on type
        switch type {
        case .firstStep:
            self.title = "First Step"
            self.description = "Attended your very first event. Every journey begins with courage!"
            self.icon = "figure.walk"
            self.color = "green"
            self.maxProgress = 1
        case .comfortZone:
            self.title = "Comfort Zone"
            self.description = "Attended 3 events that matched your comfort preferences"
            self.icon = "heart.circle.fill"
            self.color = "blue"
            self.maxProgress = 3
        case .socialButterfly:
            self.title = "Social Butterfly"
            self.description = "Left comments on 10 different events"
            self.icon = "text.bubble.fill"
            self.color = "purple"
            self.maxProgress = 10
        case .conversationStarter:
            self.title = "Conversation Starter"
            self.description = "Used conversation starters at 5 events"
            self.icon = "message.fill"
            self.color = "orange"
            self.maxProgress = 5
        case .regularAttendee:
            self.title = "Regular Attendee"
            self.description = "Checked in to 15 events total"
            self.icon = "checkmark.seal.fill"
            self.color = "green"
            self.maxProgress = 15
        case .buddyFinder:
            self.title = "Buddy Finder"
            self.description = "Successfully connected with 3 event buddies"
            self.icon = "person.2.fill"
            self.color = "pink"
            self.maxProgress = 3
        case .wingman:
            self.title = "Wingman"
            self.description = "Helped 5 other people find event buddies"
            self.icon = "hand.raised.fill"
            self.color = "yellow"
            self.maxProgress = 5
        case .socialConnector:
            self.title = "Social Connector"
            self.description = "Made connections at events with different social intensity levels"
            self.icon = "link"
            self.color = "blue"
            self.maxProgress = 3
        case .eventCreator:
            self.title = "Event Creator"
            self.description = "Created your first event for the community"
            self.icon = "plus.circle.fill"
            self.color = "indigo"
            self.maxProgress = 1
        case .communityBuilder:
            self.title = "Community Builder"
            self.description = "Created 5 events that others attended"
            self.icon = "building.2.fill"
            self.color = "teal"
            self.maxProgress = 5
        case .inclusiveHost:
            self.title = "Inclusive Host"
            self.description = "Created beginner-friendly events with comfort features"
            self.icon = "heart.text.square.fill"
            self.color = "green"
            self.maxProgress = 3
        case .branchingOut:
            self.title = "Branching Out"
            self.description = "Attended events in 3 different categories"
            self.icon = "tree.fill"
            self.color = "brown"
            self.maxProgress = 3
        case .diverseExplorer:
            self.title = "Diverse Explorer"
            self.description = "Tried events with different comfort levels"
            self.icon = "globe.americas.fill"
            self.color = "blue"
            self.maxProgress = 3
        case .confidenceBuilder:
            self.title = "Confidence Builder"
            self.description = "Attended a large group event after starting with smaller ones"
            self.icon = "arrow.up.circle.fill"
            self.color = "orange"
            self.maxProgress = 1
        case .weeklyWarrior:
            self.title = "Weekly Warrior"
            self.description = "Attended events for 4 consecutive weeks"
            self.icon = "calendar.badge.plus"
            self.color = "purple"
            self.maxProgress = 4
        case .monthlyMover:
            self.title = "Monthly Mover"
            self.description = "Attended at least one event for 3 consecutive months"
            self.icon = "calendar.circle.fill"
            self.color = "red"
            self.maxProgress = 3
        case .consistentAttendee:
            self.title = "Consistent Attendee"
            self.description = "Built a 30-day streak of event activity"
            self.icon = "flame.fill"
            self.color = "red"
            self.maxProgress = 30
        }
    }
    var progressPercentage: Double {
        return Double(currentProgress) / Double(maxProgress)
    }
    var isComplete: Bool {
        return currentProgress >= maxProgress
    }
}
