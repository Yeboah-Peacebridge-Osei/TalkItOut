import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let transcript: String
    let audioURL: String // Now stores URL as String (can be local or remote)
    
    init(date: Date, transcript: String, audioURL: String) {
        self.id = UUID()
        self.date = date
        self.transcript = transcript
        self.audioURL = audioURL
    }
} 