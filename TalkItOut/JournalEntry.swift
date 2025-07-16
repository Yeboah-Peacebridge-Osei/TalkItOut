import Foundation

struct JournalEntry: Identifiable, Codable {
    enum EntryType: String, Codable {
        case audio
        case text
    }
    let id: UUID
    let date: Date
    let type: EntryType
    let title: String? // New property for text journal title
    let transcript: String?
    let audioURL: String?
    let text: String?
    
    // Audio entry initializer
    init(date: Date, transcript: String, audioURL: String) {
        self.id = UUID()
        self.date = date
        self.type = .audio
        self.title = nil
        self.transcript = transcript
        self.audioURL = audioURL
        self.text = nil
    }
    // Text entry initializer
    init(date: Date, title: String, text: String) {
        self.id = UUID()
        self.date = date
        self.type = .text
        self.title = title
        self.transcript = nil
        self.audioURL = nil
        self.text = text
    }
} 