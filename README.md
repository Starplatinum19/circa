# Circa — Local Event Discovery for Everyone

Circa is an iOS app built with SwiftUI that helps users discover and engage with local events. It is designed with introvert-friendly features at its core, giving every user the context they need to attend events comfortably and confidently.

<img width="230" height="533" alt="image" src="https://github.com/user-attachments/assets/39553b41-7bcd-4f26-bab0-524f767e81ce" />


<img width="229" height="492" alt="image" src="https://github.com/user-attachments/assets/34898795-0a6e-4fb9-9b56-a271593fd8f5" />






---

## About

Circa lets you browse events in your city, RSVP, react, comment, check in, and even find an event buddy — all from a clean, gradient-driven UI with an animated mascot companion that greets you contextually based on the time of day and how long it's been since your last visit.


---

## Features

### Event Discovery
- Browse events filtered by city or ZIP code
- Search across event titles, categories, and locations
- Category tags: Art, Music, Tech, Food, Film, Wellness, Fitness, Community, and more
- Star/bookmark events you're interested in

<img width="229" height="536" alt="image" src="https://github.com/user-attachments/assets/20296e92-8b7b-44af-8f67-1dcdbc408a70" />
<img width="230" height="532" alt="image" src="https://github.com/user-attachments/assets/33c20239-78b6-4db5-b16e-451e0347d5e9" />


### Introvert-Friendly Metadata
Every event surfaces comfort indicators so you know what to expect before you go:
- **Comfort Level** — Intimate (<20), Small (20–50), Medium (50–100), Large (100+)
- **Social Intensity** — Minimal interaction to High social interaction
- **Noise Level** — Quiet, Moderate, or Loud
- **Quiet Spaces** — Whether designated rest areas are available
- **Early Exit Allowed** — No pressure to stay the whole time
- **Beginner Friendly** — Welcoming to first-timers
- **Conversation Starters** — Curated prompts to break the ice
- **Preparation Tips** — What to expect and how to get ready

  <img width="233" height="502" alt="image" src="https://github.com/user-attachments/assets/c29df7f5-3a05-4804-b57b-812eaa913004" />
  <img width="232" height="501" alt="image" src="https://github.com/user-attachments/assets/fd383a7f-2433-4479-b5df-724139bd6dee" />
  <img width="236" height="503" alt="image" src="https://github.com/user-attachments/assets/206884f6-0902-4ce7-ae12-9758396898eb" />
  <img width="233" height="509" alt="image" src="https://github.com/user-attachments/assets/4d6ded96-d512-48fc-a73f-b2c579fb64c3" />
  <img width="233" height="503" alt="image" src="https://github.com/user-attachments/assets/e0cfa31d-5737-42fc-aca2-4ef6a66ffa4e" />
  <img width="233" height="500" alt="image" src="https://github.com/user-attachments/assets/d6b5feac-a169-4523-a5ae-4b750ec8492c" />


### RSVP System
- Going / Maybe / Not Going responses with optional personal notes
- RSVP deadlines and capacity limits
- Live RSVP counts displayed on event cards
<img width="230" height="533" alt="image" src="https://github.com/user-attachments/assets/874a5cfc-3db4-473d-a701-fa22e7d959f3" />
<img width="231" height="539" alt="image" src="https://github.com/user-attachments/assets/ff565166-f9ea-42e2-9205-1e4c26078431" />


### Social & Engagement
- Emoji reactions on events
- Comment threads per event
- Check-in when you arrive
- Photo carousel supporting multiple images per event
  

<img width="236" height="533" alt="image" src="https://github.com/user-attachments/assets/4c364e60-3f75-42ef-a23f-996498bb1468" />
<img width="236" height="529" alt="image" src="https://github.com/user-attachments/assets/818cec70-259f-4110-b9d5-a32921ac2257" />
<img width="236" height="538" alt="image" src="https://github.com/user-attachments/assets/bcbff8cf-096f-4d2d-bc2e-19923ca93095" />


### Buddy System
Match with another attendee going to the same event:
- Set buddy preferences: type (Quiet Companion, Fellow Beginner, Local Guide, etc.), age range, communication style, and meetup preference
- Compatibility scoring based on shared interests, communication style, comfort preferences, and age proximity
- Buddy messages and meetup detail coordination
- Match statuses: Looking → Matched → Confirmed → Completed

<img width="233" height="352" alt="image" src="https://github.com/user-attachments/assets/0d4c94ac-2226-433e-9a6b-57ed3110043d" />


### Map View
- Explore events pinned on an interactive map
- Tap a pin to preview the event and navigate to its detail page
- Filter the main list by tapping a city on the map
  
<img width="236" height="539" alt="image" src="https://github.com/user-attachments/assets/6f301994-3015-4f27-9849-5e7a4b7909ea" />


### Animated Mascot
A floating face companion with blinking eyes, breathing animation, and mood-reactive expressions (happy, calm, sad, surprised, celebrating). Greets you differently based on:
- First-time use
- Time of day (morning, afternoon, evening, night)
- Days since last visit

<img width="236" height="537" alt="image" src="https://github.com/user-attachments/assets/4013ce07-95fc-4bd8-ba15-74af893a8068" />
<img width="236" height="538" alt="image" src="https://github.com/user-attachments/assets/0fcfaf26-ae64-4d5d-8ca3-764b344876d1" />


### Onboarding
- Name, city, and ZIP entry on first launch
- Comfort preferences sheet to personalize the experience before entering the app
- Mascot welcome screen after preferences are saved
  

### User Profile
- View and manage your events and RSVPs from a dedicated profile screen

<img width="235" height="533" alt="image" src="https://github.com/user-attachments/assets/f41b83e2-cdcf-449a-8fd4-e74c2411ab3c" />


### Add Events
- Create your own events with full metadata support including comfort level, noise level, RSVP requirements, capacity, and multiple photos

<img width="239" height="535" alt="image" src="https://github.com/user-attachments/assets/74aba9a8-8d55-4f8b-a437-8f1c8715bd86" />
<img width="235" height="531" alt="image" src="https://github.com/user-attachments/assets/0fe2dc65-5dce-478d-a3c3-949dea35d7d8" />

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5 |
| UI Framework | SwiftUI |
| Architecture | MVVM |
| State Management | `ObservableObject`, `EnvironmentObject`, `@AppStorage` |
| Location | CoreLocation (`LocationManager`) |
| Maps | MapKit |
| Persistence | `UserDefaults` via `PersistenceManager` |
| Minimum Target | iOS 17+ |

---

## Project Layout

- **CircaApp.swift** — App entry point
- **Models/**
  - Event.swift — Event model, RSVP, comfort enums, user preferences
  - BuddySystem.swift — Buddy requests, matching, messaging, compatibility scoring
  - ContextTypes.swift — Mascot context and mood types
- **ViewModels/**
  - EventsViewModel.swift — Event list state and actions
  - MascotViewModel.swift — Mascot mood and message logic
- **Views/**
  - EventsView.swift — Main feed with floating nav bar and mascot toggle
  - EventListView.swift — Scrollable event card list with search
  - EventDetailView.swift — Full event detail: photos, RSVP, reactions, comments
  - EventMapView.swift — Map with event pins
  - AddEventView.swift — Create new event form
  - WelcomeView.swift — Onboarding: name, city, ZIP
  - ComfortPreferencesView.swift — Introvert preference setup
  - MascotWelcomeView.swift — Post-onboarding mascot intro
  - ProfileView.swift — User profile
  - BuddySystemView.swift — Browse buddy requests for an event
  - BuddyPreferencesView.swift — Set your buddy preferences
  - BuddyMatchesView.swift — View and manage your buddy matches
- **Components/**
  - EventCardView.swift — Event summary card
  - EventImageView.swift — Single event image with fallback
  - PhotoCarouselView.swift — Horizontal multi-image carousel
  - MascotView.swift — Animated mascot face
  - FloatingMascotView.swift — Floating mascot overlay with speech bubble
  - TextBubbleView.swift — Speech bubble component
  - BubbleShape.swift — Custom bubble shape
  - RSVPView.swift — RSVP action buttons
  - RSVPCardView.swift — RSVP response display card
  - ReactionButton.swift — Emoji reaction button
  - SplashScreenView.swift — Launch screen
  - AchievementType.swift — Achievement definitions
- **Utilities/**
  - LocationManager.swift — CoreLocation wrapper, stores username, city, ZIP
  - PersistenceManager.swift — UserDefaults read/write for events
  - Comparable+Clamp.swift — Clamp utility extension
- **Assets.xcassets/** — App icon, gradient colors, event images






---

## Getting Started

1. Clone the repo
2. Open `Circa.xcodeproj` in Xcode
3. Select a simulator or connected iOS device (iOS 17+)
4. Build and run (`Cmd + R`)

No external dependencies or package manager setup required.
