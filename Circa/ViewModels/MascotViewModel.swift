import SwiftUI
import Foundation

// MARK: - Mascot View Model

@MainActor
class MascotViewModel: ObservableObject {
    @Published var currentMood: MascotMood = .encouraging
    @Published var currentMessage: String = ""
    @Published var isVisible: Bool = true
    @Published var shouldAnimate: Bool = false
    
    private var lastContextChange: Date = Date()
    private var messageHistory: [String] = []
    private let maxHistorySize = 10
    
    // Add cycling index for browsing tips
    private var browsingTipIndex = 0
    
    // Context tracking
    private var browsingStartTime: Date?
    private var currentEventBeingViewed: Event?
    
    func updateContext(_ context: MascotContext, user: LocationManager, forceUpdate: Bool = false) {
        let now = Date()
        guard forceUpdate || now.timeIntervalSince(lastContextChange) > 2.0 else { return }
        lastContextChange = now
        switch context {
        case .browsing(let timeOfDay):
            handleBrowsingContext(user: user, timeOfDay: timeOfDay)
        case .viewingComfortableEvent(let eventType, let timeOfDay):
            setMood(.encouraging)
            setMessage(getComfortableEventMessage(user: user, eventType: eventType, timeOfDay: timeOfDay))
        case .viewingChallengingEvent(let eventType, let timeOfDay):
            setMood(.calming)
            setMessage(getChallengingEventMessage(user: user, eventType: eventType, timeOfDay: timeOfDay))
        case .achievementUnlocked(let achievement):
            setMood(.celebrating)
            setMessage(getAchievementMessage(achievement))
            triggerCelebration()
        case .longBrowsing(let timeOfDay):
            setMood(.supportive)
            setMessage(getLongBrowsingMessage(user: user, timeOfDay: timeOfDay))
        case .firstTimeUser:
            setMood(.excited)
            setMessage(getFirstTimeUserMessage())
        case .returningUser(let daysSinceLast):
            setMood(.encouraging)
            setMessage(getReturningUserMessage(user: user, daysSinceLast: daysSinceLast))
        case .eventCreation(let eventType):
            setMood(.proud)
            setMessage(getEventCreationMessage(eventType: eventType))
        case .preEventAnxiety(let eventType):
            setMood(.calming)
            setMessage(getPreEventAnxietyMessage(eventType: eventType))
        case .postEventSuccess(let eventType):
            setMood(.celebrating)
            setMessage(getPostEventSuccessMessage(eventType: eventType))
            triggerCelebration()
        }
    }
    
    private func setMood(_ mood: MascotMood) {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentMood = mood
        }
    }
    
    private func setMessage(_ message: String) {
        // For cycling tips, bypass history checking and set message directly
        addToHistory(message)
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMessage = message
        }
    }
    
    private func addToHistory(_ message: String) {
        messageHistory.append(message)
        if messageHistory.count > maxHistorySize {
            messageHistory.removeFirst()
        }
    }
    
    private func triggerCelebration() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            shouldAnimate = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.shouldAnimate = false
        }
    }
    
    // MARK: - Context Handlers
    private func handleBrowsingContext(user: LocationManager, timeOfDay: TimeOfDay) {
        if browsingStartTime == nil {
            browsingStartTime = Date()
        }
        let browsingDuration = Date().timeIntervalSince(browsingStartTime!)
        if browsingDuration > 30 {
            updateContext(.longBrowsing(timeOfDay: timeOfDay), user: user)
        } else {
            setMood(.thoughtful)
            setMessage(getBrowsingMessage(user: user, timeOfDay: timeOfDay))
        }
    }
    // MARK: - Enhanced Message Generation
    private func getBrowsingMessage(user: LocationManager, timeOfDay: TimeOfDay) -> String {
        let greeting: String
        switch timeOfDay {
        case .morning: greeting = "Good morning!"
        case .afternoon: greeting = "Good afternoon!"
        case .evening: greeting = "Good evening!"
        case .night: greeting = "Up late?"
        }
        
        // Define the cycling tips array
        let browsingTips = [
            "\(greeting) Looking for the perfect event? I can help you find something comfortable!",
            "\(greeting) Want me to highlight events that match your comfort preferences?",
            "\(greeting) I see some beginner-friendly events that might interest you!",
            "\(greeting) Take your time browsing. I'll be here if you need any tips!",
            "💡 Tap the location icon in the search bar to find events near you!",
            "🔍 Use the search bar to find events in any city or ZIP code.",
            "👆 Tap any event card to see more details and RSVP options.",
            "🗺️ Use the map view to see events plotted on a map of your area.",
            "➕ Tap the plus button to create your own event and invite others.",
            "👤 Check your profile to see events you've created and starred."
        ]
        
        // Ensure the index is within bounds and get current tip
        let safeIndex = browsingTipIndex % browsingTips.count
        let currentTip = browsingTips[safeIndex]
        
        // Advance the index for next time, ensuring it stays within bounds
        browsingTipIndex = (browsingTipIndex + 1) % browsingTips.count
        
        return currentTip
    }

    private func getComfortableEventMessage(user: LocationManager, eventType: String, timeOfDay: TimeOfDay) -> String {
        let greeting: String
        switch timeOfDay {
        case .morning: greeting = "This is a great way to start your morning!"
        case .afternoon: greeting = "A perfect afternoon pick!"
        case .evening: greeting = "A relaxing evening event for you."
        case .night: greeting = "A cozy night event!"
        }
        let messages = [
            "\(greeting) This \(eventType) event matches your comfort preferences.",
            "Perfect choice! This \(eventType) event has all your preferred comfort features.",
            "I love this pick! Small groups and optional interaction - very comfortable for you.",
            "This event has conversation starters available if you need them!"
        ]
        return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
    }

    private func getChallengingEventMessage(user: LocationManager, eventType: String, timeOfDay: TimeOfDay) -> String {
        let stats = user.userStats
        let encouragementLevel = stats.checkIns > 5 ? "experienced" : "gentle"
        let greeting: String
        switch timeOfDay {
        case .morning: greeting = "Starting your day with a challenge!"
        case .afternoon: greeting = "Taking on a new challenge this afternoon!"
        case .evening: greeting = "An adventurous evening ahead!"
        case .night: greeting = "A bold night move!"
        }
        if encouragementLevel == "experienced" {
            let messages = [
                "\(greeting) This \(eventType) event is bigger, but you've handled similar challenges before!",
                "Remember your success at previous events? You've got this!",
                "This could be a great confidence builder - and there's always early exit if needed.",
                "Want some tips for navigating larger events? I have strategies that work!"
            ]
            return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
        } else {
            let messages = [
                "This \(eventType) event is a bit outside your usual comfort zone. Want to start with something smaller?",
                "I notice this is a larger event. How about we look for similar events with fewer people?",
                "This could be exciting, but let's make sure you feel prepared. Check out the preparation tips!",
                "Remember, you can always leave early if it feels overwhelming. No pressure!"
            ]
            return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
        }
    }

    private func getAchievementMessage(_ achievement: AchievementType) -> String {
        switch achievement {
        case .firstStep:
            return "Congratulations on your first event! That took courage, and I'm so proud of you!"
        case .comfortZone:
            return "You've found your rhythm! Three comfortable events - you're building confidence beautifully."
        case .socialButterfly:
            return "Look at you engaging with the community! Your voice matters and people appreciate it."
        case .weeklyWarrior:
            return "Four weeks in a row? You're becoming a regular! I love seeing your confidence grow."
        case .branchingOut:
            return "Trying different event types shows real growth! You're expanding your horizons."
        default:
            return "Another achievement unlocked! You're making amazing progress on your social journey."
        }
    }
    private func getLongBrowsingMessage(user: LocationManager, timeOfDay: TimeOfDay) -> String {
        let messages = [
            "Take all the time you need! Sometimes the right event is worth waiting for.",
            "Feeling overwhelmed by choices? Want me to suggest some events based on your preferences?",
            "I notice you've been browsing a while. Need help narrowing down your options?",
            "Remember, there's no pressure to attend anything. Even browsing is a step forward!"
        ]
        return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
    }
    private func getFirstTimeUserMessage() -> String {
        let messages = [
            "Welcome to Circa! I'm here to help you find events that feel just right for you.",
            "Hi there! Let's start by finding some comfortable, beginner-friendly events.",
            "New here? Don't worry - we'll take things at your pace. Every journey starts somewhere!",
            "I'm excited to help you discover amazing events that match your comfort style!"
        ]
        return messages.randomElement() ?? messages[0]
    }
    private func getReturningUserMessage(user: LocationManager, daysSinceLast: Int) -> String {
        let stats = user.userStats
        let daysMsg = daysSinceLast > 7 ? "It's been a while!" : "Welcome back!"
        let messages = [
            "\(daysMsg) Ready to find your next adventure?",
            "Great to see you again! You've attended \(stats.checkIns) events so far - impressive!",
            "Back for more? I love your enthusiasm for trying new experiences!",
            "Hello again! Want to see what new events match your preferences?"
        ]
        return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
    }
    private func getEventCreationMessage(eventType: String) -> String {
        let messages = [
            "Creating your own \(eventType) event? That's fantastic! You're helping build the community.",
            "I'm so proud - from attending events to hosting them. What growth!",
            "Event creation is a big step! Make sure to add those comfort features others will appreciate.",
            "You're becoming a community leader! Your event will help others feel welcome."
        ]
        return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
    }
    private func getPreEventAnxietyMessage(eventType: String) -> String {
        let messages = [
            "Feeling nervous about this \(eventType) event? That's completely normal. You can always leave early if needed.",
            "Pre-event jitters are natural. Want to review the conversation starters for this event?",
            "Take a deep breath. You've prepared well, and the event has quiet spaces if you need a break.",
            "Anxiety before events is okay! Focus on why you wanted to attend in the first place."
        ]
        return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
    }
    private func getPostEventSuccessMessage(eventType: String) -> String {
        let messages = [
            "You did it! How do you feel about the \(eventType) experience?",
            "I'm so proud of you for following through! Every event builds your confidence.",
            "Another successful event! You're proving to yourself that you can do this.",
            "Look at you! From nervous browsing to successful attendance. Growth in action!"
        ]
        return messages.shuffled().first { !messageHistory.contains($0) } ?? messages.randomElement() ?? messages[0]
    }
    private func getAlternativeMessage() -> String {
        let messages = [
            "I'm here whenever you need encouragement or tips!",
            "You're doing great! Keep exploring at your own pace.",
            "I believe in you! Social growth takes time and that's perfectly okay.",
            "Remember, every small step counts toward building confidence!"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    // MARK: - Public Methods
    func updateMessage(_ message: String) {
        setMessage(message)
    }
}
