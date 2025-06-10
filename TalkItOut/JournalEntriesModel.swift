import Foundation
 
class JournalEntriesModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
} 