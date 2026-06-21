//
//  PersistenceManager.swift
//  Circa
//
//  Created by Jackenson Charles on 4/29/25.
//




//
//  PersistenceManager.swift
//  Circa
//
//  Created by Jackenson Charles on 4/29/25.
//

import Foundation

struct PersistenceManager {
    static let eventsFileName = "events.json"

    static var eventsFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(eventsFileName)
    }

    static func saveEvents(_ events: [Event]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(events)
            try data.write(to: eventsFileURL, options: [.atomicWrite, .completeFileProtection])
            print("✅ Events saved successfully to disk.")
        } catch {
            print("❌ Failed to save events: \(error.localizedDescription)")
        }
    }

    static func loadEvents() -> [Event] {
        do {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: eventsFileURL.path) {
                print("⚠️ No events file found yet. Returning empty event list.")
                return []
            }
            let data = try Data(contentsOf: eventsFileURL)
            let events = try JSONDecoder().decode([Event].self, from: data)
            print("✅ Events loaded successfully from disk.")
            return events
        } catch {
            print("⚠️ Failed to load events: \(error.localizedDescription)")
            return []
        }
    }

    static func deleteEventsFile() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: eventsFileURL.path) {
            do {
                try fileManager.removeItem(at: eventsFileURL)
                print("✅ Events file deleted successfully.")
            } catch {
                print("❌ Failed to delete events file: \(error.localizedDescription)")
            }
        }
    }
}
