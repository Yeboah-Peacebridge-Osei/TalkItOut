import SwiftUI

struct TextJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var textJournalModel: TextJournalEntriesModel
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            AppColors.mistyGray.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("New Text Journal Entry")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.deepCharcoal)
                    .padding(.top, 32)
                // Title field
                TextField("Title", text: $title)
                    .padding()
                    .background(AppColors.paleLavender)
                    .cornerRadius(10)
                    .font(.headline)
                    .foregroundColor(AppColors.deepCharcoal)
                // Main text field
                TextEditor(text: $text)
                    .frame(height: 220)
                    .padding()
                    .background(AppColors.paleLavender)
                    .cornerRadius(16)
                    .font(.body)
                    .foregroundColor(AppColors.deepCharcoal)
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
                            .background(AppColors.mutedTeal)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding()
        }
    }
    
    private func saveEntry() {
        errorMessage = nil
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
        // Save text to Firebase Storage
        let filename = "text_entries/\(UUID().uuidString).txt"
        guard let data = trimmedText.data(using: .utf8) else {
            errorMessage = "Failed to encode text."
            isSaving = false
            return
        }
        StorageManager.shared.uploadText(data: data, path: filename) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success(let url):
                    let entry = JournalEntry(date: Date(), title: trimmedTitle, text: url.absoluteString)
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