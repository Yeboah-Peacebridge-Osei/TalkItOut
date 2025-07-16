import SwiftUI

struct TextJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var textJournalModel: TextJournalEntriesModel
    @State private var text: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.7, green: 0.9, blue: 0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 24) {
                Text("New Text Journal Entry")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 32)
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
                Button(action: saveEntry) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Save Entry")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(isSaving || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding()
        }
    }
    
    private func saveEntry() {
        errorMessage = nil
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter some text."
            return
        }
        isSaving = true
        // Save text to Firebase Storage
        let filename = "text_entries/\(UUID().uuidString).txt"
        guard let data = trimmed.data(using: .utf8) else {
            errorMessage = "Failed to encode text."
            isSaving = false
            return
        }
        StorageManager.shared.uploadText(data: data, path: filename) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success(let url):
                    let entry = JournalEntry(date: Date(), text: url.absoluteString)
                    textJournalModel.entries.insert(entry, at: 0)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct TextJournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TextJournalEntryView().environmentObject(TextJournalEntriesModel())
    }
} 