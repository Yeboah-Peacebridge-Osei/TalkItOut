import SwiftUI

class TextJournalEntriesModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
}

struct TextJournalListView: View {
    @EnvironmentObject var textJournalModel: TextJournalEntriesModel
    @State private var showNewEntry = false
    @State private var selectedEntry: JournalEntry? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.7, green: 0.9, blue: 0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack {
                    if textJournalModel.entries.isEmpty {
                        Spacer()
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.7))
                        Text("No text journal entries yet.")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    } else {
                        List {
                            ForEach(textJournalModel.entries) { entry in
                                Button(action: { selectedEntry = entry }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(entry.text ?? "")
                                            .font(.body)
                                            .lineLimit(2)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 6)
                                }
                                .listRowBackground(Color.white.opacity(0.08))
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Text Journal")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showNewEntry = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $showNewEntry) {
                    TextJournalEntryView()
                        .environmentObject(textJournalModel)
                }
                .sheet(item: $selectedEntry) { entry in
                    TextJournalDetailView(entry: entry)
                }
            }
        }
    }
}

struct TextJournalDetailView: View {
    let entry: JournalEntry
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.7, green: 0.9, blue: 0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                Text(entry.date, style: .date)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                ScrollView {
                    Text(entry.text ?? "")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct TextJournalListView_Previews: PreviewProvider {
    static var previews: some View {
        TextJournalListView().environmentObject(TextJournalEntriesModel())
    }
} 