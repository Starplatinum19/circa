import Foundation
import SwiftUI

// MARK: - Mascot Mouth Expression

enum MouthExpression: CaseIterable {
    case smile, neutral, frown, surprised
}

// MARK: - Mascot Eye State

enum MascotEyeState {
    case normal, sparkling, gentle, focused, winking
}

// MARK: - Mascot Mood

enum MascotMood: String, CaseIterable {
    case encouraging = "encouraging"
    case celebrating = "celebrating"
    case calming = "calming"
    case excited = "excited"
    case thoughtful = "thoughtful"
    case supportive = "supportive"
    case proud = "proud"
    case sad = "sad"
    case disappointed = "disappointed"
    case surprised = "surprised"
    
    var expression: MouthExpression {
        switch self {
        case .encouraging, .supportive: return .smile
        case .celebrating, .excited, .proud: return .smile
        case .calming, .thoughtful: return .neutral
        case .sad, .disappointed: return .frown
        case .surprised: return .surprised
        }
    }
    
    var eyeState: MascotEyeState {
        switch self {
        case .encouraging, .supportive: return .normal
        case .celebrating, .excited, .proud: return .sparkling
        case .calming: return .gentle
        case .thoughtful: return .focused
        case .sad, .disappointed: return .gentle
        case .surprised: return .winking
        }
    }
}

// MARK: - Time Of Day Enum

enum TimeOfDay: String, CaseIterable {
    case morning
    case afternoon
    case evening
    case night
}

// MARK: - Mascot Context

enum MascotContext {
    case browsing(timeOfDay: TimeOfDay)
    case viewingComfortableEvent(eventType: String, timeOfDay: TimeOfDay)
    case viewingChallengingEvent(eventType: String, timeOfDay: TimeOfDay)
    case achievementUnlocked(AchievementType)
    case longBrowsing(timeOfDay: TimeOfDay)
    case firstTimeUser
    case returningUser(daysSinceLast: Int)
    case eventCreation(eventType: String)
    case preEventAnxiety(eventType: String)
    case postEventSuccess(eventType: String)
}
