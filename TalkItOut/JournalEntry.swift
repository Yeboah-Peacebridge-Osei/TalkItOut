import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let transcript: String
    let audioURL: URL
    
    init(date: Date, transcript: String, audioURL: URL) {
        self.id = UUID()
        self.date = date
        self.transcript = transcript
        self.audioURL = audioURL
    }
} 