import SwiftUI
import AVKit

struct ProfileView: View {
    @EnvironmentObject var journalEntriesModel: JournalEntriesModel
    @State private var selectedEntry: JournalEntry? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Placeholder for profile info and entries grid
                Text("Profile Page")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Text("Your journal entries will appear here.")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                // Simple grid of entries as before
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(journalEntriesModel.entries) { entry in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                            VStack(spacing: 6) {
                                Image(systemName: "video.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 36)
                                    .foregroundColor(.blue)
                                Text(entry.date, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                        }
                        .frame(height: 80)
                        .onTapGesture {
                            selectedEntry = entry
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(item: $selectedEntry) { entry in
            JournalEntryPlaybackView(entry: entry)
                .onAppear {
                    print("[DEBUG] Presenting JournalEntryPlaybackView for entry: \(entry.id)")
                }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(JournalEntriesModel())
    }
} 