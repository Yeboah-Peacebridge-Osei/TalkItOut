import SwiftUI

struct TextJournalDetailView: View {
    let entry: JournalEntry
    @State private var loadedText: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showEditSheet = false
    @EnvironmentObject var textJournalModel: TextJournalEntriesModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.7, green: 0.9, blue: 0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text(entry.title ?? "Untitled")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Button(action: { showEditSheet = true }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Edit Entry")
                }
                Text(entry.date, style: .date)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                if isLoading {
                    ProgressView("Loading...")
                        .foregroundColor(.white)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else if let text = loadedText {
                    ScrollView {
                        Text(text)
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(12)
                    }
                } else {
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .onAppear {
                loadTextIfNeeded()
            }
            .sheet(isPresented: $showEditSheet) {
                EditTextJournalEntryView(entry: entry, originalText: loadedText ?? "") { updatedTitle, updatedText in
                    updateEntry(title: updatedTitle, text: updatedText)
                }
            }
        }
    }
    
    private func loadTextIfNeeded() {
        guard let text = entry.text else { return }
        // If text is a URL, fetch the content
        if let url = URL(string: text), text.starts(with: "http") {
            isLoading = true
            errorMessage = nil
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = "Failed to load entry: \(error.localizedDescription)"
                        return
                    }
                    guard let data = data, let content = String(data: data, encoding: .utf8) else {
                        errorMessage = "Failed to decode entry."
                        return
                    }
                    loadedText = content
                }
            }.resume()
        } else {
            loadedText = text
        }
    }
    
    private func updateEntry(title: String, text: String) {
        // Find and update the entry in the model
        if let idx = textJournalModel.entries.firstIndex(where: { $0.id == entry.id }) {
            // Optionally, update in Firebase as well
            let updatedEntry = JournalEntry(date: entry.date, title: title, text: self.entry.text ?? "")
            textJournalModel.entries[idx] = updatedEntry
            // Optionally, upload the new text to Firebase and update the URL
            // For now, just update the title locally
            self.loadedText = text
        }
    }
}

struct EditTextJournalEntryView: View {
    let entry: JournalEntry
    let originalText: String
    var onSave: (String, String) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var text: String
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    
    init(entry: JournalEntry, originalText: String, onSave: @escaping (String, String) -> Void) {
        self.entry = entry
        self.originalText = originalText
        self.onSave = onSave
        _title = State(initialValue: entry.title ?? "")
        _text = State(initialValue: originalText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                TextField("Title", text: $title)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .font(.headline)
                TextEditor(text: $text)
                    .frame(height: 220)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                    .font(.body)
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                Button(action: save) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Save Changes")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Entry")
            .navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
        }
    }
    
    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a title."
            return
        }
        guard !trimmedText.isEmpty else {
            errorMessage = "Please enter some text."
            return
        }
        isSaving = true
        // Optionally, upload to Firebase here
        // For now, just call onSave
        onSave(trimmedTitle, trimmedText)
        isSaving = false
        presentationMode.wrappedValue.dismiss()
    }
} 