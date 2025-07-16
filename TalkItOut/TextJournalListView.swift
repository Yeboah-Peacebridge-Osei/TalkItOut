import SwiftUI

class TextJournalEntriesModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
}

struct TextJournalListView: View {
    @EnvironmentObject var textJournalModel: TextJournalEntriesModel
    @State private var showNewEntry = false
    @State private var selectedEntry: JournalEntry? = nil
    @State private var searchText: String = ""
    @State private var selectedType: JournalEntry.EntryType? = nil // nil = all
    
    var filteredEntries: [JournalEntry] {
        textJournalModel.entries.filter { entry in
            let matchesType = selectedType == nil || entry.type == selectedType
            let matchesSearch = searchText.isEmpty || (entry.text?.localizedCaseInsensitiveContains(searchText) ?? false)
            return matchesType && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepCream.ignoresSafeArea()
                VStack {
                    // Search bar
                    HStack {
                        TextField("Search entries...", text: $searchText)
                            .padding(8)
                            .background(AppColors.paleLavender)
                            .cornerRadius(8)
                            .foregroundColor(AppColors.deepCharcoal)
                        // Filter by type
                        Menu {
                            Button("All", action: { selectedType = nil })
                            Button("Text", action: { selectedType = .text })
                            Button("Audio", action: { selectedType = .audio })
                        } label: {
                            Label(selectedType == nil ? "All" : (selectedType == .text ? "Text" : "Audio"), systemImage: "line.3.horizontal.decrease.circle")
                                .padding(8)
                                .background(AppColors.paleLavender)
                                .cornerRadius(8)
                                .foregroundColor(AppColors.deepCharcoal)
                        }
                    }
                    .padding([.horizontal, .top])
                    if filteredEntries.isEmpty {
                        Spacer()
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.softNavy.opacity(0.7))
                        Text("No text journal entries yet.")
                            .font(.headline)
                            .foregroundColor(AppColors.deepCharcoal)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredEntries) { entry in
                                Button(action: { selectedEntry = entry }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(AppColors.deepCharcoal)
                                        // Show title if available, else fallback to first line of text
                                        Text(entry.title ?? (entry.text ?? "").components(separatedBy: "\n").first ?? "Untitled")
                                            .font(.headline)
                                            .foregroundColor(AppColors.deepCharcoal)
                                    }
                                    .padding(.vertical, 6)
                                }
                                .listRowBackground(AppColors.paleLavender)
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
                                .foregroundColor(.white)
                                .padding(8)
                                .background(AppColors.mutedTeal)
                                .cornerRadius(8)
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

struct TextJournalListView_Previews: PreviewProvider {
    static var previews: some View {
        TextJournalListView().environmentObject(TextJournalEntriesModel())
    }
} 